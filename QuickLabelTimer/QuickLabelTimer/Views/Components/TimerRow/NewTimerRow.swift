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
            HStack(alignment: .center, spacing: 8) {
                FavoriteToggleButton(
                    endAction: timer.endAction,
                    onToggle: onToggleFavorite
                )

                Text(timer.label)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
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

                TimerActionButtons(
                    status: timer.status,
                    onPlayPause: onPlayPause,
                    onReset: onReset
                )
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
            color: AppTheme.TimerCard.shadowColor,
            radius: AppTheme.TimerCard.shadowRadius,
            x: 0,
            y: AppTheme.TimerCard.shadowY
        )
    }
}

#Preview("NewTimerRow – Light & Dark") {
    let now = Date()

    // Running timer
    let runningTimer = TimerData(
        label: "Running Timer",
        hours: 0,
        minutes: 25,
        seconds: 0,
        isSoundOn: true,
        isVibrationOn: false,
        createdAt: now,
        endDate: now.addingTimeInterval(25 * 60),
        remainingSeconds: 10 * 60,
        status: .running,
        presetId: nil,
        endAction: .discard
    )

    // Paused timer
    let pausedTimer = TimerData(
        label: "Paused Timer",
        hours: 0,
        minutes: 15,
        seconds: 0,
        isSoundOn: false,
        isVibrationOn: true,
        createdAt: now,
        endDate: now.addingTimeInterval(15 * 60),
        remainingSeconds: 15 * 60,
        status: .paused,
        presetId: nil,
        endAction: .preserve
    )

    Group {
        VStack(spacing: 16) {
            NewTimerRow(
                timer: runningTimer,
                onToggleFavorite: {},
                onPlayPause: {},
                onReset: {},
                onDelete: {}
            )

            NewTimerRow(
                timer: pausedTimer,
                onToggleFavorite: {},
                onPlayPause: {},
                onReset: {},
                onDelete: {}
            )
        }
        .padding()
        .background(AppTheme.pageBackground)
        .previewDisplayName("Light Mode")

        VStack(spacing: 16) {
            NewTimerRow(
                timer: runningTimer,
                onToggleFavorite: {},
                onPlayPause: {},
                onReset: {},
                onDelete: {}
            )

            NewTimerRow(
                timer: pausedTimer,
                onToggleFavorite: {},
                onPlayPause: {},
                onReset: {},
                onDelete: {}
            )
        }
        .padding()
        .background(AppTheme.pageBackground)
        .environment(\.colorScheme, .dark)
        .previewDisplayName("Dark Mode")
    }
}

