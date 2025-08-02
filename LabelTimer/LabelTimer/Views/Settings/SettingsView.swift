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
    @AppStorage("isAutoSaveEnabled") private var isAutoSaveEnabled = true
    @AppStorage("isDarkMode") private var isDarkMode = true

    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - 알림 설정
                Section(header: Text("알림 설정")) {
                    Toggle(isOn: $isAutoSaveEnabled) {
                        VStack(alignment: .leading) {
                            Text("타이머 자동 저장")
                            Text("타이머 종료 시 자동으로 [타이머 목록]에 저장됩니다.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    NavigationLink("기본 사운드") {
                        SoundPickerView()
                    }

                    Toggle("다크 모드", isOn: $isDarkMode)
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
                    NavigationLink("도움말") {
                        Text("앱 사용법 작성 예정 화면") // TODO: 연결 예정
                    }

                    NavigationLink("문의하기") {
                        Text("문의하기 화면") // TODO: 메일 보내기 + 태그 선택 예정
//셋팅에서 문의하기는 의견보내기로 바꿀까? 알라미 앱 참고하기


                    }

                    Link("개인정보 처리방침", destination: URL(string: "https://your.notion.site/privacy")!)
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
        }
    }
}

//#Preview {
//    SettingsView()
//}
