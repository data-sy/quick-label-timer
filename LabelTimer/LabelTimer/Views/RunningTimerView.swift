import SwiftUI

//
//  RunningTimerView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/9/25.
//
/// 실행 중인 타이머의 남은 시간을 표시하는 화면
///
/// - 사용 목적: 실시간 카운트다운 표시, 종료 시 알람으로 전환
/// - ViewModel: RunningTimerViewModel

struct RunningTimerView: View {
    let timerData: TimerData

    var body: some View {
        VStack(spacing: 20) {
            Text("⏱ 타이머 실행 중")
                .font(.title)

            Text(String(format: "%02d:%02d:%02d", timerData.hours, timerData.minutes, timerData.seconds))
                .font(.system(size: 48, weight: .bold))

            if !timerData.label.isEmpty {
                Text("라벨: \(timerData.label)")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .navigationTitle("실행 중")
    }
}

