//
//  TimerButtonStyle.swift
//  LabelTimer
//
//  Created by 이소연 on 8/11/25.
//
/// 타이머 버튼 공통 스타일
///
/// - 사용 목적: 좌/우 버튼 모두 동일한 크기/패딩/코너/폰트/강조 정도를 일관되게 적용

import SwiftUI

public enum TimerButtonEmphasis {
    case primary   // 채움
    case secondary // 외곽선
}

public struct TimerButtonStyle: ButtonStyle {
    let color: Color

    public init(color: Color = .accentColor) {
        self.color = color
    }

    public func makeBody(configuration: Configuration) -> some View {
        let isPrimary = (AppTheme.Buttons.emphasis == .primary)
        let diameter = AppTheme.Buttons.diameter

        @ViewBuilder
        var background: some View {
            if isPrimary {
                Circle().fill(color)
            } else {
                Circle().strokeBorder(color, lineWidth: 1)
            }
        }

        return configuration.label
            .font(.body.weight(.semibold))
            .foregroundColor(isPrimary ? .white : color)
            .frame(width: diameter, height: diameter)
            .background(background)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

public extension View {
    /// `.timerButton(color:)`
    func timerButton(color: Color = .accentColor) -> some View {
        self.buttonStyle(TimerButtonStyle(color: color))
    }
}
