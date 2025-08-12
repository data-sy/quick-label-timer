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
    var mockPlayer: MockSoundPlayer!
    var handler: AlarmHandler!

    // 테스트 실행 '전' Mock 객체들 초기화 (테스트의 독립성 보장)
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockPlayer = MockSoundPlayer()
        handler = AlarmHandler(player: mockPlayer)
    }

    // 테스트가 실행 '후' 인스턴스를 nil로 만들어 메모리 정리
    override func tearDownWithError() throws {
        mockPlayer = nil
        handler = nil
        try super.tearDownWithError()
    }
    
    func test_playSound_callsPlayerWithCorrectId() {
        let testId = UUID()
        handler.playSound(for: testId)
        XCTAssertEqual(mockPlayer.playedSoundId, testId)
    }

    func test_playDefaultSound_usesCurrentDefaultSound() {
        // given
        let testId = UUID()
        UserDefaults.standard.set("low-buzz", forKey: "defaultSound")

        // when
        handler.playDefaultSound(for: testId)

        // then
        XCTAssertEqual(mockPlayer.playedSound, .siren)
    }
    
    func test_stopSound_callsPlayerWithCorrectId() {
        let testId = UUID()
        handler.stopSound(for: testId)
        XCTAssertEqual(mockPlayer.stoppedSoundId, testId)
    }
    
    // [추가] stopAllSounds가 player의 stopAll을 호출하는지 검증하는 새로운 테스트입니다.
    func test_stopAllSounds_callsPlayerStopAll() {
        // when: 핸들러의 stopAllSounds 메서드를 호출하면
        handler.stopAllSounds()

        // then: 내부의 mockPlayer의 stopAllCallCount가 1 증가해야 합니다.
        XCTAssertEqual(mockPlayer.stopAllCallCount, 1, "stopAll() should be called exactly once")
    }
}
