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

struct MainTabView: View {
    @State private var showSettings = false
    @StateObject private var favoriteListVM: FavoriteListViewModel
    
    init(presetManager: PresetManager, timerManager: TimerManager) {
        _favoriteListVM = StateObject(
            wrappedValue: FavoriteListViewModel(
                presetManager: presetManager,
                timerManager: timerManager
            )
        )
    }
    
    // 탭뷰 방식
    var body: some View {
        VStack(spacing: 0) {
            TabView {
                TimerView()
                    .tabItem { Label("타이머", systemImage: "timer") }
                FavoriteListView(viewModel: favoriteListVM)
                    .tabItem { Label("즐겨찾기", systemImage: "star.fill") }
            }
            .onReceive(favoriteListVM.timerDidRunPublisher) { _ in
                    selectedTab = .timer
            }
        }
    }
    

}
