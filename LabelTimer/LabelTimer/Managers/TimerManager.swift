//
//  TimerManager.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 실행 중인 타이머들을 관리하는 클래스
///
/// - 사용 목적: 타이머 추가, 삭제, 상태 업데이트 등을 전역에서 관리함.

import Foundation
import Combine
import AVFoundation

final class TimerManager: ObservableObject {
    @Published var timers: [TimerData] = []
    
    private let presetManager: PresetManager
    private let userSettings: UserSettings
    private let alarmHandler: AlarmTriggering

    private var timer: Timer?
    
    init(presetManager: PresetManager, userSettings: UserSettings = .shared,
         alarmHandler: AlarmTriggering = AlarmHandler()) {
        self.presetManager = presetManager
        self.userSettings = userSettings
        self.alarmHandler = alarmHandler // 테스트용
        startTicking()
    }
    
    /// 타이머 로컬 알림 예약
    private func scheduleNotification(for timer: TimerData) {
        let interval = max(1, timer.endDate.timeIntervalSince(Date()))
        NotificationUtils.scheduleNotification(
            id: timer.id.uuidString,
            label: timer.label,
            after: Int(interval)
        )
    }

    /// 타이머 상태를 현재 시각 기준으로 1초 업데이트하고 알람 조건을 확인
    func tick() {
        let now = Date()

        self.timers = self.timers.map { timer in
            guard timer.status == .running else { return timer }

            let remaining = Int(timer.endDate.timeIntervalSince(now))
            let clamped = max(remaining, 0)

            if timer.remainingSeconds != clamped, clamped == 0 { // 테스트 하는 과정에서 조건 수정
                if userSettings.isSoundOn {
                    alarmHandler.playSound(for: timer.id)
                }
                if userSettings.isVibrationOn {
                    alarmHandler.vibrate()
                }
            }

            return timer.updating(remainingSeconds: clamped)
        }
    }

    /// 매초마다 타이머 상태 업데이트 (매초마다 tick()을 반복 실행)
    func startTicking() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
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
        scheduleNotification(for: newTimer)
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
        NotificationUtils.cancelScheduledNotification(id: id.uuidString)
        
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
            
            let resumed = TimerData(
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
            scheduleNotification(for: resumed)
            return resumed
        }
    }
    
    /// 타이머를 정지 상태로 변경
    func stopTimer(id: UUID) {
        NotificationUtils.cancelScheduledNotification(id: id.uuidString)
        
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
        scheduleNotification(for: restarted)
    }
    
    /// 실행 중인 타이머 삭제 (실행중인 타이머 -> 프리셋 목록으로 이동)
    @discardableResult
    func removeTimer(id: UUID) -> TimerData? {
        NotificationUtils.cancelScheduledNotification(id: id.uuidString)
        
        guard let index = timers.firstIndex(where: { $0.id == id }) else { return nil }
        let removed = timers.remove(at: index)
        return removed
    }

    /// 남은 시간이 0인 타이머들의 알람을 모두 중지
    func stopAlarmsForExpiredTimers() {
        let expiredTimers = timers.filter { $0.remainingSeconds <= 0 }
        for timer in expiredTimers {
            alarmHandler.stopSound(for: timer.id)
        }
    }
}
