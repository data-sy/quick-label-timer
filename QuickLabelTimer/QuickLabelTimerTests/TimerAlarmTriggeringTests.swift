//
//  TimerAlarmTriggeringTests.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 7/26/25.
//
/// TimerManager의 사운드/진동 알람 트리거 동작에 대한 단위 테스트
///
/// - 사용 목적: 사용자 설정에 따라 올바르게 알람 사운드 또는 진동이 호출되는지 검증

import XCTest
@testable import QuickLabelTimer

final class TimerAlarmTriggeringTests: XCTestCase {
    var timerManager: TimerManager!
    var mockAlarmHandler: MockAlarmHandler!

    override func setUp() {
        super.setUp()
        mockAlarmHandler = MockAlarmHandler()

        let presetRepository = PresetRepository()
        timerManager = TimerManager(
            presetRepository: presetRepository,
            alarmHandler: mockAlarmHandler
        )
    }

    // 🔊✅ 📳✅
    func test_alarmTriggers_whenBothSoundAndVibrationAreOn() {
        let expiredTimer = makeExpiredTimer(label: "사운드+진동", isSoundOn: true, isVibrationOn: true)
        mockAlarmHandler.reset()
        timerManager.timers = [expiredTimer]

        timerManager.tick()

        XCTAssertTrue(mockAlarmHandler.didPlaySound)
        XCTAssertTrue(mockAlarmHandler.didVibrate)
    }

    // 🔊✅ 📳❌
    func test_alarmTriggers_onlySoundOn() {
        let expiredTimer = makeExpiredTimer(label: "사운드만", isSoundOn: true, isVibrationOn: false)
        mockAlarmHandler.reset()
        timerManager.timers = [expiredTimer]

        timerManager.tick()

        XCTAssertTrue(mockAlarmHandler.didPlaySound)
        XCTAssertFalse(mockAlarmHandler.didVibrate)
    }

    // 🔊❌ 📳✅
    func test_alarmTriggers_onlyVibrationOn() {
        let expiredTimer = makeExpiredTimer(label: "진동만", isSoundOn: false, isVibrationOn: true)
        mockAlarmHandler.reset()
        timerManager.timers = [expiredTimer]

        timerManager.tick()

        XCTAssertFalse(mockAlarmHandler.didPlaySound)
        XCTAssertTrue(mockAlarmHandler.didVibrate)
    }

    // 🔊❌ 📳❌
    func test_alarmTriggers_none_whenAllSettingsOff() {
        let expiredTimer = makeExpiredTimer(label: "무음무진동", isSoundOn: false, isVibrationOn: false)
        mockAlarmHandler.reset()
        timerManager.timers = [expiredTimer]

        timerManager.tick()

        XCTAssertFalse(mockAlarmHandler.didPlaySound)
        XCTAssertFalse(mockAlarmHandler.didVibrate)
    }

    // 공통 expired Timer 생성기
    private func makeExpiredTimer(label: String, isSoundOn: Bool, isVibrationOn: Bool) -> TimerData {
        return TimerData(
            label: label,
            hours: 0,
            minutes: 0,
            seconds: 3,
            isSoundOn: isSoundOn,
            isVibrationOn: isVibrationOn,
            createdAt: Date().addingTimeInterval(-2),
            endDate: Date().addingTimeInterval(1), // 앞으로 1초 남은 상태
            remainingSeconds: 1,                  // 타이머에는 1초 남았다고 표시
            status: .running
        )
    }
}
