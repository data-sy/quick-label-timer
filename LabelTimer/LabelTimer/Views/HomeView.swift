import SwiftUI
import UserNotifications

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
    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 20) {
                Text("LabelTimer")
                    .font(.largeTitle)
                    .bold()

                Button("+ 새 타이머") {
                    path.append(.timerInput)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .timerInput:
                    TimerInputView(path: $path)
                case .runningTimer(data: let data):
                    RunningTimerView(timerData: data, path: $path)
                case .alarm(data: let data):
                    AlarmView(timerData: data, path: $path)
                }
            }
            .onAppear {
                UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        if granted {
                            print("🔔 알림 권한 허용됨")
                        } else {
                            print("❌ 알림 권한 거부됨 또는 오류: \(error?.localizedDescription ?? "알 수 없음")")
                        }
                    }
            }
        }
    }
}

