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
    @Published var timers: [TimerData] = []

    private let presetManager: PresetManager
    private var timer: Timer?

    init(presetManager: PresetManager) {
        self.presetManager = presetManager
        startTicking()
    }

    /// 매초마다 타이머 상태 업데이트
    func startTicking() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let now = Date()

            // 실행 중인 타이머만 남은 시간 갱신
            self.timers = self.timers.map { timer in
                guard timer.status == .running else { return timer }

                let remaining = Int(timer.endDate.timeIntervalSince(now))
                return timer.updating(remainingSeconds: max(remaining, 0))
            }
        }

        RunLoop.main.add(timer!, forMode: .common)
    }

    /// 새 타이머 추가
    func addTimer(hours: Int, minutes: Int, seconds: Int, label: String) {
        let totalSeconds = hours * 3600 + minutes * 60 + seconds
        guard totalSeconds > 0 else { return }

        let now = Date()
        let end = now.addingTimeInterval(TimeInterval(totalSeconds))

        let finalLabel = label.isEmpty ? generateAutoLabel() : label
        
        let newTimer = TimerData(
            label: finalLabel,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            createdAt: now,
            endDate: end,
            remainingSeconds: totalSeconds,
            status: .running
        )

        timers.append(newTimer)
    }

    /// 레이블이 비어 있을 경우 중복되지 않는 자동 레이블("타이머N") 생성
    private func generateAutoLabel() -> String {
        let existingLabels = timers.map(\.label) + presetManager.allPresets.map(\.label)
        var index = 1
        while true {
            let candidate = "타이머\(index)"
            if !existingLabels.contains(candidate) {
                return candidate
            }
            index += 1
        }
    }

    /// 실행 중인 타이머를 일시정지
    func pauseTimer(id: UUID) {
        timers = timers.map { timer in
            guard timer.id == id, timer.status == .running else { return timer }
            return timer.updating(status: .paused)
        }
    }

    /// 일시정지된 타이머를 재개
    func resumeTimer(id: UUID) {
        timers = timers.map { timer in
            guard timer.id == id, timer.status == .paused else { return timer }

            let now = Date()
            let newEnd = now.addingTimeInterval(TimeInterval(timer.remainingSeconds))

            return TimerData(
                id: timer.id,
                label: timer.label,
                hours: timer.hours,
                minutes: timer.minutes,
                seconds: timer.seconds,
                createdAt: timer.createdAt,
                endDate: newEnd,
                remainingSeconds: timer.remainingSeconds,
                status: .running
            )
        }
    }

    /// 타이머를 정지 상태로 변경
    func stopTimer(id: UUID) {
        timers = timers.map { timer in
            guard timer.id == id else { return timer }

            let total = timer.totalSeconds
            let now = Date()
            let newEnd = now.addingTimeInterval(TimeInterval(total))

            return TimerData(
                id: timer.id,
                label: timer.label,
                hours: timer.hours,
                minutes: timer.minutes,
                seconds: timer.seconds,
                createdAt: timer.createdAt,
                endDate: newEnd,
                remainingSeconds: total,
                status: .stopped
            )
        }
    }


    /// 기존 타이머를 재시작 (위치 유지)
    func restartTimer(id: UUID) {
        guard let index = timers.firstIndex(where: { $0.id == id }) else { return }

        let old = timers[index]
        let totalSeconds = old.totalSeconds
        let now = Date()
        let newEnd = now.addingTimeInterval(TimeInterval(totalSeconds))

        let restarted = TimerData(
            id: old.id,
            label: old.label,
            hours: old.hours,
            minutes: old.minutes,
            seconds: old.seconds,
            createdAt: old.createdAt,
            endDate: newEnd,
            remainingSeconds: totalSeconds,
            status: .running
        )

        timers[index] = restarted
    }
    
    /// 실행 중인 타이머 삭제 (실행중인 타이머 -> 프리셋 목록으로 이동)
    @discardableResult
    func removeTimer(id: UUID) -> TimerData? {
        guard let index = timers.firstIndex(where: { $0.id == id }) else { return nil }
        let removed = timers.remove(at: index)
        return removed
    }

}
