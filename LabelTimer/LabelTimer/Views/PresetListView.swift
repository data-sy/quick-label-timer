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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle(text: "타이머 목록")

            List {
                ForEach(presetManager.allPresets, id: \.id) { preset in
                    PresetTimerRowView(
                        preset: preset,
                        onAction: { action in
                            handleAction(action, preset: preset)
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
                isVibrationOn: preset.isVibrationOn // 에러 안 나라고 잠시 넣은 것. 리팩토링 될 예정
            )
            presetManager.deletePreset(preset)

        case .delete:
            presetToDelete = preset
            showingDeleteAlert = true

        default:
            break
        }
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

