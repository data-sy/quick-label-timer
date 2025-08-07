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
    
    var body: some View {
        VStack(spacing: 0) {
            MainHeaderView{
                showSettings = true
            }
            TabView {
                TimerView()
                    .tabItem { Label("타이머", systemImage: "timer") }
                FavoritesView()
                    .tabItem { Label("즐겨찾기", systemImage: "star.fill") }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}
