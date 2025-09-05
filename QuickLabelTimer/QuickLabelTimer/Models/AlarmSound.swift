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
import UserNotifications

enum AlarmSound: String, CaseIterable, Identifiable {
    // 사용자에게 표시될 실제 사운드
    case systemDefault, beepSingle, beepDouble, buzzLow, buzzHigh, ringtone01, ringtone02
    // '진동만' 모드를 위한 기술적인 케이스 (UI에는 표시되지 않음)
    case silence
    
    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .systemDefault: return "Default"
        case .buzzLow: return "Low Buzz"
        case .buzzHigh: return "High Buzz"
        case .beepSingle: return "Beep"
        case .beepDouble: return "Double Beep"
        case .ringtone01: return "Ringtone 1"
        case .ringtone02: return "Ringtone 2"
        case .silence: return "Silence For Vibration" // UI에 표시되진 않지만, 디버깅 등을 위해 명확한 이름 부여
        }
    }
    
    /// 실제 알림 요청에 사용할 UNNotificationSound 객체
    var notificationSound: UNNotificationSound {
        if self == .systemDefault {
            return .default
        }
        guard let fileName = self.fileName else {
            return .default
        }

        return UNNotificationSound(named: .init(fileName + self.fileExtension))
    }
 
    var playableURL: URL? {
        guard let fileName = self.fileName else {
            return nil
        }
        return Bundle.main.url(forResource: fileName, withExtension: self.fileExtension)
    }
    
    static var selectableSounds: [AlarmSound] {
        return allCases.filter { $0 != .silence && $0 != .systemDefault }
    }

    static var `default`: AlarmSound { .beepSingle }

    static var current: AlarmSound {
        if let id = UserDefaults.standard.string(forKey: "defaultSound"),
           let sound = AlarmSound(rawValue: id) {
            return sound
        }
        return self.default
    }
    
    static func from(id: String) -> AlarmSound {
        return AlarmSound(rawValue: id) ?? .default
    }
    
    private var fileName: String? {
        switch self {
        case .systemDefault: return nil
        case .buzzLow: return "buzz-low"
        case .buzzHigh: return "buzz-high"
        case .beepSingle: return "beep-single"
        case .beepDouble: return "beep-double"
        case .ringtone01: return "ringtone-01"
        case .ringtone02: return "ringtone-02"
        case .silence: return "inaudible_tone"
        }
    }

    private var fileExtension: String { ".caf" }
}
