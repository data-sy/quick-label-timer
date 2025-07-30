//
//  TimerData+InteractionState.swift
//  LabelTimer
//
//  Created by 이소연 on 7/22/25.
//
/// TimerData 모델 확장: 상태값을 UI 상태로 변환하는 computed property 제공
///
/// - 사용 목적: 모델 내부 상태(.running, .paused 등)를 UI 상호작용용 상태로 변환하여 뷰가 쉽게 참조할 수 있도록 함

import Foundation

extension TimerData {
    var interactionState: TimerInteractionState {
        switch status {
        case .running:
            return .running
        case .paused:
            return .paused
        case .completed, .stopped:
            return .stopped
        }
    }
}
