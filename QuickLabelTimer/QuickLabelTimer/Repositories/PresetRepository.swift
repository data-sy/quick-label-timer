//
//  PresetRepository.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 프리셋 타이머를 저장하고 관리하는 저장소 클래스
///
/// - 사용 목적: 앱 최초 실행 시 기본 프리셋을 초기화하고, 사용자 정의 프리셋을 UserDefaults에 영속화하여
///          추가, 수정, 삭제, 숨김/표시 등의 CRUD 동작을 전역에서 관리함


import Foundation
import Combine
import OSLog

// MARK: - Protocol Definition
protocol PresetRepositoryProtocol {
    var allPresets: [TimerPreset] { get }
    var visiblePresetsCount: Int { get }
    var userPresetsPublisher: AnyPublisher<[TimerPreset], Never> { get }

    func getPreset(byId id: UUID) -> TimerPreset?
    func addPreset(from timer: TimerData) -> Bool
    func showPreset(withId id: UUID)
    func hidePreset(withId id: UUID)
    func updatePreset(_ preset: TimerPreset, label: String, hours: Int, minutes: Int, seconds: Int, isSoundOn: Bool, isVibrationOn: Bool)
    func updateLastUsed(for presetId: UUID)
}

// MARK: - PresetRepository Class
final class PresetRepository: ObservableObject, PresetRepositoryProtocol {
    
    private let logger = Logger.withCategory("PresetRepository")
    
    @Published var userPresets: [TimerPreset] = []
    
    // MARK: - Preset 목록
    
    /// 전체 프리셋 목록 (숨김 포함)
    var allPresets: [TimerPreset] {
        userPresets
    }
    
    /// 사용자에게 보여지는 프리셋 개수 (숨김 제외)
    var visiblePresetsCount: Int {
        userPresets.filter { !$0.isHiddenInList }.count
    }
    
    // Publisher
    var userPresetsPublisher: AnyPublisher<[TimerPreset], Never> {
        $userPresets.eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties

    private let userDefaultsKey = "user_presets"
    private let didInitializeKey = "did_initialize_presets"
    
    // MARK: - Initializer
    
    init() {
        loadPresets()
    }
    
    // MARK: - CRUD
    
    /// ID로 특정 프리셋 객체 반환
    func getPreset(byId id: UUID) -> TimerPreset? {
        userPresets.first { $0.id == id }
    }
    
    /// 사용자 프리셋 추가
    func addPreset(_ preset: TimerPreset) -> Bool {
        guard visiblePresetsCount < 20 else {
            
            #if DEBUG
            logger.info("프리셋 개수 제한(20개) 도달")
            #endif
            
            return false
        }
        userPresets.append(preset)
        savePresets()
        return true
    }
    
    /// 실행 중 타이머를 프리셋으로 추가
    @discardableResult
    func addPreset(from timer: TimerData) -> Bool {
        guard visiblePresetsCount < 20 else {
            
            #if DEBUG
            logger.info("프리셋 개수 제한(20개) 도달")
            #endif
            
            return false
        }
        
        let now = Date()
        let preset = TimerPreset(
            label: timer.label,
            hours: timer.hours,
            minutes: timer.minutes,
            seconds: timer.seconds,
            isSoundOn: timer.isSoundOn,
            isVibrationOn: timer.isVibrationOn,
            createdAt: now,
            lastUsedAt: now
        )
        userPresets.insert(preset, at: 0)
        savePresets()
        return true
    }

    /// 프리셋 수정
    func updatePreset(_ preset: TimerPreset, label: String, hours: Int, minutes: Int, seconds: Int, isSoundOn: Bool, isVibrationOn: Bool) {
        guard let index = userPresets.firstIndex(where: { $0.id == preset.id }) else {
            
            #if DEBUG
            logger.warning("수정하려는 프리셋(\(preset.id, privacy: .public))을 찾을 수 없습니다.")
            #endif
            
            return
        }
        
        let updated = TimerPreset(
            id: preset.id,
            label: label,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            isSoundOn: isSoundOn,
            isVibrationOn: isVibrationOn,
            createdAt: preset.createdAt,
            lastUsedAt: preset.lastUsedAt,
            isHiddenInList: preset.isHiddenInList
        )
        userPresets[index] = updated
        savePresets()
    }
    
    // 마지막 사용 시간 업데이트
    func updateLastUsed(for presetId: UUID) {
        if let index = userPresets.firstIndex(where: { $0.id == presetId }) {
            userPresets[index].lastUsedAt = Date()
            savePresets()
        }
    }

    /// 사용자 프리셋 삭제
    func deletePreset(_ preset: TimerPreset) {
        
        #if DEBUG
        logger.debug("Deleting preset with ID: \(preset.id, privacy: .public)")
        #endif

        userPresets.removeAll { $0.id == preset.id }
        savePresets()
    }

    // MARK: - 숨김/표시 상태 관리

    /// 프리셋 숨기기
    func hidePreset(withId id: UUID) {
        guard let idx = userPresets.firstIndex(where: { $0.id == id }) else {

            #if DEBUG
            logger.warning("숨기려는 프리셋(\(id, privacy: .public))을 찾을 수 없습니다.")
            #endif

            return
        }
        
        if let idx = userPresets.firstIndex(where: { $0.id == id }) {
            userPresets[idx].isHiddenInList = true
            savePresets()
        }
    }

    /// 프리셋 다시 보이기
    func showPreset(withId id: UUID) {
        if let idx = userPresets.firstIndex(where: { $0.id == id }) {
            userPresets[idx].isHiddenInList = false
            userPresets[idx].lastUsedAt = Date()
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

            #if DEBUG
            logger.debug("First launch: Initializing with \(self.userPresets.count) sample presets.")
            #endif
            
            return
        }

        if let data = defaults.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([TimerPreset].self, from: data) {
            userPresets = decoded
            
            #if DEBUG
            logger.debug("Loaded \(decoded.count) presets from UserDefaults.")
            #endif
            
        }
    }
    
    /// 프리셋 저장
    private func savePresets() {
        
        #if DEBUG
        logger.debug("Saving \(self.userPresets.count) presets to UserDefaults.")
        #endif
        
        if let data = try? JSONEncoder().encode(userPresets) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
}
