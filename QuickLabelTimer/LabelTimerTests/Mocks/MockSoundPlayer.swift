//
//  MockSoundPlayer.swift
//  LabelTimer
//
//  Created by 이소연 on 8/1/25.
//
/// AlarmPlayable을 구현한 Mock 객체
///
/// - 사용 목적: AlarmHandler 테스트에서 사운드 재생/정지 관련 호출을 검증

import Foundation
@testable import LabelTimer

final class MockSoundPlayer: AlarmPlayable {
    // MARK: - Sound Tracking Properties
    private(set) var playedSound: AlarmSound?
    private(set) var lastPlayedID: UUID?
    private(set) var lastStoppedID: UUID?
    // MARK: - Vibration Tracking Properties
    private(set) var vibrationStartedForIDs: [UUID] = []
    // MARK: - General Tracking Properties
    private(set) var stopAllCallCount = 0

    func play(for id: UUID, sound: AlarmSound, needsVibration: Bool) {
        lastPlayedID = id
        
        if sound != .none {
            self.playedSound = sound
        }
        if needsVibration {
            vibrationStartedForIDs.append(id)
        }
    }

    func playDefault(for id: UUID, needsVibration: Bool) {
        play(for: id, sound: .current, needsVibration: needsVibration)
    }

    func stop(for id: UUID) {
        lastStoppedID = id
    }

    func stopAll() {
        stopAllCallCount += 1
    }
    
    func reset() {
        playedSound = nil
        lastPlayedID = nil
        lastStoppedID = nil
        vibrationStartedForIDs.removeAll()
        stopAllCallCount = 0
    }
}
