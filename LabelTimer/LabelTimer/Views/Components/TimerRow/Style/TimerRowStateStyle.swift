//
//  TimerRowStateStyle.swift
//  LabelTimer
//
//  Created by 이소연 on 7/24/25.
//
/// 타이머 상태에 따라 배경색, 텍스트 색상을 설정하는 ViewModifier
///
/// - 사용 목적: 실행 중, 일시정지, 정지 등의 상태에 따라 TimerRowView에 일관된 스타일을 적용

import SwiftUI

struct TimerRowStateStyle: ViewModifier {
    let state: TimerInteractionState
    @Environment(\.colorScheme) private var colorScheme

    private var textColor: Color {
        switch state {
        case .running:
            return colorScheme == .dark ? .black : .white
        case .preset:
            return colorScheme == .dark ? .white : .black
        case .paused, .stopped, .completed:
            return .gray
        }
    }

    private var backgroundColor: Color {
        switch state {
        case .running:
            return colorScheme == .dark ? .white : .black
        case .preset:
            return colorScheme == .dark ? .black : .white
        case .paused, .stopped, .completed:
            return Color(.systemGray6)
        }
    }

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
            )
            .foregroundColor(textColor)
    }
}

extension View {
    func timerRowStateStyle(for state: TimerInteractionState) -> some View {
        self.modifier(TimerRowStateStyle(state: state))
    }
}
