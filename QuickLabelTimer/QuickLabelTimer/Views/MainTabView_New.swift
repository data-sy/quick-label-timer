//
//  MainTabView_New.swift
//  QuickLabelTimer
//
//  Created by Claude on 12/15/25.
//
/// 메인 통합 스크롤 뷰 (실험)
///
/// - 사용 목적: AddTimer와 RunningList를 단일 ScrollView에 통합하여 중첩 스크롤 문제 해결

import SwiftUI
import Combine

struct MainTabView_New: View {
    @Environment(\.colorScheme) private var colorScheme
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

                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal)
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)

                    // MARK: - Auto-scroll (TODO: Phase 2)
                    // .onReceive(timerDidStart.receive(on: RunLoop.main)) { _ in
                    //     withAnimation {
                    //         proxy.scrollTo("runningListSection", anchor: .top)
                    //     }
                    // }
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
        .background(AppTheme.pageBackground)
        .tint(.blue)
        .id(colorScheme)
    }
}
