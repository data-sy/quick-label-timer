//
//  TimerData.swift
//  LabelTimer
//
//  Created by 이소연 on 7/9/25.
//
/// 타이머 설정 정보를 저장하는 모델
///
/// - 사용 목적: 사용자가 입력한 시, 분, 초, 라벨을 보존하고 총 시간을 계산함
/// - 주요 속성: hours, minutes, seconds, label, totalSeconds

struct TimerData: Hashable {
    let hours: Int
    let minutes: Int
    let seconds: Int
    let label: String
}
