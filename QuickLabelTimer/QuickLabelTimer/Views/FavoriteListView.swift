//
//  FavoriteListView.swift
//  QuickLabelTimer
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
    
    let selectedTab: Tab
    
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
                    emptyMessage: A11yText.FavoriteList.emptyMessage,
                    stateProvider: { _ in
                        return .preset
                    },
                    onDelete: viewModel.hidePreset(at:)
                ) { preset in
                    ZStack {
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
                        // 실행 중인 프리셋
                        if viewModel.isPresetRunning(preset) {
                            Color.black.opacity(0.4)
                                .cornerRadius(12)
                                .padding(4)
                            HStack(spacing: 8) {
                                Text("ui.favorite.runningIndicator")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Image(systemName: "figure.run")
                                    .font(.title)
                                    .scaleEffect(x: -1, y: 1)
                            }
                            .foregroundColor(.white)
                            .accessibilityHidden(true)
                        }
                    }
                    .disabled(viewModel.isPresetRunning(preset))
                    .deleteDisabled(viewModel.isPresetRunning(preset))
                    .accessibilityValue(
                        viewModel.isPresetRunning(preset) ? A11yText.FavoriteList.runningStatus : ""
                    )
                }
                .padding(.horizontal)
                .navigationTitle("ui.favorite.title")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    MainToolbarContent(showSettings: $showSettings, showEditButton: true)
                }
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
        .appAlert(item: $viewModel.activeAlert)
        .onChange(of: selectedTab) {
            if selectedTab != .favorites {
                editMode?.wrappedValue = .inactive
            }
        }
    }
}
