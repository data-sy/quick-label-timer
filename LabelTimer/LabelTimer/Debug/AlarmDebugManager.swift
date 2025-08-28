//
//  AlarmDebugManager.swift
//  LabelTimer
//
//  Created by 이소연 on 8/20/25.
//
/// 알림 기능 테스트 시나리오를 실행하고 관리하는 유틸리티
///
/// - 사용 목적: 다양한 조건의 로컬 알림을 생성하고 검증하기 위한 테스트 로직 모음

import Foundation
import UserNotifications


@MainActor
enum AlarmDebugManager {
    
    private static let testPrefix = "debug-"
    private static let soundTestInterval: TimeInterval = 20.0 
    
    static var timerService: TimerServiceProtocol!
    
    // MARK: - 0. 유틸리티 기능
    
    static func requestAuth() {
        NotificationUtils.requestAuthorization()
    }
    
    static func clearAllTestNotifications() {
        NotificationUtils.cancelNotifications(withPrefix: testPrefix)
    }
    
    static func dumpSettings() async {
        let settings = await NotificationUtils.center.notificationSettings()
        print("""
        🔔 LN Settings Dump:
           - Auth Status: \(settings.authorizationStatus.rawValue)
           - Sound: \(settings.soundSetting.rawValue)
           - Badge: \(settings.badgeSetting.rawValue)
           - Alert: \(settings.alertSetting.rawValue)
           - Lock Screen: \(settings.lockScreenSetting.rawValue)
           - Notification Center: \(settings.notificationCenterSetting.rawValue)
        """)
    }
    
    static func dumpPending() async {
        let pending = await NotificationUtils.center.pendingNotificationRequests()
        let ids = pending.map(\.identifier).joined(separator: ", ")
        print("🔔 LN Pending Dump (\(pending.count) items): [\(ids)]")
    }
    
    static func dumpDelivered() async {
        let delivered = await NotificationUtils.center.deliveredNotifications()
        let ids = delivered.map { $0.request.identifier }.joined(separator: ", ")
        print("🔔 LN Delivered Dump (\(delivered.count) items): [\(ids)]")
    }
    
    
    // MARK: - 0. 소리 기본 동작 검증 (1회 로컬)
    
    static func testCustomSoundOne() {
        let sound = NotificationUtils.createSound(fromSound: .melody)

        NotificationUtils.scheduleNotification(
            id: "\(testPrefix)single-custom",
            title: "1회 0-1: 커스텀 사운드",
            body: "무음 모드에서의 진동 확인",
            sound: sound,
            interval: 5
        )
    }
    
    static func testSilentSoundOne() {
        let sound = NotificationUtils.createSound(fromSound: .silence)
        NotificationUtils.scheduleNotification(
            id: "\(testPrefix)single-system",
            title: "1회 0-2: 기본 사운드",
            body: "무음 모드에서의 진동 확인",
            sound: sound,
            interval: 5
        )
    }
    
    // MARK: - 1. 소리 기본 동작 검증 (연속 로컬)
    
    static func testCustomSound() {
        let sound = NotificationUtils.createSound(fromSound: .melody)
        let endDate = Date().addingTimeInterval(soundTestInterval)
        
        timerService.scheduleRepeatingNotifications(
            baseId: "\(testPrefix)repeating-custom",
            title: "연속 1-1: 커스텀 사운드",
            body: "melody 파일이 반복 재생되어야 합니다.",
            sound: sound,
            endDate: endDate,
            repeatingInterval: 2
        )
    }
    
    static func testSystemSound() {
        let sound = UNNotificationSound.default
        let endDate = Date().addingTimeInterval(soundTestInterval)
        
        timerService.scheduleRepeatingNotifications(
            baseId: "\(testPrefix)repeating-system",
            title: "연속 1-2: 시스템 사운드",
            body: "iOS 기본 알림음이 반복 재생되어야 합니다.",
            sound: sound,
            endDate: endDate,
            repeatingInterval: 2
        )
    }
    
