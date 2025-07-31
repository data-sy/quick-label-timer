//
//  AddTimerView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/30/25.
//
/// 새로운 타이머를 생성하는 화면
///
/// - 사용 목적: 사용자가 타이머의 라벨, 시간, 사운드/진동 옵션을 입력하고, 타이머를 추가할 수 있도록 제공

import SwiftUI

struct AddTimerView: View {
    @State private var label = ""
    @State private var hours = 0
    @State private var minutes = 0
    @State private var seconds = 0
    @State private var isSoundOn = true
    @State private var isVibrationOn = true
    @FocusState private var isLabelFocused: Bool

    @EnvironmentObject var timerManager: TimerManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            TimerInputForm(
                sectionTitle: "타이머 생성",
                label: $label,
                hours: $hours,
                minutes: $minutes,
                seconds: $seconds,
                isSoundOn: $isSoundOn,
                isVibrationOn: $isVibrationOn,
                isLabelFocused: $isLabelFocused,
                isStartDisabled: (hours + minutes + seconds) == 0,
                onStart: {
                    timerManager.addTimer(
                        label: label,
                        hours: hours,
                        minutes: minutes,
                        seconds: seconds,
                        isSoundOn: isSoundOn,
                        isVibrationOn: isVibrationOn
                    )
                    // 입력 초기화
                    label = ""
                    hours = 0
                    minutes = 0
                    seconds = 0
                }
            )
        }
    }
}

#Preview {
    let presetManager = PresetManager()
    let timerManager = TimerManager(presetManager: presetManager)
    return AddTimerView()
        .environmentObject(timerManager)
}
