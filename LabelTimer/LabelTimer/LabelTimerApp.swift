//
//  LabelTimerApp.swift
//  LabelTimer
//
//  Created by 이소연 on 7/9/25.
//
/// 앱 진입점 및 환경설정, 글로벌 상태 객체 초기화
///

import SwiftUI

@main
struct LabelTimerApp: App {
    static let deleteCountdownSeconds = 10
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var presetManager: PresetManager
    @StateObject private var timerManager: TimerManager
    @StateObject private var settingsViewModel: SettingsViewModel
    
    
    // 지연 초기화(deferred init)
    init() {
        let preset = PresetManager()
        _presetManager = StateObject(wrappedValue: preset)
        _timerManager = StateObject(
            wrappedValue: TimerManager(
                presetManager: preset,
                deleteCountdownSeconds: Self.deleteCountdownSeconds
            )
        )
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel())
        
        // 페이지 인디케이터 색상 설정
        UIPageControl.appearance().currentPageIndicatorTintColor = .label
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray4
        
        NotificationUtils.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView(
                presetManager: presetManager,
                timerManager: timerManager
            )
            .environmentObject(timerManager)
            .environmentObject(presetManager)
            .environmentObject(settingsViewModel)
            .preferredColorScheme(settingsViewModel.isDarkMode ? .dark : .light)
        }
        .onChange(of: scenePhase) { newPhase in
            timerManager.updateScenePhase(newPhase)
        }
    }
}
