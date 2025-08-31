//
//  EditPresetViewModel.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/8/25.
//
/// EditPresetView의 상태와 로직을 관리하는 ViewModel
///
/// - 사용 목적: 프리셋 수정에 필요한 데이터(@Published)와 액션(저장, 숨기기 등)을 캡슐화하여 View의 복잡도를 낮춤

import SwiftUI

@MainActor
class EditPresetViewModel: ObservableObject {
    private let preset: TimerPreset
    private let presetRepository: PresetRepositoryProtocol
    private let timerService: TimerServiceProtocol

    let maxLabelLength = AppConfiguration.maxLabelLength
    
    @Published var label: String
    @Published var hours: Int
    @Published var minutes: Int
    @Published var seconds: Int
    @Published var selectedMode: AlarmMode
    @Published var activeAlert: AppAlert?
    @Published var isDeleted = false
    
    // 재생, 저장 유효성
    var totalSeconds: Int { hours * 3600 + minutes * 60 + seconds }
    var trimmedLabel: String { label.trimmingCharacters(in: .whitespacesAndNewlines) } // "   " 공백 라벨도 무효로 판단
    var isLabelValid: Bool { !trimmedLabel.isEmpty }
    var isDurationValid: Bool { totalSeconds > 0 }
    var canStart: Bool { isLabelValid && isDurationValid }
    var canSave:  Bool { isLabelValid && isDurationValid }
    
    init(preset: TimerPreset, presetRepository: PresetRepositoryProtocol, timerService: TimerServiceProtocol) {
        self.preset = preset
        self.presetRepository = presetRepository
        self.timerService = timerService
        
        self.label = preset.label
        self.hours = preset.hours
        self.minutes = preset.minutes
        self.seconds = preset.seconds
        let initialPolicy = AlarmNotificationPolicy.determine(
            soundOn: preset.isSoundOn,
            vibrationOn: preset.isVibrationOn
        )
        self.selectedMode = initialPolicy.asMode
    }
        
    /// 변경된 내용 저장
    @discardableResult
    func save() -> Bool {
        guard canSave else { return false }
        let attributes = AlarmNotificationPolicy.getBools(from: selectedMode)
        presetRepository.updatePreset(
            preset,
            label: label,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            isSoundOn: attributes.sound,
            isVibrationOn: attributes.vibration
        )
        return true
    }
    
    // 타이머 삭제 확인창 띄우기
    func requestToDelete() {
        activeAlert = .confirmDeletion(
            itemName: self.label,
            onConfirm: { [weak self] in
                self?.hide()
            }
        )
    }
    
    /// 프리셋 삭제
    func hide() {
        presetRepository.hidePreset(withId: preset.id)
        isDeleted = true
    }
    
    /// 변경된 내용으로 타이머 시작
    func start() -> Bool {
        guard canStart else { return false }
        save()
        if let updatedPreset = presetRepository.allPresets.first(where: { $0.id == preset.id }) {
            let success = timerService.runTimer(from: updatedPreset)
            
            if !success {
                activeAlert = .timerRunLimit
                return false
            }
        }
        return true
    }
}
