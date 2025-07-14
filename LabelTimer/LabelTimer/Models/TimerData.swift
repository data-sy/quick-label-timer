import Foundation

//
//  TimerData.swift
//  LabelTimer
//
//  Created by 이소연 on 7/9/25.
//
/// 타이머 설정 정보를 저장하는 모델
///
/// - 사용 목적: 타이머의 설정 값과 실행 시각, 종료 시각, 실행 여부, 남은 시간 등을 통합 관리함.

struct TimerData: Identifiable, Hashable {
    let id: UUID = UUID()

    let label: String
    let hours: Int
    let minutes: Int
    let seconds: Int

    var totalSeconds: Int {
        hours * 3600 + minutes * 60 + seconds
    }

    // ⏱ 실행 관련 속성
    var startDate: Date
    var endDate: Date
    var isRunning: Bool
    var remainingSeconds: Int
}

extension TimerData {
    func updating(remainingSeconds: Int) -> TimerData {
        TimerData(
            label: self.label,
            hours: self.hours,
            minutes: self.minutes,
            seconds: self.seconds,
            startDate: self.startDate,
            endDate: self.endDate,
            isRunning: remainingSeconds > 0,
            remainingSeconds: remainingSeconds
        )
    }
}
