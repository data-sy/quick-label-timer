import SwiftUI

//
//  PresetListView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 저장된 프리셋 타이머 목록을 보여주는 뷰
///
/// - 사용 목적: 사용자 또는 앱이 제공한 프리셋 타이머를 리스트 형태로 표시하고, 실행 버튼을 통해 타이머를 즉시 시작할 수 있도록 함.
struct PresetListView: View {
    @EnvironmentObject var presetManager: PresetManager
    @EnvironmentObject var timerManager: TimerManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("타이머 목록")
                .font(.headline)
                .padding(.horizontal)

            List {
                ForEach(presetManager.allPresets, id: \.id) { preset in
                    PresetTimerRowView(
                        preset: preset,
                        onStart: {
                            timerManager.addTimer(
                                hours: preset.hours,
                                minutes: preset.minutes,
                                seconds: preset.seconds,
                                label: preset.label
                            )
                            presetManager.deletePreset(preset)
                        }
                    )
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            presetManager.deletePreset(preset)
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}
