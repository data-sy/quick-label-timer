//
//  FavoriteToggleButton.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/5/25.
//
/// 즐겨찾기(별) 토글 버튼
///
/// - 사용 목적: 즐겨찾기 상태를 표시하고 토글함

import SwiftUI

struct FavoriteToggleButton: View {
    let endAction: TimerEndAction
    let onToggle: () -> Void
    
    private var isOn: Bool { endAction.isPreserve }
    
    var body: some View {
        Button(action: onToggle) {
//            Image(systemName: endAction.isPreserve ? "star.fill" : "star")
            Image(systemName: endAction.isPreserve ? "bookmark.fill" : "bookmark")
                .foregroundColor(endAction.isPreserve ? .yellow : .gray.opacity(0.6))
                .font(.title2)
                .frame(width: 44, height: 44) // 탭 영역 확보
                .a11y(
                    label: A11yText.TimerRow.favoriteLabel,
                    hint: isOn ? A11yText.TimerRow.favoriteOnHint : A11yText.TimerRow.favoriteOffHint,
                    traits: isOn ? [.isButton, .isSelected] : .isButton
                )
                .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.7), value: endAction)
        }
        .buttonStyle(.plain)
    }
}
