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
    
    // MARK: - Init

    /// 초기화 시: UserDefaults에서 프리셋 불러오거나 기본 프리셋 저장
    init() {
        loadPresets()
    }
    
    // MARK: - Preset 목록
    
    /// 전체 프리셋 목록 (기본 + 사용자)
    var allPresets: [TimerPreset] {
        userPresets
    }
    
    // MARK: - CRUD

    /// 사용자 프리셋 추가
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

    /// 프리셋 수정
    func updatePreset(
        _ preset: TimerPreset,
        label: String,
        hours: Int,
        minutes: Int,
        seconds: Int,
        isSoundOn: Bool,
        isVibrationOn: Bool
    ) {
        guard let index = userPresets.firstIndex(where: { $0.id == preset.id }) else { return }
        // 기존 id와 createdAt(필요시)만 유지, 나머지는 새로 생성
        let updated = TimerPreset(
            id: preset.id,
            label: label,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            isSoundOn: isSoundOn,
            isVibrationOn: isVibrationOn,
            createdAt: preset.createdAt, // 있으면 유지
            isHiddenInList: preset.isHiddenInList
        )
        userPresets[index] = updated
        savePresets()
    }

    /// 사용자 프리셋 삭제
    func deletePreset(_ preset: TimerPreset) {
        userPresets.removeAll { $0.id == preset.id }
        savePresets()
    }

    // MARK: - 숨김/표시 상태 관리
    
    /// 프리셋 숨기기
    func hidePreset(withId id: UUID) {
        if let idx = userPresets.firstIndex(where: { $0.id == id }) {
            userPresets[idx].isHiddenInList = true
            savePresets()
        }
    }

    /// 프리셋 다시 보이기
    func showPreset(withId id: UUID) {
        if let idx = userPresets.firstIndex(where: { $0.id == id }) {
            userPresets[idx].isHiddenInList = false
            savePresets()
        }
    }
    
    // MARK: - Persistence
    
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
