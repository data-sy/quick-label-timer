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

    /// 현재 UI 상태 (일시정지, 멈춤 등)
    @State private var uiState: TimerInteractionState

    init(timer: TimerData) {
        self.timer = timer
        _uiState = State(initialValue: timer.interactionState) // 초기 상태 설정
    }

    /// 남은 시간을 계산해 포맷된 문자열로 반환
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
        let buttons = buttonSet(for: uiState) // 현재 UI 상태에 따른 버튼 세트

        TimerRowView(
            label: timer.label,
            timeText: formattedRemainingTime,
            leftButton: AnyView(
                Button(action: {
                    uiState = nextState(from: uiState, button: buttons.left)
                    // TODO: 버튼 동작 로직은 추후 연결
                }) {
                    Image(systemName: buttons.left.iconName)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(buttons.left.backgroundColor)
                        .clipShape(Circle())
                }
            ),
            rightButton: AnyView(
                Button(action: {
                    uiState = nextState(from: uiState, button: buttons.right)
                    // TODO: 버튼 동작 로직은 추후 연결
                }) {
                    Image(systemName: buttons.right.iconName)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(buttons.right.backgroundColor)
                        .clipShape(Circle())
                }
            )
        )
    }
}

// MARK: - UI 상태 관련 타입 및 로직

/// 실행 중 타이머의 UI 상태
fileprivate enum TimerInteractionState {
    case running
    case paused
    case stopped
}

/// 좌/우 버튼 종류
private enum TimerButtonType {
    case play     // 재생
    case pause    // 일시정지
    case restart  // 재시작
    case stop     // 멈춤
    case delete   // 삭제

    var iconName: String {
        switch self {
        case .play: return "play.fill"
        case .pause: return "pause.fill"
        case .restart: return "gobackward"
        case .stop: return "stop.fill"
        case .delete: return "xmark"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .play: return .green
        case .pause: return .orange
        case .restart: return .blue
        case .stop: return .red
        case .delete: return .gray
        }
    }
}

/// 좌/우 버튼 세트
private struct TimerButtonSet {
    let left: TimerButtonType
    let right: TimerButtonType
}

/// 상태에 따라 버튼 세트 반환
private func buttonSet(for state: TimerInteractionState) -> TimerButtonSet {
    switch state {
    case .running: return TimerButtonSet(left: .stop, right: .pause)
    case .paused:  return TimerButtonSet(left: .delete, right: .play)
    case .stopped: return TimerButtonSet(left: .delete, right: .restart)
    }
}

/// 버튼 클릭에 따라 다음 상태 반환
private func nextState(from current: TimerInteractionState, button: TimerButtonType) -> TimerInteractionState {
    switch (current, button) {
    case (.running, .stop): return .stopped
    case (.running, .pause): return .paused
    case (.paused, .play): return .running
    case (.paused, .delete): return .stopped
    case (.stopped, .restart): return .running
    case (.stopped, .delete): return .stopped
    default: return current
    }
}

// MARK: - TimerData 확장: 상태 → UI 상태

extension TimerData {
    fileprivate var interactionState: TimerInteractionState {
        switch status {
        case .running: return .running
        case .paused: return .paused
        case .completed, .stopped: return .stopped
        }
    }
}
