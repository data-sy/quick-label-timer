//
//  TimerManager.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 실행 중인 타이머들을 관리하는 클래스
///
/// - 사용 목적: 타이머 추가, 삭제, 상태 변경 등을 전역에서 관리함

import SwiftUI
import Foundation
import Combine
import AVFoundation

// MARK: - Protocol Definition
/// 다른 객체가 이 프로토콜에 의존하게 만들어, 코드의 유연성과 테스트 용이성을 높임
protocol TimerManagerProtocol {
    func getTimer(byId id: UUID) -> TimerData?
    
    @discardableResult
    func removeTimer(id: UUID) -> TimerData?
}

// MARK: - TimerManager Class
final class TimerManager: ObservableObject, TimerManagerProtocol {
    @Published var timers: [TimerData] = []
    @Published private(set) var scenePhase: ScenePhase = .active
    
    private let presetManager: PresetManagerProtocol
    private let alarmHandler: AlarmTriggering
    let deleteCountdownSeconds: Int
    let didStart = PassthroughSubject<Void, Never>()

    // --- 완료 로직을 전담할 Handler ---
    private lazy var completionHandler: TimerCompletionHandler = {
        let handler = TimerCompletionHandler(timerManager: self, presetManager: self.presetManager)
        
        handler.onTick = { [weak self] _ in
            self?.objectWillChange.send()
        }
        
        handler.onComplete = { [weak self] timerId in
            if let index = self?.timers.firstIndex(where: { $0.id == timerId }) {
                self?.timers[index].pendingDeletionAt = nil
            }
        }
        return handler
    }()
    
    private var timer: Timer?
    
    init(presetManager: PresetManagerProtocol, deleteCountdownSeconds: Int, alarmHandler: AlarmTriggering = AlarmHandler()) {
        self.presetManager = presetManager
        self.deleteCountdownSeconds = deleteCountdownSeconds
        self.alarmHandler = alarmHandler
        startTicking()
    }
    
    // MARK: - Tick 메인 루프 & 상태 업데이트
    func startTicking() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func tick() {
        updateTimerStates()
    }
    
    /// 실행 중인 타이머들의 남은 시간 매초 갱신
    private func updateTimerStates() {
        let now = Date()
        for index in timers.indices {
            guard timers[index].status == .running else { continue }
            
            let remaining = max(0, Int(timers[index].endDate.timeIntervalSince(now)))
            
            if timers[index].remainingSeconds != remaining {
                timers[index].remainingSeconds = remaining
                
                if remaining == 0 {
                    timers[index].status = .completed
                    alarmHandler.playIfNeeded(for: timers[index])
                    
                    if scenePhase == .active {
                        startCompletionProcess(for: timers[index])
                    }
                }
            }
        }
    }
    
    // MARK: - Completion Handling
    
    /// 타이머가 완료되었을 때, Handler에게 작업을 위임하는 "핸드오프" 함수
    private func startCompletionProcess(for timer: TimerData) {
        guard let index = timers.firstIndex(where: { $0.id == timer.id }) else { return }
        
        timers[index].pendingDeletionAt = Date().addingTimeInterval(TimeInterval(deleteCountdownSeconds))
                
        completionHandler.scheduleCompletion(for: timers[index], after: deleteCountdownSeconds)
    }
    
    // MARK: - User Actions (UI에서 호출할 함수들)
    // TODO: 추후 RunningListViewModel 리팩토링 시, 완료 상태의 타이머 버튼 액션을 이 함수로 연결
            // Handler를 통해 '최신' 데이터를 기준으로 액션을 처리하여 데이터 정합성을 보장
    func userDidConfirmCompletion(for timerId: UUID) {
        completionHandler.forceHandle(timerId: timerId)
    }

    func userDidRequestDelete(for timerId: UUID) {
        completionHandler.forceHandle(timerId: timerId)
    }
    
    // MARK: - CRUD
    
    func getTimer(byId id: UUID) -> TimerData? {
        return timers.first { $0.id == id }
    }

    func addTimer(label: String, hours: Int, minutes: Int, seconds: Int, isSoundOn: Bool, isVibrationOn: Bool, presetId: UUID? = nil, isFavorite: Bool = false) {
        let newTimer = TimerData(
            label: label.isEmpty ? generateAutoLabel() : label,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            isSoundOn: isSoundOn,
            isVibrationOn: isVibrationOn,
            createdAt: Date(),
            endDate: Date().addingTimeInterval(TimeInterval(hours * 3600 + minutes * 60 + seconds)),
            remainingSeconds: hours * 3600 + minutes * 60 + seconds,
            status: .running,
            presetId: presetId,
            isFavorite: isFavorite
        )
        timers.append(newTimer)
        scheduleNotification(for: newTimer)
    }
    
