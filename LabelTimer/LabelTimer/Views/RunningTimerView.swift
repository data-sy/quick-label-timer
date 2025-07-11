import SwiftUI
import UserNotifications

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
    @State private var timer: Timer? = nil

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

            Button("중지 후 홈으로") {
                timer?.invalidate()
                path = []
            }
            .foregroundColor(.red)
            .padding(.top, 20)
        }
        .padding()
        .navigationTitle("타이머 실행")
        .onAppear {
            remainingSeconds = timerData.totalSeconds

            guard remainingSeconds > 0 else {
                path.append(.alarm(data: timerData))
                return
            }

            startCountdown()
            scheduleNotification(label: timerData.label, after: remainingSeconds)
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    func timeString(from seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                timer?.invalidate()
                path.append(.alarm(data: timerData))
            }
        }
    }

    func scheduleNotification(label: String, after seconds: Int) {
        let content = UNMutableNotificationContent()
        content.title = "⏰ 타이머 종료"
        content.body = label.isEmpty ? "타이머가 끝났습니다." : "\(label) 타이머가 끝났습니다."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
