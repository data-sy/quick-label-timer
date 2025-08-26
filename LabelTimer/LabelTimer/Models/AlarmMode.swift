//
//  AlarmMode.swift
//  LabelTimer
//
//  Created by 이소연 on 8/22/25.
//
/// 로컬 알림 UI에서 사용자가 선택할 수 있는 모드를 정의하는 Enum
///
/// - 사용 목적: 소리/진동/무음 옵션을 세그먼트로 직관적으로 표현하고,
///          선택 결과를 AlarmNotificationPolicy와 1:1 매핑하기 위한 모델
import SwiftUI

enum AlarmMode: String, CaseIterable, Identifiable {
    case soundAndVibration   // 소리+진동
    case vibrationOnly       // 진동만
    case silent              // 무음
    
    var id: Self { self }
        
    /// 시스템 아이콘 (SF Symbol). 아이콘이 2개 필요한 경우를 위해 배열로 반환
    var symbolNames: [String] {
        switch self {
        case .soundAndVibration:
            return ["speaker.wave.2.fill", "iphone.radiowaves.left.and.right"]
        case .vibrationOnly:
            return ["iphone.radiowaves.left.and.right"]
        case .silent:
            return ["speaker.slash.fill", "iphone.slash"]
        }
    }
    
    /// 각 모드를 나타내는 고유 색상
    var color: Color {
        switch self {
        case .soundAndVibration: return .indigo
        case .vibrationOnly:     return AppTheme.vibrationModeColor // darkCyan
        case .silent:            return Color(white: 0.2)
        }
    }
}
