//
//  TimerManagerAlarmTests.swift
//  LabelTimer
//
//  Created by 이소연 on 7/26/25.
//
/// TimerManagerAlarmTests
///
/// - 사용 목적: TimerManager가 타이머 상태 및 앱 환경 변화에 따라 알람을 정상적으로 제어하는지 검증

import Foundation
import Testing
@testable import LabelTimer

@Suite("TimerManager 알람 제어 로직 테스트")
struct TimerManagerAlarmTests {

    final class MockAlarmHandler: AlarmTriggering {
        var playIfNeededCallCount = 0
        var stopSoundCallCount = 0
        var stoppedTimerIDs: [UUID] = []
        var vibrateCallCount = 0
        var stopAllSoundsCallCount = 0

        func playIfNeeded(for timer: TimerData) {
           playIfNeededCallCount += 1
       }

       func stopSound(for id: UUID) {
           stopSoundCallCount += 1
           stoppedTimerIDs.append(id)
       }
       
       func vibrate() {
           vibrateCallCount += 1
       }
       
       func stopAllSounds() {
           stopAllSoundsCallCount += 1
       }
    }

    @Test("타이머 종료 시 playIfNeeded가 호출되는지 검증")
    func test_tick_triggersSoundAndVibrationWhenTimerEnds() async throws {
        let mockHandler = MockAlarmHandler()
        let manager = TimerManager(
            presetManager: PresetManager(),
            deleteCountdownSeconds: 10,
            alarmHandler: mockHandler
        )

        manager.addTimer(label: "test", hours: 0, minutes: 0, seconds: 1, isSoundOn: true, isVibrationOn: true)

        // 시간이 1초 남은 상태에서 tick() 호출 → 0초로 줄어들며 알람 트리거
        manager.timers[0].remainingSeconds = 1
        manager.tick()

        // then
        #expect(mockHandler.playIfNeededCallCount == 1)
    }
    
    // [추가] 앱이 Active 상태가 되면 모든 알람을 중지시키는지 검증하는 핵심 테스트
    @Test("Scene이 Active가 되면 stopAllSounds가 호출되는지 검증")
    func test_updateScenePhase_toActive_stopsAllAlarms() {
        // given
        let mockHandler = MockAlarmHandler()
        let manager = TimerManager(
            presetManager: PresetManager(),
            deleteCountdownSeconds: 10,
            alarmHandler: mockHandler
        )

        // when
        manager.updateScenePhase(.active)

        // then
        #expect(mockHandler.stopAllSoundsCallCount == 1, "stopAllSounds() should be called when scene becomes active")
    }
    
    // [추가] 타이머 삭제 시 해당 알람을 중지시키는지 검증
    @Test("타이머 삭제 시 stopSound가 호출되는지 검증")
    func test_removeTimer_stopsSoundForThatTimer() {
        // given
        let mockHandler = MockAlarmHandler()
        let manager = TimerManager(
            presetManager: PresetManager(),
            deleteCountdownSeconds: 10,
            alarmHandler: mockHandler
        )
        manager.addTimer(label: "test", hours: 0, minutes: 0, seconds: 1, isSoundOn: true, isVibrationOn: true)
        let timerId = manager.timers[0].id

        // when
        manager.removeTimer(id: timerId)
        
        // then
        #expect(mockHandler.stopSoundCallCount == 1)
        #expect(mockHandler.stoppedTimerIDs.contains(timerId))
    }
    
    // [추가] 타이머 정지 시 해당 알람을 중지시키는지 검증
    @Test("타이머 정지 시 stopSound가 호출되는지 검증")
    func test_stopTimer_stopsSoundForThatTimer() {
        // given
        let mockHandler = MockAlarmHandler()
        let manager = TimerManager(
            presetManager: PresetManager(),
            deleteCountdownSeconds: 10,
            alarmHandler: mockHandler
        )
        manager.addTimer(label: "test", hours: 0, minutes: 0, seconds: 1, isSoundOn: true, isVibrationOn: true)
        let timerId = manager.timers[0].id

        // when
        manager.stopTimer(id: timerId)
        
        // then
        #expect(mockHandler.stopSoundCallCount == 1)
        #expect(mockHandler.stoppedTimerIDs.contains(timerId))
    }
}
