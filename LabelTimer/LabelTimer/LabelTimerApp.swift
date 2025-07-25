import SwiftUI

//
//  LabelTimerApp.swift
//  LabelTimer
//
//  Created by 이소연 on 7/9/25.
//

@main
struct LabelTimerApp: App {
    @StateObject private var presetManager = PresetManager()
    @StateObject private var timerManager : TimerManager
    
    // 지연 초기화(deferred init)
    init() {
        let preset = PresetManager()
        _presetManager = StateObject(wrappedValue: preset)
        _timerManager = StateObject(wrappedValue: TimerManager(presetManager: preset))
        NotificationUtils.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTimerBoardView()
                .environmentObject(timerManager)
                .environmentObject(presetManager)
                .preferredColorScheme(.dark) // 다크모드
        }
    }
}
