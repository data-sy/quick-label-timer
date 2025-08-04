//
//  SettingsView.swift
//  LabelTimer
//
//  Created by 이소연 on 8/1/25.
//
/// 앱의 전역 설정 화면
///
/// - 사용 목적: 알람 관련 기본 설정, 개인정보 방침, 앱 정보 및 피드백 창구 제공

import SwiftUI
import UserNotifications

struct SettingsView: View {
    private let githubUsername = "data-sy"
    private let repoName = "label-timer"

    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    private var privacyPolicyURL: URL {
        URL(string: "https://\(githubUsername).github.io/\(repoName)/privacy-policy-kr")!
    }
    private var privacyPolicyURL_en: URL {
        URL(string: "https://\(githubUsername).github.io/\(repoName)/privacy-policy-en")!
    }
    
    var body: some View {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en"
        let languageCode = preferredLanguage.components(separatedBy: "-").first ?? "en"
        
        return NavigationView {
            Form {
                // MARK: - 알림 설정
                Section(header: Text("알림 설정")) {
                    NavigationLink("기본 사운드") {
                        SoundPickerView()
                    }

                    Toggle("다크 모드", isOn: $settingsViewModel.isDarkMode)
                        .onChange(of: settingsViewModel.isDarkMode) { _ in
                            settingsViewModel.applyAppearance()
                        }
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
//                    NavigationLink("도움말") {
//                        Text("앱 사용법 작성 예정 화면") // TODO: 작성 예정
//                    }
//
//                    Link("의견 보내기", destination: URL(string: "https://forms.gle/your-google-form-id")!) // TODO: 구글 폼 연결 예정

                    if languageCode == "ko" {
                        Link("개인정보 처리방침", destination: privacyPolicyURL)
                    } else {
                        Link("Privacy Policy", destination: privacyPolicyURL_en)
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

//#Preview {
//    SettingsView()
//}
