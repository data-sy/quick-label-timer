//
//  MainTabView.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/7/25.
//
/// 메인 탭바 컨테이너
///
/// - 사용 목적: 홈, 즐겨찾기, 설정 화면을 탭으로 전환하는 루트 뷰

import SwiftUI
import Combine

enum Tab {
    case timer
    case favorites
}

struct MainTabView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var selectedTab: Tab = .timer
    private let timerDidStart: AnyPublisher<Void,Never>
    
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
    
    // 슬라이드 방식
    var body: some View {
        TabView(selection: $selectedTab) {
            TimerView(addTimerVM: addTimerVM, runningListVM: runningListVM)
                .tag(Tab.timer)
            
            FavoriteListView(viewModel: favoriteListVM, selectedTab: selectedTab)
                .tag(Tab.favorites)
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .animation(.easeInOut, value: selectedTab)
        .background(AppTheme.pageBackground)
        .onReceive(timerDidStart.receive(on: RunLoop.main)) { _ in
            selectedTab = .timer
        }
        .tint(.blue)
        .id(colorScheme)
    }
}
