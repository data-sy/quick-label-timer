//
//  TimerService.swift
//  QuickLabelTimer
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
import UserNotifications

// MARK: - Protocol Definition
@MainActor
protocol TimerServiceProtocol: ObservableObject {
    var didStart: PassthroughSubject<Void, Never> { get }

    // MARK: - CRUD
    func getTimer(byId id: UUID) -> TimerData?
    func addTimer(label: String, hours: Int, minutes: Int, seconds: Int, isSoundOn: Bool, isVibrationOn: Bool, presetId: UUID?,  endAction: TimerEndAction) -> Bool
    func runTimer(from preset: TimerPreset) -> Bool
    @discardableResult
    func removeTimer(id: UUID) -> TimerData?
    
    // MARK: - Timer Controls
    func pauseTimer(id: UUID)
    func resumeTimer(id: UUID)
    func stopTimer(id: UUID)
    func restartTimer(id: UUID)

    // MARK: - Favorite
    @discardableResult
    func toggleFavorite(for id: UUID) -> Bool
    
    // MARK: - Completion Handling
    func userDidConfirmCompletion(for timerId: UUID)
    func userDidRequestDelete(for timerId: UUID)

    // MARK: - App Lifecycle
    func updateScenePhase(_ phase: ScenePhase)
    
    // MARK: - Notification Scheduling
    func scheduleNotification(for timer: TimerData)
    func scheduleRepeatingNotifications(baseId: String, title: String, body: String, sound: UNNotificationSound?, endDate: Date, repeatingInterval: TimeInterval)
    func stopTimerNotifications(for baseId: String)
}

// MARK: - TimerService Class
@MainActor
final class TimerService: ObservableObject, TimerServiceProtocol {
    private let timerRepository: TimerRepositoryProtocol
    private let presetRepository: PresetRepositoryProtocol

    @Published private(set) var scenePhase: ScenePhase = .active

    let deleteCountdownSeconds: Int
    private let repeatingNotificationCount = 60  // iOS pending limit 64 고려, 여유 4
    private let defaultRepeatingInterval: TimeInterval = 2.0 // 연속 알림 반복 간격
    
    let didStart = PassthroughSubject<Void, Never>()
    
    private var lastActivationCleanupAt: Date = .distantPast
    private let activationCleanupThrottle: TimeInterval = 0.8 // 연속 활성화 디바운스
    private let activationGraceWindow: TimeInterval = 0.5

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

    init(timerRepository: TimerRepositoryProtocol, presetRepository: PresetRepositoryProtocol, deleteCountdownSeconds: Int) {
        self.timerRepository = timerRepository
        self.presetRepository = presetRepository
        self.deleteCountdownSeconds = deleteCountdownSeconds
        reconcileTimersOnLaunch()
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
        completionHandler.handleCompletionImmediately(timerId: timerId)
    }

    func userDidRequestDelete(for timerId: UUID) {
        completionHandler.handleCompletionImmediately(timerId: timerId)
    }

    // MARK: - CRUD
    
    func getTimer(byId id: UUID) -> TimerData? {
        return timerRepository.getTimer(byId: id)
    }

