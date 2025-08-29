//
//  RunningListViewModel.swift
//  LabelTimer
//
//  Created by 이소연 on 8/7/25.
//
/// RunningTimerListView의 상태와 로직을 관리하는 ViewModel
///
/// - 사용 목적: 실행 중인 타이머 목록 상태, 타이머 관련 액션(정지, 재시작 등)의 비즈니스 로직을 View와 분리

import Foundation
import Combine

@MainActor
final class RunningListViewModel: ObservableObject {
    private let timerService: TimerServiceProtocol
    private let timerRepository: TimerRepositoryProtocol
    private let presetRepository: PresetRepositoryProtocol

    let deleteCountdownSeconds = LabelTimerApp.deleteCountdownSeconds

    @Published private(set) var sortedTimers: [TimerData] = []
    @Published var activeAlert: AppAlert?

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
        let set = makeButtonSet(for: timer.interactionState, endAction: timer.endAction)
        switch set.left {
        case .none:
            break
        case .stop:
            timerService.stopTimer(id: timer.id)
        case .moveToFavorite:
            handleMoveToPreset(for: timer)
        case .delete:
            if let presetId = timer.presetId {
                presetRepository.hidePreset(withId: presetId)
            }
            timerService.removeTimer(id: timer.id)
        case .edit:
            // Running에선 등장하지 않아야 함
            assertionFailure("Left .edit should not appear for running timers")
            break
        }
    }

    /// Right 버튼 액션 처리
    func handleRight(for timer: TimerData) {
        let set = makeButtonSet(for: timer.interactionState, endAction: timer.endAction)
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
        // 기존 프리셋에서 실행된 타이머였다면 타이머 삭제만 하면 됨 (id가 쓰이지 않게 된 프리셋은 자동으로 실행중 화면 사라짐)
        guard timer.presetId == nil else {
            timerService.removeTimer(id: timer.id)
            return
        }
        // 사용자 생성 타이머라면 새 프리셋으로 변환 후 삭제
        let success = presetRepository.addPreset(from: timer)
        
        if success {
            timerService.removeTimer(id: timer.id)
        } else {
            activeAlert = .presetSaveLimit
        }
    }
    
    /// 타이머의 즐겨찾기 상태를 토글
    func toggleFavorite(for id: UUID) {
        let success = timerService.toggleFavorite(for: id)
        
        if !success {
            activeAlert = .presetSaveLimit
        }
    }
    
}
