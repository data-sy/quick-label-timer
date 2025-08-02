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
    func test_playSound_callsPlayerWithCorrectId() {
        let mockPlayer = MockSoundPlayer()
        let handler = AlarmHandler(player: mockPlayer)
        let testId = UUID()

        handler.playSound(for: testId)

        XCTAssertEqual(mockPlayer.playedSoundId, testId)
    }

    func test_playDefaultSound_usesCurrentDefaultSound() {
        // given
        let mockPlayer = MockSoundPlayer()
        let handler = AlarmHandler(player: mockPlayer)
        let testId = UUID()

        // 현재 설정을 lowBuzz로 지정
        UserDefaults.standard.set("low-buzz", forKey: "defaultSound")

        // when
        handler.playDefaultSound(for: testId)

        // then
        XCTAssertEqual(mockPlayer.playedSound, AlarmSound.lowBuzz)
    }

    
    func test_stopSound_callsPlayerWithCorrectId() {
        let mockPlayer = MockSoundPlayer()
        let handler = AlarmHandler(player: mockPlayer)
        let testId = UUID()

        handler.stopSound(for: testId)

        XCTAssertEqual(mockPlayer.stoppedSoundId, testId)
    }
}
