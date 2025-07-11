import SwiftUI
import AudioToolbox

//
//  AlarmView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/9/25.
//
/// 타이머 종료 시 알람과 라벨을 표시하는 화면
///
/// - 사용 목적: 타이머 종료 후 알림 및 라벨 텍스트 강조

struct AlarmView: View {
    let timerData: TimerData
    @Binding var path: [Route]
    
    @State private var alarmTimer: Timer?

    var body: some View {
        VStack(spacing: 24) {
            Text("⏰ 타이머 종료")
                .font(.title3)
                .fontWeight(.regular)

            if !timerData.label.isEmpty {
                Text(timerData.label)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 8)
            } else {
                Spacer().frame(height: 16) // 라벨이 없을 때 간격 유지
            }
            
            Spacer().frame(height: 40)

            HStack {
                Button {
                    stopAlarm()
                    path.append(.runningTimer(data: timerData))
                } label: {
                    Label("재시작", systemImage: "arrow.counterclockwise")
                }
                .frame(width: UIScreen.main.bounds.width * 0.23)
                .padding()
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.primary)
                .cornerRadius(10)
                .contentShape(Rectangle())

                Button("확인") {
                    stopAlarm()
                    path = []
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .contentShape(Rectangle())
            }
            .padding(.horizontal)
            
        }
        .padding()
        .navigationTitle("알람")
        .navigationBarBackButtonHidden(true)
        .onAppear {
            startAlarm()
        }
        .onDisappear {
            stopAlarm()
        }
    }

    func startAlarm() {
        alarmTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            AudioServicesPlaySystemSound(1005) // 사운드
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) // 진동
        }
    }

    func stopAlarm() {
        alarmTimer?.invalidate()
        alarmTimer = nil
    }
}
