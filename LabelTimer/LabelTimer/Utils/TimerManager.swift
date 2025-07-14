import Foundation
import Combine

//
//  TimerManager.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 실행 중인 타이머들을 관리하는 클래스
///
/// - 사용 목적: 타이머 추가, 삭제, 상태 업데이트 등을 전역에서 관리함.

final class TimerManager: ObservableObject {
    /// 현재 실행 중인 타이머 목록
    @Published var timers: [TimerData] = []
    
    private var timer: Timer?

    init() {
        startTicking()
    }
    
    func startTicking() {
        timer?.invalidate() // 기존 타이머 종료

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let now = Date()

            // 매초마다 타이머 상태 업데이트
            self.timers = self.timers.map { timer in
                guard timer.isRunning else { return timer }

                let remaining = Int(timer.endDate.timeIntervalSince(now))
                return timer.updating(remainingSeconds: max(remaining, 0))
            }
        }

        RunLoop.main.add(timer!, forMode: .common)
    }
    
    /// 타이머 추가
    func addTimer(hours: Int, minutes: Int, seconds: Int, label: String) {
        let totalSeconds = hours * 3600 + minutes * 60 + seconds
        guard totalSeconds > 0 else { return }

        let start = Date()
        let end = start.addingTimeInterval(TimeInterval(totalSeconds))

        let newTimer = TimerData(
            label: label,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            startDate: start,
            endDate: end,
            isRunning: true,
            remainingSeconds: totalSeconds
        )

        timers.append(newTimer)
        
        // ✅ 로깅
        print("✅ 타이머 추가됨: \(newTimer.label) (\(totalSeconds)초)")
        print("현재 실행 중인 타이머 수: \(timers.count)")
    }
}
