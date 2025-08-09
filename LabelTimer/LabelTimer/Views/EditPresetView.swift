//
//  EditTimerView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/30/25.
//
/// 프리셋 타이머를 수정하는 화면
///
/// - 사용 목적: 사용자가 저장된 프리셋 타이머의 정보를 편집/저장/삭제/실행할 수 있도록 제공

import SwiftUI

struct EditPresetView: View {
    @StateObject private var viewModel: EditPresetViewModel
    
    @FocusState private var isLabelFocused: Bool
    @Environment(\.dismiss) private var dismiss

    init(preset: TimerPreset, presetManager: PresetManager, timerManager: TimerManager) {
        _viewModel = StateObject(wrappedValue: EditPresetViewModel(
            preset: preset,
            presetManager: presetManager,
            timerManager: timerManager
        ))
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                SectionContainerView {
                    VStack(spacing: 0) {
                        TimerInputForm(
                            sectionTitle: "",
                            label: $viewModel.label,
                            hours: $viewModel.hours,
                            minutes: $viewModel.minutes,
                            seconds: $viewModel.seconds,
                            isSoundOn: $viewModel.isSoundOn,
                            isVibrationOn: $viewModel.isVibrationOn,
                            isLabelFocused: $isLabelFocused,
                            isStartDisabled: (viewModel.hours + viewModel.minutes + viewModel.seconds) == 0,
                            onStart: {
                                viewModel.start()
                                dismiss()
                            }
                        )
                    }
                }
                .padding()
                Spacer()
                Button(role: .destructive) {
                    viewModel.isShowingHideAlert = true
                } label: {
                    Text("삭제")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("타이머 수정")
            .navigationBarTitleDisplayMode(.inline)
            .background(AppTheme.contentBackground)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        viewModel.save()
                        dismiss()
                    }
                    // 저장 버튼은 시간이 0이 아닐 때만 활성화
                    .disabled((viewModel.hours + viewModel.minutes + viewModel.seconds) == 0)
                }
            }
            // ViewModel의 상태와 연결된 삭제 확인 알림창입니다.
            .deleteAlert(
                isPresented: $viewModel.isShowingHideAlert,
                itemName: viewModel.label,
                deleteLabel: ""
            ) {
                viewModel.hide()
                dismiss()
            }
        }
    }
}
