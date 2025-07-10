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
/// - ViewModel: TimerInputViewModel

struct TimerInputView: View {
    @Binding var path: [Route]

    @State private var hours = 0
    @State private var minutes = 0
    @State private var seconds = 0
    @State private var label = ""

    var body: some View {
        VStack {
            Form {
                Section(header: Text("시간 설정")) {
                    Stepper("시: \(hours)", value: $hours, in: 0...23)
                    Stepper("분: \(minutes)", value: $minutes, in: 0...59)
                    Stepper("초: \(seconds)", value: $seconds, in: 0...59)
                }

                Section(header: Text("라벨")) {
                    TextField("라벨을 입력하세요", text: $label)
                }

                // ✅ 타이머 시작 버튼 (Form 안에 포함)
                Section {
                    Button("타이머 시작") {
                        let data = TimerData(
                            hours: hours,
                            minutes: minutes,
                            seconds: seconds,
                            label: label
                        )
                        path.append(.runningTimer(data))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }

            Button("홈으로") {
                path = []
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.red)
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("타이머 설정")
    }
}

