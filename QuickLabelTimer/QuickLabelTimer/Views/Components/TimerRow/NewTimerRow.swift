//
//  NewTimerRow.swift
//  QuickLabelTimer
//
//  Created for TimerRow Redesign
//

import SwiftUI

/// 새로운 카드 스타일 타이머 행 (3-section layout)
struct NewTimerRow: View {
    let timer: TimerData

    // Closure pattern for actions
    let onToggleFavorite: () -> Void
    let onPlayPause: () -> Void
    let onReset: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // TOP: Favorite + Label + Delete
            HStack {
                Text("TOP")
                    .foregroundColor(.secondary)
            }

            Divider()
                .background(Color.secondary.opacity(0.3))
                .padding(.vertical, 4)

            // MIDDLE: Time + Buttons
            HStack {
                Text(timer.formattedTime)
                    .font(.system(size: AppTheme.TimerCard.timeTextSize, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .minimumScaleFactor(0.5)

                Spacer()

                Text("BUTTONS")
                    .foregroundColor(.secondary)
            }

            // BOTTOM: Info
            HStack {
                Text("BOTTOM")
                    .foregroundColor(.secondary)
            }
        }
        .padding(AppTheme.TimerCard.padding)
        .background(AppTheme.contentBackground)
        .cornerRadius(AppTheme.TimerCard.cornerRadius)
        .shadow(
            color: .black.opacity(0.1),
            radius: AppTheme.TimerCard.shadowRadius,
            x: 0,
            y: AppTheme.TimerCard.shadowY
        )
    }
}
