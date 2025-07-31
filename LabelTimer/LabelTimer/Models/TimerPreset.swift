//
//  TimerPreset.swift
//  LabelTimer
//
//  Created by 이소연 on 7/12/25.
//
/// 타이머 실행을 위한 프리셋 모델
///
/// - 사용 목적: 자주 사용하는 시간과 라벨을 저장해두고 빠르게 실행할 수 있도록 함.

import Foundation

struct TimerPreset: Identifiable, Codable, Hashable {
    let id: UUID
    
    let label: String
    let hours: Int
    let minutes: Int
    let seconds: Int
    let isSoundOn: Bool
    let isVibrationOn: Bool
    
    let createdAt: Date
    
    var totalSeconds: Int {
        hours * 3600 + minutes * 60 + seconds
    }
    
    // 1. id 없이 생성할 때(새 프리셋 생성)
    init(
        label: String,
        hours: Int,
        minutes: Int,
        seconds: Int,
        isSoundOn: Bool = true,
        isVibrationOn: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = UUID()
        self.label = label
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
        self.isSoundOn = isSoundOn
        self.isVibrationOn = isVibrationOn
        self.createdAt = createdAt
    }
    
    // 2. id 포함 생성자(복사/업데이트/디코딩 등)
    init(
        id: UUID = UUID(),
        label: String,
        hours: Int,
        minutes: Int,
        seconds: Int,
        isSoundOn: Bool,
        isVibrationOn: Bool,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.label = label
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
        self.isSoundOn = isSoundOn
        self.isVibrationOn = isVibrationOn
        self.createdAt = createdAt
    }
}
