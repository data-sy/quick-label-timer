//
//  AlarmHandler.swift
//  LabelTimer
//
//  Created by 이소연 on 7/26/25.
//
/// 실제 사운드 및 진동 기능을 수행하는 클래스
///
/// - 사용 목적: AlarmTriggering 프로토콜을 채택하여 실제 알람 기능을 캡슐화하고, 테스트 시 Mock과 교체 가능하게 함

import Foundation

final class AlarmHandler: AlarmTriggering {
    private let player: AlarmSoundPlayable

    init(player: AlarmSoundPlayable = AlarmSoundPlayer.shared) {
        self.player = player
    }

    func playSound(for id: UUID) {
        player.playAlarmSound(for: id, sound: .default, loop: true)
    }

    func stopSound(for id: UUID) {
        player.stopAlarm(for: id)
    }

    func vibrate() {
        VibrationUtils.vibrate()
    }
    
    func playIfNeeded(for timer: TimerData) {
        if timer.isSoundOn {
            playSound(for: timer.id)
        }
        if timer.isVibrationOn {
            vibrate()
        }
    }
}

extension AlarmSoundPlayer: AlarmSoundPlayable {}
