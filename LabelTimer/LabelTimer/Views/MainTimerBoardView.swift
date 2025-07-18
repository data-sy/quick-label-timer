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
                TimerInputView()
                RunningTimersView()
                PresetListView()
                    .frame(height: 400) // ScrollView안에 List를 넣을 경우 List의 높이가 자동으로 계산되지 않아서 height가 0으로 렌더링됨. 이를 방지하기 위한 고정 높이
            }
            .padding()
        }
    }
}
