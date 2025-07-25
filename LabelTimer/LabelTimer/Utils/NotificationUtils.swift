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
/// - 기능: 알림 권한 요청, 알림 예약, 알림 취소
///

enum NotificationUtils {
    
    static var center: NotificationScheduling = UNUserNotificationCenter.current()

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
        center.delegate = NotificationDelegate.shared
    }

    /// 특정 타이머에 대한 로컬 알림 예약
    static func scheduleNotification(id: String, label: String, after seconds: Int) {
        let content = UNMutableNotificationContent()
        content.title = "⏰ 타이머 종료"
        content.body = label.isEmpty ? "타이머가 끝났습니다." : label
        content.sound = .default

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

    /// 특정 타이머 알림 취소
    static func cancelScheduledNotification(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    /// 전체 예약 알림 취소
    static func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
