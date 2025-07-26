//
//  TimerManagerNotificationTests.swift
//  LabelTimer
//
//  Created by 이소연 on 7/26/25.
//


//
//  TimerManagerNotificationTests.swift
//  LabelTimer
//
//  Created by 이소연 on 7/24/25.
//
/// TimerManager의 알림 예약 동작을 검증하는 테스트
///
/// - 사용 목적: 타이머 추가 시 NotificationUtils가 올바르게 호출되어 로컬 알림이 예약되는지 확인하기 위한 단위 테스트

import Testing
@testable import LabelTimer

struct TimerManagerNotificationTests {

    @Test
    func test_addTimer_schedulesNotification() async throws {
        let mockCenter = MockNotificationCenter()
        NotificationUtils.center = mockCenter

        let manager = TimerManager(presetManager: PresetManager())
        manager.addTimer(hours: 0, minutes: 0, seconds: 5, label: "Test")

        #expect(mockCenter.addedRequests.count == 1)
        #expect(mockCenter.addedRequests.first?.content.body == "Test")
    }

    @Test
    func test_pauseTimer_cancelsNotification() async throws {
        let mockCenter = MockNotificationCenter()
        NotificationUtils.center = mockCenter

        let manager = TimerManager(presetManager: PresetManager())
        manager.addTimer(hours: 0, minutes: 0, seconds: 5, label: "Test")
        let timerID = manager.timers.first!.id

        manager.pauseTimer(id: timerID)

        #expect(mockCenter.removedIdentifiers.contains(timerID.uuidString))
    }

    @Test
    func test_resumeTimer_schedulesNotificationAgain() async throws {
        let mockCenter = MockNotificationCenter()
        NotificationUtils.center = mockCenter

        let manager = TimerManager(presetManager: PresetManager())
        manager.addTimer(hours: 0, minutes: 0, seconds: 5, label: "Test")
        let timerID = manager.timers.first!.id

        manager.pauseTimer(id: timerID)
        #expect(mockCenter.removedIdentifiers.contains(timerID.uuidString))
 
        mockCenter.reset()

        manager.resumeTimer(id: timerID)

        #expect(mockCenter.addedRequests.count == 1)
        #expect(mockCenter.addedRequests.first?.identifier == timerID.uuidString)
    }

    @Test
    func test_stopTimer_cancelsNotification() async throws {
        let mockCenter = MockNotificationCenter()
        NotificationUtils.center = mockCenter

        let manager = TimerManager(presetManager: PresetManager())
        manager.addTimer(hours: 0, minutes: 0, seconds: 5, label: "Test")
        let timerID = manager.timers.first!.id

        manager.stopTimer(id: timerID)

        #expect(mockCenter.removedIdentifiers.contains(timerID.uuidString))
    }

    @Test
    func test_restartTimer_schedulesNewNotification() async throws {
        let mockCenter = MockNotificationCenter()
        NotificationUtils.center = mockCenter

        let manager = TimerManager(presetManager: PresetManager())
        manager.addTimer(hours: 0, minutes: 0, seconds: 5, label: "Test")
        let timerID = manager.timers.first!.id

        manager.stopTimer(id: timerID)
        #expect(mockCenter.removedIdentifiers.contains(timerID.uuidString))
        
        mockCenter.reset()
        
        manager.restartTimer(id: timerID)

        #expect(mockCenter.addedRequests.count == 1)
        #expect(mockCenter.addedRequests.first?.identifier == timerID.uuidString)
    }

    @Test
    func test_removeTimer_cancelsNotification() async throws {
        let mockCenter = MockNotificationCenter()
        NotificationUtils.center = mockCenter

        let manager = TimerManager(presetManager: PresetManager())
        manager.addTimer(hours: 0, minutes: 0, seconds: 5, label: "Test")
        let timerID = manager.timers.first!.id

        _ = manager.removeTimer(id: timerID)

        #expect(mockCenter.removedIdentifiers.contains(timerID.uuidString))
    }
}
