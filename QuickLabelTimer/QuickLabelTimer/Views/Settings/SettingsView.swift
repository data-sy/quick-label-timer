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
    private let repoName = "label-timer"

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
                Section(header: Text("알림 설정")) {
                    NavigationLink("기본 사운드") {
                        SoundPickerView()
                    }
                    NavigationLink("기본 알림 방식") {
                        AlarmModePickerView()
                    }

                    Toggle("다크 모드", isOn: $settingsViewModel.isDarkMode)
                }

                // MARK: - 알림 권한
                Section(header: Text("알림 권한")) {
                    HStack {
                        Text("현재 상태")
                        Spacer()
                        Text(settingsViewModel.notificationStatusText)
                            .foregroundColor(.gray)
                    }
                    if settingsViewModel.notificationStatus != .authorized {
                        Button("설정에서 알림 허용하기") {
                            settingsViewModel.openSystemSettings()
                        }
                    }
                }

                // MARK: - 지원
                Section(header: Text("지원")) {
                    NavigationLink {
                        SoundHelpView()
                    } label: {
                        HStack(spacing: 8) {
                            SpeakerBadgeIcon()
                                .frame(width: iconAreaWidth, alignment: .center)
                            Text("소리가 안 들려요")
                        }
                    }

                    NavigationLink {
                        VibrationHelpView()
                    } label: {
                        HStack(spacing: 8) {
                            VibrationBadgeIcon()
                                .frame(width: iconAreaWidth, alignment: .center)
                            Text("진동이 안 울려요")
                        }
                    }

                    Link("문의하기", destination: URL(string: "https://forms.gle/CobXgiRGjEFQZKgr8")!)
                        .accessibilityHint(A11yText.Settings.opensExternalLinkHint)

                    if languageCode == "ko" {
                        Link("개인정보 처리방침", destination: privacyPolicyURL)
                            .accessibilityHint(A11yText.Settings.opensExternalLinkHint)
                    } else {
                        Link("Privacy Policy", destination: privacyPolicyURL_en)
                            .accessibilityHint(A11yText.Settings.opensExternalLinkHint_EN)
                    }
                }
            }
            .navigationTitle("설정")
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 2) {
                    Text("Quick Label Timer")
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
