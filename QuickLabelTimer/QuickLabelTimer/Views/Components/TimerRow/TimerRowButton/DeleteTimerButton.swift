//
//  DeleteTimerButton.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/23/25.
//
/// 타이머 삭제/중지 버튼
///
/// - 사용 목적: 실행 중인 타이머를 중지하거나 삭제하는 X 버튼

import SwiftUI

struct DeleteTimerButton: View {
    let status: TimerStatus
    let onTap: () -> Void
    
    private var foregroundColor: Color {
        let colors = RowTheme.colors(for: status)
        return colors.cardForeground.opacity(RowTheme.deleteButtonOpacity)
    }
    
    var body: some View {
        Button(action: onTap) {
            Image(systemName: "xmark")
                .font(.caption)
                .foregroundColor(foregroundColor)
                .frame(width: RowTheme.deleteButtonSize, height: RowTheme.deleteButtonSize)
                .frame(width: RowTheme.deleteButtonTapArea, height: RowTheme.deleteButtonTapArea)
        }
        .buttonStyle(.plain)
    }
}
