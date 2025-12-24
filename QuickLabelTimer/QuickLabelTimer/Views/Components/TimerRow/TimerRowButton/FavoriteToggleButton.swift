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
    let status: TimerStatus
    let onToggle: () -> Void
    
    private var isOn: Bool {
        endAction.isPreserve
    }
    
    private var tint: Color {
        _ = RowTheme.colors(for: status)
        
        switch (isOn, status) {
        case (true, _):
            // 북마크 ON = 항상 노란색
            return AppTheme.Bookmark.on
        case (false, .running), (false, .completed), (false, .paused):
            // 북마크 OFF + 실행중/완료 = 흰색 아웃라인
            return AppTheme.Bookmark.offRunning
        case (false, .stopped):
            // 북마크 OFF + 준비/일시정지 = 검정 아웃라인
            return AppTheme.Bookmark.off
        }
    }
    
    var body: some View {
        Button(action: onToggle) {
            Image(systemName: isOn ? "bookmark.fill" : "bookmark")
                .foregroundColor(tint)
                .font(.title2)
                .frame(width: 44, height: 44)
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
