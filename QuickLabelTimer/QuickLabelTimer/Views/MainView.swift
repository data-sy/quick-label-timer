//
//  MainView.swift
//  QuickLabelTimer
//
//  Created by Claude on 12/15/25.
//
/// 타이머 관리의 메인 화면
///
/// - 사용 목적: 사용자가 타이머를 생성하고 실행하며, 저장된 타이머 목록을 한 화면에서 확인할 수 있도록 제공

import SwiftUI
import Combine

struct MainView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.editMode) private var editMode
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var showSettings = false
    private let timerDidStart: AnyPublisher<Void, Never>

    @StateObject private var addTimerVM: AddTimerViewModel
    @StateObject private var runningTimersVM: RunningTimersViewModel
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
        _runningTimersVM = StateObject(
            wrappedValue: RunningTimersViewModel(
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
                                RunningTimersView(viewModel: runningTimersVM)
                            }
                            .id("runningTimersSection")

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
                             proxy.scrollTo("runningTimersSection", anchor: .top)
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
