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

struct RunningTimerView: View {
    let timerData: TimerData
    @Binding var path: [Route]

    @State private var remainingSeconds: Int = 0
    @State private var timer: Timer? = nil
    
    var body: some View {
        AppScreenLayout(
            content: {
                VStack(spacing: 24) {
                    TimerTitleView(text: "타이머 실행 중")
                    LabelDisplayView(label: timerData.label)
                    CountdownView(seconds: remainingSeconds)
                }
            },
            bottom: {
                Button("중지 후 홈으로") {
                    stopTimer()
                    NotificationUtils.cancelScheduledNotification()
                    path = []
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.red)
                .cornerRadius(10)
            }
        )
        .navigationTitle("타이머 실행")
        .onAppear {
            remainingSeconds = timerData.totalSeconds

            guard remainingSeconds > 0 else {
                path.append(.alarm(data: timerData))
                return
            }
            
            NotificationUtils.scheduleNotification(label: timerData.label, after: remainingSeconds)
            startCountdown()
        }
        .onDisappear {
            stopTimer()
        }
    }

    func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                stopTimer()
                path.append(.alarm(data: timerData))
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
}
