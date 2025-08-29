//
//  NotificationScheduling.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 7/24/25.
//
/// NotificationScheduling 프로토콜은 알림 예약과 취소 기능을 추상화
///
/// - 사용 목적: 테스트 코드에서 NotificationCenter를 모킹(mocking)할 수 있게 하기 위함
///   실제 구현체로 UNUserNotificationCenter를 사용하되, 의존성을 프로토콜로 추상화하여 테스트 가능하게 함

import UserNotifications

protocol NotificationScheduling {
    func add(_ request: UNNotificationRequest, withCompletionHandler: ((Error?) -> Void)?)
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
}

// UNUserNotificationCenter를 이 프로토콜에 맞게 확장
extension UNUserNotificationCenter: NotificationScheduling {}
