//
//  TimerInputForm.swift
//  LabelTimer
//
//  Created by 이소연 on 7/30/25.
//
/// 타이머 입력 필드를 하나로 묶은 폼 컴포넌트
///
/// - 사용 목적: 타이머 생성 및 수정 화면에서 입력 UI를 재사용할 수 있도록 분리한 폼

import SwiftUI

struct TimerInputForm: View {
    var sectionTitle: String

    @Binding var label: String
    @Binding var hours: Int
    @Binding var minutes: Int
    @Binding var seconds: Int
    @Binding var isSoundOn: Bool
    @Binding var isVibrationOn: Bool
    @FocusState.Binding var isLabelFocused: Bool

    var isStartDisabled: Bool = false
    var onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                SectionTitle(text: sectionTitle)
                Spacer()
                AlarmSettingToggles(
                    isSoundOn: $isSoundOn,
                    isVibrationOn: $isVibrationOn
                )
            }
            LabelInputField(label: $label, isFocused: $isLabelFocused)
            Divider()
            HStack(spacing: 24) {
                TimePickerGroup(
                    hours: $hours,
                    minutes: $minutes,
                    seconds: $seconds
                )
                TimerInputStartButton(
                    isDisabled: isStartDisabled,
                    onTap: onStart
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
    }
}
