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

public struct TimerButtonStyle: ButtonStyle {
    let color: Color

    public init(color: Color = .accentColor) {
        self.color = color
    }

    public func makeBody(configuration: Configuration) -> some View {
        let diameter = AppTheme.Buttons.diameter
        let lineWidth = AppTheme.Buttons.lineWidth
        let font = AppTheme.Buttons.iconFont
        let fontWeight = AppTheme.Buttons.iconWeight
        
        return configuration.label
            .font(font.weight(fontWeight))
            .foregroundColor(color)
            .frame(width: diameter, height: diameter)
            .background(Circle().fill(Color.clear))
            .overlay(
                Circle().strokeBorder(color, lineWidth: lineWidth)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

public extension View {
    /// `.timerButton(color:)`
    func timerButton(color: Color = .accentColor) -> some View {
        self.buttonStyle(TimerButtonStyle(color: color))
    }
}
