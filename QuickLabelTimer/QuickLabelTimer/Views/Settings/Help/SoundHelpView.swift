//
//  SoundHelpView.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/31/25.
//
/// 소리 관련 도움말을 제공하는 화면
///
/// - 사용 목적: 타이머 알림 소리가 들리지 않을 경우의 해결 방법을 단계별로 안내

import SwiftUI
import UIKit

struct SoundHelpView: View {
    var body: some View {
        List {
            Section(header: Text(.init("ui.help.soundIntro"))){}

            Section(header: Text("ui.help.basicChecklist").accessibilityAddTraits(.isHeader)) {
                Text(.init("ui.help.checkMuteMode"))
                Text(.init("ui.help.checkVolume"))
            }

            Section(header: Text("ui.help.systemSettings").accessibilityAddTraits(.isHeader)) {
                Text(.init("ui.help.notificationPathText"))

                Button("ui.help.openNotificationSettings") {
                    openAppNotificationSettings()
                }
                .a11y(
                    label: "ui.help.openNotificationSettings",
                    hint: A11yText.Settings.opensSystemSettingsHint,
                    traits: .isButton
                )
            }

            Section(header: Text("ui.help.focusModeCheck").accessibilityAddTraits(.isHeader)) {
                Text("ui.help.focusModeText")
            }

            Section(header: Text("ui.help.appleWatchUsers").accessibilityAddTraits(.isHeader)) {
                Text("ui.help.appleWatchVibrationText")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("ui.help.soundIssueTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func openAppNotificationSettings() {
        // iOS 16 이상에서는 앱의 '알림' 설정으로 바로 이동
        if #available(iOS 16.0, *), let url = URL(string: UIApplication.openNotificationSettingsURLString) {
            UIApplication.shared.open(url)
            return
        }
        
        // iOS 16 미만에서는 앱의 '일반' 설정으로 이동
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    NavigationStack {
        SoundHelpView()
    }
}
