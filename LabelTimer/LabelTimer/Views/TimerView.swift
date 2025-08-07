//
//  TimerView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 앱의 메인 타이머 보드 화면
///
/// - 사용 목적: 타이머 입력, 실행 중 타이머, 프리셋 목록을 한 화면에서 관리

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var presetManager: PresetManager

    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                AddTimerView()
                RunningListView(timerManager: timerManager, presetManager: presetManager)
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .navigationTitle("타이머 실행")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
