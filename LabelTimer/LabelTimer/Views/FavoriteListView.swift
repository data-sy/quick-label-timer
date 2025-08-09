//
//  FavoriteListView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 저장된 프리셋 타이머 목록을 보여주는 뷰
///
/// - 사용 목적: 사용자 또는 앱이 제공한 프리셋 타이머를 리스트 형태로 표시하고, 실행 버튼을 통해 타이머를 시작할 수 있도록 함

import SwiftUI

struct FavoriteListView: View {
    @Environment(\.editMode) private var editMode
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }

    @ObservedObject var viewModel: FavoriteListViewModel
    
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                TimerListContainerView(
                    title: nil,
                    items: viewModel.visiblePresets,
                    emptyMessage: "저장된 즐겨찾기가 없습니다.",
                    stateProvider: { _ in
                        return .preset
                    },
                    onDelete: viewModel.hidePreset(at:)
                ) { preset in
                    PresetTimerRowView(
                        preset: preset,
                        onAction: { action in
                            viewModel.runTimer(from: preset)
                        },
                        onToggleFavorite: {
                            viewModel.requestToHide(preset)
                        },
                        onTap: {
                            viewModel.startEditing(for: preset)
                        }
                    )
                }
                .padding(.horizontal)
                .navigationTitle("즐겨찾기")
                .navigationBarTitleDisplayMode(.large)
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
                .deleteAlert(
                    isPresented: $viewModel.isShowingHideAlert,
                    itemName: viewModel.presetToHide?.label ?? "",
                    deleteLabel: "즐겨찾기에서 숨김",
                    onDelete: viewModel.confirmHide
                )
                .sheet(isPresented: $viewModel.isEditing, onDismiss: viewModel.stopEditing) {
                    if let preset = viewModel.editingPreset {
                        EditPresetView(
                            preset: preset,
                            presetManager: viewModel.presetManager,
                            timerManager: viewModel.timerManager
                        )
                        .presentationDetents([.medium])
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
                .toolbarBackground(
                    Color(.systemGroupedBackground),
                    for: .navigationBar
                )
                .toolbarBackground(.visible, for: .navigationBar)
            }
        }
    }
}