    @discardableResult
    func addTimer(label: String, hours: Int, minutes: Int, seconds: Int, isSoundOn: Bool, isVibrationOn: Bool, presetId: UUID? = nil, endAction: TimerEndAction = .discard) -> Bool  {
        guard timerRepository.getAllTimers().count < 10 else {
            print("실행 가능한 타이머 개수(10개) 초과")
            return false
        }
        
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
            endAction: endAction
        )
        timerRepository.addTimer(newTimer)
        scheduleNotification(for: newTimer)
        return true
    }
    
    @discardableResult
    func runTimer(from preset: TimerPreset) -> Bool {
        guard presetRepository.getPreset(byId: preset.id) != nil else {
            print("존재하지 않는 프리셋으로는 타이머를 실행할 수 없습니다.")
            return false
        }
        
        let success = addTimer(
            label: preset.label,
            hours: preset.hours,
            minutes: preset.minutes,
            seconds: preset.seconds,
            isSoundOn: preset.isSoundOn,
            isVibrationOn: preset.isVibrationOn,
            presetId: preset.id,
            endAction: .preserve
        )
        if success {
            presetRepository.updateLastUsed(for: preset.id)
            didStart.send()
        }
        return success
    }
    
    @discardableResult
    func removeTimer(id: UUID) -> TimerData? {
        completionHandler.cancelPendingAction(for: id)
        NotificationUtils.cancelNotifications(withPrefix: id.uuidString)
        
        return timerRepository.removeTimer(byId: id)
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
        scheduleNotification(for: timer)
    }
    
    func stopTimer(id: UUID) {
        completionHandler.cancelPendingAction(for: id)
        NotificationUtils.cancelNotifications(withPrefix: id.uuidString)

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
        scheduleNotification(for: updatedTimer)
    }

    // MARK: - 즐겨찾기 (endAction)

    @discardableResult
    func toggleFavorite(for id: UUID) -> Bool {
        guard var timer = timerRepository.getTimer(byId: id) else { return false }

        switch timer.endAction {
        case .discard:
            // 즐겨찾기를 '추가'하려는 경우, '총 잠재적 프리셋 개수' 확인
            let visiblePresetCount = presetRepository.visiblePresetsCount
            let pendingPresetCount = timerRepository.preservingInstantTimersCount // 저장될 예정인 즉석 타이머 개수
            guard (visiblePresetCount + pendingPresetCount) < 20 else { return false }
            timer.endAction = .preserve
        case .preserve:
            timer.endAction = .discard
        }
        timerRepository.updateTimer(timer)
        return true
    }

    // MARK: - Scene 관리
    
    func updateScenePhase(_ phase: ScenePhase) {
        self.scenePhase = phase
        guard phase == .active else { return }
        
        #if DEBUG
        NotiLog.logDelivered("scene.active")
        #endif

        guard shouldRunActivationCleanup() else { return }

        let now = Date()
        let candidates = collectCleanupCandidates(now: now)
        guard !candidates.isEmpty else { return }

        runActivationCleanup(for: candidates) { [weak self] in
            self?.finalizeCompletedTimers(candidates)
        }
    }
    
    // MARK: - Notification Scheduling
    
    // 로컬 알림 예약 (고수준)
    func scheduleNotification(for timer: TimerData) {
        let policy = AlarmNotificationPolicy.determine(soundOn: timer.isSoundOn, vibrationOn: timer.isVibrationOn)
        let sound = NotificationUtils.createSound(fromPolicy: policy)
        let title = timer.label.isEmpty ? "타이머 완료" : timer.label
        let body = "눌러서 알람 끄기"
        
        scheduleRepeatingNotifications(
            baseId: timer.id.uuidString,
            title: title,
            body: body,
            sound: sound,
            endDate: timer.endDate,
            repeatingInterval: defaultRepeatingInterval
        )
    }
    
    /// 연속 로컬 알림 예약 (저수준)
    func scheduleRepeatingNotifications(baseId: String, title: String, body: String, sound: UNNotificationSound?, endDate: Date, repeatingInterval: TimeInterval) {
        let minimumStartDate = Date().addingTimeInterval(2)
        let effectiveEndDate = max(endDate, minimumStartDate)
        
        for i in 0..<repeatingNotificationCount {
            let interval = effectiveEndDate.timeIntervalSinceNow + (Double(i) * repeatingInterval)
            
            guard interval > 0 else { continue }
            
            let clockCount = (i % 5) + 1
            let clocks = String(repeating: "⏰", count: clockCount)
            let dynamicBody = "\(body) \(clocks)"

            let userInfo: [AnyHashable: Any] = [
                "baseIdentifier": baseId,
                "index": i
            ]
            
            NotificationUtils.scheduleNotification(
                id: "\(baseId)_\(i)",
                title: title,
                body: dynamicBody,
                sound: sound,
                interval: interval,
                userInfo: userInfo,
                threadIdentifier: baseId
            )
        }
    }
    
    /// 특정 타이머와 연결된 모든 예정/도착된 알림을 중단(취소)
    func stopTimerNotifications(for baseId: String) {
        #if DEBUG
        print("🛑 Stopping all notifications for timer with baseId: \(baseId)")
        #endif
        NotificationUtils.cancelNotifications(withPrefix: baseId)
    }
    
    // MARK: - Private Helpers
    
    private func reconcileTimersOnLaunch() {
        let now = Date()
        for timer in timerRepository.getAllTimers() {
            
            switch timer.status {
            
            case .running:
                let remaining = Int(timer.endDate.timeIntervalSince(now))
                if remaining <= 0 {
                    let completedTimer = timer.updating(remainingSeconds: 0, status: .completed)
                    timerRepository.updateTimer(completedTimer)
                    startCompletionProcess(for: completedTimer)
                } else {
                    let updatedTimer = timer.updating(remainingSeconds: remaining)
                    timerRepository.updateTimer(updatedTimer)
                }

            case .completed:
                let elapsedTime = now.timeIntervalSince(timer.endDate)
                if elapsedTime > TimeInterval(deleteCountdownSeconds) {
                    completionHandler.handleCompletionImmediately(timerId: timer.id)
                }
            
            // .paused, .stopped 상태는 보정할 필요 없으므로 default에서 처리
            default:
                continue
            }
        }
    }
    
    /// 사용자가 라벨을 입력하지 않았을 때 "타이머N" 형식의 고유한 라벨 생성 (오름차순)
    private func generateAutoLabel() -> String {
        let existingLabels = Set(timerRepository.getAllTimers().map(\.label) + presetRepository.allPresets.map(\.label))
        var index = 1
        while true {
            let candidate = "타이머\(index)"
            if !existingLabels.contains(candidate) {
                return candidate
            }
            index += 1
        }
    }
    
    /// 연속 활성화 시 과도 호출을 방지하는 디바운스
    private func shouldRunActivationCleanup() -> Bool {
        let now = Date()
        guard now.timeIntervalSince(lastActivationCleanupAt) > activationCleanupThrottle else {
            #if DEBUG
            print("[LNGuard] Skipped activation cleanup due to throttle")
            #endif
            return false
        }
        lastActivationCleanupAt = now
        return true
    }

    /// 정리 대상 타이머 수집 (완료 상태 or 사실상 종료 시각을 지난 타이머)
    private func collectCleanupCandidates(now: Date) -> [TimerData] {
        let allTimers = timerRepository.getAllTimers()
        let candidates = allTimers.filter { timer in
            switch timer.status {
            case .completed:
                return true
            case .running, .paused:
                return timer.endDate <= now.addingTimeInterval(activationGraceWindow)
            default:
                return false
            }
        }

        #if DEBUG
        if candidates.isEmpty {
            print("[LNGuard] Activation candidates count=0")
        } else {
            let ids = candidates.map { $0.id.uuidString }
            print("[LNGuard] Activation candidates count=\(candidates.count) ids=\(ids)")
        }
        #endif

        return candidates
    }

    /// 알림 체인 중단 및 사운드 정지
    private func runActivationCleanup(for timers: [TimerData], completion: @escaping () -> Void) {
        let baseIds = Set(timers.map { $0.id.uuidString })
        guard !baseIds.isEmpty else { completion(); return }

        let group = DispatchGroup()

        // 알림 정리
        for baseId in baseIds {
            group.enter()
            NotificationUtils.cancelNotifications(withPrefix: baseId) {
                #if DEBUG
                print("[LNGuard] cleaned notifications for \(baseId)")
                #endif
                group.leave()
            }
        }
        group.notify(queue: .main) { completion() }
    }

    /// 완료 처리 루틴 진입
    private func finalizeCompletedTimers(_ timers: [TimerData]) {
        for timer in timers {
            guard timer.pendingDeletionAt == nil else { continue }
            startCompletionProcess(for: timer)
        }
    }
}
