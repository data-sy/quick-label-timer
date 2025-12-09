//
//  SettingsViewModel.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/2/25.
//
/// SettingsView의 상태와 로직을 관리하는 ViewModel
///
/// - 사용 목적: 자동저장, 다크모드, 알림 권한 등 앱 설정 상태를 통합 관리하고, View와 비즈니스 로직을 분리

import SwiftUI
import UserNotifications

final class SettingsViewModel: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    @Published var notificationStatus: UNAuthorizationStatus = .notDetermined

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
        case .authorized: return String(localized: "ui.settings.statusAuthorized")
        case .denied: return String(localized: "ui.settings.statusDenied")
        case .notDetermined: return String(localized: "ui.settings.statusNotDetermined")
        case .provisional: return String(localized: "ui.settings.statusProvisional")
        case .ephemeral: return String(localized: "ui.settings.statusEphemeral")
        @unknown default: return String(localized: "ui.settings.statusUnknown")
        }
    }

    /// 시스템 설정 화면 열기
    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

