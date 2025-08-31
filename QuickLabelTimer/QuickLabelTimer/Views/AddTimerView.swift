//
//  AddTimerView.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 7/30/25.
//
/// 새로운 타이머를 생성하는 화면
///
/// - 사용 목적: 사용자가 타이머의 라벨, 시간, 사운드/진동 옵션을 입력하고, 타이머를 추가할 수 있도록 제공

import SwiftUI

struct AddTimerView: View {
    @AppStorage("defaultAlarmMode") private var defaultAlarmMode: AlarmMode = .sound
    @ObservedObject private var viewModel: AddTimerViewModel
    
    @FocusState private var isLabelFocused: Bool
    
    init(viewModel: AddTimerViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            TimerInputForm(
                sectionTitle: "타이머 생성",
                label: $viewModel.label,
                hours: $viewModel.hours,
                minutes: $viewModel.minutes,
                seconds: $viewModel.seconds,
                selectedMode: $viewModel.selectedMode,
                isLabelFocused: $isLabelFocused,
                isStartDisabled: viewModel.isStartDisabled,
                onStart: {
                    if isLabelFocused { isLabelFocused = false }
                    viewModel.startTimer()
//                    // TODO: 기존 코드에서 DispatchQueue를 없앤 상태. 만약 문제가 발생한다면 다시 투입할 예정
//                    DispatchQueue.main.async {
//                        viewModel.startTimer()
//                    }
                }
            )
            .appAlert(item: $viewModel.activeAlert)
        }
        .onAppear {
            viewModel.setDefaultAlarmMode(defaultAlarmMode)
        }
        .onChange(of: defaultAlarmMode) { newValue in
            viewModel.setDefaultAlarmMode(newValue)
        }
        .onSubmit { isLabelFocused = false }
        .submitLabel(.done)
    }
}
