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
    var sectionTitle: String?

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
                if let sectionTitle {
                    SectionTitle(text: sectionTitle)
                }
                                
                AlarmModeSelectorView(selectedMode: $selectedMode)
                    .fixedSize()
                                
                TimeChipButton(minutes: 5) {
                    addMinutes(5)
                }
                .fixedSize()
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.horizontal, RowTheme.padding)
            .padding(.top, RowTheme.padding)
            
            LabelInputField(
                label: $label,
                isFocused: $isLabelFocused
            )
            .padding(.horizontal, RowTheme.padding)
            
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
            .padding(.horizontal, RowTheme.padding)
        }
        .cornerRadius(RowTheme.cornerRadius)
        .padding(.horizontal, RowTheme.padding)
        .overlay(
            RoundedRectangle(cornerRadius: RowTheme.cornerRadius)
                .stroke(
                    isLabelFocused
                    ? Color.blue.opacity(0.8)
                    : Color(.systemGray4),
                    lineWidth: isLabelFocused ? 1 : 0.5
                )
                .animation(.easeOut(duration: 0.15), value: isLabelFocused)
        )

    }
    
    // [+N분] 버튼 공용 로직
    func addMinutes(_ amount: Int) {
        withAnimation {
            let totalMinutes = hours * 60 + minutes + amount
            
            hours = totalMinutes / 60
            minutes = totalMinutes % 60
        }
    }
}

struct TimeChipButton: View {
    let minutes: Int
    let action: () -> Void
    
    private var labelKey: LocalizedStringKey {
        LocalizedStringKey("ui.input.addMinutes.\(minutes)")
    }
    
    var body: some View {
        Button(action: action) {
            Text(labelKey)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.controlForegroundColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(AppTheme.controlBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .a11y(
            label: labelKey, // "+5분"
            hint: A11yText.AddTimer.timeChipHint,
            traits: .isButton
        )
    }
}
