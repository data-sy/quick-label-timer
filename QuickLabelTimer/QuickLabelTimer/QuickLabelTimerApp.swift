//
//  QuickLabelTimerApp.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 7/9/25.
//
/// 앱 진입점 및 환경설정, 글로벌 상태 객체 초기화
///
/// - 사용 목적: 앱 최상위 진입점으로서 초기 뷰(scene)를 설정하고, 앱 전역 공유 객체를 생성해 환경에 주입

import SwiftUI

@main
struct QuickLabelTimerApp: App {
    static let deleteCountdownSeconds = 10
    
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var timerRepository: TimerRepository
    @StateObject private var presetRepository: PresetRepository
    @StateObject private var timerService: TimerService
    @StateObject private var settingsViewModel: SettingsViewModel

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // 지연 초기화(deferred init)
    init() {
        logLocalizationState()
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
        .onChange(of: scenePhase) { _, newPhase in
            timerService.updateScenePhase(newPhase)
        }
    }
}

private func logLocalizationState() {
    print("Locale.current =", Locale.current)
    print("Preferred localizations =", Bundle.main.preferredLocalizations)
    print("Available localizations =", Bundle.main.localizations)
}
