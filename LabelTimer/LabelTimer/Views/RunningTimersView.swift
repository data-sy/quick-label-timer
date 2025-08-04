//
//  RunningTimersView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 실행 중인 타이머 목록을 표시하는 뷰
///
/// - 사용 목적: 생성된 타이머를 리스트 형태로 보여주고, 남은 시간을 실시간으로 업데이트

import SwiftUI

struct RunningTimersView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var presetManager: PresetManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(text: "실행중인 타이머")

            if timerManager.timers.isEmpty {
                Text("아직 실행 중인 타이머가 없습니다.")
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(timerManager.timers.sorted(by: { $0.createdAt > $1.createdAt })) { timer in
                    RunningTimerRowView(timer: timer, deleteCountdownSeconds: timerManager.deleteCountdownSeconds) { action in
                        handleAction(action, for: timer)
                    }
                }
            }
        }
        .padding()
    }

    /// 버튼 액션 처리
    private func handleAction(_ action: TimerButtonType, for timer: TimerData) {
        switch action {
        case .pause:
            timerManager.pauseTimer(id: timer.id)
        case .play:
            timerManager.resumeTimer(id: timer.id)
        case .stop:
            timerManager.stopTimer(id: timer.id)
        case .restart:
            timerManager.restartTimer(id: timer.id)
        case .delete:
            timerManager.convertTimerToPreset(timerId: timer.id)
        }
    }
}
