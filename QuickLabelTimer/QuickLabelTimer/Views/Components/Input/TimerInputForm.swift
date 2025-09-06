//
//  TimerInputForm.swift
//  QuickLabelTimer
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
    @Binding var selectedMode: AlarmMode
    @FocusState.Binding var isLabelFocused: Bool

    var isStartDisabled: Bool = false
    var onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                SectionTitle(text: sectionTitle)
                Spacer()
                AlarmModeSelectorView(selectedMode: $selectedMode)
                    .fixedSize()
                TimeChipButton(label: "+5분", action: addFiveMinutes)
            }
            LabelInputField(
                label: $label,
                isFocused: $isLabelFocused
            )
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
    }
    
    // [+5분] 버튼
    func addFiveMinutes() {
        withAnimation {
            let newMinutes = self.minutes + 5
            
            if newMinutes < 60 {
                self.minutes = newMinutes
            } else {
                self.hours += newMinutes / 60
                self.minutes = newMinutes % 60
            }
        }
    }
}

struct TimeChipButton: View {
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.controlForegroundColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(AppTheme.controlBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .a11y(
            label: LocalizedStringKey(label), // "+5분"
            hint: A11yText.AddTimer.timeChipHint,
            traits: .isButton
        )
    }
}
