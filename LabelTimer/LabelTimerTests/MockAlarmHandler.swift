//
//  MockAlarmHandler.swift
//  LabelTimerTests
//
//  Created by 이소연 on 7/26/25.
//
/// AlarmTriggering을 구현한 Mock 객체로, 실제 사운드/진동 없이 호출 여부만 기록함

import Foundation
@testable import LabelTimer

final class MockAlarmHandler: AlarmTriggering {
    private(set) var didPlaySound: Bool = false
    private(set) var didVibrate: Bool = false

    func playSound(for id: UUID) {
        didPlaySound = true
    }

    func vibrate() {
        didVibrate = true
    }

    func reset() {
        didPlaySound = false
        didVibrate = false
    }
}
