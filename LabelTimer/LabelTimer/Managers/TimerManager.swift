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
    private let alarmHandler: AlarmTriggering

    private var timer: Timer?
    
    init(presetManager: PresetManager, alarmHandler: AlarmTriggering = AlarmHandler()) {
        self.presetManager = presetManager
        self.alarmHandler = alarmHandler
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

    /// 1초마다 전체 타이머 상태 업데이트 및 자동 삭제 체크
    func tick() {
        updateTimerStates()
        removeExpiredTimers()
    }
        
    /// 모든 실행 중 타이머의 남은 시간을 1초 단위로 갱신 & 알람 조건 확인
    private func updateTimerStates() {
        let now = Date()
        self.timers = self.timers.map { timer in
            guard timer.status == .running else { return timer }
            let remaining = Int(timer.endDate.timeIntervalSince(now))
            let clamped = max(remaining, 0)
            if timer.remainingSeconds != clamped, clamped == 0 {
                alarmHandler.playIfNeeded(for: timer)
            }
            return timer.updating(remainingSeconds: clamped)
        }
    }
    
    /// 60초 이상 지난 완료 타이머를 자동 삭제 및 프리셋으로 변환
    private func removeExpiredTimers() {
        let now = Date()
        let expiredTimers = timers.filter { timer in
            timer.status == .completed &&
            timer.completedAt != nil &&
            now.timeIntervalSince(timer.completedAt!) >= 60
        }
        for timer in expiredTimers {
            _ = removeTimer(id: timer.id)
            presetManager.addPreset(from: timer)
            // [추가] 필요시 알림 로그 남기기
            print("[AUTO REMOVE] 타이머 \(timer.label) 종료 후 60초 경과 → 삭제 및 프리셋 전환")
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
    
    /// 새 타이머 추가 ( 사용자 입력 기반 )
    func addTimer(label: String, hours: Int, minutes: Int, seconds: Int, isSoundOn: Bool, isVibrationOn: Bool) {
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
            isSoundOn: isSoundOn,
            isVibrationOn: isVibrationOn,
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
    
    /// 새 타이머 추가 ( 프리셋 기반 )
    func addTimer(from preset: TimerPreset) {
        addTimer(
            label: preset.label,
            hours: preset.hours,
            minutes: preset.minutes,
            seconds: preset.seconds,
            isSoundOn: preset.isSoundOn,
            isVibrationOn: preset.isVibrationOn
        )
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
            
            let resumed = timer.updating(
                endDate: newEnd,
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
            
            return timer.updating(
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
        
        let restarted = old.updating(
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
