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
    @ObservedObject var viewModel: FavoriteListViewModel
    @State private var showSettings = false
    
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.pageBackground
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
                    FavoritePresetRowView(
                        preset: preset,
                        onToggleFavorite: {
                            viewModel.requestToHide(preset)
                        },
                        onLeftTap: {
                            viewModel.handleLeft(for: preset)
                            editMode?.wrappedValue = .inactive
                        },
                        onRightTap: {
                            viewModel.handleRight(for: preset)
                            editMode?.wrappedValue = .inactive
                        }
                    )
                }
                .padding(.horizontal)
                .navigationTitle("즐겨찾기")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    MainToolbarContent(showSettings: $showSettings, showEditButton: true)
                }
                .confirmationAlert(
                    isPresented: $viewModel.isShowingHideAlert,
                    itemName: viewModel.presetToHide?.label ?? "",
                    titleMessage: "이 타이머를 삭제하시겠습니까?",
                    actionButtonLabel: "삭제",
                    onConfirm: viewModel.confirmHide
                )
                .sheet(isPresented: $viewModel.isEditing, onDismiss: viewModel.stopEditing) {
                    if let preset = viewModel.editingPreset {
                        let editViewModel = EditPresetViewModel(
                            preset: preset,
                            presetRepository: viewModel.presetRepository,
                            timerService: viewModel.timerService
                        )
                        EditPresetView(viewModel: editViewModel)
                        .presentationDetents([.medium])
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
                .standardToolbarStyle()
            }
        }
    }
}
