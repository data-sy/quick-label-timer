//
//  MainTimerBoardView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 앱의 메인 타이머 보드 화면
///
/// - 사용 목적: 타이머 입력, 실행 중 타이머, 프리셋 목록을 한 화면에서 관리

import SwiftUI

struct MainTimerBoardView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
//                // 실험용 폰트 비교 뷰
//                TimerFontExperimentView()
  
                // 기존 뷰
                TimerInputView()
                RunningTimersView()
                PresetListView()
                    .frame(height: 400) // ScrollView 내 List높이 0 방지용 고정 height
            }
            .padding()
        }
    }
}

#Preview {
    let presetManager = PresetManager()
    let timerManager = TimerManager(presetManager: presetManager)
    return MainTimerBoardView()
        .environmentObject(timerManager)
        .environmentObject(presetManager)
}

