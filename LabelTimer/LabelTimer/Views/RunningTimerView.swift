import SwiftUI
import Combine

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
    @Binding var path: [Route]

    @State private var remainingSeconds: Int = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 20) {
            Text("⏱ 타이머 실행 중")
                .font(.title)

            Text(timeString(from: remainingSeconds))
                .font(.system(size: 48, weight: .bold))
                .monospacedDigit()

            if !timerData.label.isEmpty {
                Text("라벨: \(timerData.label)")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .navigationTitle("실행 중")
        .onAppear {
            remainingSeconds = timerData.hours * 3600 + timerData.minutes * 60 + timerData.seconds
        }
        .onReceive(timer) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                timer.upstream.connect().cancel()
                path.append(.alarm(data: timerData))
            }
        }
    }

    func timeString(from totalSeconds: Int) -> String {
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        let s = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

