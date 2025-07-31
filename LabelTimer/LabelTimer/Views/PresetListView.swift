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

    @State private var isEditing = false
    @State private var editingPreset: TimerPreset? = nil
    @State private var editingLabel = ""
    @State private var editingHours = 0
    @State private var editingMinutes = 0
    @State private var editingSeconds = 0
    @State private var editingSoundOn = true
    @State private var editingVibrationOn = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle(text: "타이머 목록")
            List {
                ForEach(presetManager.allPresets, id: \.id) { preset in
                    PresetTimerRowView(
                        preset: preset,
                        onAction: { action in
                            handleAction(action, preset: preset)
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
//        .border(Color.green)
        .alert("\(presetToDelete?.label.isEmpty == false ? "“\(presetToDelete!.label)”" : "이") 타이머를 삭제하시겠습니까?",
               isPresented: $showingDeleteAlert,
               actions: {
                   Button("취소", role: .cancel) { }
                   Button("삭제", role: .destructive) {
                       if let preset = presetToDelete {
                           presetManager.deletePreset(preset)
                           presetToDelete = nil
                       }
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
//                        presetManager.updatePreset( // 함수 만들 예정
//                            preset,
//                            label: editingLabel,
//                            hours: editingHours,
//                            minutes: editingMinutes,
//                            seconds: editingSeconds,
//                            isSoundOn: editingSoundOn,
//                            isVibrationOn: editingVibrationOn
//                        )
                    },
                    onDelete: {
                        presetManager.deletePreset(preset)
                    },
                    onStart: {
                        timerManager.addTimer(
                            label: editingLabel,
                            hours: editingHours,
                            minutes: editingMinutes,
                            seconds: editingSeconds,
                            isSoundOn: editingSoundOn,
                            isVibrationOn: editingVibrationOn
                        )
                        // 필요하다면 프리셋 삭제 등 후처리
                    }
                )
                .presentationDetents([.medium])
            }
        }
    }
    
    private func handleAction(_ action: TimerButtonType, preset: TimerPreset) {
        switch action {
        case .play:
            timerManager.addTimer(
                label: preset.label,
                hours: preset.hours,
                minutes: preset.minutes,
                seconds: preset.seconds,
                isSoundOn: preset.isSoundOn,
                isVibrationOn: preset.isVibrationOn
            )
            presetManager.deletePreset(preset)

        case .delete:
            presetToDelete = preset
            showingDeleteAlert = true

        default:
            break
        }
    }
    private func startEdit(for preset: TimerPreset) {
        editingPreset = preset
        editingPreset = preset
        editingLabel = preset.label
        editingHours = preset.hours
        editingMinutes = preset.minutes
        editingSeconds = preset.seconds
        editingSoundOn = preset.isSoundOn
        editingVibrationOn = preset.isVibrationOn
        isEditing = true
    }
}

#if DEBUG
struct PresetListView_Previews: PreviewProvider {
    static var previews: some View {
        let presetManager = PresetManager()
        presetManager.setPresets([
            TimerPreset(label: "집중", hours: 0, minutes: 25, seconds: 0, isSoundOn: true, isVibrationOn: true),
            TimerPreset(label: "짧은 휴식", hours: 0, minutes: 5, seconds: 0, isSoundOn: false, isVibrationOn: true),
            TimerPreset(label: "긴 휴식", hours: 0, minutes: 15, seconds: 0, isSoundOn: true, isVibrationOn: false)
        ])

        let timerManager = TimerManager(presetManager: presetManager)

        return PresetListView()
            .environmentObject(presetManager)
            .environmentObject(timerManager)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
#endif
