//
//  SamplePresetData.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 앱에서 기본으로 제공하는 추천 타이머 프리셋 목록
///
/// - 사용 목적: 사용자에게 자주 사용되는 타이머를 빠르게 시작할 수 있도록 미리 정의된 목록 제공

import Foundation

let samplePresets: [TimerPreset] = [
    TimerPreset(label: "세탁기 빨래 꺼내기 🧺", hours: 0, minutes: 45, seconds: 0, isSoundOn: true, isVibrationOn: true, createdAt: Date().addingTimeInterval(-10)),
    TimerPreset(label: "마스크팩 🧖‍♀️", hours: 0, minutes: 15, seconds: 0, isSoundOn: false, isVibrationOn: true, createdAt: Date().addingTimeInterval(-20)),
    TimerPreset(label: "유튜브 이제 그만, 공부 시작 ‼️", hours: 0, minutes: 10, seconds: 0, isSoundOn: false, isVibrationOn: false, createdAt: Date().addingTimeInterval(-30)),
    TimerPreset(label: "보고서 검토 종료 📝 더 본다고 좋아지지 않아. 이 버전으로 제출하고 피드백을 받자", hours: 0, minutes: 30, seconds: 0, isSoundOn: true, isVibrationOn: true, createdAt: Date().addingTimeInterval(-40)),
    TimerPreset(label: "염색약 헹굴 시간 💇‍♀️", hours: 0, minutes: 25, seconds: 0, isSoundOn: true, isVibrationOn: true, createdAt: Date().addingTimeInterval(-50)),
    TimerPreset(label: "고기 해동 확인 🥩 (덜 녹았으면 10분 더 / 다 녹았으면 밥솥 취사 누르기)", hours: 0, minutes: 30, seconds: 0, isSoundOn: false, isVibrationOn: true, createdAt: Date().addingTimeInterval(-60)),
    TimerPreset(label: "무료 주차 만료 10분 전 🚗", hours: 1, minutes: 50, seconds: 0, isSoundOn: true, isVibrationOn: true, createdAt: Date().addingTimeInterval(-70))
]

