//
//  AlarmSettingToggles.swift
//  LabelTimer
//
//  Created by 이소연 on 7/25/25.
//
/// 타이머 입력 화면에서 사운드 및 진동 알림 설정을 제어하는 토글 컴포넌트
///
/// - 사용 목적: 사용자가 사운드 및 진동 알람 여부를 개별적으로 설정할 수 있도록 제공

import SwiftUI

struct AlarmSettingToggles: View {
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        HStack(spacing: 12) {
            ToggleButton(
                isOn: settings.isSoundOn,
                iconName: settings.isSoundOn ? "speaker.wave.2.fill" : "speaker.slash.fill",
                onTap: { settings.isSoundOn.toggle() }
            )

            ToggleButton(
                isOn: settings.isVibrationOn,
                iconName: settings.isVibrationOn ? "iphone.radiowaves.left.and.right" : "iphone.slash",
                onTap: { settings.isVibrationOn.toggle() }
            )
        }
        .padding(.trailing, 8)
    }
}

private struct ToggleButton: View {
    let isOn: Bool
    let iconName: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: iconName)
                .font(.body)
                .frame(width: 24, height: 24)
                .foregroundStyle(isOn ? .white : .gray)
                .padding(8)
                .background(
                    Circle()
                        .fill(isOn ? Color.brandColor.opacity(0.75) : Color(UIColor.systemGray5))
                )
        }
        .buttonStyle(.plain)
    }
}

//#Preview(traits: .sizeThatFitsLayout) {
//    AlarmSettingToggles()
//        .environmentObject(UserSettings.shared)
//        .padding()
//}
