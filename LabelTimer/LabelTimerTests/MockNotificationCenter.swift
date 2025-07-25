import UserNotifications
@testable import LabelTimer

//
//  MockNotificationCenter.swift
//  LabelTimer
//
//  Created by 이소연 on 7/24/25.
//

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
}
