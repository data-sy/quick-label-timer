//
//  RunningTimersViewModel.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/7/25.
//
/// RunningTimerListView의 상태와 로직을 관리하는 ViewModel
///
/// - 사용 목적: 실행 중인 타이머 목록 상태, 타이머 관련 액션(정지, 재시작 등)의 비즈니스 로직을 View와 분리

import Foundation
import Combine

@MainActor
final class RunningTimersViewModel: ObservableObject {
    private let timerService: any TimerServiceProtocol
    private let timerRepository: TimerRepositoryProtocol
    private let presetRepository: PresetRepositoryProtocol

    let deleteCountdownSeconds = AppConfig.deleteCountdownSeconds

    @Published private(set) var sortedTimers: [TimerData] = []
    @Published var activeAlert: AppAlert?

    private var cancellables = Set<AnyCancellable>()
    
    init(timerService: any TimerServiceProtocol, timerRepository: TimerRepositoryProtocol, presetRepository: PresetRepositoryProtocol) {
        self.timerService = timerService
        self.timerRepository = timerRepository
        self.presetRepository = presetRepository
        
        timerRepository.timersPublisher
            .map { timers in
                timers.sorted { $0.createdAt > $1.createdAt }
            }
            .receive(on: RunLoop.main)
            .assign(to: \.sortedTimers, on: self)
            .store(in: &cancellables)
    }
    
    /// 실행 중인 타이머를 프리셋으로 이동/복구
    func handleMoveToPreset(for timer: TimerData) {
        // 기존 프리셋에서 실행된 타이머였다면 타이머 삭제만 하면 됨 (id가 쓰이지 않게 된 프리셋은 자동으로 실행중 화면 사라짐)
        if let presetId = timer.presetId {
            // 프리셋 기반: 라벨 업데이트 + 삭제
            presetRepository.updatePresetLabel(presetId: presetId, newLabel: timer.label)
            timerService.removeTimer(id: timer.id)
        } else {
            // 사용자 생성 타이머라면 새 프리셋으로 변환 후 삭제
            let success = presetRepository.addPreset(from: timer)
            
            if success {
                timerService.removeTimer(id: timer.id)
            } else {
                activeAlert = .presetSaveLimit
            }
        }
    }
    
    /// 타이머의 즐겨찾기 상태를 토글
    func toggleFavorite(for id: UUID) {
        let success = timerService.toggleFavorite(for: id)

        if !success {
            activeAlert = .presetSaveLimit
        }
    }

    /// 실행 중인 타이머의 라벨 업데이트
    func updateLabel(for timerId: UUID, newLabel: String) {
        Task { @MainActor in
            timerService.updateLabel(timerId: timerId, newLabel: newLabel)
        }
    }

    // MARK: - Button Actions

    /// Play/Pause 버튼 액션 - 타이머 상태에 따라 동작 결정
    func playPauseTimer(timer: TimerData) {
        switch timer.status {
        case .running:
            timerService.pauseTimer(id: timer.id)
            print("Paused timer: \(timer.id)")
        case .paused:
            timerService.resumeTimer(id: timer.id)
            print("Resumed timer: \(timer.id)")
        case .completed:
            timerService.restartTimer(id: timer.id)
            print("Restarted completed timer: \(timer.id)")
        case .stopped:
            // Stopped 상태는 현재 UI에 나타나지 않음
            break
        }
    }

    /// Reset 버튼 액션 - 타이머를 처음부터 다시 시작
    func resetTimer(id: UUID) {
        timerService.restartTimer(id: id)
        print("Reset timer: \(id)")
    }
    
    // MARK: - Delete (X 버튼)
    
    /// X 버튼 액션 - 타이머 삭제 요청 (얼럿 표시)
    func requestToDeleteTimer(_ timer: TimerData) {
        // 최신 타이머 데이터 가져오기 (라벨이 변경되었을 수 있음)
        guard let latestTimer = timerService.getTimer(byId: timer.id) else {
            print("⚠️ [RunningVM] Timer not found: \(timer.id)")
            return
        }
        
        switch (latestTimer.presetId, latestTimer.endAction) {
        case (.none, .preserve):
            activeAlert = .confirmStopAndSaveTimer(
                itemName: latestTimer.label,
                onConfirm: { [weak self] in
                    guard let self = self else { return }
                    guard let finalTimer = self.timerService.getTimer(byId: timer.id) else { return }
                    self.presetRepository.addPreset(from: finalTimer)
                    self.timerService.removeTimer(id: timer.id)
                }
            )
            
        case (.none, .discard):
            activeAlert = .confirmStopTimer(
                itemName: latestTimer.label,
                onConfirm: { [weak self] in
                    self?.timerService.removeTimer(id: timer.id)
                }
            )
            
        case (.some(let presetId), .preserve):
            activeAlert = .confirmStopTimer(
                itemName: latestTimer.label,
                onConfirm: { [weak self] in
                    guard let self = self else { return }
                    guard let finalTimer = self.timerService.getTimer(byId: timer.id) else { return }
                    self.presetRepository.updatePresetLabel(presetId: presetId, newLabel: finalTimer.label)
                    self.timerService.removeTimer(id: timer.id)
                }
            )
            
        case (.some(let presetId), .discard):
            activeAlert = .confirmStopAndHideTimer(
                itemName: latestTimer.label,
                onConfirm: { [weak self] in
                    guard let self = self else { return }
                    self.presetRepository.hidePreset(withId: presetId)
                    self.timerService.removeTimer(id: timer.id)
                }
            )
        }
    }
}
