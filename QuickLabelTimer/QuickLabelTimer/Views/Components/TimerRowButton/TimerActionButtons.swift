//
//  TimerActionButtons.swift
//  QuickLabelTimer
//
//  Created for TimerRow Redesign
//

import SwiftUI

/// 타이머 액션 버튼 (Play/Pause + Reset)
///
/// - 단순화된 버튼 시스템: 상태 기반으로 버튼을 표시
struct TimerActionButtons: View {
    let status: TimerStatus
    let isRunning: Bool
    let onPlayPause: () -> Void
    let onReset: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Reset button (left) - only show when paused
            if status == .paused {
                Button(action: onReset) {
                    Image(systemName: "arrow.clockwise")
                        .font(.footnote)
                        .foregroundColor(isRunning ? .white : .blue)
                        .frame(
                            width: AppTheme.TimerCard.secondaryButtonSize,
                            height: AppTheme.TimerCard.secondaryButtonSize
                        )
                        .background(
                            Circle()
                                .strokeBorder(
                                    isRunning ? Color.white.opacity(0.5) : Color.blue.opacity(0.3),
                                    lineWidth: 1.5
                                )
                        )
                }
                .buttonStyle(.plain)
            }

            // Play/Pause button (right) - always visible
            Button(action: onPlayPause) {
                Image(systemName: status == .running ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .foregroundColor(isRunning ? .blue : .white)
                    .frame(
                        width: AppTheme.TimerCard.primaryButtonSize,
                        height: AppTheme.TimerCard.primaryButtonSize
                    )
                    .background(Circle().fill(isRunning ? Color.white : Color.blue))
                    .shadow(radius: 4)
            }
            .buttonStyle(.plain)
        }
    }
}
