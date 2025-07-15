import SwiftUI

//
//  RunningTimerRowView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 실행 중인 타이머에 대한 UI를 제공하는 래퍼 뷰
///
/// - 사용 목적: 타이머의 남은 시간과 정지 버튼을 표시함

struct RunningTimerRowView: View {
    let timer: TimerData

    /// 남은 시간을 계산해 포맷된 문자열로 반환
    private var formattedRemainingTime: String {
        let remaining = max(timer.remainingSeconds, 0)
        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        let seconds = remaining % 60

        if hours > 0 {
            return String(format: "%01d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    var body: some View {
        TimerRowView(
            label: timer.label,
            timeText: formattedRemainingTime
//            button: AnyView(
//                Button(action: {
//                    // TODO: 타이머 정지 로직 구현 예정
//                    print("🛑 정지: \(timer.label)")
//                }) {
//                    Image(systemName: "stop.fill")
//                        .foregroundColor(.white)
//                        .padding(8)
//                        .background(Color.red)
//                        .clipShape(Circle())
//                }
//            )
        )
    }
}
