import UserNotifications

//
//  NotificationUtils.swift
//  LabelTimer
//
//  Created by 이소연 on 7/11/25.
//
/// 로컬 알림을 요청, 예약, 취소하는 유틸리티
///
/// - 사용 목적: 타이머 종료 시 로컬 알림을 발송하거나 취소하기 위한 로직 모듈화
/// - 포함 기능: 알림 권한 요청, 알림 예약, 알림 취소
///

enum NotificationUtils {
    
    /// 알림 권한 요청 (앱 시작 시 1회)
    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
            } else {
            }
        }
    }

    /// 로컬 알림 예약
    static func scheduleNotification(label: String, after seconds: Int) {
        let content = UNMutableNotificationContent()
        content.title = "⏰ 타이머 종료"
        content.body = label.isEmpty ? "타이머가 끝났습니다." : label
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)

        let request = UNNotificationRequest(
            identifier: "labelTimerNotification",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
            } else {
            }
        }
    }

    /// 예약된 알림 취소
    static func cancelScheduledNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["labelTimerNotification"])
    }
}
