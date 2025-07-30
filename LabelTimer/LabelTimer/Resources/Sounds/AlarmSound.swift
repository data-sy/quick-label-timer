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
    case `default`

    var fileName: String {
        switch self {
        case .default: return "test-alarm01"
        }
    }

    var fileExtension: String {
        switch self {
        case .default: return "caf"
        }
    }

    var displayName: String {
        switch self {
        case .default: return "기본 알람"
        }
    }

    var id: String { fileName }
}
