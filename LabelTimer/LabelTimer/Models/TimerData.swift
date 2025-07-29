//
//  TimerData.swift
//  LabelTimer
//
//  Created by 이소연 on 7/9/25.
//
/// 타이머 설정 정보를 저장하는 모델
///
/// - 사용 목적: 타이머의 설정 값과 실행 시각, 종료 시각, 실행 여부, 남은 시간 등을 통합 관리함.

import Foundation

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
    let isSoundOn: Bool
    let isVibrationOn: Bool
    
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
        isSoundOn: Bool = true,
        isVibrationOn: Bool = true,
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
        self.isSoundOn = isSoundOn
        self.isVibrationOn = isVibrationOn
        self.createdAt = createdAt
        self.endDate = endDate
        self.remainingSeconds = remainingSeconds
        self.status = status
    }
}

extension TimerData {
    /// 여러 필드를 한 번에 업데이트. remainingSeconds가 전달되면 상태 자동 판정
    func updating(
        endDate: Date? = nil,
        remainingSeconds: Int? = nil,
        status: TimerStatus? = nil
    ) -> TimerData {
        let finalRemaining = remainingSeconds ?? self.remainingSeconds

        return TimerData(
            id: self.id,
            label: self.label,
            hours: self.hours,
            minutes: self.minutes,
            seconds: self.seconds,
            isSoundOn: self.isSoundOn,
            isVibrationOn: self.isVibrationOn,
            createdAt: self.createdAt,
            endDate: endDate ?? self.endDate,
            remainingSeconds: finalRemaining,
            status: status ?? (finalRemaining > 0 ? .running : .completed)
        )
    }
}
