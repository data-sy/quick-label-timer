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
    @StateObject private var favoriteTimersVM: FavoriteTimersViewModel

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

        _favoriteTimersVM = StateObject(
            wrappedValue: FavoriteTimersViewModel(
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
                            
                            Spacer()

                            AddTimerView(viewModel: addTimerVM)
                                .accessibilityLabel(A11yText.MainView.addTimerSection)
                                .id("addTimerSection")

                            RunningTimersView(viewModel: runningTimersVM)
                                .accessibilityLabel(A11yText.MainView.runningTimersSection)
                                .id("runningTimersSection")

                            Divider()
                                .padding(.vertical, 12)
                                .accessibilityHidden(true)

                            FavoriteTimersView(
                                viewModel: favoriteTimersVM,
                                editMode: editMode ?? .constant(.inactive),
                                scrollProxy: proxy
                            )
                                .accessibilityLabel(A11yText.MainView.favoriteTimersSection)
                                .id("favoriteTimersSection")
                            
                            Spacer(minLength: 100) // 목록의 사이즈 확보를 위해 필수. 지우지 말 것!
                            
                        }
                        .padding(.horizontal)
                    }
                    .accessibilityIdentifier("unifiedTimerScrollView")

                    // MARK: - Auto-scroll
                     .onReceive(timerDidStart.receive(on: RunLoop.main)) { _ in
                         withAnimation {
                             proxy.scrollTo("runningTimersSection", anchor: .top)
                         }
                     }
                }
                .toolbar {
                    MainToolbarContent(showSettings: $showSettings, showEditButton: false)
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
            }
        }
        .appAlert(item: $favoriteTimersVM.activeAlert)
        .background(AppTheme.pageBackground)
        .tint(.blue)
        .id(colorScheme)
    }
}
