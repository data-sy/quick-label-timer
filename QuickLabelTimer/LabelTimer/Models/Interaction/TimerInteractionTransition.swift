//
//  TimerInteractionTransition.swift
//  LabelTimer
//
//  Created by 이소연 on 8/10/25.
//
/// UI 상호작용 상태 전이 로직
///
/// - 사용 목적: 현재 UI 상태와 눌린 버튼 타입에 따라 다음 UI 상태를 결정 (실제 타이머 동작은 ViewModel → TimerService가 수행)

import Foundation

// MARK: - Right button (play/pause/restart) → 상태 전이 담당
func nextState(
    from current: TimerInteractionState,
    right button: TimerRightButtonType
) -> TimerInteractionState {
    switch (current, button) {
    case (.preset, .play):
        return .running
    case (.running, .pause):
        return .paused
    case (.paused, .play):
        return .running
    case (.stopped, .restart), (.completed, .restart):
        return .running
    default:
        return current
    }
}

// MARK: - Left button (stop/moveToFavorite/delete) → 주로 동작, 최소 전이만 반영
func nextState(
    from current: TimerInteractionState,
    left button: TimerLeftButtonType
) -> TimerInteractionState {
    switch (current, button) {
    case (.running, .stop):
        return .stopped

    // 아래 둘은 데이터 변경/리스트 이동 성격이라 상태 전이는 유지
    // - .moveToFavorite: 즐겨찾기 토글/이동(리스트 재배치)
    // - .delete: 항목 제거 (보통 행 자체가 사라짐)
    case (_, .moveToFavorite), (_, .delete), (_, .none):
        return current
        
    default:
        return current
    }
}