    static func testSilentSound() {
        let sound = NotificationUtils.createSound(fromSound: .silence)
        let endDate = Date().addingTimeInterval(soundTestInterval)
        
        timerService.scheduleRepeatingNotifications(
            baseId: "\(testPrefix)repeating-silent",
            title: "연속 1-3: 무음 사운드",
            body: " (햅틱 켠 경우) 소리 없이 진동만 반복.",
            sound: sound,
            endDate: endDate,
            repeatingInterval: 2
        )
    }
    
    static func testNilSound() {
        let endDate = Date().addingTimeInterval(soundTestInterval)
        
        timerService.scheduleRepeatingNotifications(
            baseId: "\(testPrefix)repeating-nil",
            title: "연속 1-4: 사운드 없음(nil)",
            body: "시스템 기본 동작(소리/진동)이 반복되어야 합니다.",
            sound: nil,
            endDate: endDate,
            repeatingInterval: 2
        )
    }
    
    // MARK: - 2. 배너 기본 동작 검증

    /// 2-1: 배너 없이 소리만 (연속)
     /// 가설: title과 body가 nil이면 배너나 알림창 없이 소리만 재생될 것이다.
     static func testSoundOnly() {
         let sound = UNNotificationSound.default
         let endDate = Date().addingTimeInterval(soundTestInterval)
         
         timerService.scheduleRepeatingNotifications(
             baseId: "\(testPrefix)sound-only",
             // 테스트 후, nil이 들어오지 못하게 논옵셔널로 수정해서 주석 처리
//             title: nil,
//             body: nil,
             title: "",
             body: "",
             sound: sound,
             endDate: endDate,
             repeatingInterval: 2
         )
         NotiLog.logPending("after-schedule:sound-only")
     }
    static func testBodyOnly() {
        let sound = UNNotificationSound.default
        let endDate = Date().addingTimeInterval(soundTestInterval)
        
        timerService.scheduleRepeatingNotifications(
            baseId: "\(testPrefix)body-only",
            title: "",
            body: "바디는 있음",
            sound: nil,
            endDate: endDate,
            repeatingInterval: 2
        )
        NotiLog.logPending("after-schedule:body-only")
    }
    
    static func testTitleOnly() {
        let sound = UNNotificationSound.default
        let endDate = Date().addingTimeInterval(soundTestInterval)
        
        timerService.scheduleRepeatingNotifications(
            baseId: "\(testPrefix)title-only",
            title: "타이틀은 있음",
            body: "",
            sound: nil,
            endDate: endDate,
            repeatingInterval: 2
        )
        NotiLog.logPending("after-schedule:title-only")
    }
    

    static func testSameIdentifierNotifications() {
        let notificationId = "test_unified_id" // ✨ 모든 알림이 사용할 단일 ID
        let title = "동일 ID 테스트"
        let body = "이 알림은 이전 알림을 대체합니다."
        let sound = UNNotificationSound.default
        let intervalSeconds: TimeInterval = 3 // 3초 간격으로 테스트
        
        let initialDelay: TimeInterval = 10
        
        for i in 1...10 {
            let interval = initialDelay + (TimeInterval(i-1) * intervalSeconds)
            
            NotificationUtils.scheduleNotification(
                id: notificationId, // ✨ 루프 안에서도 항상 동일한 ID 사용
                title: title,
                body: "\(body) (\(i)/10)", // 몇 번째 알림인지 본문에 표시
                sound: sound,
                interval: interval
            )
        }
        NotiLog.logPending("after-schedule:test_unified_id")
    }

    static func testThreadIdentifierGrouping() {
        let groupID = "test_thread_group_final"
        let title = "threadID 그룹핑 테스트"
        let body = "이 알림들은 하나로 묶입니다."
        let sound = UNNotificationSound.default
        let intervalSeconds: TimeInterval = 3 // 3초 간격으로 테스트
        
        let initialDelay: TimeInterval = 10
        
        for i in 1...10 {
            // ✨ 각 알림마다 고유한 ID를 생성합니다.
            let uniqueId = "\(groupID)_\(i)"
            let interval = initialDelay + (TimeInterval(i-1) * intervalSeconds)
            
            // NotificationUtils.scheduleNotification 함수를 수정해야 합니다. (아래 참고)
            NotificationUtils.scheduleNotification(
                id: uniqueId, // ✨ 고유 ID 전달
                title: title,
                body: "\(body) (\(i)/10)",
                sound: sound,
                interval: interval,
                threadIdentifier: groupID // ✨ 모든 알림에 동일한 threadIdentifier 전달
            )
        }
        NotiLog.logPending("after-schedule:\(groupID)")
}
   