    func runTimer(from preset: TimerPreset) {
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
        presetManager.updateLastUsed(for: preset.id)
        presetManager.hidePreset(withId: preset.id)
        didStart.send()
    }
    
    @discardableResult
    func removeTimer(id: UUID) -> TimerData? {
        completionHandler.cancelPendingAction(for: id)
        NotificationUtils.cancelScheduledNotification(id: id.uuidString)
        
        alarmHandler.stopSound(for: id)
        
        guard let index = timers.firstIndex(where: { $0.id == id }) else { return nil }
        return timers.remove(at: index)
    }
    
    func convertTimerToPreset(timerId: UUID) {
        if let timer = removeTimer(id: timerId) {
            presetManager.addPreset(from: timer)
        }
    }
    
    // MARK: - 타이머 상태 제어
    
    func pauseTimer(id: UUID) {
        guard let index = timers.firstIndex(where: { $0.id == id }), timers[index].status == .running else { return }
        NotificationUtils.cancelScheduledNotification(id: id.uuidString)
                
        timers[index].status = .paused
    }
    
    func resumeTimer(id: UUID) {
        guard let index = timers.firstIndex(where: { $0.id == id }), timers[index].status == .paused else { return }
        
        let now = Date()
        timers[index].endDate = now.addingTimeInterval(TimeInterval(timers[index].remainingSeconds))
        timers[index].status = .running
        scheduleNotification(for: timers[index])
    }
    
    func stopTimer(id: UUID) {
        completionHandler.cancelPendingAction(for: id)
        NotificationUtils.cancelScheduledNotification(id: id.uuidString)
        
        alarmHandler.stopSound(for: id)

        guard let index = timers.firstIndex(where: { $0.id == id }) else { return }
        
        let old = timers[index]
        timers[index] = old.updating(
            endDate: Date().addingTimeInterval(TimeInterval(old.totalSeconds)),
            remainingSeconds: old.totalSeconds,
            status: .stopped,
            pendingDeletionAt: .some(nil)
        )
    }
    
    func restartTimer(id: UUID) {
        completionHandler.cancelPendingAction(for: id)
        
        guard let index = timers.firstIndex(where: { $0.id == id }) else { return }
        
        let old = timers[index]
        timers[index] = old.updating(
            endDate: Date().addingTimeInterval(TimeInterval(old.totalSeconds)),
            remainingSeconds: old.totalSeconds,
            status: .running,
            pendingDeletionAt: .some(nil)
        )
        scheduleNotification(for: timers[index])
    }
    
    // MARK: - 즐겨찾기 (isFavorite)

    func toggleFavorite(for id: UUID) {
        guard let index = timers.firstIndex(where: { $0.id == id }) else { return }
        timers[index].isFavorite.toggle()
    }
    
    func setFavorite(for id: UUID, to value: Bool) {
        guard let index = timers.firstIndex(where: { $0.id == id }) else { return }
        timers[index].isFavorite = value
    }

    // MARK: - Scene 관리
    
    func updateScenePhase(_ phase: ScenePhase) {
        self.scenePhase = phase
        if phase == .active {
            alarmHandler.stopAllSounds()
            markCompletedTimersForDeletion(n: deleteCountdownSeconds) { [weak self] markedTimer in
                self?.startCompletionProcess(for: markedTimer)
            }
        }
    }
    
    
    private func markCompletedTimersForDeletion(n: Int, onMarked: ((TimerData) -> Void)? = nil) {
        let now = Date()
        for i in timers.indices {
            if timers[i].status == .completed && timers[i].pendingDeletionAt == nil {
                timers[i].pendingDeletionAt = now.addingTimeInterval(TimeInterval(n))
                onMarked?(timers[i])
            }
        }
    }
    
    // MARK: - Private Helpers
    
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
    
    private func scheduleNotification(for timer: TimerData) {
        let interval = max(1, timer.endDate.timeIntervalSince(Date()))
        NotificationUtils.scheduleNotification(
            id: timer.id.uuidString,
            label: timer.label,
            after: Int(interval)
        )
    }
}
