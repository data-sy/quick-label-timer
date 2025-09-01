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
            Section(header: Text(.init("""
                iOS 알림의 진동(햅틱) 동작은 **시스템 설정에 따라 달라**집니다.  
                진동이 느껴지지 않는다면 아래 항목을 확인해 주세요.
                """))){}

            Section(header: Text("시스템 설정 확인")) {
                Text(.init("**설정 > 손쉬운 사용 > 터치**로 이동해 '진동'이 켜져 있는지 확인해 주세요"))
                Text(.init("""
                **설정 > 사운드 및 햅틱**으로 이동해 아래 항목을 확인해 주세요
                  **•** '벨소리 모드에서 햅틱 재생'이 켜져 있는지
                  **•** '무음 모드에서 햅틱 재생'이 켜져 있는지
                  **•** '시스템 햅틱'이 켜져 있는지
                """))
            }

            Section(header: Text("집중 모드 확인")) {
                Text(.init("**설정 > 집중 모드**에서 활성화된 모드가 알림/진동을 차단하지 않는지 확인해 주세요"))
            }

            Section(header: Text("Apple Watch 사용자")) {
                Text(.init("Apple Watch를 착용 중이라면, 알림이 Watch로 전달될 수 있습니다"))
                Text(.init("**Watch 앱 > 나의 시계 > 사운드 및 햅틱**에서 '촉각' 강도가 충분한지 확인하세요"))
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("진동 문제 해결")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        VibrationHelpView()
    }
}
