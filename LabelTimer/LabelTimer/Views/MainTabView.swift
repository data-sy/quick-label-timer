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

enum Tab {
    case timer
    case favorites
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .timer
    @StateObject private var favoriteListVM: FavoriteListViewModel
    
    init(presetManager: PresetManager, timerManager: TimerManager) {
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
            TimerView()
                .tag(Tab.timer)
            
            FavoriteListView(viewModel: favoriteListVM)
                .tag(Tab.favorites)
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .onReceive(favoriteListVM.timerDidRunPublisher) { _ in
            withAnimation(.easeInOut) {
                self.selectedTab = .timer
            }
        }
    }
}
