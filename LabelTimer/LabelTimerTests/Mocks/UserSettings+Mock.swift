//
//  UserSettings+Mock.swift
//  LabelTimer
//
//  Created by 이소연 on 7/26/25.
//
/// UserSettings의 테스트 전용 mock 인스턴스 생성 확장
///
/// - 사용 목적: 유닛 테스트에서 사운드/진동 설정 값을 주입하기 위해 사용

import Foundation
@testable import LabelTimer

extension UserSettings {
    static func mock(soundOn: Bool = true, vibrationOn: Bool = true) -> UserSettings {
        let settings = UserSettings()
        settings.isSoundOn = soundOn
        settings.isVibrationOn = vibrationOn
        return settings
    }
}
