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
TimerPreset(label: "1 소리진동없음", hours: 0, minutes: 0, seconds: 3, isSoundOn: false, isVibrationOn: false, createdAt: Date().addingTimeInterval(-10), lastUsedAt: Date().addingTimeInterval(-10)),
   TimerPreset(label: "2 소리진동없음", hours: 0, minutes: 0, seconds: 7, isSoundOn: false, isVibrationOn: false, createdAt: Date().addingTimeInterval(-20), lastUsedAt: Date().addingTimeInterval(-20)),
   TimerPreset(label: "3 소리진동없음", hours: 0, minutes: 0, seconds: 10, isSoundOn: false, isVibrationOn: false, createdAt: Date().addingTimeInterval(-30), lastUsedAt: Date().addingTimeInterval(-30)),
   TimerPreset(label: "4 소리진동없음", hours: 0, minutes: 0, seconds: 5, isSoundOn: false, isVibrationOn: false, createdAt: Date().addingTimeInterval(-40), lastUsedAt: Date().addingTimeInterval(-40)),
   TimerPreset(label: "5 소리진동없음", hours: 0, minutes: 0, seconds: 8, isSoundOn: false, isVibrationOn: false, createdAt: Date().addingTimeInterval(-50), lastUsedAt: Date().addingTimeInterval(-50)),
   
   // 주석 처리된 기존 샘플 데이터
   // TimerPreset(label: "소리o진동o테스트", hours: 0, minutes: 0, seconds: 5, isSoundOn: true, isVibrationOn: true),
   // TimerPreset(label: "소리o진동x테스트", hours: 0, minutes: 0, seconds: 7, isSoundOn: true, isVibrationOn: false),
   // TimerPreset(label: "소리x진동o테스트", hours: 0, minutes: 0, seconds: 9, isSoundOn: false, isVibrationOn: true),
   // TimerPreset(label: "소리x진동x테스트", hours: 0, minutes: 0, seconds: 11, isSoundOn: false, isVibrationOn: false)
]

