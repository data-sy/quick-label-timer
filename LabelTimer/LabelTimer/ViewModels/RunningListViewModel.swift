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

final class RunningListViewModel: ObservableObject {
    @Published var timers: [TimerData] = []
    let deleteCountdownSeconds = LabelTimerApp.deleteCountdownSeconds
    private let timerManager: TimerManager
    private let presetManager: PresetManager
    
    private var cancellables = Set<AnyCancellable>()
    
    init(timerManager: TimerManager, presetManager: PresetManager) {
        self.timerManager = timerManager
        self.presetManager = presetManager
        
        // 타이머 매니저의 상태를 실시간으로 구독하여 동기화
        timerManager.$timers
            .receive(on: RunLoop.main)
            .assign(to: &$timers)
    }
    
    /// 버튼 액션 처리
    func handleAction(_ action: TimerButtonType, for timer: TimerData) {
        switch action {
        case .pause:
            timerManager.pauseTimer(id: timer.id)
        case .play:
            timerManager.resumeTimer(id: timer.id)
        case .stop:
            timerManager.stopTimer(id: timer.id)
        case .restart:
            timerManager.restartTimer(id: timer.id)
        case .moveToPreset:
            handleMoveToPreset(for: timer)
        }
    }
    
    /// 실행 중인 타이머를 프리셋으로 이동/복구
    func handleMoveToPreset(for timer: TimerData) {
        if let presetId = timer.presetId,
           let preset = presetManager.userPresets.first(where: { $0.id == presetId }) {
            // 기존 프리셋에서 실행된 타이머였다면 프리셋을 다시 보이게 처리 후 타이머 삭제
            presetManager.showPreset(withId: preset.id)
            timerManager.removeTimer(id: timer.id)
        } else {
            // 사용자 생성 타이머라면 새 프리셋으로 변환
            timerManager.convertTimerToPreset(timerId: timer.id)
        }
    }

    /// 타이머의 즐겨찾기 상태를 토글
    func toggleFavorite(for id: UUID) {
        timerManager.toggleFavorite(for: id)
    }
    
    /// 특정 타이머를 삭제
    func deleteTimer(_ timer: TimerData) {
        timerManager.removeTimer(id: timer.id)
    }
}
