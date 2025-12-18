//
//  FavoriteTimersViewModel.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/8/25.
//
/// FavoriteTimersView의 상태와 비즈니스 로직을 관리하는 ViewModel
///
/// - 사용 목적: View로부터 이벤트(버튼 클릭 등)를 받아 로직을 처리하고, View에 표시될 데이터를 @Published 프로퍼티로 제공

import SwiftUI
import Combine

@MainActor
class FavoriteTimersViewModel: ObservableObject {
    // MARK: - Dependencies
    let presetRepository: PresetRepositoryProtocol
    let timerService: any TimerServiceProtocol
    private let timerRepository: TimerRepositoryProtocol
    
    // MARK: - Published Properties for UI
    @Published var visiblePresets: [TimerPreset] = []
    @Published private(set) var runningPresetIds: Set<UUID> = []
    
    @Published var presetToHide: TimerPreset?
    @Published var isShowingHideAlert: Bool = false
    
    @Published var editingPreset: TimerPreset?
    @Published var isEditing: Bool = false
    
    @Published var activeAlert: AppAlert?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()

    
    init(presetRepository: PresetRepositoryProtocol, timerService: any TimerServiceProtocol, timerRepository: TimerRepositoryProtocol) {
        self.presetRepository = presetRepository
        self.timerService = timerService
        self.timerRepository = timerRepository
        
        // 프리셋 목록 구독
        presetRepository.userPresetsPublisher
            .map { presets in
                let visible = presets.filter { !$0.isHiddenInList }
                return visible.sorted { $0.createdAt > $1.createdAt }
            }
            .receive(on: DispatchQueue.main) // UI 업데이트는 메인 스레드에서
            .assign(to: \.visiblePresets, on: self)
            .store(in: &cancellables)
        
        // 타이머 목록 구독
        timerRepository.timersPublisher
            .map { timers in
                let ids = timers.compactMap { $0.presetId } // presetId가 nil이 아닌 타이머들
                return Set(ids)
            }
            .receive(on: RunLoop.main)
            .assign(to: \.runningPresetIds, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - State Checkers
    
    // 프리셋이 실행 중인지 확인
    func isPresetRunning(_ preset: TimerPreset) -> Bool {
        return runningPresetIds.contains(preset.id)
    }
    
    // MARK: - Actions (Left / Right)

//    /// Left 버튼 액션 처리
//    func handleLeft(for preset: TimerPreset) {
//        startEditing(for: preset)
//    }
//
//    /// Right 버튼 액션 처리
//    func handleRight(for preset: TimerPreset) {
//        runTimer(from: preset)
//    }
//    
    // MARK: - Business
    
    /// 프리셋의 라벨 업데이트
    func updateLabel(for presetId: UUID, newLabel: String) {
        presetRepository.updatePresetLabel(presetId: presetId, newLabel: newLabel)
    }
        
    /// 타이머 실행 (프리셋 숨김 + 타이머 생성)
    func runTimer(from preset: TimerPreset) {
        presetRepository.updateLastUsed(for: preset.id)
        let success = timerService.runTimer(from: preset)
        if !success {
            activeAlert = .timerRunLimit
        }
    }
    
    // MARK: - Hide (즐겨찾기 제거 흐름)
    
    /// 즐겨찾기 삭제 확인창 띄우기
    func requestToHide(_ preset: TimerPreset) {
        activeAlert = .confirmDeletion(
            itemName: preset.label,
            onConfirm: { [weak self] in
                self?.presetRepository.hidePreset(withId: preset.id)
            }
        )
    }
    
    /// 편집모드에서의 즐겨찾기 삭제
    func hidePreset(at offsets: IndexSet) {
        let presetsToHide = offsets.map { visiblePresets[$0] }
        var wasDeletionBlocked = false
        
        for preset in presetsToHide {
            if isPresetRunning(preset) {
                wasDeletionBlocked = true
            } else {
                presetRepository.hidePreset(withId: preset.id)
            }
        }

        if wasDeletionBlocked {
            activeAlert = .cannotDeleteRunningPreset
        }
    }
    
    // MARK: - Edit
    
    /// 프리셋 수정화면 열기
    func startEditing(for preset: TimerPreset) {
        editingPreset = preset
        isEditing = true
    }
    
    /// 프리셋 수정화면 닫기
    func stopEditing() {
        editingPreset = nil
        isEditing = false
    }

    // MARK: - Direct Button Actions

    /// Run 버튼 액션 - 프리셋에서 타이머를 실행합니다
    func runTimerFromPreset(preset: TimerPreset) {
        runTimer(from: preset)
        print("Run timer from preset: \(preset.label)")
    }
}
