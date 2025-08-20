//
//  TimerService.swift
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
@MainActor
protocol TimerServiceProtocol: ObservableObject {
    var didStart: PassthroughSubject<Void, Never> { get }

    func getTimer(byId id: UUID) -> TimerData?
    func addTimer(label: String, hours: Int, minutes: Int, seconds: Int, isSoundOn: Bool, isVibrationOn: Bool, presetId: UUID?, isFavorite: Bool)
    func runTimer(from preset: TimerPreset)
    @discardableResult
    func removeTimer(id: UUID) -> TimerData?
    func convertTimerToPreset(timerId: UUID)
    
    func pauseTimer(id: UUID)
    func resumeTimer(id: UUID)
    func stopTimer(id: UUID)
    func restartTimer(id: UUID)

    func toggleFavorite(for id: UUID)
    func setFavorite(for id: UUID, to value: Bool)
    
    func userDidConfirmCompletion(for timerId: UUID)
    func userDidRequestDelete(for timerId: UUID)

    func updateScenePhase(_ phase: ScenePhase)
}

// MARK: - TimerService Class
@MainActor
final class TimerService: ObservableObject, TimerServiceProtocol {
    private let timerRepository: TimerRepositoryProtocol
    private let presetRepository: PresetRepositoryProtocol
    private let alarmHandler: AlarmTriggering

    @Published private(set) var scenePhase: ScenePhase = .active

    let deleteCountdownSeconds: Int
    private let repeatingNotificationInterval: TimeInterval = 4.0
    private let repeatingNotificationCount = 60  // iOS 최대 64개
    
    let didStart = PassthroughSubject<Void, Never>()

    // --- 완료 로직을 전담할 Handler ---
    private lazy var completionHandler: TimerCompletionHandler = {
        let handler = TimerCompletionHandler(
            timerService: self,
            presetRepository: self.presetRepository
        )
        handler.onComplete = { [weak self] timerId in
            guard var timerToUpdate = self?.timerRepository.getTimer(byId: timerId) else { return }
            
            timerToUpdate.pendingDeletionAt = nil
            self?.timerRepository.updateTimer(timerToUpdate)
        }
        return handler
    }()
    
    private var timer: Timer?

