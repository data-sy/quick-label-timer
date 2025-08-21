//
//  AlarmNotificationPolicy.swift
//  LabelTimer
//
//  Created by 이소연 on 8/20/25.
//
/// 로컬 알림을 보낼 때 사용할 기술적인 정책을 정의하는 Enum
///
///- 사용 목적: 사용자의 소리/진동 설정을 실제 로컬 알림 동작으로 변환하기 위한 명확한 정책을 정의함

import Foundation

enum AlarmNotificationPolicy {
    /// 사용자가 설정한 기본 알림음 + 시스템 진동
    case soundAndVibration
    /// 소리가 없는 오디오 파일('무음 사운드')를 재생하여 진동만
    case vibrationOnly
    /// 소리와 진동 없이 시각적인 알림(배너)만
    case silent
    
    /// isSoundOn, isVibrationOn 값에 따라 정책을 결정하는 공용 함수
    static func determine(soundOn: Bool, vibrationOn: Bool) -> AlarmNotificationPolicy {
        if soundOn {
            return .soundAndVibration
        } else {
            return vibrationOn ? .vibrationOnly : .silent
        }
    }
}
