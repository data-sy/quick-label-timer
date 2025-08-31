//
//  AddTimerViewModel.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/28/25.
//
/// AddTimerView의 상태와 로직을 관리하는 ViewModel
///
/// - 사용 목적: 사용자로부터 시간 및 레이블 입력을 받아 타이머를 생성하고 시작하는 핵심 로직을 담당. View는 UI 표시에만 집중하도록 역할을 분리

import SwiftUI

@MainActor
class AddTimerViewModel: ObservableObject {
    private let timerService: TimerServiceProtocol
    
    @Published var label = ""
    @Published var hours = 0
    @Published var minutes = 5
    @Published var seconds = 0
    @Published var selectedMode: AlarmMode
    @Published var activeAlert: AppAlert?
    
    var isStartDisabled: Bool {
        (hours + minutes + seconds) == 0
    }
    
    init(timerService: TimerServiceProtocol, defaultAlarmMode: AlarmMode) {
        self.timerService = timerService
        self.selectedMode = defaultAlarmMode
    }
    
    func setDefaultAlarmMode(_ mode: AlarmMode) {
        self.selectedMode = mode
    }
        
    func startTimer() {
        let attributes = AlarmNotificationPolicy.getBools(from: selectedMode)

        let trimmedLabel = label.trimmingCharacters(in: .whitespacesAndNewlines)

        let success = timerService.addTimer(
            label: trimmedLabel,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            isSoundOn: attributes.sound,
            isVibrationOn: attributes.vibration,
            presetId: nil,
            endAction: .discard
        )
        
        if success {
            resetInputFields()
        } else {
            activeAlert = .timerRunLimit
        }
    }
    
    func resetInputFields() {
        label = ""
        hours = 0
        minutes = 5
        seconds = 0
    }
}
