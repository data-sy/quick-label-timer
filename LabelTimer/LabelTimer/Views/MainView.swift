//
//  MainView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 앱의 메인 타이머 보드 화면
///
/// - 사용 목적: 타이머 입력, 실행 중 타이머, 프리셋 목록을 한 화면에서 관리

import SwiftUI

struct MainView: View {
    @State private var showSettings = false
    
    var body: some View {
        MainHeaderView {
            showSettings = true
        }
        ScrollView {
            VStack(spacing: 24) {
                AddTimerView()
                RunningTimersView()
                PresetListView()
                    .frame(height: 400) // ScrollView 내 List높이 0 방지용 고정 height
            }
            .padding()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}
