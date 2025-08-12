//
//  AlarmHandler.swift
//  LabelTimer
//
//  Created by 이소연 on 7/26/25.
//
/// 타이머의 알람(소리/진동)과 관련된 모든 동작을 중계하는 클래스
///
/// - 사용 목적: TimerManager 등 앱의 다른 부분에서는 이 핸들러를 통해서만 알람 기능을 사용하도록 하여,
///             실제 재생 로직(AlarmSoundPlayer)과의 의존성을 분리하고 코드를 단순화함

import Foundation

protocol AlarmTriggering {
    func playIfNeeded(for timer: TimerData)
    func stopSound(for id: UUID)
    func vibrate()
    func stopAllSounds()
}

final class AlarmHandler: AlarmTriggering {
    private let player: AlarmSoundPlayable

    init(player: AlarmSoundPlayable = AlarmSoundPlayer.shared) {
        self.player = player
    }

    func playSound(for id: UUID) {
        player.playAlarm(for: id, sound: .default, loop: true)
    }
    
    func playDefaultSound(for id: UUID) {
        player.playDefaultAlarm(for: id, loop: true)
    }

    func stopSound(for id: UUID) {
        player.stopAlarm(for: id)
    }
    
    func stopAllSounds() {
        player.stopAll()
    }

    func vibrate() {
        VibrationUtils.vibrate()
    }
    
    func playIfNeeded(for timer: TimerData) {
        if timer.isSoundOn {
            playDefaultSound(for: timer.id)
        }
        if timer.isVibrationOn {
            vibrate()
        }
    }
}
