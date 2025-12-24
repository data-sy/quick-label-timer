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
    let scrollProxy: ScrollViewProxy?

    // Closure pattern for actions
    let onToggleFavorite: () -> Void
    let onPlayPause: () -> Void
    let onReset: () -> Void
    let onDelete: () -> Void
    let onEdit: (() -> Void)?
    let onLabelChange: (String) -> Void
    let trailingContent: (() -> AnyView)? // 우측 상단 슬롯

    @State private var isLabelEditing = false

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
                    timerId: timer.id,
                    scrollProxy: scrollProxy,
                    onLabelChange: onLabelChange,
                    isEditing: $isLabelEditing
                )
                
                if let trailingContent = trailingContent {
                    trailingContent()
                }
            }

            Divider()
                .background(colors.cardForeground.opacity(RowTheme.dividerOpacity)) // cardForeground 사용
                .padding(.vertical, 4)

            // MIDDLE: Time + Buttons
            HStack {
                HStack(alignment: .center, spacing: 8) {
                    Text(timer.formattedTime)
                        .font(.system(size: RowTheme.timeTextSize, weight: .bold, design: .rounded))
                        .foregroundColor(colors.cardForeground)
                        .minimumScaleFactor(0.5)
                    
                    if onEdit != nil {
                        Image(systemName: "pencil")
                            .font(.title3)
                            .foregroundColor(colors.cardForeground)
                            .opacity(RowTheme.editIconOpacity)
                    }
                }
                .contentShape(Rectangle())
                .if(onEdit != nil) { view in
                    view.onTapGesture {
                        onEdit?()
                    }
                }

                Spacer()

                TimerActionButtons(
                    status: timer.status,
                    onPlayPause: {
                        // Force commit any pending label edit before playing
                        if isLabelEditing {
                            isLabelEditing = false
                            DispatchQueue.main.async {
                                onPlayPause()
                            }
                        } else {
                            onPlayPause()
                        }
                    },
                    onReset: onReset
                )
            }

            // BOTTOM: Alarm + End Time (stopped 상태가 아닐 때만)
            if timer.status != .stopped {
                HStack(spacing: 4) {
                    if timer.status == .completed, timer.pendingDeletionAt != nil {
                        CountdownMessageView(timer: timer)
                    } else {
                        EndTimeInfoView(timer: timer, foregroundColor: colors.cardForeground)
                    }
                    
                    Spacer()
                }
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

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
