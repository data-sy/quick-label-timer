//
//  AlarmSound.swift
//  LabelTimer
//
//  Created by 이소연 on 7/26/25.
//
/// 알람 사운드 리소스 식별자
///
/// - 사용 목적: 현재는 단일 사운드지만, 추후 사용자가 선택할 수 있도록 확장 가능하게 설계

import Foundation

enum AlarmSound: CaseIterable, Identifiable {
    case lowBuzz, highBuzz, siren, melody

    var fileName: String {
        switch self {
        case .lowBuzz: return "low-buzz"
        case .highBuzz: return "high-buzz"
        case .siren: return "siren"
        case .melody: return "melody"
        }
    }

    var fileExtension: String { "caf" }

    var displayName: String {
        switch self {
        case .lowBuzz: return "낮은 알림음"
        case .highBuzz: return "높은 알림음"
        case .siren: return "사이렌"
        case .melody: return "멜로디"
        }
    }

    var id: String { fileName }

    static var `default`: AlarmSound { .lowBuzz }
}
