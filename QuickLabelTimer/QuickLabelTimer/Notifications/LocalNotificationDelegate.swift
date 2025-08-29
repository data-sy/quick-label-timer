//
//  LocalNotificationDelegate.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/20/25.
//
/// 로컬 알림의 포그라운드 수신 및 사용자 인터랙션을 처리하는 델리게이트 클래스
///
/// - 사용 목적: 앱이 실행 중일 때 알림을 어떻게 표시할지, 사용자가 알림을 탭했을 때 어떤 동작을 할지 결정

import UserNotifications

final class LocalNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    /// 앱이 포그라운드(실행 중) 상태일 때 알림이 도착하면 호출 (willPresent)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        
        let request = notification.request
        let content = request.content
        let identifier = request.identifier // 예: "<baseIdentifier>_<index>"
        let baseIdentifier = extractBaseIdentifier(from: identifier, userInfo: content.userInfo)
        let index = extractIndex(from: identifier, userInfo: content.userInfo)
        
        #if DEBUG
        print("[LNDelegate] 📬 willPresent: id=\(identifier) index=\(index)")
        #endif

        // 두 번째 알림부터는 억제 + 일괄 취소
        guard index == 0 else {
            completionHandler([])
            // 포그라운드에서 추가 표시 방지: 바로 pending 정리
            NotificationUtils.cancelPending(withPrefix: baseIdentifier, excluding: Set([identifier])) {}
            // delivered는 약간 지연 후 정리 (현재 표시 알림 보존 및 사운드 보장)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                NotificationUtils.cancelDelivered(withPrefix: baseIdentifier, excluding: Set([identifier])) {}
            }
            return
        }

        // 첫 번째 알림은 표기 + 사운드
        completionHandler([.banner, .list, .sound])

        // 현재 표시 중인 id는 제외하고 정리
        NotificationUtils.cancelPending(withPrefix: baseIdentifier, excluding: Set([identifier])) {}
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            NotificationUtils.cancelDelivered(withPrefix: baseIdentifier, excluding: Set([identifier])) {}
        }
    }
    
    /// 사용자가 알림 배너를 탭하거나, 알림 센터에서 항목을 선택했을 때 호출 (didReceive)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let request = response.notification.request
        let content = request.content
        let identifier = request.identifier
        let baseIdentifier = extractBaseIdentifier(from: identifier, userInfo: content.userInfo)
        
        #if DEBUG
        print("[LNDelegate] 👇 didReceive (user tapped): \(identifier)")
        #endif

        NotificationUtils.cancelNotifications(withPrefix: baseIdentifier) {
            #if DEBUG
            print("[LNDelegate] 🧹 didReceive cleaned up for prefix=\(baseIdentifier)")
            #endif
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
}

private extension LocalNotificationDelegate {
    func extractBaseIdentifier(from identifier: String, userInfo: [AnyHashable: Any]) -> String {
        if userInfo["baseIdentifier"] == nil {
            #if DEBUG
            print("[LNDelegate] ⚠️ userInfo.baseIdentifier missing; falling back to identifier prefix")
            #endif
        }
        if let base = userInfo["baseIdentifier"] as? String {
            return base
        }
        return identifier.components(separatedBy: "_").first ?? identifier
    }
    
    func extractIndex(from identifier: String, userInfo: [AnyHashable: Any]) -> Int {
        if userInfo["index"] == nil {
            #if DEBUG
            print("[LNDelegate] ⚠️ userInfo.index missing; falling back to suffix parsing")
            #endif
        }
        if let idx = userInfo["index"] as? Int {
            return idx
        }
        return Int(identifier.components(separatedBy: "_").last ?? "") ?? 0
    }
}
