//
//  TimerManager.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 실행 중인 타이머들을 관리하는 클래스
///
/// - 사용 목적: 타이머 추가, 삭제, 상태 업데이트 등을 전역에서 관리함.

import SwiftUI
import Foundation
import Combine
import AVFoundation

final class TimerManager: ObservableObject {
    @Published var timers: [TimerData] = []
    @Published private(set) var scenePhase: ScenePhase = .active
    
    private let presetManager: PresetManager
    private let alarmHandler: AlarmTriggering
    let deleteCountdownSeconds: Int

    private var timer: Timer?
    
    // MARK: - Init

    init(presetManager: PresetManager, deleteCountdownSeconds: Int, alarmHandler: AlarmTriggering = AlarmHandler()) {
        self.presetManager = presetManager
        self.deleteCountdownSeconds = deleteCountdownSeconds
        self.alarmHandler = alarmHandler
        startTicking()
    }
    
    // MARK: - Tick 메인 루프 & 상태 업데이트
    
    /// 매초마다 타이머 상태 업데이트 (매초마다 tick()을 반복 실행)
    func startTicking() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    /// 1초마다 전체 타이머 상태 업데이트 및 자동 삭제 체크
    func tick() {
        updateTimerStates()
        cleanupTimers()
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
                let deletionTime: Date? = (scenePhase == .active)
                    ? Date().addingTimeInterval(TimeInterval(deleteCountdownSeconds))
                    : nil
                let completedTimer = timer.updating(
                    remainingSeconds: clamped,
                    status: .completed,
                    pendingDeletionAt: deletionTime
                )
                if scenePhase == .active {
                    handleTimerCompletion(completedTimer)
                }
                return completedTimer
            }
            return timer.updating(remainingSeconds: clamped)
        }
    }
    
    /// 삭제 예정 시간이 지난 모든 타이머를 일괄 삭제
    func cleanupTimers() {
        let now = Date()
        timers.removeAll {
            if let pending = $0.pendingDeletionAt {
                return now >= pending
            }
            return false
        }
    }
    
    // MARK: - CRUD (타이머 생성, 실행, 삭제, 프리셋 전환)
    
    /// 새 타이머 추가 ( 사용자 입력 기반 )
    func addTimer(label: String, hours: Int, minutes: Int, seconds: Int, isSoundOn: Bool, isVibrationOn: Bool, presetId: UUID? = nil, isFavorite: Bool = false) {
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
            status: .running,
            pendingDeletionAt: nil,
            presetId: presetId,
            isFavorite: isFavorite
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
    
    /// 타이머 로컬 알림 예약
    private func scheduleNotification(for timer: TimerData) {
        let interval = max(1, timer.endDate.timeIntervalSince(Date()))
        NotificationUtils.scheduleNotification(
            id: timer.id.uuidString,
            label: timer.label,
            after: Int(interval)
        )
    }
    
    /// 새 타이머 추가 + 프리셋 숨김 처리
    func runTimer(from preset: TimerPreset, presetManager: PresetManager) {
        addTimer(
            label: preset.label,
            hours: preset.hours,
            minutes: preset.minutes,
            seconds: preset.seconds,
            isSoundOn: preset.isSoundOn,
            isVibrationOn: preset.isVibrationOn,
            presetId: preset.id,
            isFavorite: true
        )
        presetManager.hidePreset(withId: preset.id)
    }

    /// 새 타이머 추가 ( 프리셋 기반 )
    func addTimer(from preset: TimerPreset) {
        addTimer(
            label: preset.label,
            hours: preset.hours,
            minutes: preset.minutes,
            seconds: preset.seconds,
            isSoundOn: preset.isSoundOn,
            isVibrationOn: preset.isVibrationOn,
            presetId: preset.id,
            isFavorite: true
        )
    }
    
    /// 타이머 삭제
    @discardableResult
    func removeTimer(id: UUID) -> TimerData? {
        NotificationUtils.cancelScheduledNotification(id: id.uuidString)
        
        guard let index = timers.firstIndex(where: { $0.id == id }) else { return nil }
        let removed = timers.remove(at: index)
        return removed
    }
    
    /// 타이머를 프리셋으로 전환 (실행중 타이머 삭제 + 프리셋 추가)
    func convertTimerToPreset(timerId: UUID) {
        if let timer = removeTimer(id: timerId) {
            presetManager.addPreset(from: timer)
        }
    }
    
    // MARK: - 타이머 상태 제어
    
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
            status: .running,
            pendingDeletionAt: .some(nil)
        )
        
        timers[index] = restarted
        scheduleNotification(for: restarted)
    }
    
    // MARK: - 즐겨찾기 (isFavorite)

    /// 실행 중인 타이머의 isFavorite 값을 토글
    func toggleFavorite(for id: UUID) {
        timers = timers.map { timer in
            guard timer.id == id else { return timer }
            return timer.updating(isFavorite: !timer.isFavorite)
        }
    }

    /// 실행 중인 타이머의 isFavorite 값을 특정 값으로 설정
    func setFavorite(for id: UUID, to value: Bool) {
        timers = timers.map { timer in
            guard timer.id == id else { return timer }
            return timer.updating(isFavorite: value)
        }
    }

    // MARK: - 완료/삭제 관련 유틸
    
    /// (inactive/background에서 완료된) 아직 삭제 예약이 안 된 타이머에 pendingDeletionAt을 세팅
    /// - 사용 목적: 앱이 포그라운드(.active)로 돌아올 때, 타이머에 삭제 카운트다운 시작
    /// - onMarked: 방금 예약된 타이머만 콜백으로 전달
    func markCompletedTimersForDeletion(
        n: Int,
        onMarked: ((TimerData) -> Void)? = nil
    ) {
        let now = Date()
        for i in timers.indices {
            if timers[i].status == .completed && timers[i].pendingDeletionAt == nil {
                timers[i].pendingDeletionAt = now.addingTimeInterval(TimeInterval(n))
                onMarked?(timers[i])
            }
        }
    }
    
    /// 타이머 완료 시, 상태 별 분기 처리
    func handleTimerCompletion(_ timer: TimerData) {
        let n = self.deleteCountdownSeconds

        if timer.presetId == nil {
            // 즉석 타이머
            if timer.isFavorite {
                scheduleAfter(seconds: n) { [weak self] in
                    guard let self else { return }
                    withAnimation(.spring()) {
                        self.presetManager.addPreset(from: timer)
                        self.removeTimer(id: timer.id)
                    }
                }
            } else {
                scheduleAfter(seconds: n) { [weak self] in
                    guard let self else { return }
                    self.removeTimer(id: timer.id)
                }
            }
        } else {
            // 프리셋 기반
            if timer.isFavorite {
                scheduleAfter(seconds: n) { [weak self] in
                    guard let self else { return }
                    withAnimation(.spring()) {
                        if let presetId = timer.presetId {
                            self.presetManager.showPreset(withId: presetId)
                        }
                        self.removeTimer(id: timer.id)
                    }
                }
            } else {
                // 프리셋 기반인데 isFavorite: false (= 실행 중에 즐겨찾기 해제)
                if let presetId = timer.presetId {
                    presetManager.hidePreset(withId: presetId)
                }
                scheduleAfter(seconds: n) { [weak self] in
                    guard let self else { return }
                    self.removeTimer(id: timer.id)
                }
            }
        }
    }
    
    /// 남은 시간이 0인 타이머들의 알람을 모두 중지
    func stopAlarmsForExpiredTimers() {
        let expiredTimers = timers.filter { $0.remainingSeconds <= 0 }
        for timer in expiredTimers {
            alarmHandler.stopSound(for: timer.id)
        }
    }
    
    // MARK: - Scene 관리
    
    /// ScenePhase(.active/.inactive/.background 등) 상태 업데이트
    func updateScenePhase(_ phase: ScenePhase) {
        self.scenePhase = phase
    }
}
