//
//  RunningListViewModel.swift
//  LabelTimer
//
//  Created by 이소연 on 8/7/25.
//
/// 실행 중인 타이머 리스트의 상태와 액션을 관리하는 뷰모델
///
/// - 사용 목적: 타이머 리스트의 상태, 타이머 관련 버튼 액션, 프리셋 변환 등 비즈니스 로직을 View와 분리하여 관리

import Foundation
import Combine

@MainActor
final class RunningListViewModel: ObservableObject {
    @Published private(set) var sortedTimers: [TimerData] = []

    let deleteCountdownSeconds = LabelTimerApp.deleteCountdownSeconds

    private let timerService: TimerServiceProtocol
    private let timerRepository: TimerRepositoryProtocol
    private let presetRepository: PresetRepositoryProtocol
    
    
    private var cancellables = Set<AnyCancellable>()
    
    init(timerService: TimerServiceProtocol, timerRepository: TimerRepositoryProtocol, presetRepository: PresetRepositoryProtocol) {
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
    
    /// Left 버튼 액션 처리
    func handleLeft(for timer: TimerData) {
        let set = makeButtonSet(for: timer.interactionState, isFavorite: timer.isFavorite)
        switch set.left {
        case .none:
            break
        case .stop:
            timerService.stopTimer(id: timer.id)
        case .moveToFavorite:
            handleMoveToPreset(for: timer)
        case .delete:
            deleteTimer(timer)
        case .edit:
            // Running에선 등장하지 않아야 함
            assertionFailure("Left .edit should not appear for running timers")
            break
        }
    }

    /// Right 버튼 액션 처리
    func handleRight(for timer: TimerData) {
        let set = makeButtonSet(for: timer.interactionState, isFavorite: timer.isFavorite)
        switch set.right {
        case .play:
            timerService.resumeTimer(id: timer.id)
        case .pause:
            timerService.pauseTimer(id: timer.id)
        case .restart:
            timerService.restartTimer(id: timer.id)
        }
    }    
    
    /// 실행 중인 타이머를 프리셋으로 이동/복구
    func handleMoveToPreset(for timer: TimerData) {
        if let presetId = timer.presetId,
           let preset = presetRepository.getPreset(byId: presetId) {
            // 기존 프리셋에서 실행된 타이머였다면 프리셋을 다시 보이게 처리 후 타이머 삭제
            presetRepository.showPreset(withId: preset.id)
            timerService.removeTimer(id: timer.id)
        } else {
            // 사용자 생성 타이머라면 새 프리셋으로 변환
            timerService.convertTimerToPreset(timerId: timer.id)
        }
    }

    /// 타이머의 즐겨찾기 상태를 토글
    func toggleFavorite(for id: UUID) {
        timerService.toggleFavorite(for: id)
    }
    
    /// 타이머 삭제 (편집 모드)
    func deleteTimer(at offsets: IndexSet) {
        let timersToDelete = offsets.map { sortedTimers[$0] }
        for timer in timersToDelete {
            timerService.removeTimer(id: timer.id)
        }
    }
    
    /// 특정 타이머를 삭제
    func deleteTimer(_ timer: TimerData) {
        timerService.removeTimer(id: timer.id)
    }
}
