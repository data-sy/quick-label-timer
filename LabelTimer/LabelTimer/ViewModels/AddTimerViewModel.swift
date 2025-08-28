//
//  AddTimerViewModel.swift
//  LabelTimer
//
//  Created by 이소연 on 8/28/25.
//

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

        let success = timerService.addTimer(
            label: label,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            isSoundOn: attributes.sound,
            isVibrationOn: attributes.vibration,
            presetId: nil,
            isFavorite: false
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
