//
//  TimerAlarmTriggerTests.swift
//  LabelTimerTests
//
//  Created by 이소연 on 7/26/25.
//
/// TimerManager의 사운드/진동 알람 트리거 동작에 대한 단위 테스트
///
/// - 사용 목적: 사용자 설정에 따라 올바르게 알람 사운드 또는 진동이 호출되는지 검증

import XCTest
@testable import LabelTimer

final class TimerAlarmTriggerTests: XCTestCase {
    var timerManager: TimerManager!
    var mockAlarmHandler: MockAlarmHandler!

    override func setUp() {
        super.setUp()
        mockAlarmHandler = MockAlarmHandler()

        // 공유 인스턴스 설정값 초기화
        UserSettings.shared.isSoundOn = false
        UserSettings.shared.isVibrationOn = false

        let presetManager = PresetManager()
        timerManager = TimerManager(
            presetManager: presetManager,
            userSettings: UserSettings.shared,
            alarmHandler: mockAlarmHandler
        )
    }

    // 🔊✅ 📳✅
    func test_alarmTriggers_whenBothSoundAndVibrationAreOn() {
        UserSettings.shared.isSoundOn = true
        UserSettings.shared.isVibrationOn = true

        let expiredTimer = makeExpiredTimer(label: "사운드+진동")
        mockAlarmHandler.reset()
        timerManager.timers = [expiredTimer]

        timerManager.tick()

        XCTAssertTrue(mockAlarmHandler.didPlaySound)
        XCTAssertTrue(mockAlarmHandler.didVibrate)
    }

    // 🔊✅ 📳❌
    func test_alarmTriggers_onlySoundOn() {
        UserSettings.shared.isSoundOn = true
        UserSettings.shared.isVibrationOn = false

        let expiredTimer = makeExpiredTimer(label: "사운드만")
        mockAlarmHandler.reset()
        timerManager.timers = [expiredTimer]

        timerManager.tick()

        XCTAssertTrue(mockAlarmHandler.didPlaySound)
        XCTAssertFalse(mockAlarmHandler.didVibrate)
    }

    // 🔊❌ 📳✅
    func test_alarmTriggers_onlyVibrationOn() {
        UserSettings.shared.isSoundOn = false
        UserSettings.shared.isVibrationOn = true

        let expiredTimer = makeExpiredTimer(label: "진동만")
        mockAlarmHandler.reset()
        timerManager.timers = [expiredTimer]

        timerManager.tick()

        XCTAssertFalse(mockAlarmHandler.didPlaySound)
        XCTAssertTrue(mockAlarmHandler.didVibrate)
    }

    // 🔊❌ 📳❌
    func test_alarmTriggers_none_whenAllSettingsOff() {
        UserSettings.shared.isSoundOn = false
        UserSettings.shared.isVibrationOn = false

        let expiredTimer = makeExpiredTimer(label: "무음무진동")
        mockAlarmHandler.reset()
        timerManager.timers = [expiredTimer]

        timerManager.tick()

        XCTAssertFalse(mockAlarmHandler.didPlaySound)
        XCTAssertFalse(mockAlarmHandler.didVibrate)
    }

    // 공통 expired Timer 생성기
    private func makeExpiredTimer(label: String) -> TimerData {
        return TimerData(
            label: label,
            hours: 0,
            minutes: 0,
            seconds: 3,
            createdAt: Date().addingTimeInterval(-2),
            endDate: Date().addingTimeInterval(1), // 앞으로 1초 남은 상태
            remainingSeconds: 1,                  // 타이머에는 1초 남았다고 표시
            status: .running
        )
    }
}
