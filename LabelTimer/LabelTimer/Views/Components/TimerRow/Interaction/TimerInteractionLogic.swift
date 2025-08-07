//
//  TimerInteractionLogic.swift
//  LabelTimer
//
//  Created by 이소연 on 7/22/25.
//
/// 타이머 상호작용 상태에 따른 버튼 구성 및 상태 전이 로직을 정의함
///
/// - 사용 목적: UI 상태에 따라 표시할 버튼 쌍을 반환하거나, 버튼 액션 후 다음 상태를 반환하는 로직 제공
///   UI 뷰는 이 로직을 호출만 하고, 내부 전이를 직접 처리하지 않도록 분리함

import Foundation

/// 상태에 따라 보여줄 버튼 세트
struct TimerButtonSet {
    let left: TimerButtonType?
    let right: TimerButtonType
}

/// 현재 상태에 따라 버튼 세트를 반환
func buttonSet(for state: TimerInteractionState) -> TimerButtonSet {
    switch state {
    case .preset:
        return TimerButtonSet(left: nil, right: .play)
    case .running:
        return TimerButtonSet(left: .stop, right: .pause)
    case .paused:
        return TimerButtonSet(left: .moveToPreset, right: .play)
    case .stopped, .completed:
        return TimerButtonSet(left: .moveToPreset, right: .restart)
    }
}

/// 현재 상태와 누른 버튼에 따라 다음 상태를 반환
func nextState(from current: TimerInteractionState, button: TimerButtonType) -> TimerInteractionState {
    switch (current, button) {
    case (.preset, .play):
        return .running
    case (.running, .pause):
        return .paused
    case (.running, .stop):
        return .stopped
    case (.paused, .play):
        return .running
    case (.stopped, .restart), (.completed, .restart):
        return .running
    default:
        return current
    }
}
