import SwiftUI

//
//  RunningTimerRowView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 실행 중인 타이머에 대한 UI를 제공하는 래퍼 뷰
///
/// - 사용 목적: 실행 중 타이머의 정보와 동작 버튼(일시정지, 정지 등)을 표시

struct RunningTimerRowView: View {
    let timer: TimerData
    let onAction: (TimerButtonType) -> Void

    @State private var uiState: TimerInteractionState

    init(timer: TimerData, onAction: @escaping (TimerButtonType) -> Void) {
        self.timer = timer
        self._uiState = State(initialValue: timer.interactionState)
        self.onAction = onAction
    }

    private var formattedRemainingTime: String {
        let remaining = max(timer.remainingSeconds, 0)
        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        let seconds = remaining % 60

        if hours > 0 {
            return String(format: "%01d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    var body: some View {
        let buttons = buttonSet(for: uiState)

        TimerRowView(
            label: timer.label,
            timeText: formattedRemainingTime,
            leftButton: AnyView(
                TimerActionButton(type: buttons.left) {
                    handleAction(buttons.left)
                }
            ),

            rightButton: AnyView(
                TimerActionButton(type: buttons.right) {
                    handleAction(buttons.right)
                }
            ),
            state: uiState
        )
    }

    private func handleAction(_ button: TimerButtonType) {
        onAction(button)
        uiState = nextState(from: uiState, button: button)
    }
}
