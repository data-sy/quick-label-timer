import UserNotifications

//
//  NotificationScheduling.swift
//  LabelTimer
//
//  Created by 이소연 on 7/24/25.
//

protocol NotificationScheduling {
    func add(_ request: UNNotificationRequest, withCompletionHandler: ((Error?) -> Void)?)
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
}

// UNUserNotificationCenter를 이 프로토콜에 맞게 확장
extension UNUserNotificationCenter: NotificationScheduling {}
