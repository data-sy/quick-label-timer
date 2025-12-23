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
    let scrollProxy: ScrollViewProxy?
    
    var body: some View {
        TimerSectionView(
            title: String(localized: "ui.favorite.title"),
            items: viewModel.visiblePresets,
            emptyMessage: A11yText.FavoriteTimers.emptyMessage,
            stateProvider: { _ in .preset },
            onDelete: viewModel.hidePreset(at:)
        ) { preset in
            if !viewModel.isPresetRunning(preset) {
                FavoritePresetRowView(
                    preset: preset,
                    scrollProxy: scrollProxy,
                    onToggleFavorite: { viewModel.requestToHide(preset) },
                    onPlayPause: {
                        viewModel.runTimerFromPreset(preset: preset)
                        editMode = .inactive
                    },
                    onDelete: { viewModel.requestToHide(preset) },
                    onEdit: { viewModel.startEditing(for: preset) },
                    onLabelChange: { newLabel in
                        viewModel.updateLabel(for: preset.id, newLabel: newLabel)
                    }
                )
                .id(preset.id)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95)),
                    removal: .opacity.combined(with: .scale(scale: 0.95))
                ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.runningPresetIds)
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
}
