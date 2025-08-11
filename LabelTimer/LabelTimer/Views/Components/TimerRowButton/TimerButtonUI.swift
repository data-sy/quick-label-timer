//
//  TimerButtonUI.swift
//  LabelTimer
//
//  Created by 이소연 on 8/11/25.
//
/// 버튼 타입 → UI 속성 매핑 모음
/// 
/// - 사용 목적: 좌/우 버튼이 동일한 룩앤필 규칙을 공유하도록 중앙에서 관리

import SwiftUI

struct TimerButtonUI {
    let title: String
    let systemImage: String
    let tint: Color
    let role: ButtonRole?
    let emphasis: TimerButtonEmphasis
    let size: TimerButtonSize
    let shape: TimerButtonShape
    let showsTitle: Bool
}

// Left
func ui(for type: TimerLeftButtonType) -> TimerButtonUI? {
    switch type {
    case .none:
        return nil
    case .stop:
        return .init(title: "정지",
                     systemImage: "stop.fill",
                     tint: .red,
                     role: .destructive,
                     emphasis: .secondary,
                     size: .regular,
                     shape: .circle, showsTitle: false)
    case .moveToFavorite:
        return .init(title: "즐겨찾기 이동",
                     systemImage: "arrow.right",
                     tint: .gray,
                     role: nil,
                     emphasis: .secondary,
                     size: .regular,
                     shape: .circle, showsTitle: true)
    case .delete:
        return .init(title: "삭제",
                     systemImage: "trash.fill",
                     tint: .red,
                     role: .destructive,
                     emphasis: .secondary,
                     size: .regular,
                     shape: .circle, showsTitle: false)
    }
}

// Right
func ui(for type: TimerRightButtonType) -> TimerButtonUI {
    switch type {
    case .play:
        return .init(title: "재생",
                     systemImage: "play.fill",
                     tint: Color.accentColor,
                     role: nil,
                     emphasis: .primary,
                     size: .regular,
                     shape: .circle, showsTitle: true)
    case .pause:
        return .init(title: "일시정지",
                     systemImage: "pause.fill",
                     tint: .gray,
                     role: nil,
                     emphasis: .secondary,
                     size: .regular,
                     shape: .circle, showsTitle: true)
    case .restart:
        return .init(title: "재시작",
                     systemImage: "gobackward",
                     tint: .accentColor,
                     role: nil,
                     emphasis: .primary,
                     size: .regular,
                     shape: .circle, showsTitle: true)
    }
}
