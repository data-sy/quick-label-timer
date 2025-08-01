//
//  AlarmSoundPlayable.swift
//  LabelTimer
//
//  Created by 이소연 on 7/26/25.
//
/// AlarmSoundPlayer가 준수해야 하는 사운드 재생 추상화 프로토콜
///
/// - 사용 목적: AlarmHandler에서 사운드 재생 기능을 테스트 가능하도록 분리

import Foundation

protocol AlarmSoundPlayable {
    func playAlarm(for id: UUID, sound: AlarmSound, loop: Bool)
    func playDefaultAlarm(for id: UUID, loop: Bool)
    func stopAlarm(for id: UUID)
}
