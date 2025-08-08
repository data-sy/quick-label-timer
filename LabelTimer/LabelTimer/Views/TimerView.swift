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
    @Environment(\.editMode) private var editMode
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }

    @ObservedObject var runningListVM: RunningListViewModel
    
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation {
                            editMode?.wrappedValue = isEditing ? .inactive : .active
                        }
                    } label: {
                        Text(isEditing ? "완료" : "삭제")
                    }
                }
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
