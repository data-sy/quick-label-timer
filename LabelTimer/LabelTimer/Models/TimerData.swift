//
//  TimerData.swift
//  LabelTimer
//
//  Created by 이소연 on 7/9/25.
//
/// 타이머 설정 정보를 저장하는 모델
///
/// - 사용 목적: 사용자가 입력한 시, 분, 초, 라벨을 보존하고 총 시간을 계산함

struct TimerData: Hashable {
    let hours: Int
    let minutes: Int
    let seconds: Int
    let label: String
    let emoji: String?
    let usageType: UsageType
    
    var totalSeconds: Int {
        hours * 3600 + minutes * 60 + seconds
    }
        
}

// MARK: - Preset 변환용 이니셜라이저
extension TimerData {
    init(from preset: TimerPreset) {
        self.hours = preset.hours
        self.minutes = preset.minutes
        self.seconds = preset.seconds
        self.label = preset.label
        self.emoji = preset.emoji
        self.usageType = preset.usageType
    }
}
