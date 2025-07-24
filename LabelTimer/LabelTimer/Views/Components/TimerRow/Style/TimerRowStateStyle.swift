import SwiftUI

//
//  TimerRowStateStyle.swift
//  LabelTimer
//
//  Created by 이소연 on 7/24/25.
//
/// 타이머 상태에 따라 배경색, 텍스트 색상을 설정하는 ViewModifier
///
/// - 사용 목적: 실행 중, 일시정지, 정지 등의 타이머 상태에 따라 `TimerRowView` 에 일관된 스타일을 적용함

struct TimerRowStateStyle: ViewModifier {
    let state: TimerInteractionState

    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .foregroundColor(textColor)
//            .overlay(
//                RoundedRectangle(cornerRadius: 8)
//                    .stroke(borderColor, lineWidth: borderWidth)
//            )
    }

    private var backgroundColor: Color {
        switch state {
        case .waiting, .running, .paused:
            return .white
        case .stopped:
            return Color(.systemGray6)
        }
    }

    private var textColor: Color {
        switch state {
        case .waiting, .running, .paused:
            return .black
        case .stopped:
            return .gray
        }
    }

    private var borderColor: Color {
        switch state {
        case .waiting, .running, .paused:
            return .gray.opacity(0.3)
        case .stopped:
            return .clear
        }
    }

    private var borderWidth: CGFloat {
        switch state {
        case .waiting, .running, .paused:
            return 1
        case .stopped:
            return 0
        }
    }
}

extension View {
    /// 타이머 상태에 따라 `TimerRowStateStyle` Modifier를 적용함
    func timerRowStateStyle(for state: TimerInteractionState) -> some View {
        self.modifier(TimerRowStateStyle(state: state))
    }
}
