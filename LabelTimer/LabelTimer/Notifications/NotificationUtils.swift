//
//  NotificationUtils.swift
//  LabelTimer
//
//  Created by 이소연 on 7/11/25.
//
/// 로컬 알림을 생성, 조회, 취소하는 범용 유틸리티
///
/// - 사용 목적: 앱의 모든 부분에서 일관된 방식으로 로컬 알림을 관리

import UserNotifications

enum NotificationUtils {
    
    static let center = UNUserNotificationCenter.current()

//    private static let maxNotifications = 60 // (iOS가 허용하는 최대 알림 개수: 64개)

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
    static func scheduleNotification(id: String, title: String?, body: String?, sound: UNNotificationSound?, interval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title ?? ""
        content.body = body ?? ""
        content.sound = sound

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request) { error in
            #if DEBUG
            if let error = error { print("🔔 LN Schedule Failed: \(id), \(error.localizedDescription)") }
            else { print("🔔 LN Scheduled: \(id) after \(interval)s") }
            #endif
        }
    }
    
    // MARK: - 알림 취소
    
    /// ID prefix로 예약/도착된 알림 모두 취소
    static func cancelNotifications(withPrefix prefix: String, completion: (() -> Void)? = nil) {
        center.getPendingNotificationRequests { pendingRequests in
            let pendingIDs = pendingRequests.map(\.identifier).filter { $0.hasPrefix(prefix) }
            center.removePendingNotificationRequests(withIdentifiers: pendingIDs)
            
            center.getDeliveredNotifications { deliveredNotifications in
                let deliveredIDs = deliveredNotifications.map { $0.request.identifier }.filter { $0.hasPrefix(prefix) }
                center.removeDeliveredNotifications(withIdentifiers: deliveredIDs)
                
                #if DEBUG
                print("🔔 LN Cancelled by prefix '\(prefix)': \(pendingIDs.count) pending, \(deliveredIDs.count) delivered.")
                #endif
                completion?()
            }
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
