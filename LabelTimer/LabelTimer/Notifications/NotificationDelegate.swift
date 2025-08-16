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
    
    var timerService: TimerServiceProtocol?
    var alarmHandler: AlarmTriggering?

    private override init() {
        super.init()
    }

    /// 포그라운드 상태에서 알림이 도착하면 알림 배너를 표시
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        guard let id = UUID(uuidString: notification.request.identifier) else {
            completionHandler([.banner, .list, .badge])
            return
        }
        // 메인 액터로 hop해서 @MainActor 서비스 안전 호출
        Task { [weak self] in
            let timer = await self?.timerService?.getTimer(byId: id)

            // 1회성 피드백(소리/진동) 재생
            if let timer, let handler = self?.alarmHandler {
                handler.playSystemFeedback(for: timer)
            }

            // 원본 알림의 소리는 끄고, 배너/리스트/배지 표시
            completionHandler([.banner, .list, .badge])
        }
    }
}
