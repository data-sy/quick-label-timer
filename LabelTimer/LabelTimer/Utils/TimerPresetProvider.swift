
import Foundation

//
//  TimerPresetProvider.swift
//  LabelTimer
//
//  Created by 이소연 on 7/12/25.
//
/// 타이머 프리셋 목록을 제공하는 유틸리티
///
/// - 사용 목적: 앱 내에서 기본 제공되는 타이머 목록 관리
/// - 기능: 고정된 프리셋 목록을 정적으로 제공
///

struct TimerPresetProvider {
    static let presets: [TimerPreset] = [
//        TimerPreset(hours: 0, minutes: 10, seconds: 0, label: "회의 입장", emoji: "📅", usageType: .plan),
        TimerPreset(hours: 0, minutes: 15, seconds: 0, label: "출발하기", emoji: "🚗", usageType: .plan),
        TimerPreset(hours: 0, minutes: 30, seconds: 0, label: "약 먹기", emoji: "💊", usageType: .plan),
        
//        TimerPreset(hours: 0, minutes: 5, seconds: 0, label: "명상", emoji: "🧘", usageType: .active),
        TimerPreset(hours: 0, minutes: 10, seconds: 0, label: "낮잠", emoji: "😴", usageType: .active),
        TimerPreset(hours: 0, minutes: 20, seconds: 0, label: "휴식", emoji: "📱", usageType: .active),
    ]
}
