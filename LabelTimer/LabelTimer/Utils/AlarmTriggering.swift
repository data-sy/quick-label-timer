import Foundation

//
//  AlarmTriggering.swift
//  LabelTimer
//
//  Created by 이소연 on 7/26/25.
//
/// 사운드 및 진동 알림 기능을 추상화한 프로토콜
///
/// - 사용 목적: 실제 사운드/진동 로직과 테스트용 Mock 구현을 분리하여 테스트 가능하게 함

protocol AlarmTriggering {
    func playSound(for id: UUID)
    func vibrate()
}
