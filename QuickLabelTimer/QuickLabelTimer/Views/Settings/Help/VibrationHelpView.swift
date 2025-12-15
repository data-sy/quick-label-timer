//
//  VibrationHelpView.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/31/25.
//
/// 진동 관련 도움말을 제공하는 화면
///
/// - 사용 목적: 타이머 알림 진동이 울리지 않을 경우의 해결 방법을 단계별로 안내

import SwiftUI

struct VibrationHelpView: View {
    var body: some View {
        List {
            Section(header: Text(.init("ui.help.vibrationIntro"))){}

            Section(header: Text("ui.help.systemSettings").accessibilityAddTraits(.isHeader)) {
                Text(.init("ui.help.vibrationAccessibilityText"))
                Text(.init("ui.help.vibrationHapticText"))
            }

            Section(header: Text("ui.help.focusModeCheck").accessibilityAddTraits(.isHeader)) {
                Text(.init("ui.help.focusModeVibrationText"))
            }

            Section(header: Text("ui.help.appleWatchUsers").accessibilityAddTraits(.isHeader)) {
                Text(.init("ui.help.appleWatchVibrationText"))
                Text(.init("ui.help.appleWatchHapticText"))
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("ui.help.vibrationIssueTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        VibrationHelpView()
    }
}
