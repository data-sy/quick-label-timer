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
    @ObservedObject var runningListVM: RunningListViewModel
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.pageBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    SectionContainerView{
                        AddTimerView()
                    }
                    Divider()
                    SectionContainerView{
                        RunningListView(viewModel: runningListVM)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .navigationTitle("타이머 실행")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    MainToolbarContent(showSettings: $showSettings, showEditButton: false)
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
                .standardToolbarStyle()
            }
        }
    }
}
