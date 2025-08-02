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

    @StateObject private var viewModel = SettingsViewModel()

    @AppStorage("isAutoSaveEnabled") private var isAutoSaveEnabled = true
    @AppStorage("isDarkMode") private var isDarkMode = true
    
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
//                    Toggle(isOn: $isAutoSaveEnabled) {
//                        VStack(alignment: .leading) {
//                            Text("타이머 자동 저장")
//                            Text("타이머 종료 시 자동으로 [타이머 목록]에 저장됩니다.")
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                        }
//                    }

                    NavigationLink("기본 사운드") {
                        SoundPickerView()
                    }

                    Toggle("다크 모드", isOn: $viewModel.isDarkMode)
                        .onChange(of: viewModel.isDarkMode) { _ in
                            viewModel.applyAppearance()
                        }
                }

                // MARK: - 알림 권한
                Section(header: Text("알림 권한")) {
                    HStack {
                        Text("현재 상태")
                        Spacer()
                        Text(viewModel.notificationStatusText)
                            .foregroundColor(.gray)
                    }
                    if viewModel.notificationStatus != .authorized {
                        Button("설정에서 알림 허용하기") {
                            viewModel.openSystemSettings()
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
                viewModel.fetchNotificationStatus()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                viewModel.fetchNotificationStatus()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

//#Preview {
//    SettingsView()
//}
