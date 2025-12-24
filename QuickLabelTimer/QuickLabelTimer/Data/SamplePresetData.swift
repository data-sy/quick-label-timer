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
    // 1. 딥 워크 (50분): 앱의 핵심 가치 (생산성/몰입)
    TimerPreset(
        label: String(localized: "preset.label.deepwork"),
        hours: 0,
        minutes: 50,
        seconds: 0,
        isSoundOn: true,
        isVibrationOn: true,
        createdAt: Date().addingTimeInterval(-10)
    ),
    
    // 2. 뽀모도로 (25분): 가장 대중적인 시간 관리
    TimerPreset(
        label: String(localized: "preset.label.pomodoro"),
        hours: 0,
        minutes: 25,
        seconds: 0,
        isSoundOn: true,
        isVibrationOn: true,
        createdAt: Date().addingTimeInterval(-20)
    ),
    
    // 3. 브레이크 타임 (10분): 업무 후의 자연스러운 흐름
    TimerPreset(
        label: String(localized: "preset.label.break"),
        hours: 0,
        minutes: 10,
        seconds: 0,
        isSoundOn: true,
        isVibrationOn: true,
        createdAt: Date().addingTimeInterval(-30)
    ),
    
    // 4. 반숙 계란 삶기 (7분): 요리 등 일상 활용성 강조 (반전 매력)
    TimerPreset(
        label: String(localized: "preset.label.egg"),
        hours: 0,
        minutes: 7,
        seconds: 0,
        isSoundOn: true,
        isVibrationOn: true,
        createdAt: Date().addingTimeInterval(-40)
    ),
    
    // 5. 모닝 루틴: 명상 (5분): 라벨 수정 유도 & 웰니스 (소리 끔)
    TimerPreset(
        label: String(localized: "preset.label.meditation"),
        hours: 0,
        minutes: 5,
        seconds: 0,
        isSoundOn: false, // 명상은 조용하게 진동으로만
        isVibrationOn: true,
        createdAt: Date().addingTimeInterval(-50)
    ),
    
    // 6. 플랭크 (1분): 가벼운 도전 의식 자극
    TimerPreset(
        label: String(localized: "preset.label.plank"),
        hours: 0,
        minutes: 1,
        seconds: 0,
        isSoundOn: true,
        isVibrationOn: true,
        createdAt: Date().addingTimeInterval(-60)
    ),
    
    // 7. 눈 스트레칭 (1분): 섬세한 배려와 감동 포인트
    TimerPreset(
        label: String(localized: "preset.label.eyecare"),
        hours: 0,
        minutes: 1,
        seconds: 0,
        isSoundOn: true,
        isVibrationOn: true,
        createdAt: Date().addingTimeInterval(-70)
    )
]
