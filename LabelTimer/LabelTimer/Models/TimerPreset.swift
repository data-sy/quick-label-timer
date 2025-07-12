import Foundation

//
//  TimerPreset.swift
//  LabelTimer
//
//  Created by 이소연 on 7/12/25.
//
/// 앱에서 기본으로 제공하는 추천 타이머 모델
///
/// - 사용 목적: 빠르게 사용할 수 있도록 사전에 정의된 타이머 목록 제공
///

struct TimerPreset: Identifiable, Hashable {
    let id = UUID()
    let hours: Int
    let minutes: Int
    let seconds: Int
    let label: String
    let emoji: String
    let usageType: UsageType

    var totalSeconds: Int {
        hours * 3600 + minutes * 60 + seconds
    }
}
