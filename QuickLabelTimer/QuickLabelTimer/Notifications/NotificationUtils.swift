//
//  NotificationUtils.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 7/11/25.
//
/// 로컬 알림을 생성, 조회, 취소하는 범용 유틸리티
///
/// - 사용 목적: 앱의 모든 부분에서 일관된 방식으로 로컬 알림을 관리

import UserNotifications

enum NotificationUtils {
    
    static let center = UNUserNotificationCenter.current()

    // MARK: - 권한 및 기본 유틸
    
    /// 알림 권한 요청 (앱 시작 시 1회)
    static func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            #if DEBUG
            if let error = error { print("🔔 LN Auth Failed: \(error.localizedDescription)") }
            else { print("🔔 LN Auth Granted: \(granted)") }
            #endif
        }
    }
    /// AlarmSound enum을 UNNotificationSound 객체로 변환
    static func createSound(fromSound sound: AlarmSound) -> UNNotificationSound? {
         let fileNameWithExtension = "\(sound.fileName).\(sound.fileExtension)"
        return UNNotificationSound(named: UNNotificationSoundName(fileNameWithExtension))
    }
    
    /// AlarmNotificationPolicy enum을 UNNotificationSound 객체로 변환
    static func createSound(fromPolicy policy: AlarmNotificationPolicy) -> UNNotificationSound? {
        switch policy {
        case .soundAndVibration:
            return createSound(fromSound: AlarmSound.current)
        case .vibrationOnly:
            // '무음' 사운드 트릭
            return createSound(fromSound: AlarmSound.silence)
        case .silent:
            return nil
        }
    }
    // MARK: - 알림 예약
    
    /// 단일 로컬 알림 예약
    static func scheduleNotification(id: String, title: String, body: String, sound: UNNotificationSound?, interval: TimeInterval, userInfo: [AnyHashable: Any]? = nil, threadIdentifier: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound
        if let info = userInfo {
            content.userInfo = info
        }

        if let threadId = threadIdentifier {
            content.threadIdentifier = threadId
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request) { error in
            #if DEBUG
            if let error = error { print("🔔 LN Schedule Failed: \(id), \(error.localizedDescription)") }
            else {
                let fireDate = Date().addingTimeInterval(interval)
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                print("🔔 LN Scheduled: \(id) → \(formatter.string(from: fireDate)) 예정")
            }
            #endif
        }
    }
    
    // MARK: - 알림 취소
    
    /// ID prefix로 예약/도착된 알림 모두 취소
    static func cancelNotifications(withPrefix prefix: String, completion: (() -> Void)? = nil) {
        let group = DispatchGroup()

        group.enter()
        cancelPending(withPrefix: prefix) { group.leave() }

        group.enter()
        cancelDelivered(withPrefix: prefix) { group.leave() }

        group.notify(queue: .main) {
            #if DEBUG
            print("🔔 LN Cancelled by prefix '\(prefix)' (pending + delivered)")
            #endif
            completion?()
        }
    }
    
    /// 예약된(Pending) 연속 알림 취소
    static func cancelPending(
        withPrefix prefix: String,
        excluding excludedIDs: Set<String> = [],
        completion: (() -> Void)? = nil
    ) {
        center.getPendingNotificationRequests { requests in
            let ids = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(prefix) && !excludedIDs.contains($0) }

            if !ids.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: ids)
            }

            #if DEBUG
            print("🔔 LN Cancel pending by prefix '\(prefix)' excluding \(excludedIDs) → \(ids.count)")
            #endif
            DispatchQueue.main.async { completion?() }
        }
    }

    /// 표시된(Delivered) 연속 알림 취소
    static func cancelDelivered(
        withPrefix prefix: String,
        excluding excludedIDs: Set<String> = [],
        completion: (() -> Void)? = nil
    ) {
        center.getDeliveredNotifications { delivered in
            let ids = delivered
                .map { $0.request.identifier }
                .filter { $0.hasPrefix(prefix) && !excludedIDs.contains($0) }

            if !ids.isEmpty {
                center.removeDeliveredNotifications(withIdentifiers: ids)
            }

            #if DEBUG
            print("🔔 LN Cancel delivered by prefix '\(prefix)' excluding \(excludedIDs) → \(ids.count)")
            #endif
            DispatchQueue.main.async { completion?() }
        }
    }
    
    /// 모든 예약/도착된 알림 삭제
    static func cancelAll(completion: (() -> Void)? = nil) {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        #if DEBUG
        print("🔔 LN Cancelled All.")
        #endif
        completion?()
    }
}
