import SwiftUI

//
//  HomeView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/9/25.
//
/// 타이머 생성을 시작하는 메인 화면
///
/// - 사용 목적: "+ 새 타이머" 버튼을 통해 입력 화면으로 이동
/// - ViewModel: 없음

struct HomeView: View {
    @State private var path: [TimerData] = []

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Spacer()

                NavigationLink("＋ 새 타이머", destination: TimerInputView(path: $path))
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)

                Spacer()
            }
            .navigationTitle("홈")
            .navigationDestination(for: TimerData.self) { timerData in
                RunningTimerView(timerData: timerData)
            }
        }
    }
}
