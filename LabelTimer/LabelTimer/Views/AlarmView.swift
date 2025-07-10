import SwiftUI

//
//  AlarmView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/9/25.
//
/// 타이머 종료 시 알람과 라벨을 표시하는 화면
///
/// - 사용 목적: 타이머 종료 후 알림 및 라벨 텍스트 강조
/// - ViewModel: RunningTimerViewModel

struct AlarmView: View {
    let timerData: TimerData
    @Binding var path: [Route]

    var body: some View {
        VStack(spacing: 24) {
            Text("⏰ 타이머 종료")
                .font(.largeTitle)

            if !timerData.label.isEmpty {
                Text("라벨: \(timerData.label)")
                    .font(.title2)
                    .foregroundColor(.gray)
            }

            Button("재시작") {
                path.append(.runningTimer(timerData))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("홈으로") {
                path = []
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.red)
            .cornerRadius(10)
        }
        .padding()
        .navigationTitle("알람")
        .navigationBarBackButtonHidden(true)
    }
}

