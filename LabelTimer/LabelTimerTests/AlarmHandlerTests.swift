//
//  AlarmHandlerTests.swift
//  LabelTimer
//
//  Created by 이소연 on 7/26/25.
//
/// AlarmHandlerTests
///
/// - 사용 목적: AlarmHandler가 AlarmSoundPlayable 프로토콜을 통해 사운드 재생/정지 요청을 정상 위임하는지 검증

import XCTest
@testable import LabelTimer

final class AlarmHandlerTests: XCTestCase {
    final class MockSoundPlayer: AlarmSoundPlayable {
        var playedSoundId: UUID?
        var stoppedSoundId: UUID?

        func playAlarmSound(for id: UUID, sound: AlarmSound, loop: Bool) {
            playedSoundId = id
        }

        func stopAlarm(for id: UUID) {
            stoppedSoundId = id
        }
    }

    func test_playSound_callsPlayerWithCorrectId() {
        let mockPlayer = MockSoundPlayer()
        let handler = AlarmHandler(player: mockPlayer)
        let testId = UUID()

        handler.playSound(for: testId)

        XCTAssertEqual(mockPlayer.playedSoundId, testId)
    }

    func test_stopSound_callsPlayerWithCorrectId() {
        let mockPlayer = MockSoundPlayer()
        let handler = AlarmHandler(player: mockPlayer)
        let testId = UUID()

        handler.stopSound(for: testId)

        XCTAssertEqual(mockPlayer.stoppedSoundId, testId)
    }
}
