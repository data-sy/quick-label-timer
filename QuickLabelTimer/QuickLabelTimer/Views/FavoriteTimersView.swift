//
//  FavoriteTimersView.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//
/// 즐겨찾기(북마크)된 타이머 목록을 표시하는 뷰
///
/// - 사용 목적: 저장된 타이머를 리스트로 보여주고, 실행/편집/삭제 기능을 제공

import SwiftUI

struct FavoriteTimersView: View {
    @ObservedObject var viewModel: FavoriteTimersViewModel
    @Binding var editMode: EditMode
    
    var body: some View {
        TimerSectionView(
            title: String(localized: "ui.favorite.title"),
            items: viewModel.visiblePresets,
            emptyMessage: A11yText.FavoriteTimers.emptyMessage,
            stateProvider: { _ in .preset },
            onDelete: viewModel.hidePreset(at:)
        ) { preset in
            ZStack {
                FavoritePresetRowView(
                    preset: preset,
                    onToggleFavorite: { viewModel.requestToHide(preset) },
                    onLeftTap: {
                        viewModel.startEditing(for: preset)
                        editMode = .inactive
                    },
                    onRightTap: {
                        viewModel.runTimerFromPreset(preset: preset)
                        editMode = .inactive
                    },
                    onLabelChange: { newLabel in
                        viewModel.updateLabel(for: preset.id, newLabel: newLabel)
                    }
                )
                
                // 실행 중일 때 가림막(Overlay) 처리
                if viewModel.isPresetRunning(preset) {
                    runningOverlay
                }
            }
            .disabled(viewModel.isPresetRunning(preset))
            .deleteDisabled(viewModel.isPresetRunning(preset))
            .accessibilityValue(
                viewModel.isPresetRunning(preset) ? A11yText.FavoriteTimers.runningStatus : ""
            )
        }
        .sheet(isPresented: $viewModel.isEditing, onDismiss: viewModel.stopEditing) {
            if let preset = viewModel.editingPreset {
                EditPresetView(viewModel: EditPresetViewModel(
                    preset: preset,
                    presetRepository: viewModel.presetRepository,
                    timerService: viewModel.timerService
                ))
                .presentationDetents([.medium])
            }
        }
    }
    
    private var runningOverlay: some View {
        Color.black.opacity(0.4)
            .cornerRadius(12)
            .padding(4)
            .overlay {
                 HStack(spacing: 8) {
                    Text("ui.favorite.runningIndicator")
                        .font(.title).fontWeight(.bold)
                    Image(systemName: "figure.run")
                        .font(.title).scaleEffect(x: -1, y: 1)
                }
                .foregroundColor(.white)
            }
            .accessibilityHidden(true)
    }
}
