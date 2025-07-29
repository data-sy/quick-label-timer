//
//  PresetManager.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 프리셋 타이머를 관리하는 매니저 클래스
///
/// - 사용 목적: 앱 최초 실행 시 기본 프리셋을 등록하고, 사용자 프리셋을 UserDefaults에 저장/관리함.

import Foundation

final class PresetManager: ObservableObject {
    /// 사용자 정의 프리셋 목록 (최초 실행 시 기본 프리셋 포함)
    @Published var userPresets: [TimerPreset] = []

    /// UserDefaults 저장 키
    private let userDefaultsKey = "user_presets"

    /// 최초 실행 여부 확인 키
    private let didInitializeKey = "did_initialize_presets"

    /// 초기화 시: UserDefaults에서 프리셋 불러오거나 기본 프리셋 저장
    init() {
        loadPresets()
    }

    /// 사용자 프리셋 추가
    /// - Parameter preset: 새로 추가할 프리셋
    func addPreset(_ preset: TimerPreset) {
        userPresets.append(preset)
        savePresets()
    }
    
    /// 실행 중 타이머를 프리셋으로 추가
    func addPreset(from timer: TimerData) {
        let preset = TimerPreset(
            label: timer.label,
            hours: timer.hours,
            minutes: timer.minutes,
            seconds: timer.seconds,
            isSoundOn: timer.isSoundOn,
            isVibrationOn: timer.isVibrationOn,
            createdAt: Date()
        )
        userPresets.insert(preset, at: 0) // 최신순을 유지하기 위해 앞에 삽입
        savePresets()
    }

    /// 사용자 프리셋 삭제
    /// - Parameter preset: 삭제할 프리셋
    func deletePreset(_ preset: TimerPreset) {
        userPresets.removeAll { $0.id == preset.id }
        savePresets()
    }

    /// 전체 프리셋 목록 (기본 + 사용자)
    var allPresets: [TimerPreset] {
        userPresets
    }

    /// 프리셋 불러오기 (최초 실행 시에는 기본 프리셋 저장)
    private func loadPresets() {
        let defaults = UserDefaults.standard
        let didInitialize = defaults.bool(forKey: didInitializeKey)

        if !didInitialize {
            userPresets = samplePresets
            savePresets()
            defaults.set(true, forKey: didInitializeKey)
            return
        }

        if let data = defaults.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([TimerPreset].self, from: data) {
            userPresets = decoded
        }
    }

    /// 프리셋 저장
    private func savePresets() {
        if let data = try? JSONEncoder().encode(userPresets) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
}

#if DEBUG
extension PresetManager {
    func setPresets(_ presets: [TimerPreset]) {
        self.userPresets = presets
    }
}
#endif
