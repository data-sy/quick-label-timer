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
    case primary   // 주요 전이(재생/재시작 등)
    case secondary // 보조 전이(일시정지 등)
}

public enum TimerButtonSize {
    case regular
    case compact   // 아이콘만/작은 버튼 등에 활용
}
//////// 테스트 ///////////////////////////////////
public enum TimerButtonShape { case pill, circle }

public struct TimerButtonStyle: ButtonStyle {
    let emphasis: TimerButtonEmphasis
    let size: TimerButtonSize
    let color: Color
    let shape: TimerButtonShape

    public init(emphasis: TimerButtonEmphasis = .primary,
                size: TimerButtonSize = .regular,
                color: Color = .accentColor,
                shape: TimerButtonShape = .pill
    ) {
        self.emphasis = emphasis
        self.size = size
        self.color = color
        self.shape = shape
    }

    public func makeBody(configuration: Configuration) -> some View {
        let isPrimary = (emphasis == .primary)

        // 크기/패딩
        let hPad: CGFloat = (size == .regular ? 12 : 10)
        let vPad: CGFloat = (size == .regular ? 8 : 8)

        // 모양별 배경
        @ViewBuilder
        var background: some View {
            switch shape {
            case .pill:
                Group {
                    if isPrimary {
                        RoundedRectangle(cornerRadius: 12).fill(color)
                    } else {
                        RoundedRectangle(cornerRadius: 12).strokeBorder(color, lineWidth: 1)
                    }
                }
            case .circle:
                Group {
                    if isPrimary {
                        Circle().fill(color)
                    } else {
                        Circle().strokeBorder(color, lineWidth: 1)
                    }
                }
            }
        }
        return configuration.label
            .font(size == .regular ? .body.weight(.semibold) : .footnote.weight(.semibold))
            .foregroundColor(isPrimary ? .white : color)
            .padding(.horizontal, shape == .pill ? hPad : 0)
            .padding(.vertical, shape == .pill ? vPad : 0)
            .frame(width: shape == .circle ? (size == .regular ? 50 : 40) : nil,
                   height: shape == .circle ? (size == .regular ? 50 : 40) : nil)
            .background(background)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

public extension View {
    /// 편의 적용자: `.timerButton(emphasis:size:color:)`
    func timerButton(
        emphasis: TimerButtonEmphasis = .primary,
        size: TimerButtonSize = .regular,
        color: Color = .accentColor,
        shape: TimerButtonShape = .pill
    ) -> some View {
        self.buttonStyle(TimerButtonStyle(emphasis: emphasis, size: size, color: color, shape: shape))
    }
}
