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
    @State private var label: String = ""
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    
    @EnvironmentObject var timerManager: TimerManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 라벨 + 시작 버튼
            HStack {
                TextField("라벨을 입력하세요", text: $label)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    timerManager.addTimer(
                        hours: hours,
                        minutes: minutes,
                        seconds: seconds,
                        label: label
                    )
                }) {
                    Text("시작")
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .disabled(label.isEmpty || (hours + minutes + seconds) == 0)
            }

            // 시간 선택 휠
            HStack(spacing: 0) {
                Picker(selection: $hours, label: Text("시")) {
                    ForEach(0..<24) { Text("\($0)시간") }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Picker(selection: $minutes, label: Text("분")) {
                    ForEach(0..<60) { Text("\($0)분") }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Picker(selection: $seconds, label: Text("초")) {
                    ForEach(0..<60) { Text("\($0)초") }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .frame(height: 120)
        }
        .padding()
    }
}

#Preview {
    TimerInputView()
        .environmentObject(TimerManager())
}
