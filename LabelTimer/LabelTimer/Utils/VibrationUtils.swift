//
//  VibrationUtils.swift
//  LabelTimer
//
//  Created by 이소연 on 7/25/25.
//
/// 진동 실행을 위한 유틸리티 클래스
///
/// - 사용 목적: 타이머 종료 시 포그라운드에서 진동을 발생시켜 사용자에게 알림 제공

import Foundation
import AudioToolbox

enum VibrationUtils {
    
    /// 진동 발생 (포그라운드에서만 작동)
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
