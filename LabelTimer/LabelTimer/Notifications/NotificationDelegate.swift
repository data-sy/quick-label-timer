//
//  NotificationDelegate.swift
//  LabelTimer
//
//  Created by 이소연 on 7/25/25.
//
/// 앱의 포그라운드 로컬 알림 이벤트를 수신하고 처리하는 delegate 클래스
///
/// - 사용 목적: 포그라운드 상태에서 알림이 도착했을 때의 동작을 정의 (예: 배너 표시, 피드백 재생)
///
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
        // 반복 알림 ID (예: "UUID_0")에서 순수 UUID 부분만 추출
         let identifier = notification.request.identifier
         let timerIdString = identifier.components(separatedBy: "_").first ?? identifier
         
         guard let id = UUID(uuidString: timerIdString) else {
             completionHandler([.banner, .list, .badge, .sound])
             return
         }
        // MainActor에서 실행되는 서비스/핸들러를 안전하게 호출
        Task { [weak self] in
            if let timer = await self?.timerService?.getTimer(byId: id),
               let handler = self?.alarmHandler {
                handler.playSystemFeedback(for: timer)
            }
        }
        completionHandler([.banner, .list, .badge])
    }
}
