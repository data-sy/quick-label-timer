//
//  AlarmSoundType.swift
//  LabelTimer
//
//  Created by 이소연 on 8/20/25.
//
/// 알림에 사용할 사운드 타입을 정의하는 Enum
///
/// - 사용 목적: 기술적으로 사용되는 다양한 사운드 정책을 명확한 타입으로 관리하기 위함

import Foundation

enum AlarmSoundType {
    /// 사용자 설정 기본 벨소리
    case defaultRingtone
    
    /// 진동 전용 무음 사운드
    case silentVibration
    
    /// 소리/진동 모두 없는 무음 사운드
    case silentNone
    
    /// 사운드 없음 (시스템 기본 동작에 맡김)
    case systemDefault
}