    init(timerRepository: TimerRepositoryProtocol, presetRepository: PresetRepositoryProtocol, deleteCountdownSeconds: Int, alarmHandler: AlarmTriggering = AlarmHandler()) {
        self.timerRepository = timerRepository
        self.presetRepository = presetRepository
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

    /// 실행 중인 타이머들의 남은 시간 매초 갱신 (신버전)
    private func updateTimerStates() {
        let now = Date()
        for var timer in timerRepository.getAllTimers() {
            guard timer.status == .running else { continue }

            let remaining = max(0, Int(timer.endDate.timeIntervalSince(now)))

            if timer.remainingSeconds != remaining {
                timer.remainingSeconds = remaining

                if remaining == 0 {
                    // 완료 처리: 여기서 '한 번만' 업데이트되게 분기 정리
                    var completed = timer
                    completed.status = .completed
                    timerRepository.updateTimer(completed)
                    
                    if scenePhase == .active {
                        startCompletionProcess(for: completed)
                    }
                    continue // 아래의 일반 updateTimer(timer)로 내려가지 않게!
                }
                timerRepository.updateTimer(timer)
            }
        }
    }

    // MARK: - Completion Handling
    
    /// 타이머가 완료되었을 때, Handler에게 작업을 위임하는 "핸드오프" 함수
    private func startCompletionProcess(for timer: TimerData) {
        guard timer.pendingDeletionAt == nil else { return }
        
        var mutableTimer = timer
        let deadline = Date().addingTimeInterval(TimeInterval(deleteCountdownSeconds))
        mutableTimer.pendingDeletionAt = deadline
        
        timerRepository.updateTimer(mutableTimer)
        completionHandler.scheduleCompletion(for: mutableTimer, after: deleteCountdownSeconds)
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
        return timerRepository.getTimer(byId: id)
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
        timerRepository.addTimer(newTimer)
        scheduleRepeatingNotification(for: newTimer)
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
        presetRepository.updateLastUsed(for: preset.id)
        presetRepository.hidePreset(withId: preset.id)
        didStart.send()
    }
    
    @discardableResult
    func removeTimer(id: UUID) -> TimerData? {
        completionHandler.cancelPendingAction(for: id)
        NotificationUtils.cancelNotifications(withPrefix: id.uuidString)
        alarmHandler.stop(for: id)
        
        return timerRepository.removeTimer(byId: id)
    }
    
    func convertTimerToPreset(timerId: UUID) {
        if let timer = removeTimer(id: timerId) {
            presetRepository.addPreset(from: timer)
        }
    }

    // MARK: - 타이머 상태 제어
    
    func pauseTimer(id: UUID) {
        guard var timer = timerRepository.getTimer(byId: id), timer.status == .running else { return }
        NotificationUtils.cancelNotifications(withPrefix: id.uuidString)
        
        timer.status = .paused
        timerRepository.updateTimer(timer)
    }
    
    func resumeTimer(id: UUID) {
        guard var timer = timerRepository.getTimer(byId: id), timer.status == .paused else { return }
        
        let now = Date()
        timer.endDate = now.addingTimeInterval(TimeInterval(timer.remainingSeconds))
        timer.status = .running
        timerRepository.updateTimer(timer)
        scheduleRepeatingNotification(for: timer)
    }
    
    func stopTimer(id: UUID) {
        completionHandler.cancelPendingAction(for: id)
        NotificationUtils.cancelNotifications(withPrefix: id.uuidString)
        alarmHandler.stop(for: id)

        guard let oldTimer = timerRepository.getTimer(byId: id) else { return }
        
        let updatedTimer = oldTimer.updating(
            endDate: Date().addingTimeInterval(TimeInterval(oldTimer.totalSeconds)),
            remainingSeconds: oldTimer.totalSeconds,
            status: .stopped,
            pendingDeletionAt: .some(nil)
        )
        timerRepository.updateTimer(updatedTimer)
    }
    
    func restartTimer(id: UUID) {
        completionHandler.cancelPendingAction(for: id)
        
        guard let oldTimer = timerRepository.getTimer(byId: id) else { return }
        
        let updatedTimer = oldTimer.updating(
            endDate: Date().addingTimeInterval(TimeInterval(oldTimer.totalSeconds)),
            remainingSeconds: oldTimer.totalSeconds,
            status: .running,
            pendingDeletionAt: .some(nil)
        )
        timerRepository.updateTimer(updatedTimer)
        scheduleRepeatingNotification(for: updatedTimer)
    }

    // MARK: - 즐겨찾기 (isFavorite)

    func toggleFavorite(for id: UUID) {
        guard var timer = timerRepository.getTimer(byId: id) else { return }
        timer.isFavorite.toggle()
        timerRepository.updateTimer(timer)
    }
    
    func setFavorite(for id: UUID, to value: Bool) {
        guard var timer = timerRepository.getTimer(byId: id) else { return }
        timer.isFavorite = value
        timerRepository.updateTimer(timer)
    }

    // MARK: - Scene 관리
    
    func updateScenePhase(_ phase: ScenePhase) {
        self.scenePhase = phase
        
        guard phase == .active else { return }

        let allTimers = timerRepository.getAllTimers()
        let completedTimers = allTimers.filter { $0.status == .completed }

        guard !completedTimers.isEmpty else { return }
        
        for timer in completedTimers {
            alarmHandler.stop(for: timer.id)
            NotificationUtils.cancelNotifications(withPrefix: timer.id.uuidString)
            
            if timer.pendingDeletionAt == nil {
                startCompletionProcess(for: timer)
            }
        }
    }

    // MARK: - Private Helpers
    
    /// 사용자가 라벨을 입력하지 않았을 때 "타이머N" 형식의 고유한 라벨 생성 (오름차순)
    private func generateAutoLabel() -> String {
        let existingLabels = timerRepository.getAllTimers().map(\.label) + presetRepository.allPresets.map(\.label)
        var index = 1
        while true {
            let candidate = "타이머\(index)"
            if !existingLabels.contains(candidate) {
                return candidate
            }
            index += 1
        }
    }
    
    /// 연속 로컬 알림 예약
    private func scheduleRepeatingNotification(for timer: TimerData) {
        // 타이머의 소리/진동 설정에 따라 알림 정책(AlarmSoundType)을 결정
        var soundType: AlarmSoundType
        if timer.isSoundOn {
           soundType = .defaultRingtone
        } else {
           if timer.isVibrationOn {
               soundType = .silentVibration
           } else {
               soundType = .silentNone
           }
        }

        // 정책에 맞는 UNNotificationSound 객체 생성
        let sound = NotificationUtils.createSound(from: soundType)

        let minimumStartDate = Date().addingTimeInterval(2)
        let effectiveEndDate = max(timer.endDate, minimumStartDate)

        // TimerService가 직접 반복문을 실행하여 단일 알림을 여러 개 예약
        for i in 0..<repeatingNotificationCount {
            let interval = effectiveEndDate.timeIntervalSinceNow + (Double(i) * repeatingNotificationInterval)

            guard interval > 0 else { continue }

            let title = "⏰ 타이머 종료"
            let body = timer.label.isEmpty ? "설정한 시간이 다 되었습니다." : timer.label

            // 단일 알림 예약 함수를 반복 호출
            NotificationUtils.scheduleNotification(
               id: "\(timer.id.uuidString)_\(i)",
               title: title,
               body: body,
               sound: sound,
               interval: interval
            )
        }
    }
}
