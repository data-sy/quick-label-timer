// DebugSound.swift

/// 디버그용으로 시스템 알림 사운드를 정의하는 열거형
///
/// - 사용 목적: 사운드 테스트 화면에서 다양한 시스템 사운드를 재생하고 관리

import Foundation
import UserNotifications

enum DebugSound: String, CaseIterable, Identifiable {
    
    // MARK: - 기본
    case `default`
    
    // MARK: - 클래식 알림음
    case triTone = "tri-tone.caf"
    case chime = "chime.caf"
    case glass = "glass.caf"
    case horn = "horn.caf"
    case bell = "bell.caf"
    case electronic = "electronic.caf"

    // MARK: - 최신 알림음 (Modern Alerts)
    case anticipate = "anticipate.caf"
    case bloom = "bloom.caf"
    case calypso = "calypso.caf"
    case chooChoo = "choo-choo.caf"
    case fanfare = "fanfare.caf"
    case hello = "hello.caf"
    case ladder = "ladder.caf"
    case minuet = "minuet.caf"
    case newsFlash = "new-flash.caf"
    case noir = "noir.caf"
    case sherwoodForest = "sherwood_forest.caf"
    case spell = "spell.caf"
    case suspense = "suspense.caf"
    case swish = "swish.caf"
    case telegraph = "telegraph.caf"
    case tiptoes = "tiptoes.caf"
    case typewriters = "typewriters.caf"
    case update = "update.caf"

    // MARK: - 기능 및 UI 사운드
    case lock = "lock.caf"
    case unlock = "unlock.caf"
    case photoShutter = "photoShutter.caf"
    case keyboardPressClear = "keyboard_press_clear.caf"
    case keyboardPressDelete = "keyboard_press_delete.caf"
    case keyboardPressStandard = "keyboard_press_standard.caf"
    
    // MARK: - SMS/메일 관련
    case receivedMessage = "ReceivedMessage.caf"
    case sentMessage = "SentMessage.caf"
    case newMail = "new-mail.caf"
    case mailSent = "mail-sent.caf"
    case smsReceived1 = "sms-received1.caf"
    case smsReceived2 = "sms-received2.caf"
    case smsReceived3 = "sms-received3.caf"
    case smsReceived4 = "sms-received4.caf"
    
    var id: String { self.rawValue }
    
    /// UI에 표시될 이름
    var displayName: String {
        // .caf 확장자를 제거하고, 하이픈(-)을 공백으로 바꾼 뒤, 첫 글자를 대문자로 만듭니다.
        let name = self.rawValue.replacingOccurrences(of: ".caf", with: "").replacingOccurrences(of: "-", with: " ")
        if self == .default {
            return "기본 사운드 (Default)"
        }
        return name.prefix(1).uppercased() + name.dropFirst()
    }
    
    /// 실제 UNNotificationSound 객체
    var notificationSound: UNNotificationSound {
        if self == .default {
            return .default
        } else {
            return UNNotificationSound(named: UNNotificationSoundName(self.rawValue))
        }
    }
}