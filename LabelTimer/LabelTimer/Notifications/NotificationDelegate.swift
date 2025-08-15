//
//  NotificationDelegate.swift
//  LabelTimer
//
//  Created by 이소연 on 7/25/25.
//
/// 포그라운드에서도 알림이 배너로 표시되도록 처리하는 delegate 클래스
///
/// - 사용 목적: iOS는 기본적으로 포그라운드 상태에선 알림을 자동 표시하지 않기 때문에, 수동으로 표시 옵션을 지정

import Foundation
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationDelegate()

    private override init() {
        super.init()
    }

    /// 포그라운드 상태에서 알림이 도착하면 알림 배너를 표시
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner])
    }
}
