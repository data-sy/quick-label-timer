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
//    
//    private func buttonForegroundColor(colors: (background: Color, foreground: Color, accent: Color)) -> Color {
//        switch status {
//        case .running:
//            // 실행 중: 흰색 배경에 파란 아이콘
//            return colors.accent  // 파랑
//        case .paused, .stopped:
//            // 일시정지/준비: 파란 배경에 흰색 아이콘
//            return colors.background  // 흰색
//        case .completed:
//            // ✅ 완료: 흰색 배경에 초록 아이콘
//            return RowTheme.Completed.background  // 초록
//        }
//    }
    
//    private func buttonBackgroundColor(colors: (background: Color, foreground: Color, accent: Color)) -> Color {
//        switch status {
//        case .running:
//            // 실행 중: 흰색 버튼
//            return colors.background
//        case .paused:
//            // 일시정지: 파란색 버튼
//            return colors.accent
//        case .completed:
//            // 완료: 초록색 버튼
//            return colors.accent
//        case .stopped:
//            // 준비: 파란색 버튼
//            return colors.accent
//        }
//    }
}

#Preview("TimerActionButtons - All States") {
    VStack(spacing: 32) {
        // Stopped
        VStack {
            Text("Stopped (준비)")
                .font(.caption)
            TimerActionButtons(
                status: .stopped,
                onPlayPause: { print("Play tapped") },
                onReset: { print("Reset tapped") }
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        
        // Paused
        VStack {
            Text("Paused (일시정지)")
                .font(.caption)
            TimerActionButtons(
                status: .paused,
                onPlayPause: { print("Resume tapped") },
                onReset: { print("Reset tapped") }
            )
        }
        .padding()
        .background(Color.blue.opacity(0.15))
        .cornerRadius(12)
        
        // Running
        VStack {
            Text("Running (실행 중)")
                .font(.caption)
                .foregroundColor(.white)
            TimerActionButtons(
                status: .running,
                onPlayPause: { print("Pause tapped") },
                onReset: { print("Reset tapped") }
            )
        }
        .padding()
        .background(Color.blue)
        .cornerRadius(12)
        
        // Completed
        VStack {
            Text("Completed (완료)")
                .font(.caption)
                .foregroundColor(.white)
            TimerActionButtons(
                status: .completed,
                onPlayPause: { print("Restart tapped") },
                onReset: { print("Reset tapped") }
            )
        }
        .padding()
        .background(Color.green)
        .cornerRadius(12)
    }
    .padding()
}
