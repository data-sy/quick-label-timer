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
        NotificationUtils.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(timerManager)
                .environmentObject(presetManager)
                .environmentObject(settingsViewModel)
                .preferredColorScheme(settingsViewModel.isDarkMode ? .dark : .light)
        }
        .onChange(of: scenePhase) { newPhase in
            timerManager.updateScenePhase(newPhase)
            if newPhase == .active {
                /// 만료된 타이머 알람 강제 중지 (추후 구조 변경 시 불필요해질 수 있음)
                timerManager.stopAlarmsForExpiredTimers()
                /// 완료된 타이머들에 삭제 예정 시각 세팅(자동 삭제 카운트다운 시작)
                /// 예약된 타이머에 대해 상태별 분기 처리 및 안내 메시지 표시
                timerManager.markCompletedTimersForDeletion(n: Self.deleteCountdownSeconds) { timer in
                    print("[DEBUG] markCompletedTimersForDeletion → handleTimerCompletion 호출: \(timer.label)")
                    timerManager.handleTimerCompletion(timer)
                }
            }
        }
    }
}
