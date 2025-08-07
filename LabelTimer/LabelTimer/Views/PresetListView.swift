//
//  PresetListView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 저장된 프리셋 타이머 목록을 보여주는 뷰
///
/// - 사용 목적: 사용자 또는 앱이 제공한 프리셋 타이머를 리스트 형태로 표시하고, 실행 버튼을 통해 타이머를 즉시 시작할 수 있도록 함.

import SwiftUI

struct PresetListView: View {
    @EnvironmentObject var presetManager: PresetManager
    @EnvironmentObject var timerManager: TimerManager

    @State private var presetToDelete: TimerPreset? = nil
    @State private var showingDeleteAlert: Bool = false

    @State private var presetToHide: TimerPreset? = nil
    @State private var showingHideAlert: Bool = false

    // 수정
    @State private var isEditing = false
    @State private var editingPreset: TimerPreset? = nil
    @State private var editingLabel = ""
    @State private var editingHours = 0
    @State private var editingMinutes = 0
    @State private var editingSeconds = 0
    @State private var editingSoundOn = true
    @State private var editingVibrationOn = true
    @State private var showingEditDeleteAlert: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle(text: "즐겨찾기")
            List {
                ForEach(presetManager.allPresets.filter { !$0.isHiddenInList }, id: \.id) { preset in
                    PresetTimerRowView(
                        preset: preset,
                        onAction: { action in
                            handleAction(action, preset: preset)
                        },
                        onToggleFavorite: {
                            presetToHide = preset
                            showingHideAlert = true
                        },
                        onTap: {
                            startEdit(for: preset)
                        }
                    )
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
//        .deleteAlert(
//            isPresented: $showingDeleteAlert,
//            itemName: presetToDelete?.label ?? "",
//            deleteLabel: "타이머"
//        ) {
//            if let preset = presetToDelete {
//                presetManager.deletePreset(preset)
//                presetToDelete = nil
//            }
//        }
        .deleteAlert(
            isPresented: $showingHideAlert,
            itemName: presetToHide?.label ?? "",
            deleteLabel: "즐겨찾기",
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
                            timerManager.runTimer(from: preset, presetManager: presetManager)
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
