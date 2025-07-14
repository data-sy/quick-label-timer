//
//  RunningTimersView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//


import SwiftUI

/// 실행 중인 타이머 목록을 표시하는 뷰
///
/// - 사용 목적: 생성된 타이머를 리스트 형태로 보여주고, 남은 시간을 실시간으로 업데이트
struct RunningTimersView: View {
    @EnvironmentObject var timerManager: TimerManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("실행 중인 타이머")
                .font(.headline)

            if timerManager.timers.isEmpty {
                Text("아직 실행 중인 타이머가 없습니다.")
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            } else {
                ForEach(timerManager.timers) { timer in
                    RunningTimerRowView(timer: timer)
                }
            }
        }
        .padding(.horizontal)
    }
}
