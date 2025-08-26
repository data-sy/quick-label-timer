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
    
    /// 정책을 isSoundOn, isVibrationOn Bool 값으로 변환
    var asBools: (sound: Bool, vibration: Bool) {
        switch self {
        case .soundAndVibration:
            return (sound: true, vibration: true)
        case .vibrationOnly:
            return (sound: false, vibration: true)
        case .silent:
            return (sound: false, vibration: false)
        }
    }
    
    // UI에서 선택한 모드를 정책으로 변환
    static func from(mode: AlarmMode) -> AlarmNotificationPolicy {
        switch mode {
        case .sound: return .soundAndVibration
        case .vibration:     return .vibrationOnly
        case .silent:         return .silent
        }
    }

    // 정책을 UI 모드로 변환 (예: 저장된 값을 세그먼트에 반영)
    var asMode: AlarmMode {
        switch self {
        case .soundAndVibration: return .sound
        case .vibrationOnly:     return .vibration
        case .silent:            return .silent
        }
    }
    
    // MARK: - Conversion Helpers
    
    /// [UI -> 데이터] AlarmMode에서 (isSoundOn, isVibrationOn) Bool 튜플을 바로 얻는 함수
    static func getBools(from mode: AlarmMode) -> (sound: Bool, vibration: Bool) {
        return from(mode: mode).asBools
    }
    
    /// [데이터 -> UI] (isSoundOn, isVibrationOn) Bool 값에서 AlarmMode를 바로 얻는 함수
    static func getMode(soundOn: Bool, vibrationOn: Bool) -> AlarmMode {
        return determine(soundOn: soundOn, vibrationOn: vibrationOn).asMode
    }
}
