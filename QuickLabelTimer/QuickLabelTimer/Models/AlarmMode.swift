//
//  AlarmMode.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/22/25.
//
/// 로컬 알림 UI에서 사용자가 선택할 수 있는 모드를 정의하는 Enum
///
/// - 사용 목적: 소리/진동/무음 옵션을 세그먼트로 직관적으로 표현하고, 선택 결과를 AlarmNotificationPolicy와 1:1 매핑하기 위한 모델

import SwiftUI

enum AlarmMode: String, CaseIterable, Identifiable {
    case sound
    case vibration
    case silent
    
    var id: Self { self }
    
    /// UI에 표시될 텍스트 라벨
    var label: String {
        switch self {
        case .sound: return String(localized: "ui.alarmMode.sound")
        case .vibration: return String(localized: "ui.alarmMode.vibration")
        case .silent: return String(localized: "ui.alarmMode.silent")
        }
    }
        
    /// 시스템 아이콘 (SF Symbol)
    var iconName: String {
        switch self {
        case .sound: return "speaker.wave.2.fill"
        case .vibration: return "iphone.radiowaves.left.and.right"
        case .silent: return "speaker.slash.fill"
        }
    }
    
    /// 접근성
    var a11yLabel: LocalizedStringKey {
        switch self {
        case .sound: return "ui.alarmMode.sound"
        case .vibration: return "ui.alarmMode.vibration"
        case .silent: return "ui.alarmMode.silent"
        }
    }
}
