import SwiftUI

//
//  TimerInputView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/9/25.
//
/// 타이머를 입력하는 뷰
///
/// - 사용 목적: 사용자가 라벨과 시간을 입력하고 타이머를 시작할 수 있도록 함.

struct TimerInputView: View {
    @State private var label = ""
    @State private var hours = 0
    @State private var minutes = 0
    @State private var seconds = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 타이틀
            Text("타이머 생성")
                .font(.title2)
                .bold()

            // 입력 필드 + 휠 + 버튼 묶은 내부 박스
            VStack(spacing: 16) {
                LabelInputField(label: $label)

                // 구분선
                Divider()

                HStack(spacing: 24) {
                    TimePickerGroup(
                        hours: $hours,
                        minutes: $minutes,
                        seconds: $seconds
                    )

                    TimerInputStartButton(
                        isDisabled: label.isEmpty || (hours + minutes + seconds) == 0,
                        onTap: {
                            // 타이머 시작 로직
                        }
                    )
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
//        .border(Color.blue)
    }
}

#Preview {
    TimerInputView()
}


#Preview {
    TimerInputView()
        .environmentObject(TimerManager())
}
