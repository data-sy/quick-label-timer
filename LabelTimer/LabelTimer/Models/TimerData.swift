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

enum TimerStatus: String, Codable {
    case running
    case paused
    case stopped
    case completed
}
enum TimerEndAction: String, Codable {
    case preserve // 타이머가 끝나면 '보존'한다 (프리셋으로 저장 또는 복구)
    case discard // 타이머가 끝나면 '폐기'한다 (완전 삭제 또는 숨김)
    var isPreserve: Bool { self == .preserve }
    var isDiscard: Bool { self == .discard }
}
struct TimerData: Identifiable, Hashable, Codable {
    let id: UUID
    let label: String
    let hours: Int
    let minutes: Int
    let seconds: Int
    let isSoundOn: Bool
    let isVibrationOn: Bool
    let createdAt: Date
    /// 프리셋 기반 실행일 경우 해당 프리셋의 id, 즉석 타이머는 nil
    let presetId: UUID?
        
    var totalSeconds: Int {
        hours * 3600 + minutes * 60 + seconds
    }

    // 실행 관련 속성
    var endDate: Date
    var remainingSeconds: Int
    var status: TimerStatus
    var pendingDeletionAt: Date? = nil // 삭제 종료 예정 시간
    var endAction: TimerEndAction

    init(
        id: UUID = UUID(),
        label: String,
        hours: Int, minutes: Int, seconds: Int,
        isSoundOn: Bool = true, isVibrationOn: Bool = true,
        createdAt: Date,
        endDate: Date,
        remainingSeconds: Int,
        status: TimerStatus,
        pendingDeletionAt: Date? = nil,
        presetId: UUID? = nil,
        endAction: TimerEndAction
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
        self.pendingDeletionAt = pendingDeletionAt
        self.presetId = presetId
        self.endAction = endAction
    }
}

extension TimerData {
    /// 여러 프로퍼티를 한 번에 업데이트. remainingSeconds가 전달되면 상태 자동 판정
    func updating(
        endDate: Date? = nil,
        remainingSeconds: Int? = nil,
        status: TimerStatus? = nil,
        pendingDeletionAt: Date?? = nil,
        presetId: UUID? = nil,
        endAction: TimerEndAction? = nil
    ) -> TimerData {
        let finalRemaining = remainingSeconds ?? self.remainingSeconds
        let finalStatus = status ?? (finalRemaining > 0 ? .running : .completed)
        
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
            status: finalStatus,
            pendingDeletionAt: pendingDeletionAt ?? self.pendingDeletionAt,
            presetId: presetId ?? self.presetId,
            endAction: endAction ?? self.endAction
        )
    }
    
    /// 현재 remainingSeconds를 "00:00" 또는 "00:00:00"으로 반환
    var formattedTime: String {
        let remaining = max(self.remainingSeconds, 0)
        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        let seconds = remaining % 60
        if hours > 0 {
            return String(format: "%01d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

// 테스트에 필요한 최소한의 파라미터로 TimerData 생성
extension TimerData {
    static func testData(isSoundOn: Bool = true, isVibrationOn: Bool = true,  endAction: TimerEndAction = .discard) -> TimerData {
        return .init(label: "test", hours: 0, minutes: 0, seconds: 1, isSoundOn: isSoundOn, isVibrationOn: isVibrationOn, createdAt: Date(), endDate: Date(), remainingSeconds: 1, status: .running, presetId: nil, endAction: endAction)
    }
}