    // MARK: - 3. 연속 알림 성능 및 UX 검증
    
    // 3-1, 3-2: n초 간격을 파라미터로 받아 시스템 사운드로 연속 알림을 테스트
    /// - Parameter interval: 알림이 반복될 간격(초)
    static func testBarrage(interval: TimeInterval) {
     let sound = UNNotificationSound.default
     let endDate = Date().addingTimeInterval(soundTestInterval)
     let baseId = "\(testPrefix)barrage-\(interval)s"
     
     print("▶️ Scheduling barrage test with \(interval)s interval. BaseID: \(baseId)")
     
     timerService.scheduleRepeatingNotifications(
         baseId: baseId,
         title: "연속 알림 테스트 (\(interval)초 간격)",
         body: "시스템 기본 알림음이 \(interval)초 간격으로 반복되어야 합니다.",
         sound: sound,
         endDate: endDate,
         repeatingInterval: interval
     )
    }
    
    /// 3-3. 예약된 연속 알림을 즉시 취소하는 기능을 테스트
    static func testCancel() {
        let testId = "\(testPrefix)cancellation-test"
        let sound = UNNotificationSound.default
        let endDate = Date().addingTimeInterval(soundTestInterval)
        
        print("▶️ Scheduling notifications to be cancelled immediately. BaseID: \(testId)")
        timerService.scheduleRepeatingNotifications(
            baseId: testId,
            title: "취소 테스트용 알림",
            body: "이 알림은 예약 직후 취소되어 울리면 안 됩니다.",
            sound: sound,
            endDate: endDate,
            repeatingInterval: 2
        )
        
         DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("▶️ Attempting to cancel notifications with baseId: \(testId)")
            timerService.stopTimerNotifications(for: testId)
        }
    }
    
    // MARK: - 4. 최종 정책 조합 검증
    
    static func testPolicy(soundOn: Bool, vibrationOn: Bool) {
       // 1. TimerService의 정책 결정 로직을 그대로 시뮬레이션
       //    (실제 앱에서는 timer.isSoundOn, timer.isVibrationOn으로 이 로직을 통과하게 됩니다.)
        let policy = AlarmNotificationPolicy.determine(soundOn: soundOn, vibrationOn: vibrationOn)
        // 2. 결정된 정책에 따라 실제 UNNotificationSound 객체 생성
        let sound = NotificationUtils.createSound(fromPolicy: policy)
        let endDate = Date().addingTimeInterval(soundTestInterval)

        // 3. TimerService의 실제 연속 알림 함수를 호출하여 최종 테스트
        timerService.scheduleRepeatingNotifications(
           baseId: "\(testPrefix)final-policy-s\(soundOn)-v\(vibrationOn)",
           title: "최종 정책 테스트",
           body: "소리:\(soundOn ? "ON" : "OFF"), 진동:\(vibrationOn ? "ON" : "OFF") / 정책: \(policy)",
           sound: sound,
           endDate: endDate,
           repeatingInterval: 1.5 // 테스트로 찾은 최적의 간격
        )
        
        print("▶️ Final policy test scheduled. Policy: \(policy), Interval: 1.5s")
    }
}

#if DEBUG

enum NotiLog {
    static func logPending(_ tag: String = "") {
        UNUserNotificationCenter.current().getPendingNotificationRequests { reqs in
            let ids = reqs.map { $0.identifier }
            print("🔶 [pending\(tag.isEmpty ? "" : " - \(tag)")] pending_count=\(ids.count)")
        }
    }

    static func logDelivered(_ tag: String = "") {
        UNUserNotificationCenter.current().getDeliveredNotifications { notis in
            let ids = notis.map { $0.request.identifier }
            print("🟩 [delivered\(tag.isEmpty ? "" : " - \(tag)")] delivered_count=\(ids.count)")
        }
    }
}
#endif
