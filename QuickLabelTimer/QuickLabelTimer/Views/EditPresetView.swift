//
//  EditTimerView.swift
//  QuickLabelTimer
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
                            isStartDisabled: !viewModel.canStart,
                            maxLabelLength: viewModel.maxLabelLength,
                            onStart: {
                                if viewModel.start() {
                                    dismiss()
                                } else {
                                    isLabelFocused = !viewModel.isLabelValid  // 라벨 문제면 포커스
                                }
                            }
                        )
                    }
                }
                .padding()
                Spacer()
                Button {
                    if viewModel.save() {
                        dismiss()
                    } else {
                        isLabelFocused = !viewModel.isLabelValid
                    }
                } label: {
                    Text("저장")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canSave)
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
                        viewModel.requestToDelete()
                    }
                    .foregroundColor(.red)
                }
            }
            .appAlert(item: $viewModel.activeAlert)
            .onChange(of: viewModel.isDeleted) { deleted in
                 if deleted {
                     dismiss()
                 }
            }
        }
    }
}
