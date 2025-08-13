//
//  MainTabView.swift
//  LabelTimer
//
//  Created by 이소연 on 8/7/25.
//
/// 메인 탭바 컨테이너
///
/// - 사용 목적: 홈, 즐겨찾기, 설정 화면을 탭으로 전환하는 루트 뷰

import SwiftUI
import Combine

enum Tab {
//    case debug
    case timer
    case favorites
}

struct MainTabView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var selectedTab: Tab = .timer
    private let timerDidStart: AnyPublisher<Void,Never>
    
    @StateObject private var runningListVM: RunningListViewModel
    @StateObject private var favoriteListVM: FavoriteListViewModel
    
    init(presetManager: PresetManager, timerManager: TimerManager) {
        self.timerDidStart = timerManager.didStart.eraseToAnyPublisher()
        
        _runningListVM = StateObject(
            wrappedValue: RunningListViewModel(
                timerManager: timerManager,
                presetManager: presetManager
            )
        )
        _favoriteListVM = StateObject(
            wrappedValue: FavoriteListViewModel(
                presetManager: presetManager,
                timerManager: timerManager
            )
        )
    }
    
    // 슬라이드 방식
    var body: some View {
        TabView(selection: $selectedTab) {
//            NotificationTestView()
//                .tag(Tab.debug)
            TimerView(runningListVM: runningListVM)
                .tag(Tab.timer)
            
            FavoriteListView(viewModel: favoriteListVM)
                .tag(Tab.favorites)
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .animation(.easeInOut, value: selectedTab)
        .background(AppTheme.pageBackground)
        .onReceive(timerDidStart.receive(on: RunLoop.main)) { _ in
            selectedTab = .timer
        }
        .id(settingsViewModel.isDarkMode)
    }
}
