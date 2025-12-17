//
//  NewTimerRowTestView.swift
//  QuickLabelTimer
//
//  Created for TimerRow Redesign - Testing Sandbox
//

import SwiftUI

/// 테스트 뷰: NewTimerRow를 독립적으로 테스트하기 위한 샌드박스
///
/// - 사용 목적: ViewModel 없이 상태 변화를 직접 조작하여 UI 동작 검증
struct NewTimerRowTestView: View {
    @State private var timer: TimerData

    init() {
        let now = Date()
        _timer = State(initialValue: TimerData(
            label: "Test Timer",
            hours: 0,
            minutes: 25,
            seconds: 0,
            isSoundOn: true,
            isVibrationOn: false,
            createdAt: now,
            endDate: now.addingTimeInterval(25 * 60),
            remainingSeconds: 15 * 60, // 15 minutes remaining
            status: .paused,
            presetId: nil,
            endAction: .discard
        ))
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("NewTimerRow Test Sandbox")
                .font(.title2)
                .fontWeight(.bold)

            // Status display
            HStack {
                Text("Status:")
                    .fontWeight(.semibold)
                Text(statusText)
                    .foregroundColor(statusColor)
            }

            // The actual NewTimerRow being tested
            NewTimerRow(
                timer: timer,
                onToggleFavorite: handleToggleFavorite,
                onPlayPause: handlePlayPause,
                onReset: handleReset,
                onDelete: handleDelete
            )

            // Manual controls for testing
            VStack(spacing: 12) {
                Text("Manual Test Controls")
                    .font(.headline)

                HStack {
                    Button("Set Running") {
                        timer.status = .running
                    }
                    Button("Set Paused") {
                        timer.status = .paused
                    }
                    Button("Set Stopped") {
                        timer.status = .stopped
                    }
                    Button("Set Completed") {
                        timer.status = .completed
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

            Spacer()
        }
        .padding()
        .background(AppTheme.pageBackground)
    }

    // MARK: - Action Handlers

    private func handleToggleFavorite() {
        timer.endAction = timer.endAction.isPreserve ? .discard : .preserve
        print("✨ Favorite toggled: \(timer.endAction)")
    }

    private func handlePlayPause() {
        if timer.status == .running {
            timer.status = .paused
            print("⏸️ Timer paused")
        } else {
            timer.status = .running
            print("▶️ Timer resumed")
        }
    }

    private func handleReset() {
        let totalSeconds = timer.totalSeconds
        timer.remainingSeconds = totalSeconds
        timer.endDate = Date().addingTimeInterval(TimeInterval(totalSeconds))
        timer.status = .paused
        print("🔄 Timer reset to \(totalSeconds) seconds")
    }

    private func handleDelete() {
        print("🗑️ Delete button tapped")
        // In real app, this would remove the timer
    }

    // MARK: - Helper Properties

    private var statusText: String {
        switch timer.status {
        case .running: return "Running"
        case .paused: return "Paused"
        case .stopped: return "Stopped"
        case .completed: return "Completed"
        }
    }

    private var statusColor: Color {
        switch timer.status {
        case .running: return .green
        case .paused: return .orange
        case .stopped: return .red
        case .completed: return .purple
        }
    }
}

#Preview {
    NewTimerRowTestView()
}
