//
//  AlarmSound.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 7/26/25.
//
/// 앱에서 사용할 알람 사운드의 종류를 정의하고 관리
///
/// - 사용 목적: 사용자가 선택할 수 있는 알람 사운드 목록을 제공하고, '진동만'과 같은 기술적인 사운드 트릭을 코드 내에서 명확하게 사용하기 위함

import Foundation

enum AlarmSound: String, CaseIterable, Identifiable {
    // 사용자에게 표시될 실제 사운드
    case lowBuzz, highBuzz, siren, melody
    // '진동만' 모드를 위한 기술적인 케이스 (UI에는 표시되지 않음)
    case silence
 
    var fileName: String {
        switch self {
        case .lowBuzz: return "low-buzz"
        case .highBuzz: return "high-buzz"
        case .siren: return "siren"
        case .melody: return "melody"
        case .silence: return "inaudible_tone"
        }
    }

    var fileExtension: String { "caf" }
    
    var fullName: String {
        return fileName + "." + fileExtension
    }

    var displayName: String {
        switch self {
        case .lowBuzz: return "낮은 알림음"
        case .highBuzz: return "높은 알림음"
        case .siren: return "사이렌"
        case .melody: return "멜로디"
        case .silence: return "진동용 무음사운드" // UI에 표시되진 않지만, 디버깅 등을 위해 명확한 이름 부여
        }
    }
    
    static var selectableSounds: [AlarmSound] {
        return allCases.filter { $0 != .silence } // 사운드 선택 화면에서 무음사운드 제거
    }
    
    var id: String { self.rawValue }

    static var `default`: AlarmSound { .lowBuzz }

    static var current: AlarmSound {
        if let id = UserDefaults.standard.string(forKey: "defaultSound"),
           let sound = AlarmSound(rawValue: id) {
            return sound
        }
        return self.default
    }
    
    var playableURL: URL? {
        if let url = Bundle.main.url(forResource: self.fileName, withExtension: self.fileExtension) {
            return url
        }
        
        print("[AlarmSound][WARN] 사운드 파일(\(self.fullName))을 찾을 수 없어 기본 사운드로 대체합니다.")
        if let fallbackUrl = Bundle.main.url(forResource: AlarmSound.default.fileName, withExtension: AlarmSound.default.fileExtension) {
            return fallbackUrl
        }
        print("[AlarmSound][FATAL] 기본 사운드 파일마저 찾을 수 없습니다.")
        return nil
    }
    
    static func from(id: String) -> AlarmSound {
        return AlarmSound(rawValue: id) ?? .default
    }
    
}
