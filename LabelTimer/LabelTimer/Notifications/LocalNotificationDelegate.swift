//
//  LocalNotificationDelegate.swift
//  LabelTimer
//
//  Created by 이소연 on 8/20/25.
//
/// 로컬 알림의 포그라운드 수신 및 사용자 인터랙션을 처리하는 델리게이트 클래스
///
/// - 사용 목적: 앱이 실행 중일 때 알림을 어떻게 표시할지, 사용자가 알림을 탭했을 때 어떤 동작을 할지 결정

import UserNotifications

final class LocalNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    private let alarmHandler: AlarmHandler

    init(alarmHandler: AlarmHandler) {
        self.alarmHandler = alarmHandler
        #if DEBUG
        print("✅ LocalNotificationDelegate initialized")
        #endif
    }
    
    /// 앱이 포그라운드(실행 중) 상태일 때 알림이 도착하면 호출되는 함수
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        #if DEBUG
        print("📬 Notification willPresent in foreground: \(notification.request.identifier)")
        #endif
        
        // TODO: 포그라운드 알림 정책 구현
        // 1. notification.request.identifier에서 timerId 추출
        // 2. Settings에서 현재 '소리' 및 '진동' 설정값 가져오기
        // 3. alarmHandler를 사용해 인앱 알람(소리/진동) 시작
        // 4. completionHandler([])를 호출하여 시스템 알림 배너는 억제
        
        // 임시로 기본 옵션 유지
        completionHandler([.banner, .list, .sound, .badge])
    }
    
    /// 사용자가 알림 배너를 탭하거나, 알림 센터에서 항목을 선택했을 때 호출되는 함수
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        #if DEBUG
        print("👇 Notification didReceive (user tapped): \(response.notification.request.identifier)")
        #endif
        
        // TODO: 알림 탭 시, 후속 알림 정리
        // 1. alarmHandler.stopAll()을 호출하여 현재 재생중인 모든 알람(소리/진동) 중지
        // 2. identifier에서 타이머 ID(UUID)를 추출
        // 3. NotificationUtils를 사용해 해당 타이머 ID로 예약된 모든 후속 알림(Pending) 취소
        
        completionHandler()
    }
}
