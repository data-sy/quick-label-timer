import Testing
@testable import LabelTimer

//
//  TimerManagerTests.swift
//  LabelTimer
//
//  Created by 이소연 on 7/24/25.
//

struct TimerManagerTests {

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
        mockCenter.addedRequests.removeAll()  // 이전 예약 기록 제거

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
        mockCenter.addedRequests.removeAll()

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
