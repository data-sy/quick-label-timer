//
//  LabelTimerApp.swift
//  LabelTimer
//
//  Created by 이소연 on 7/9/25.
//

import SwiftUI

@main
struct LabelTimerApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var presetManager = PresetManager()
    @StateObject private var timerManager : TimerManager
    
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    // 지연 초기화(deferred init)
    init() {
        let preset = PresetManager()
        _presetManager = StateObject(wrappedValue: preset)
        _timerManager = StateObject(wrappedValue: TimerManager(presetManager: preset))
        NotificationUtils.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(timerManager)
                .environmentObject(presetManager)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                timerManager.stopAlarmsForExpiredTimers()
            }
        }
    }
}
