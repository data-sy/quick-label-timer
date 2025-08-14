//
//  AlarmHandler.swift
//  LabelTimer
//
//  Created by 이소연 on 7/26/25.
//
/// 타이머의 알람(소리/진동)과 관련된 모든 동작을 중계하는 클래스
///
/// - 사용 목적: TimerService 등 앱의 다른 부분에서는 이 핸들러를 통해서만 알람 기능을 사용하도록 하여,
///             실제 재생 로직(AlarmPlayer)과의 의존성을 분리하고 코드를 단순화함

import Foundation

protocol AlarmTriggering {
    func playIfNeeded(for timer: TimerData)
    func stop(for id: UUID)
    func stopAll()
}

final class AlarmHandler: AlarmTriggering {
    private let player: AlarmPlayable

    init(player: AlarmPlayable = AlarmPlayer.shared) {
        self.player = player
    }

    /// 타이머 설정에 따라 소리/진동 재생
    func playIfNeeded(for timer: TimerData) {
        if timer.isSoundOn || timer.isVibrationOn {
             let sound = timer.isSoundOn ? AlarmSound.current : .none // .none 케이스 필요
             player.play(for: timer.id, sound: sound, needsVibration: timer.isVibrationOn)
        }
    }
    
    /// 특정 타이머의 알람 중지
    func stop(for id: UUID) {
        player.stop(for: id)
    }
    
    /// 모든 타이머의 알람 중지
    func stopAll() {
        player.stopAll()
    }
}
