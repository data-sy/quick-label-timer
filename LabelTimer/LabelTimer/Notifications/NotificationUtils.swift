//
//  NotificationUtils.swift
//  LabelTimer
//
//  Created by 이소연 on 7/11/25.
//
/// 로컬 알림을 요청, 예약, 취소하는 유틸리티
///
/// - 사용 목적: 타이머 종료 시 로컬 알림을 발송하거나 취소하기 위한 로직 모듈화

import UserNotifications

enum NotificationUtils {
    
    static let center = UNUserNotificationCenter.current()

    private static let maxNotifications = 60 // (iOS가 허용하는 최대 알림 개수: 64개)

    /// 알림 권한 요청 (앱 시작 시 1회)
    static func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                #if DEBUG
                print("알림 권한 요청 실패: \(error)")
                #endif
            } else {
                #if DEBUG
                print("알림 권한: \(granted ? "허용됨" : "거부됨")")
                #endif
            }
        }
    }
    
    // MARK: - 단일 알림 예약/취소
    
    /// 단일 로컬 알림 예약
        static func scheduleNotification(id: String, label: String, after seconds: Int) {
            let content = UNMutableNotificationContent()
            content.title = "⏰ 타이머 종료"
            content.body = label.isEmpty ? "타이머가 끝났습니다." : label
            content.sound = nil

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)

            let request = UNNotificationRequest(
                identifier: id,  // 각 타이머 ID를 identifier로 사용
                content: content,
                trigger: trigger
            )

            center.add(request) { error in
                #if DEBUG
                if let error = error {
                    print("알림 예약 실패: \(error)")
                }
                #endif
            }
        }

        /// 단일 알림 취소
        static func cancelScheduledNotification(id: String) {
            center.removePendingNotificationRequests(withIdentifiers: [id])
        }

    // MARK: - 연속 표시 알림 (반복 배너 방식)

    /// 연속 표시 알림 예약
    static func scheduleRepeatingNotifications(id: String, startDate: Date, interval: TimeInterval) {
        print("🚀 [NotificationUtils] '보이는' 연속 알람 예약을 시작합니다...")
        
        for i in 0..<Self.maxNotifications {
            let content = UNMutableNotificationContent()
            content.title = "알람!"
            content.body = "타이머가 완료되었습니다."
            content.sound = .default // 소리가 있는 기본 알림

            let timeIntervalSinceNow = startDate.addingTimeInterval(Double(i) * interval).timeIntervalSinceNow
            
            guard timeIntervalSinceNow > 0 else {
                continue
            }
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeIntervalSinceNow, repeats: false)
            let notificationId = "\(id)_\(i)"
            let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("❗️[NotificationUtils] add 실패 \(notificationId): \(error.localizedDescription)")
//                } else {
//                    #if DEBUG
//                    print("✅ add 성공 \(notificationId) (+\(Int(timeIntervalSinceNow))s)")
//                    #endif
                }
            }
        }
    }
    
    /// 연속 표시 알림 일괄 취소
    static func cancelRepeatingNotifications(for id: String) {
        let identifiers = (0..<Self.maxNotifications).map { "\(id)_\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
        
        #if DEBUG
        print("🗑️ \(identifiers.count)개의 연속 알림 취소 완료 (ID: \(id))")
        #endif
    }
    
    /// 전체 예약 알림 취소
    static func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
}
