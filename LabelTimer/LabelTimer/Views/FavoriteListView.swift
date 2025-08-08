//
//  FavoriteListView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 저장된 프리셋 타이머 목록을 보여주는 뷰
///
/// - 사용 목적: 사용자 또는 앱이 제공한 프리셋 타이머를 리스트 형태로 표시하고, 실행 버튼을 통해 타이머를 즉시 시작할 수 있도록 함.

import SwiftUI

struct FavoriteListView: View {
    @EnvironmentObject var presetManager: PresetManager
    @EnvironmentObject var timerManager: TimerManager

    @State private var presetToHide: TimerPreset? = nil
    @State private var showingHideAlert: Bool = false

    // 수정용
    @State private var isEditing = false
    @State private var editingPreset: TimerPreset? = nil
    @State private var editingLabel = ""
    @State private var editingHours = 0
    @State private var editingMinutes = 0
    @State private var editingSeconds = 0
    @State private var editingSoundOn = true
    @State private var editingVibrationOn = true
    @State private var showingEditDeleteAlert: Bool = false

    @State private var showSettings = false
    
    // 화면에 표시될 프리셋 목록
    private var visiblePresets: [TimerPreset] {
        presetManager.allPresets.filter { !$0.isHiddenInList }
    }

    var body: some View {
        NavigationStack {
            SectionContainerView {
                TimerListContainerView(
                    title: nil,
                    items: visiblePresets,
                    emptyMessage: "저장된 즐겨찾기가 없습니다.",
                    stateProvider: { _ in
                        return .preset
                    }
                ) { preset in
                    PresetTimerRowView(
                        preset: preset,
                        onAction: { action in
                            handleAction(action, preset: preset)
                        },
                        onToggleFavorite: {
                            requestToHide(preset)
                        },
                        onTap: {
                            startEdit(for: preset)
                        }
                    )
                }
            }
            .padding(.horizontal)
            .navigationTitle("즐겨찾기")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .deleteAlert(
                isPresented: $showingHideAlert,
                itemName: presetToHide?.label ?? "",
                deleteLabel: "즐겨찾기에서 숨김",
                onDelete: {
                    if let preset = presetToHide {
                        presetManager.hidePreset(withId: preset.id)
                        presetToHide = nil
                    }
                }
            )
            .sheet(isPresented: $isEditing) {
                if let preset = editingPreset {
                    EditPresetView(
                        label: $editingLabel,
                        hours: $editingHours,
                        minutes: $editingMinutes,
                        seconds: $editingSeconds,
                        isSoundOn: $editingSoundOn,
                        isVibrationOn: $editingVibrationOn,
                        onSave: {
                            presetManager.updatePreset(
                                preset,
                                label: editingLabel,
                                hours: editingHours,
                                minutes: editingMinutes,
                                seconds: editingSeconds,
                                isSoundOn: editingSoundOn,
                                isVibrationOn: editingVibrationOn
                            )
                            isEditing = false
                        },
                        onDelete: {
                            showingEditDeleteAlert = true
                        },
                        onStart: {
                            if let preset = editingPreset {
                                presetManager.updatePreset(
                                    preset,
                                    label: editingLabel,
                                    hours: editingHours,
                                    minutes: editingMinutes,
                                    seconds: editingSeconds,
                                    isSoundOn: editingSoundOn,
                                    isVibrationOn: editingVibrationOn
                                )
                                if let updated = presetManager.userPresets.first(where: { $0.id == preset.id }) {
                                    timerManager.runTimer(from: updated, presetManager: presetManager)
                                }
                            } else {
                                timerManager.addTimer(
                                    label: editingLabel,
                                    hours: editingHours,
                                    minutes: editingMinutes,
                                    seconds: editingSeconds,
                                    isSoundOn: editingSoundOn,
                                    isVibrationOn: editingVibrationOn,
                                    presetId: preset.id,
                                    isFavorite: true
                                )
                            }
                            isEditing = false
                        }
                    )
                    .deleteAlert(
                        isPresented: $showingEditDeleteAlert,
                        itemName: editingLabel,
                        deleteLabel: "타이머"
                    ) {
                        if let preset = editingPreset {
                            presetManager.deletePreset(preset)
                            isEditing = false
                        }
                    }
                    .presentationDetents([.medium])
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    private func requestToHide(_ preset: TimerPreset) {
        presetToHide = preset
        showingHideAlert = true
    }

    private func startEdit(for preset: TimerPreset) {
        editingPreset = preset
        editingLabel = preset.label
        editingHours = preset.hours
        editingMinutes = preset.minutes
        editingSeconds = preset.seconds
        editingSoundOn = preset.isSoundOn
        editingVibrationOn = preset.isVibrationOn
        isEditing = true
    }

    private func handleAction(_ action: TimerButtonType, preset: TimerPreset) {
        switch action {
        case .play:
            timerManager.runTimer(from: preset, presetManager: presetManager)

        default:
            break
        }
    }
}
