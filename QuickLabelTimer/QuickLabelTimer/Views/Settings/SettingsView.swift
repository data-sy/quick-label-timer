//
//  SettingsView.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/1/25.
//
/// 앱의 전역 설정 화면
///
/// - 사용 목적: 알람 관련 기본 설정, 개인정보 방침, 앱 정보 및 피드백 창구 제공

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel

    let iconAreaWidth: CGFloat = 36

    private let githubUsername = "data-sy"
    private let repoName = "quick-label-timer"

    private var privacyPolicyURL: URL {
        URL(string: "https://\(githubUsername).github.io/\(repoName)/privacy-policy-kr")!
    }
    private var privacyPolicyURL_en: URL {
        URL(string: "https://\(githubUsername).github.io/\(repoName)/privacy-policy-en")!
    }
    
    var body: some View {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en"
        let languageCode = preferredLanguage.components(separatedBy: "-").first ?? "en"
        
        return NavigationStack {
            Form {
                // MARK: - 알림 설정
                Section(header: Text("ui.settings.notificationSection")) {
                    NavigationLink("ui.settings.defaultSound") {
                        SoundPickerView()
                    }
                    NavigationLink("ui.settings.alarmModeTitle") {
                        AlarmModePickerView()
                    }

                    Toggle("ui.settings.darkMode", isOn: $settingsViewModel.isDarkMode)
                }

                // MARK: - 알림 권한
                Section(header: Text("ui.settings.permissionSection")) {
                    HStack {
                        Text("ui.settings.currentStatus")
                        Spacer()
                        Text(settingsViewModel.notificationStatusText)
                            .foregroundColor(.gray)
                    }
                    if settingsViewModel.notificationStatus != .authorized {
                        Button("ui.settings.enableNotifications") {
                            settingsViewModel.openSystemSettings()
                        }
                    }
                }

                // MARK: - 지원
                Section(header: Text("ui.settings.supportSection")) {
                    NavigationLink {
                        SoundHelpView()
                    } label: {
                        HStack(spacing: 8) {
                            SpeakerBadgeIcon()
                                .frame(width: iconAreaWidth, alignment: .center)
                            Text("ui.settings.soundHelp")
                        }
                    }

                    NavigationLink {
                        VibrationHelpView()
                    } label: {
                        HStack(spacing: 8) {
                            VibrationBadgeIcon()
                                .frame(width: iconAreaWidth, alignment: .center)
                            Text("ui.settings.vibrationHelp")
                        }
                    }

                    Link("ui.settings.contact", destination: URL(string: "https://forms.gle/CobXgiRGjEFQZKgr8")!)
                        .accessibilityHint(A11yText.Settings.opensExternalLinkHint)

                    if languageCode == "ko" {
                        Link("ui.settings.privacyPolicy", destination: privacyPolicyURL)
                            .accessibilityHint(A11yText.Settings.opensExternalLinkHint)
                    } else {
                        Link("ui.settings.privacyPolicy", destination: privacyPolicyURL_en)
                            .accessibilityHint(A11yText.Settings.opensExternalLinkHint_EN)
                    }
                }
            }
            .navigationTitle("ui.settings.title")
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 2) {
                    Text("ui.common.appName")
                        .font(.footnote)
                    Text(Bundle.appVersion)
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .onAppear {
                settingsViewModel.fetchNotificationStatus()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                settingsViewModel.fetchNotificationStatus()
            }
        }
        .preferredColorScheme(settingsViewModel.isDarkMode ? .dark : .light)
    }
}
