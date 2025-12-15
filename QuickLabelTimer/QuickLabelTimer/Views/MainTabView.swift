//
//  MainTabView.swift
//  QuickLabelTimer
//
//  Created by Claude on 12/15/25.
//
/// 메인 통합 스크롤 뷰 (실험)
///
/// - 사용 목적: AddTimer와 RunningList를 단일 ScrollView에 통합하여 중첩 스크롤 문제 해결

import SwiftUI
import Combine

struct MainTabView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.editMode) private var editMode
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var showSettings = false
    private let timerDidStart: AnyPublisher<Void, Never>

    @StateObject private var addTimerVM: AddTimerViewModel
    @StateObject private var runningListVM: RunningListViewModel
    @StateObject private var favoriteListVM: FavoriteListViewModel

    init(
        timerService: any TimerServiceProtocol,
        timerRepository: TimerRepositoryProtocol,
        presetRepository: PresetRepositoryProtocol
    ) {
        self.timerDidStart = timerService.didStart.eraseToAnyPublisher()

        _addTimerVM = StateObject(
            wrappedValue: AddTimerViewModel(
                timerService: timerService,
                defaultAlarmMode: .sound
            )
        )
        _runningListVM = StateObject(
            wrappedValue: RunningListViewModel(
                timerService: timerService,
                timerRepository: timerRepository,
                presetRepository: presetRepository
            )
        )

        _favoriteListVM = StateObject(
            wrappedValue: FavoriteListViewModel(
                presetRepository: presetRepository,
                timerService: timerService,
                timerRepository: timerRepository
            )
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.pageBackground
                    .ignoresSafeArea()

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            SectionContainerView {
                                AddTimerView(viewModel: addTimerVM)
                            }
                            .id("addTimerSection")

                            Divider()
                                .padding(.vertical, 12)
                                .accessibilityHidden(true)

                            SectionContainerView {
                                RunningListView(viewModel: runningListVM)
                            }
                            .id("runningListSection")

                            Divider()
                                .padding(.vertical, 12)
                                .accessibilityHidden(true)

                            TimerSectionView(
                                title: String(localized: "ui.favorite.title"),
                                items: favoriteListVM.visiblePresets,
                                emptyMessage: A11yText.FavoriteList.emptyMessage,
                                stateProvider: { _ in .preset },
                                onDelete: favoriteListVM.hidePreset(at:)
                            ) { preset in
                                ZStack {
                                    FavoritePresetRowView(
                                        preset: preset,
                                        onToggleFavorite: { favoriteListVM.requestToHide(preset) },
                                        onLeftTap: {
                                            favoriteListVM.handleLeft(for: preset)
                                            editMode?.wrappedValue = .inactive
                                        },
                                        onRightTap: {
                                            favoriteListVM.handleRight(for: preset)
                                            editMode?.wrappedValue = .inactive
                                        }
                                    )

                                    if favoriteListVM.isPresetRunning(preset) {
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
                                .disabled(favoriteListVM.isPresetRunning(preset))
                                .deleteDisabled(favoriteListVM.isPresetRunning(preset))
                                .accessibilityValue(
                                    favoriteListVM.isPresetRunning(preset)
                                        ? A11yText.FavoriteList.runningStatus
                                        : ""
                                )
                            }
                            .id("favoriteListSection")

                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal)
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)

                    // MARK: - Auto-scroll (TODO: anchor 위치 고민)
                     .onReceive(timerDidStart.receive(on: RunLoop.main)) { _ in
                         withAnimation {
                             proxy.scrollTo("runningListSection", anchor: .top)
                         }
                     }
                }
                .navigationTitle("ui.timer.title")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    MainToolbarContent(showSettings: $showSettings, showEditButton: false)
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
                .sheet(isPresented: $favoriteListVM.isEditing, onDismiss: favoriteListVM.stopEditing) {
                    if let preset = favoriteListVM.editingPreset {
                        let editViewModel = EditPresetViewModel(
                            preset: preset,
                            presetRepository: favoriteListVM.presetRepository,
                            timerService: favoriteListVM.timerService
                        )
                        EditPresetView(viewModel: editViewModel)
                            .presentationDetents([.medium])
                    }
                }
                .standardToolbarStyle()
            }
        }
        .appAlert(item: $favoriteListVM.activeAlert)
        .background(AppTheme.pageBackground)
        .tint(.blue)
        .id(colorScheme)
    }
}
