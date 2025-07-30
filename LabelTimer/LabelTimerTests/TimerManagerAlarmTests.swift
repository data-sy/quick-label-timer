//
//  TimerManagerAlarmTests.swift
//  LabelTimer
//
//  Created by 이소연 on 7/26/25.
//
/// TimerManagerAlarmTests
///
/// - 사용 목적: TimerManager가 타이머 종료 시 사운드 및 진동을 정상적으로 트리거하는지 검증

import Foundation
import Testing
@testable import LabelTimer

struct TimerManagerAlarmTests {

    final class MockAlarmHandler: AlarmTriggering {
        var playedSoundId: UUID?
        var vibrated = false

        func playSound(for id: UUID) {
            playedSoundId = id
        }

        func stopSound(for id: UUID) {}

        func vibrate() {
            vibrated = true
        }
        
        func playIfNeeded(for timer: TimerData) {
            if timer.isSoundOn {
                playSound(for: timer.id)
            }
            if timer.isVibrationOn {
                vibrate()
            }
        }
    }

    @Test
    func test_tick_triggersSoundAndVibrationWhenTimerEnds() async throws {
        let mockHandler = MockAlarmHandler()
        let manager = TimerManager(
            presetManager: PresetManager(),
            alarmHandler: mockHandler
        )

        manager.addTimer(label: "test", hours: 0, minutes: 0, seconds: 1, isSoundOn: true, isVibrationOn: true)

        // 시간이 1초 남은 상태에서 tick() 호출 → 0초로 줄어들며 알람 트리거
        manager.timers[0] = manager.timers[0].updating(remainingSeconds: 1)
        manager.tick()

        #expect(mockHandler.playedSoundId == manager.timers[0].id)
        #expect(mockHandler.vibrated == true)
    }
}
