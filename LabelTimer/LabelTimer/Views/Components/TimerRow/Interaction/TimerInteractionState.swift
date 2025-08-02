//
//  TimerInteractionState.swift
//  LabelTimer
//
//  Created by 이소연 on 7/22/25.
//
/// 타이머 UI 상호작용 상태 정의
///
/// - 사용 목적: 사용자의 상호작용 흐름에 따라 버튼 조합과 다음 상태를 결정하기 위한 기준 상태값을 정의함
///   내부적으로 타이머 모델의 status를 변환해 UI용 상태로 활용

enum TimerInteractionState {
    case preset
    case running
    case paused
    case stopped
    case completed
}
