import SwiftUI

//
//  TimerInputView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/9/25.
//
/// 시/분/초 및 라벨을 입력받는 타이머 설정 화면
///
/// - 사용 목적: 타이머 시간과 라벨 입력 처리

struct TimerInputView: View {
    @Binding var path: [Route]

    @Binding var hours: Int
    @Binding var minutes: Int
    @Binding var seconds: Int
    @Binding var label: String

    @FocusState private var isLabelFocused: Bool

    var body: some View {
        AppScreenLayout(
            content: {
                VStack(spacing: 24) {
                    TimePickerGroupView(
                        hours: $hours,
                        minutes: $minutes,
                        seconds: $seconds
                    )

                    LabelInputFieldView(
                        label: $label,
                        isLabelFocused: _isLabelFocused
                    )
                }
            },
            bottom: {
                CommonButtonRow(
                    leftTitle: "리셋",
                    leftIcon: "arrow.counterclockwise",
                    leftAction: {
                        hours = 0
                        minutes = 0
                        seconds = 0
                        label = ""
                        isLabelFocused = false
                    },
                    leftColor: .red,
                    leftWidthRatio: 0.23,
                    rightTitle: "타이머 시작",
                    rightAction: {
                        let data = TimerData(
                            hours: hours,
                            minutes: minutes,
                            seconds: seconds,
                            label: label
                        )
                        path.append(.runningTimer(data: data))
                    },
                    rightColor: .green,
                    isRightDisabled: hours + minutes + seconds == 0
                )
            }
        )
        .navigationTitle("타이머 설정")
    }
}
