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
    TimerPreset(hours: 0, minutes: 1, seconds: 0, label: "집중"),
    TimerPreset(hours: 0, minutes: 3, seconds: 0, label: "양치"),
    TimerPreset(hours: 0, minutes: 5, seconds: 0, label: "준비"),
    TimerPreset(hours: 0, minutes: 10, seconds: 0, label: "스트레칭"),
    TimerPreset(hours: 0, minutes: 20, seconds: 0, label: "짧은 공부")
]
