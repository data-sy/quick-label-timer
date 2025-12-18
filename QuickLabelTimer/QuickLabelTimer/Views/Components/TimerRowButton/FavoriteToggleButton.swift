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
    let isRunning: Bool
    
    //TODO: 실험실 코드 용이므로, Debug 삭제할 때 함께 삭제하기
    init(
        endAction: TimerEndAction,
        onToggle: @escaping () -> Void,
        isRunning: Bool = false
    ) {
        self.endAction = endAction
        self.onToggle = onToggle
        self.isRunning = isRunning
    }
    
    private var isOn: Bool { endAction.isPreserve }
    
    private var tint: Color {
        if isOn { return AppTheme.Bookmark.on }
        if isRunning { return AppTheme.Bookmark.offRunning }
        return AppTheme.Bookmark.off
    }
    
    var body: some View {
        Button(action: onToggle) {
            Image(systemName: isOn ? "bookmark.fill" : "bookmark")
                .foregroundColor(tint)
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
