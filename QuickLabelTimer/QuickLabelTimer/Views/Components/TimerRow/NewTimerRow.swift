//
//  NewTimerRow.swift
//  QuickLabelTimer
//
//  Created for TimerRow Redesign
//
/// 나중에 이름 다시 정상화 시키면 그 때 주석 추가하자
///
/// - 사용 목적: 


import SwiftUI

/// 새로운 카드 스타일 타이머 행 (3-section layout)
struct NewTimerRow: View {
    let timer: TimerData

    // Closure pattern for actions
    let onToggleFavorite: () -> Void
    let onPlayPause: () -> Void
    let onReset: () -> Void
    let onDelete: () -> Void
    let onLabelChange: (String) -> Void

    var body: some View {
        let colors = RowTheme.colors(for: timer.status)

        VStack(alignment: .leading, spacing: 12) {
            // TOP: Favorite + Label
            HStack(alignment: .center, spacing: 8) {
                FavoriteToggleButton(
                    endAction: timer.endAction,
                    status: timer.status,
                    onToggle: onToggleFavorite
                )

                EditableTimerLabel(
                    label: timer.label,
                    status: timer.status,
                    onLabelChange: onLabelChange
                )
                
                Spacer()
                
                // X 삭제 버튼
                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(colors.cardForeground.opacity(RowTheme.deleteButtonOpacity))
                        .frame(width: RowTheme.deleteButtonSize, height: RowTheme.deleteButtonSize)
                        .frame(width: RowTheme.deleteButtonTapArea, height: RowTheme.deleteButtonTapArea)
                }
                .buttonStyle(.plain)

            }

            Divider()
                .background(colors.cardForeground.opacity(RowTheme.dividerOpacity)) // cardForeground 사용
                .padding(.vertical, 4)

            // MIDDLE: Time + Buttons
            HStack {
                Text(timer.formattedTime)
                    .font(.system(size: RowTheme.timeTextSize, weight: .bold, design: .rounded))
                    .foregroundColor(colors.cardForeground)
                    .minimumScaleFactor(0.5)

                Spacer()

                TimerActionButtons(
                    status: timer.status,
                    onPlayPause: onPlayPause,
                    onReset: onReset
                )
            }

            // BOTTOM: Alarm + End Time
            HStack(spacing: 4) {
                let alarmMode = AlarmNotificationPolicy.getMode(
                    soundOn: timer.isSoundOn,
                    vibrationOn: timer.isVibrationOn
                )
                Image(systemName: alarmMode.iconName)
                    .font(.caption)
                    .foregroundColor(colors.cardForeground.opacity(RowTheme.secondaryOpacity))

                if timer.status == .paused || timer.status == .stopped {
                    // 일시정지/준비 상태는 실시간 업데이트
                    TimelineView(.periodic(from: .now, by: 60)) { _ in
                        Text(timer.formattedEndTime)
                            .font(.footnote)
                            .foregroundColor(colors.cardForeground.opacity(RowTheme.secondaryOpacity))
                    }
                } else {
                    Text(timer.formattedEndTime)
                        .font(.footnote)
                        .foregroundColor(colors.cardForeground.opacity(RowTheme.secondaryOpacity))
                }

                Spacer()
            }
        }
        .padding(RowTheme.padding)
        .background(colors.cardBackground)
        .cornerRadius(RowTheme.cornerRadius)
        .shadow(
            color: RowTheme.shadowColor,
            radius: RowTheme.shadowRadius,
            x: 0,
            y: RowTheme.shadowY
        )
    }
}

#Preview("NewTimerRow – All States") {
    let now = Date()

    // Stopped timer (프리셋)
    let stoppedTimer = TimerData(
        label: "Ready Timer",
        hours: 1,
        minutes: 0,
        seconds: 0,
        isSoundOn: false,
        isVibrationOn: false,
        createdAt: now,
        endDate: now,
        remainingSeconds: 3600,
        status: .stopped,
        presetId: nil,
        endAction: .preserve
    )

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

    // Completed timer
    let completedTimer = TimerData(
        label: "Completed Timer",
        hours: 0,
        minutes: 10,
        seconds: 0,
        isSoundOn: true,
        isVibrationOn: true,
        createdAt: now,
        endDate: now,
        remainingSeconds: 0,
        status: .completed,
        presetId: nil,
        endAction: .preserve
    )

    Group {
        VStack(spacing: 16) {
            NewTimerRow(
                timer: stoppedTimer,
                onToggleFavorite: {},
                onPlayPause: {},
                onReset: {},
                onDelete: {},
                onLabelChange: { print("Label changed to: \($0)") }
            )

            NewTimerRow(
                timer: runningTimer,
                onToggleFavorite: {},
                onPlayPause: {},
                onReset: {},
                onDelete: {},
                onLabelChange: { print("Label changed to: \($0)") }
            )

            NewTimerRow(
                timer: pausedTimer,
                onToggleFavorite: {},
                onPlayPause: {},
                onReset: {},
                onDelete: {},
                onLabelChange: { print("Label changed to: \($0)") }
            )

            NewTimerRow(
                timer: completedTimer,
                onToggleFavorite: {},
                onPlayPause: {},
                onReset: {},
                onDelete: {},
                onLabelChange: { print("Label changed to: \($0)") }
            )
        }
        .padding()
        .background(AppTheme.pageBackground)
        .previewDisplayName("Light Mode")

        VStack(spacing: 16) {
            NewTimerRow(
                timer: stoppedTimer,
                onToggleFavorite: {},
                onPlayPause: {},
                onReset: {},
                onDelete: {},
                onLabelChange: { print("Label changed to: \($0)") }
            )

            NewTimerRow(
                timer: runningTimer,
                onToggleFavorite: {},
                onPlayPause: {},
                onReset: {},
                onDelete: {},
                onLabelChange: { print("Label changed to: \($0)") }
            )

            NewTimerRow(
                timer: pausedTimer,
                onToggleFavorite: {},
                onPlayPause: {},
                onReset: {},
                onDelete: {},
                onLabelChange: { print("Label changed to: \($0)") }
            )

            NewTimerRow(
                timer: completedTimer,
                onToggleFavorite: {},
                onPlayPause: {},
                onReset: {},
                onDelete: {},
                onLabelChange: { print("Label changed to: \($0)") }
            )
        }
        .padding()
        .background(AppTheme.pageBackground)
        .environment(\.colorScheme, .dark)
        .previewDisplayName("Dark Mode")
    }
}
