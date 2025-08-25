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

    init(viewModel: EditPresetViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                            selectedMode: $viewModel.selectedMode,
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
                Button {
                    viewModel.save()
                    dismiss()
                } label: {
                    Text("저장")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .disabled((viewModel.hours + viewModel.minutes + viewModel.seconds) == 0) // 저장 비활성화 조건
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
                    Button("삭제", role: .destructive) {
                        viewModel.isShowingHideAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .confirmationAlert(
                isPresented: $viewModel.isShowingHideAlert,
                itemName: viewModel.label,
                titleMessage: "이 타이머를 삭제하시겠습니까?",
                actionButtonLabel: "삭제",
                onConfirm: {
                    viewModel.hide()
                    dismiss()
                }
            )
        }
    }
}
