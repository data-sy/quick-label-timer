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
            Section(header: Text(.init("""
                iOS 알림의 소리 출력은 **시스템 설정에 따라 동작**합니다.  
                알림 소리가 들리지 않는다면 아래 항목을 확인해 주세요.
                """))){}

            Section(header: Text("기본 점검 항목").accessibilityAddTraits(.isHeader)) {
                Text(.init("기기가 **무음 모드**로 설정되어 있지는 않나요?"))
                Text(.init("기기의 **볼륨**이 0 이지는 않나요?"))
            }
            
            Section(header: Text("시스템 설정 확인").accessibilityAddTraits(.isHeader)) {
                Text(.init("**설정 > 알림 > 퀵라벨타이머** 로 이동해 '알림 허용'과 '사운드'가 켜져 있는지 확인해 주세요"))
            
                Button("알림 설정 열기") {
                    openAppNotificationSettings()
                }
                .a11y(
                    label:  "알림 설정 열기",
                    hint: A11yText.Settings.opensSystemSettingsHint,
                    traits: .isButton
                )
            }

            Section(header: Text("집중 모드 확인").accessibilityAddTraits(.isHeader)) {
                Text("**설정 > 집중 모드**에서 활성화된 모드가 알림을 차단하고 있지 않은지 확인해 주세요")
            }
            
            Section(header: Text("Apple Watch 사용자").accessibilityAddTraits(.isHeader)) {
                Text("Apple Watch를 착용 중이라면, 알림이 Watch로 전달될 수 있습니다")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("알림 소리가 나지 않나요?")
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
