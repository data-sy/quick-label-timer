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

enum TimerStatus {
    case running
    case paused
    case stopped
    case completed
}

struct TimerData: Identifiable, Hashable {
    let id: UUID

    let label: String
    let hours: Int
    let minutes: Int
    let seconds: Int
    let createdAt: Date
    
    var totalSeconds: Int {
        hours * 3600 + minutes * 60 + seconds
    }

    // 실행 관련 속성
    var endDate: Date
    var remainingSeconds: Int
    var status: TimerStatus

    // 명시적 생성자 (id는 기본값으로 자동 생성 가능)
    init(
        id: UUID = UUID(),
        label: String,
        hours: Int,
        minutes: Int,
        seconds: Int,
        createdAt: Date,
        endDate: Date,
        remainingSeconds: Int,
        status: TimerStatus
    ) {
        self.id = id
        self.label = label
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
        self.createdAt = createdAt
        self.endDate = endDate
        self.remainingSeconds = remainingSeconds
        self.status = status
    }
}

extension TimerData {
    /// 남은 시간 갱신, 완료 여부 자동 판단
    func updating(remainingSeconds: Int) -> TimerData {
        TimerData(
            id: self.id,
            label: self.label,
            hours: self.hours,
            minutes: self.minutes,
            seconds: self.seconds,
            createdAt: self.createdAt,
            endDate: self.endDate,
            remainingSeconds: remainingSeconds,
            status: remainingSeconds > 0 ? .running : .completed // 상태 반영
        )
    }
    /// 상태 변경  (예: 일시정지, 정지, 재시작 등)
    func updating(status: TimerStatus) -> TimerData {
        TimerData(
            id: self.id,
            label: self.label,
            hours: self.hours,
            minutes: self.minutes,
            seconds: self.seconds,
            createdAt: self.createdAt,
            endDate: self.endDate,
            remainingSeconds: self.remainingSeconds,
            status: status
        )
    }
}
