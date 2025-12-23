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
    func requestToDeleteTimer(id: UUID) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let latestTimer = timerService.getTimer(byId: id) else {
                print("⚠️ [RunningVM] Timer not found: \(id)")
                return
            }
            
            switch (latestTimer.presetId, latestTimer.endAction) {
            case (.none, .preserve):
                activeAlert = .confirmStopAndSaveTimer(
                    itemName: latestTimer.label,
                    onConfirm: { [weak self] in
                        guard let self = self else { return }
                        guard let finalTimer = self.timerService.getTimer(byId: id) else { return }
                        self.presetRepository.addPreset(from: finalTimer)
                        self.timerService.removeTimer(id: id)
                    }
                )
                
            case (.none, .discard):
                activeAlert = .confirmStopTimer(
                    itemName: latestTimer.label,
                    onConfirm: { [weak self] in
                        self?.timerService.removeTimer(id: id)
                    }
                )
                
            case (.some(let presetId), .preserve):
                activeAlert = .confirmStopTimer(
                    itemName: latestTimer.label,
                    onConfirm: { [weak self] in
                        guard let self = self else { return }
                        guard let finalTimer = self.timerService.getTimer(byId: id) else { return }
                        self.presetRepository.updatePresetLabel(presetId: presetId, newLabel: finalTimer.label)
                        self.timerService.removeTimer(id: id)
                    }
                )
                
            case (.some(let presetId), .discard):
                activeAlert = .confirmStopAndHideTimer(
                    itemName: latestTimer.label,
                    onConfirm: { [weak self] in
                        guard let self = self else { return }
                        self.presetRepository.hidePreset(withId: presetId)
                        self.timerService.removeTimer(id: id)
                    }
                )
            }
        }
    }
}
