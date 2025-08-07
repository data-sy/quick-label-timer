//
//  EditTimerView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/30/25.
//
/// 프리셋 타이머를 수정하는 화면
///
/// - 사용 목적: 사용자가 저장된 프리셋 타이머의 정보를 편집/저장/삭제/실행할 수 있도록 제공

import SwiftUI

struct EditPresetView: View {
    @Binding var label: String
    @Binding var hours: Int
    @Binding var minutes: Int
    @Binding var seconds: Int
    @Binding var isSoundOn: Bool
    @Binding var isVibrationOn: Bool
    @FocusState private var isLabelFocused: Bool

    var onSave: () -> Void
    var onDelete: () -> Void
    var onStart: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("삭제", role: .destructive, action: onDelete)
                Spacer()
                Button("저장", action: onSave)
            }
            .padding(.horizontal, 24)
            Spacer().frame(height: 24)
            TimerInputForm(
                sectionTitle: "타이머 수정",
                label: $label,
                hours: $hours,
                minutes: $minutes,
                seconds: $seconds,
                isSoundOn: $isSoundOn,
                isVibrationOn: $isVibrationOn,
                isLabelFocused: $isLabelFocused,
                isStartDisabled: (hours + minutes + seconds) == 0,
                onStart: {
                    withAnimation(.spring()) {
                        onStart()
                    }
                }
            )
        }
    }
}
