//
//  MockAlarmHandler.swift
//  LabelTimer
//
//  Created by 이소연 on 7/26/25.
//
/// AlarmTriggering을 구현한 Mock 객체로, 실제 사운드/진동 없이 호출 횟수나 파라미터 등을 기록함
///
/// - 사용 목적: 테스트에서 알람 관련 메서드 호출을 정밀하게 검증하기 위한 목 객체

import Foundation
import XCTest
@testable import LabelTimer

final class MockAlarmHandler: AlarmTriggering {
    private(set) var playIfNeededCallCount = 0
    private(set) var stopSoundCallCount = 0
    private(set) var stoppedTimerIDs: [UUID] = [] // stopSound가 어떤 ID로 호출되었는지 기록
    private(set) var vibrateCallCount = 0
    private(set) var stopAllSoundsCallCount = 0 // 새로 추가된 메서드의 호출 횟수 기록

    // playSound는 playIfNeeded의 내부 구현이므로, 테스트에서는 playIfNeeded 호출 여부만 확인하면 충분
    // func playSound(for id: UUID) {}

    func stopSound(for id: UUID) {
        stopSoundCallCount += 1
        stoppedTimerIDs.append(id) // 어떤 ID로 호출되었는지 배열에 저장
    }

    func vibrate() {
        vibrateCallCount += 1
    }

    func playIfNeeded(for timer: TimerData) {
        playIfNeededCallCount += 1
    }
    
    func stopAllSounds() {
        stopAllSoundsCallCount += 1
    }
    
    // 모든 추적용 프로퍼티 초기화
    func reset() {
        playIfNeededCallCount = 0
        stopSoundCallCount = 0
        stoppedTimerIDs.removeAll()
        vibrateCallCount = 0
        stopAllSoundsCallCount = 0
    }
}
