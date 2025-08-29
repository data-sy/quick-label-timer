//
//  MockAlarmHandler.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 7/26/25.
//
/// AlarmTriggering을 구현한 Mock 객체로, 실제 사운드/진동 없이 호출 횟수나 파라미터 등을 기록함
///
/// - 사용 목적: 테스트에서 알람 관련 메서드 호출을 정밀하게 검증하기 위한 목 객체

import Foundation
import XCTest
@testable import QuickLabelTimer

final class MockAlarmHandler: AlarmTriggering {
    private(set) var playIfNeededCallCount = 0
    private(set) var stopCallCount = 0
    private(set) var stoppedTimerIDs: [UUID] = []
    private(set) var stopAllCallCount = 0

    func playIfNeeded(for timer: TimerData) {
        playIfNeededCallCount += 1
    }

    func stop(for id: UUID) {
        stopCallCount += 1
        stoppedTimerIDs.append(id)
    }

    func stopAll() {
        stopAllCallCount += 1
    }
    
    func reset() {
        playIfNeededCallCount = 0
        stopCallCount = 0
        stoppedTimerIDs.removeAll()
        stopAllCallCount = 0
    }
}
