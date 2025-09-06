//
//  TimerButtonUI.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/11/25.
//
/// 버튼 타입 → UI 속성 매핑 모음
/// 
/// - 사용 목적: 좌/우 버튼이 동일한 룩앤필 규칙을 공유하도록 중앙에서 관리

import SwiftUI

struct TimerButtonUI {
    let systemImage: String
    let tint: Color
    let role: ButtonRole?
    let accessibilityLabel: LocalizedStringKey
}

// MARK: - Left
func ui(for type: TimerLeftButtonType) -> TimerButtonUI? {
    switch type {
    case .none:
        return nil
    case .stop:
        return .init(
            systemImage: "stop.fill",
            tint: .red,
            role: .destructive,
            accessibilityLabel: A11yText.TimerRow.stopLabel
        )
    case .moveToFavorite:
        return .init(
            systemImage: "chevron.right",
            tint: .yellow,
            role: nil,
            accessibilityLabel: A11yText.TimerRow.moveToFavoriteLabel
        )
    case .delete:
        return .init(
            systemImage: "xmark",
            tint: .gray,
            role: .destructive,
            accessibilityLabel: A11yText.TimerRow.deleteLabel
        )
    case .edit:
        return .init(
            systemImage: "pencil",
            tint: .teal,
            role: nil,
            accessibilityLabel: A11yText.TimerRow.editLabel
        )
    }
}

// MARK: - Right
func ui(for type: TimerRightButtonType) -> TimerButtonUI {
    switch type {
    case .play:
        return .init(
            systemImage: "play.fill",
            tint: .blue,
            role: nil,
            accessibilityLabel: A11yText.TimerRow.playLabel
        )
    case .pause:
        return .init(
            systemImage: "pause.fill",
            tint: .orange,
            role: nil,
            accessibilityLabel: A11yText.TimerRow.pauseLabel
        )
    case .restart:
        return .init(
            systemImage: "gobackward",
            tint: .blue,
            role: nil,
            accessibilityLabel: A11yText.TimerRow.restartLabel
        )
    }
}
