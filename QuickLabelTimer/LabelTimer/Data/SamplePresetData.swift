//
//  SamplePresetData.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 앱에서 기본으로 제공하는 추천 타이머 프리셋 목록
///
/// - 사용 목적: 사용자에게 자주 사용되는 타이머를 빠르게 시작할 수 있도록 미리 정의된 목록 제공

import Foundation

let samplePresets: [TimerPreset] = [
    TimerPreset(label: "1. 소리O, 진동O", hours: 0, minutes: 0, seconds: 3, isSoundOn: true, isVibrationOn: true, createdAt: Date().addingTimeInterval(-10), lastUsedAt: Date().addingTimeInterval(-10)),
    TimerPreset(label: "2. 소리O, 진동X", hours: 0, minutes: 0, seconds: 3, isSoundOn: true, isVibrationOn: false, createdAt: Date().addingTimeInterval(-20), lastUsedAt: Date().addingTimeInterval(-20)),
    TimerPreset(label: "3. 소리X, 진동O", hours: 0, minutes: 0, seconds: 3, isSoundOn: false, isVibrationOn: true, createdAt: Date().addingTimeInterval(-30), lastUsedAt: Date().addingTimeInterval(-30)),
    TimerPreset(label: "4. 소리X, 진동X", hours: 0, minutes: 0, seconds: 3, isSoundOn: false, isVibrationOn: false, createdAt: Date().addingTimeInterval(-40), lastUsedAt: Date().addingTimeInterval(-40)),
]

