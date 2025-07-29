//
//  TimerInputView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/9/25.
//
/// 타이머를 입력하는 뷰
///
/// - 사용 목적: 사용자가 라벨과 시간을 입력하고 타이머를 시작할 수 있도록 함.

import SwiftUI

struct TimerInputView: View {
    @State private var label = ""
    @State private var hours = 0
    @State private var minutes = 0
    @State private var seconds = 0
    @State private var isSoundOn = true
    @State private var isVibrationOn = true
    
    @FocusState private var isLabelFocused: Bool
    
    @EnvironmentObject var timerManager: TimerManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                SectionTitle(text: "타이머 생성")

                Spacer()
                
                AlarmSettingToggles(
                    isSoundOn: $isSoundOn,
                    isVibrationOn: $isVibrationOn
                )
            }

            // 입력 필드 + 휠 + 버튼 묶은 내부 박스
            VStack(spacing: 0) {
                LabelInputField(label: $label, isFocused: $isLabelFocused)

                // 구분선
                Divider()

                HStack(spacing: 24) {
                    TimePickerGroup(
                        hours: $hours,
                        minutes: $minutes,
                        seconds: $seconds
                    )

                    TimerInputStartButton(
                        isDisabled: (hours + minutes + seconds) == 0,
                        onTap: {
                            let total = hours * 3600 + minutes * 60 + seconds
                            guard total > 0 else { return }

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
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
//        .border(Color.blue)
    }
}

#Preview {
    let presetManager = PresetManager()
    let timerManager = TimerManager(presetManager: presetManager)
    return TimerInputView()
        .environmentObject(timerManager)
}
