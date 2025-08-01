//
//  MockSoundPlayer.swift
//  LabelTimer
//
//  Created by 이소연 on 8/1/25.
//
/// AlarmSoundPlayable을 구현한 Mock 객체
///
/// - 사용 목적: AlarmHandler 테스트에서 사운드 재생 호출 여부 검증

import Foundation
@testable import LabelTimer

final class MockSoundPlayer: AlarmSoundPlayable {
    private(set) var playedSoundId: UUID?
    private(set) var playedDefaultSoundId: UUID?
    private(set) var playedSound: AlarmSound?
    private(set) var stoppedSoundId: UUID?

    func playAlarm(for id: UUID, sound: AlarmSound, loop: Bool) {
        playedSoundId = id
        playedSound = sound
    }

    func playDefaultAlarm(for id: UUID, loop: Bool) {
        playedDefaultSoundId = id
        playAlarm(for: id, sound: AlarmSound.current, loop: loop)
    }

    func stopAlarm(for id: UUID) {
        stoppedSoundId = id
    }

    func reset() {
        playedSoundId = nil
        playedDefaultSoundId = nil
        playedSound = nil
        stoppedSoundId = nil
    }
}
