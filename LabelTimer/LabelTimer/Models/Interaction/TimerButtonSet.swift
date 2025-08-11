//
//  TimerButtonSet.swift
//  LabelTimer
//
//  Created by 이소연 on 8/10/25.
//
/// 좌/우 버튼 조합 모델
/// - 사용 목적: View에서 좌/우 버튼을 한 번에 주입할 수 있도록 타입 세트를 캡슐화

import Foundation

public struct TimerButtonSet: Equatable {
    public let left: TimerLeftButtonType
    public let right: TimerRightButtonType

    public init(left: TimerLeftButtonType, right: TimerRightButtonType) {
        self.left = left
        self.right = right
    }
}
