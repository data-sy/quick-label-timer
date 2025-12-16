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

    @StateObject private var addTimerVM: AddTimerViewModel
    @StateObject private var runningTimersVM: RunningTimersViewModel
    @StateObject private var favoriteListVM: FavoriteListViewModel

    @State private var showSettings = false
    private let timerDidStart: AnyPublisher<Void, Never>


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
                            
                            SectionContainerView {
                                FavoriteTimersView(
                                    viewModel: favoriteListVM,
                                    editMode: editMode ?? .constant(.inactive)
                                )
                            }
                            .id("favoriteListSection") //TODO: list->timers

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
                .standardToolbarStyle()
            }
        }
        .appAlert(item: $favoriteListVM.activeAlert)
        .background(AppTheme.pageBackground)
        .tint(.blue)
        .id(colorScheme)
    }
}
