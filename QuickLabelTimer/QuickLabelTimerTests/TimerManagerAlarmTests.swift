//
//  TimerManagerAlarmTests.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 7/26/25.
//
/// TimerManagerAlarmTests
///
/// - 사용 목적: TimerManager가 타이머 상태 및 앱 환경 변화에 따라 알람을 정상적으로 제어하는지 검증

import Foundation
import Testing
@testable import QuickLabelTimer

@Suite("TimerManager 알람 제어 로직 테스트")
struct TimerManagerAlarmTests {
    final class MockAlarmHandler: AlarmTriggering {
        var playIfNeededCallCount = 0
        var stopCallCount = 0
        var stoppedTimerIDs: [UUID] = []
        var stopAllCallCount = 0

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
    }

    @Test("타이머 종료 시 playIfNeeded가 호출되는지 검증")
    func test_tick_triggersPlayIfNeededWhenTimerEnds() {
        // given
        let mockHandler = MockAlarmHandler()
        let manager = TimerManager(presetRepository: PresetRepository(), deleteCountdownSeconds: 10, alarmHandler: mockHandler)
        manager.addTimer(label: "test", hours: 0, minutes: 0, seconds: 1, isSoundOn: true, isVibrationOn: true)
        
        // when
        manager.timers[0].remainingSeconds = 1
        manager.tick()

        // then
        #expect(mockHandler.playIfNeededCallCount == 1)
    }
    
    @Test("Scene이 Active가 되면 stopAll이 호출되는지 검증")
    func test_updateScenePhase_toActive_stopsAllAlarms() {
        let mockHandler = MockAlarmHandler()
        let manager = TimerManager(presetRepository: PresetRepository(), deleteCountdownSeconds: 10, alarmHandler: mockHandler)

        manager.updateScenePhase(.active)

        #expect(mockHandler.stopAllCallCount == 1)
    }
    
    @Test("타이머 삭제 시 stop이 호출되는지 검증")
    func test_removeTimer_stopsAlarmForThatTimer() {
        let mockHandler = MockAlarmHandler()
        let manager = TimerManager(presetRepository: PresetRepository(), deleteCountdownSeconds: 10, alarmHandler: mockHandler)
        manager.addTimer(label: "test", hours: 0, minutes: 0, seconds: 1, isSoundOn: true, isVibrationOn: true)
        let timerId = manager.timers[0].id

        manager.removeTimer(id: timerId)
        
        #expect(mockHandler.stopCallCount == 1)
        #expect(mockHandler.stoppedTimerIDs.contains(timerId))
    }
    
    @Test("타이머 정지 시 stop이 호출되는지 검증")
    func test_stopTimer_stopsAlarmForThatTimer() {
        let mockHandler = MockAlarmHandler()
        let manager = TimerManager(presetRepository: PresetRepository(), deleteCountdownSeconds: 10, alarmHandler: mockHandler)
        manager.addTimer(label: "test", hours: 0, minutes: 0, seconds: 1, isSoundOn: true, isVibrationOn: true)
        let timerId = manager.timers[0].id

        manager.stopTimer(id: timerId)
        
        #expect(mockHandler.stopCallCount == 1)
        #expect(mockHandler.stoppedTimerIDs.contains(timerId))
    }
}
