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
    let accessibilityLabel: String
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
            accessibilityLabel: "정지"
        )
    case .moveToFavorite:
        return .init(
            systemImage: "chevron.right",
            tint: .yellow,
            role: nil,
            accessibilityLabel: "즐겨찾기로 이동"
        )
    case .delete:
        return .init(
            systemImage: "xmark",
            tint: .gray,
            role: .destructive,
            accessibilityLabel: "삭제"
        )
    case .edit:
        return .init(
            systemImage: "pencil",
            tint: .teal,
            role: nil,
            accessibilityLabel: "편집"
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
            accessibilityLabel: "재생"
        )
    case .pause:
        return .init(
            systemImage: "pause.fill",
            tint: .orange,
            role: nil,
            accessibilityLabel: "일시정지"
        )
    case .restart:
        return .init(
            systemImage: "gobackward",
            tint: .blue,
            role: nil,
            accessibilityLabel: "재시작"
        )
    }
}
