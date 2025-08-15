//
//  FavoriteListViewModel.swift
//  LabelTimer
//
//  Created by 이소연 on 8/8/25.
//
/// FavoriteListView의 상태와 비즈니스 로직을 관리하는 ViewModel
///
/// - 사용 목적: View로부터 이벤트(버튼 클릭 등)를 받아 로직을 처리하고, View에 표시될 데이터를 @Published 프로퍼티로 제공

import SwiftUI
import Combine

class FavoriteListViewModel: ObservableObject {
    let presetRepository: PresetRepositoryProtocol
    let timerService: TimerServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()

    @Published var visiblePresets: [TimerPreset] = []
    
    @Published var presetToHide: TimerPreset?
    @Published var isShowingHideAlert: Bool = false
    
    @Published var editingPreset: TimerPreset?
    @Published var isEditing: Bool = false
    
    init(presetRepository: PresetRepositoryProtocol, timerService: TimerServiceProtocol) {
        self.presetRepository = presetRepository
        self.timerService = timerService
        
        presetRepository.userPresetsPublisher
            .map { presets in
                let visible = presets.filter { !$0.isHiddenInList }
                return visible.sorted { $0.lastUsedAt > $1.lastUsedAt }
            }
            .receive(on: DispatchQueue.main) // UI 업데이트는 메인 스레드에서
            .assign(to: &$visiblePresets)
    }

    // MARK: - Actions (Left / Right)

    /// Left 버튼 액션 처리
    func handleLeft(for preset: TimerPreset) {
        startEditing(for: preset)
    }

    /// Right 버튼 액션 처리
    func handleRight(for preset: TimerPreset) {
        runTimer(from: preset)
    }
    
    // MARK: - Business
        
    /// 타이머 실행 (프리셋 숨김 + 타이머 생성)
    func runTimer(from preset: TimerPreset) {
        presetRepository.updateLastUsed(for: preset.id)
        timerService.runTimer(from: preset)
    }
    
    // MARK: - Hide (즐겨찾기 제거 흐름)
    
    /// 즐겨찾기 삭제 확인창 띄우기
    func requestToHide(_ preset: TimerPreset) {
        presetToHide = preset
        isShowingHideAlert = true
    }
    
    /// 확인창에서의 즐겨찾기 삭제
    func confirmHide() {
        if let preset = presetToHide {
            presetRepository.hidePreset(withId: preset.id)
        }
        presetToHide = nil // 상태 초기화
    }
    
    /// 편집모드에서의 즐겨찾기 삭제
    func hidePreset(at offsets: IndexSet) {
        let presetsToHide = offsets.map { visiblePresets[$0] }
        for preset in presetsToHide {
            presetRepository.hidePreset(withId: preset.id)
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
}
