//
//  MockAlarmHandler.swift
//  LabelTimer
//
//  Created by 이소연 on 7/26/25.
//
/// AlarmTriggering을 구현한 Mock 객체로, 실제 사운드/진동 없이 호출 여부만 기록함
///
/// - 사용 목적: 테스트에서 실제 사운드나 진동 없이 알람 호출 여부를 확인하기 위한 목 객체

import Foundation
@testable import LabelTimer

final class MockAlarmHandler: AlarmTriggering {
    private(set) var didPlaySound: Bool = false
    private(set) var didStopSound: Bool = false
    private(set) var didVibrate: Bool = false

    func playSound(for id: UUID) {
        didPlaySound = true
    }

    func stopSound(for id: UUID) {
        didStopSound = true
    }

    func vibrate() {
        didVibrate = true
    }

    func reset() {
        didPlaySound = false
        didStopSound = false
        didVibrate = false
    }
}
