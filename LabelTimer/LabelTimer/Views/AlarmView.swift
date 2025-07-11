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
        AppScreenLayout(
            content: {
                VStack(spacing: 24) {
                    TimerTitleView(text: "타이머 종료")
                    LabelDisplayView(label: timerData.label)
                    CountdownView(seconds: 0).hidden() // 공간 확보용
                }
            },
            bottom: {
                CommonButtonRow(
                    leftTitle: "재시작",
                    leftIcon: "arrow.counterclockwise",
                    leftAction: {
                        stopAlarm()
                        path.append(.runningTimer(data: timerData))
                    },
                    leftColor: .primary,
                    leftWidthRatio: 0.23,
                    rightTitle: "확인",
                    rightAction: {
                        stopAlarm()
                        path = []
                    },
                    rightColor: .blue,
                    isRightDisabled: false
                )
            }
        )
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
