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

    @StateObject private var timerRepository: TimerRepository
    @StateObject private var presetRepository: PresetRepository
    @StateObject private var timerService: TimerService
    @StateObject private var settingsViewModel: SettingsViewModel

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // 지연 초기화(deferred init)
    init() {
        let timerRepository = TimerRepository()
        let presetRepository = PresetRepository()
        let timerService = TimerService(
            timerRepository: timerRepository,
            presetRepository: presetRepository,
            deleteCountdownSeconds: Self.deleteCountdownSeconds
        )

        _timerRepository = StateObject(wrappedValue: timerRepository)
        _presetRepository = StateObject(wrappedValue: presetRepository)
        _timerService = StateObject(wrappedValue: timerService)
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel())
        
        // 디버그 매니저에 실제 서비스 주입
        #if DEBUG
        AlarmDebugManager.timerService = timerService
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView(
                timerService: timerService,
                timerRepository: timerRepository,
                presetRepository: presetRepository
            )
            .environmentObject(timerService)
            .environmentObject(timerRepository)
            .environmentObject(presetRepository)
            .environmentObject(settingsViewModel)
            .preferredColorScheme(settingsViewModel.isDarkMode ? .dark : .light)
        }
        .onChange(of: scenePhase) { newPhase in
            timerService.updateScenePhase(newPhase)
        }
    }
}
