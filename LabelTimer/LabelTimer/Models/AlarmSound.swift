//
//  AlarmSound.swift
//  LabelTimer
//
//  Created by 이소연 on 7/26/25.
//
/// 알람 사운드 리소스 식별자
///
/// - 사용 목적: 사용자가 선택할 수 있는 기본 알람 사운드를 정의하고, 앱 전역에서 참조 가능하게 설계

import Foundation

enum AlarmSound: CaseIterable, Identifiable {
    case none, lowBuzz, highBuzz, siren, melody

    var fileName: String {
        switch self {
        case .none: return ""
        case .lowBuzz: return "low-buzz"
        case .highBuzz: return "high-buzz"
        case .siren: return "siren"
        case .melody: return "melody"
        }
    }

    var fileExtension: String { "caf" }

    var displayName: String {
        switch self {
        case .none: return "소리 없음"
        case .lowBuzz: return "낮은 알림음"
        case .highBuzz: return "높은 알림음"
        case .siren: return "사이렌"
        case .melody: return "멜로디"
        }
    }

    var id: String {
        switch self {
        case .none: return "none"
        default: return fileName
        }
    }

    static var `default`: AlarmSound { .lowBuzz }
    
    /// 사운드 파일 누락 시 사용할 대체(Fallback) 사운드
    static var fallback: AlarmSound { .lowBuzz }

    static var current: AlarmSound {
        let id = UserDefaults.standard.string(forKey: "defaultSound") ?? AlarmSound.default.id
        return AlarmSound.from(id: id)
    }
    
    static func from(id: String) -> AlarmSound {
        return allCases.first { $0.id == id } ?? .lowBuzz
    }
}
