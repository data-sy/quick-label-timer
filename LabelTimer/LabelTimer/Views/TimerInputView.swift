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
    
    @FocusState private var isLabelFocused: Bool

    var body: some View {
        VStack {

            HStack(spacing: 10) {
                Picker("시", selection: $hours) {
                    ForEach(0..<24, id: \.self) { Text("\($0)시") }
                }
                .pickerStyle(.wheel)
                .frame(width: 100)
                .clipped()

                Picker("분", selection: $minutes) {
                    ForEach(0..<60, id: \.self) { Text("\($0)분") }
                }
                .pickerStyle(.wheel)
                .frame(width: 100)
                .clipped()

                Picker("초", selection: $seconds) {
                    ForEach(0..<60, id: \.self) { Text("\($0)초") }
                }
                .pickerStyle(.wheel)
                .frame(width: 100)
                .clipped()
            }
            .frame(height: 150)
            .padding(.bottom)
            
            HStack {
                Text("레이블")
                    .foregroundColor(.gray)

                TextField("입력", text: $label)
                    .focused($isLabelFocused)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .contentShape(Rectangle()) // 💡 터치 영역 확대
            .onTapGesture {
                isLabelFocused = true
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)

            Spacer().frame(height: 32)

            HStack(spacing: 16) {
                Button("홈으로") {
                    path = []
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.red)
                .cornerRadius(10)
                
                Spacer(minLength: 40)

                Button("타이머 시작") {
                    let data = TimerData(
                        hours: hours,
                        minutes: minutes,
                        seconds: seconds,
                        label: label
                    )
                    path.append(.runningTimer(data: data))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("타이머 설정")
    }
}
