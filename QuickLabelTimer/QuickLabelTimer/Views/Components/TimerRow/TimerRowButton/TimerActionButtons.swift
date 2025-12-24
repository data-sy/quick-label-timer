//
//  TimerActionButtons.swift
//  QuickLabelTimer
//
//  Created for TimerRow Redesign
//
/// 타이머 액션 버튼 (Play/Pause + Reset)
///
/// - 단순화된 버튼 시스템: 상태 기반으로 버튼을 표시

import SwiftUI

struct TimerActionButtons: View {
    let status: TimerStatus
    let onPlayPause: () -> Void
    let onReset: () -> Void

    var body: some View {
        let colors = RowTheme.colors(for: status)
        
        HStack(spacing: RowTheme.actionButtonSpacing) {
            // Reset button (left) - only show when paused
            if status == .paused {
                Button(action: onReset) {
                    Image(systemName: "arrow.clockwise")
                        .font(.footnote)
                        .foregroundColor(colors.buttonBackground) // 버튼 배경색을 아이콘 색으로 사용 (외곽선 버튼이므로)
                        .frame(
                            width: RowTheme.secondaryButtonSize,
                            height: RowTheme.secondaryButtonSize
                        )
                        .background(
                              Circle()
                                  .strokeBorder(
                                      colors.buttonBackground.opacity(RowTheme.inactiveStrokeOpacity),
                                      lineWidth: 1.5
                                  )
                          )
                }
                .buttonStyle(.plain)
            }

            // Main action button (right)
            Button(action: onPlayPause) {
                Image(systemName: buttonIcon)
                    .font(.title2)
                    .foregroundColor(colors.buttonForeground)
                    .frame(
                        width: RowTheme.primaryButtonSize,
                        height: RowTheme.primaryButtonSize
                    )
                    .background(Circle().fill(colors.buttonBackground))
                    .shadow(radius: RowTheme.buttonShadowRadius)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Computed Properties
    
    private var buttonIcon: String {
        switch status {
        case .running:
            return "pause.fill"
        case .paused:
            return "play.fill"
        case .completed:
            return "arrow.clockwise"  // 재시작 아이콘
        case .stopped:
            return "play.fill"
        }
    }
}
