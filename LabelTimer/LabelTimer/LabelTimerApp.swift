import SwiftUI

//
//  LabelTimerApp.swift
//  LabelTimer
//
//  Created by 이소연 on 7/9/25.
//

@main
struct LabelTimerApp: App {
    @StateObject private var timerManager = TimerManager()
    @StateObject private var presetManager = PresetManager()

    var body: some Scene {
        WindowGroup {
            MainTimerBoardView()
                .environmentObject(timerManager)
                .environmentObject(presetManager)
                .onAppear {
                    NotificationUtils.requestAuthorization()
                }
        }
    }
}
