//
//  EditPresetViewModel.swift
//  LabelTimer
//
//  Created by 이소연 on 8/8/25.
//
/// EditPresetView의 상태와 로직을 관리하는 ViewModel
///
/// - 사용 목적: 프리셋 수정 화면 내에서 필요한 모든 데이터(@Published)와 액션(저장, 숨기기, 시작)을 캡슐화하여 View의 복잡도를 낮춥니다.

import SwiftUI

class EditPresetViewModel: ObservableObject {
    private let preset: TimerPreset
    private let presetManager: PresetManager
    private let timerManager: TimerManager
    
    @Published var label: String
    @Published var hours: Int
    @Published var minutes: Int
    @Published var seconds: Int
    @Published var isSoundOn: Bool
    @Published var isVibrationOn: Bool
    @Published var isShowingHideAlert = false
    
    init(preset: TimerPreset, presetManager: PresetManager, timerManager: TimerManager) {
        self.preset = preset
        self.presetManager = presetManager
        self.timerManager = timerManager
        
        self.label = preset.label
        self.hours = preset.hours
        self.minutes = preset.minutes
        self.seconds = preset.seconds
        self.isSoundOn = preset.isSoundOn
        self.isVibrationOn = preset.isVibrationOn
    }
        
    /// 변경된 내용 저장
    func save() {
        presetManager.updatePreset(
            preset,
            label: label,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            isSoundOn: isSoundOn,
            isVibrationOn: isVibrationOn
        )
    }
    
    /// 프리셋 삭제
    func hide() {
        presetManager.hidePreset(withId: preset.id)
    }
    
    /// 변경된 내용으로 타이머 시작
    func start() {
        save()
        if let updatedPreset = presetManager.allPresets.first(where: { $0.id == preset.id }) {
            timerManager.runTimer(from: updatedPreset, presetManager: presetManager)
        }
    }
}
