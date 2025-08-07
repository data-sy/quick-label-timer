//
//  SettingsViewModel.swift
//  LabelTimer
//
//  Created by 이소연 on 8/2/25.
//
/// 설정 화면의 상태와 로직을 관리하는 뷰모델
/// - 사용 목적: 자동저장, 다크모드, 알림 권한 상태 등의 설정 상태를 통합 관리하고,
///          뷰(UI)와 비즈니스 로직을 분리

import SwiftUI
import UserNotifications

final class SettingsViewModel: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    @Published var notificationStatus: UNAuthorizationStatus = .notDetermined
    
    /// 다크/라이트모드 전환
    func applyAppearance() {
        let style: UIUserInterfaceStyle = isDarkMode ? .dark : .light
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.overrideUserInterfaceStyle = style
        }
    }

    /// 알림 권한 상태 조회
    func fetchNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationStatus = settings.authorizationStatus
            }
        }
    }

    /// 알림 권한 상태에 따라 텍스트 반환
    var notificationStatusText: String {
        switch notificationStatus {
        case .authorized: return "허용됨"
        case .denied: return "거부됨"
        case .notDetermined: return "미요청"
        case .provisional: return "임시 허용"
        case .ephemeral: return "일시적 세션"
        @unknown default: return "알 수 없음"
        }
    }

    /// 시스템 설정 화면 열기
    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

