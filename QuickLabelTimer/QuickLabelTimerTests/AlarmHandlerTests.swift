//
//  AlarmHandlerTests.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 7/26/25.
//
/// AlarmHandlerTests
///
/// - 사용 목적: AlarmHandler가 AlarmPlayable 프로토콜을 통해 사운드 재생/정지 요청을 정상 위임하는지 검증

import XCTest
@testable import QuickLabelTimer

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
    
    // 진동이 켜져 있을 때, player의 진동 시작 로직이 호출되는지 검증
    func test_playIfNeeded_whenVibrationIsOn_startsVibration() {
        // given
        let timer = TimerData.testData(isVibrationOn: true) // 진동 ON
        
        // when
        handler.playIfNeeded(for: timer)
        
        // then
        XCTAssertTrue(mockPlayer.vibrationStartedForIDs.contains(timer.id))
    }
    
    // 진동이 꺼져 있을 때, player의 진동 시작 로직이 호출되지 않는지 검증
    func test_playIfNeeded_whenVibrationIsOff_doesNotStartVibration() {
        // given
        let timer = TimerData.testData(isVibrationOn: false) // 진동 OFF
        
        // when
        handler.playIfNeeded(for: timer)
        
        // then
        XCTAssertFalse(mockPlayer.vibrationStartedForIDs.contains(timer.id))
    }
    
    // 변경된 메서드 이름으로 테스트를 업데이트
    func test_stop_callsPlayerWithCorrectId() {
        let testId = UUID()
        handler.stop(for: testId)
        XCTAssertEqual(mockPlayer.lastStoppedID, testId)
    }
    
    func test_stopAll_callsPlayerStopAll() {
        handler.stopAll()
        XCTAssertEqual(mockPlayer.stopAllCallCount, 1)
    }
}
