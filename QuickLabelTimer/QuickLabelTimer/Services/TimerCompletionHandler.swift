//
//  TimerCompletionHandler.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/11/25.
//
/// 타이머가 '완료'된 후의 모든 비동기 로직을 전담하는 클래스
///
/// 사용 목적: TimerService가 타이머의 '실행'에만 집중하도록, '완료 후'의 복잡한 로직을 위임받아 책임을 분리함

import Foundation

// MARK: - Timer Completion Handler
final class TimerCompletionHandler {
    private var countdownTasks: [UUID: Task<Void, Never>] = [:]
    private let timerService: any TimerServiceProtocol
    private let presetRepository: PresetRepositoryProtocol
    /// 1초마다 카운트다운이 진행될 때 호출되는 클로저
    var onTick: ((_ timerId: UUID) -> Void)?
    // 카운트다운이 완전히 끝나거나 취소되었을 때 호출되는 클로저 (Service가 정리 작업 수행)
    var onComplete: ((_ timerId: UUID) -> Void)?

    init(timerService: any TimerServiceProtocol, presetRepository: PresetRepositoryProtocol) {
        self.timerService = timerService
        self.presetRepository = presetRepository
    }

    /// 이 객체가 메모리에서 해제될 때 호출됨
    /// 앱 종료나 화면 전환 시, 진행 중이던 모든 비동기 Task를 확실히 취소하여 메모리 누수 방지
    deinit {
        cancelAllPendingActions()
    }

    // MARK: - Public Methods
    
    /// 타이머 완료 후 n초 카운트다운 시작
    func scheduleCompletion(for timer: TimerData, after seconds: Int) {
        let timerId = timer.id
        cancelPendingAction(for: timerId)

        countdownTasks[timerId] = Task { [weak self] in
            guard let self = self else { return }

            do {
                for _ in 0..<seconds {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    try Task.checkCancellation()
                    await MainActor.run { self.onTick?(timerId) }
                }
                await self.handle(timerId: timerId)

            } catch {
                await MainActor.run { self.onComplete?(timerId) }
                self.countdownTasks[timerId] = nil
            }
        }
    }

    /// 타이머 완료 처리 즉시 실행
    func handleCompletionImmediately(timerId: UUID) {
        cancelPendingAction(for: timerId)
        Task {
            await handle(timerId: timerId)
        }
    }

    /// 특정 타이머 카운트다운 Task 취소
    func cancelPendingAction(for timerId: UUID) {
        countdownTasks[timerId]?.cancel()
        countdownTasks[timerId] = nil
    }

    /// 모든 타이머 카운트다운 Task 취소
    func cancelAllPendingActions() {
        countdownTasks.values.forEach { $0.cancel() }
        countdownTasks.removeAll()
    }

    // MARK: - Private Methods
    
    /// 모든 최종 로직을 실행하는 핵심 함수
    /// UI와 관련된 작업을 할 수 있으므로 @MainActor 명시
    @MainActor
    private func handle(timerId: UUID) {
        // '최신' TimerData 가져오기 (완료 후의 즐겨찾기 토글 적용)
        guard let latestTimer = timerService.getTimer(byId: timerId) else {
            onComplete?(timerId)
            countdownTasks[timerId] = nil
            return
        }
        // 1-1. 즉석 타이머 & 보존 -> 새 프리셋으로 저장 후, 기존 타이머 삭제
        // 1-2. 즉석 타이머 & 폐기 -> 타이머만 삭제
        // 2-1. 프리셋 기반 타이머 & 보존 -> 타이머만 삭제 (프리셋은 자동으로 다시 활성화됨)
        // 2-2. 프리셋 기반 타이머 & 폐기 -> 프리셋을 숨기고(hide) 타이머 삭제
        switch (latestTimer.presetId, latestTimer.endAction) {
            case (.none, .preserve):
              presetRepository.addPreset(from: latestTimer)
              timerService.removeTimer(id: timerId)
            
            case (.none, .discard):
              timerService.removeTimer(id: timerId)

            case (.some(let presetId), .preserve):
              // 변경된 라벨이 있으면 프리셋에 반영
              presetRepository.updatePresetLabel(presetId: presetId, newLabel: latestTimer.label)
              timerService.removeTimer(id: timerId)

            case (.some(let presetId), .discard):
              presetRepository.hidePreset(withId: presetId)
              timerService.removeTimer(id: timerId)
        }
        onComplete?(timerId)
        countdownTasks[timerId] = nil
    }

}
