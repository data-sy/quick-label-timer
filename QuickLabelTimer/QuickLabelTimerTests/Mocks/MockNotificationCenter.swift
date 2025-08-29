//
//  MockNotificationCenter.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 7/24/25.
//
/// 로컬 알림 스케줄링 로직 테스트를 위한 Mock 클래스 및 단위 테스트
///
/// - 사용 목적: NotificationScheduling 프로토콜을 구현한 Mock을 통해 타이머 알림 예약 동작을 검증

import UserNotifications
@testable import QuickLabelTimer

final class MockNotificationCenter: NotificationScheduling {
    var addedRequests: [UNNotificationRequest] = []
    var removedIdentifiers: [String] = []
    
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        addedRequests.append(request)
        completionHandler?(nil)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers.append(contentsOf: identifiers)
    }
    
    func reset() {
        addedRequests.removeAll()
        removedIdentifiers.removeAll()
    }
}
