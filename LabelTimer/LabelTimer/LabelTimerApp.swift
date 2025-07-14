import SwiftUI

//
//  LabelTimerApp.swift
//  LabelTimer
//
//  Created by 이소연 on 7/9/25.
//

@main
struct LabelTimerApp: App {
    var body: some Scene {
        WindowGroup {
            MainTimerBoardView()
                .environmentObject(TimerManager())
                .onAppear {
                    NotificationUtils.requestAuthorization()
                }
        }
    }
}
