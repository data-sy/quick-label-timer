//
//  UserSettings.swift
//  LabelTimer
//
//  Created by 이소연 on 7/25/25.
//
/// 사용자 사운드 및 진동 설정을 저장하고 관리하는 모델
///
/// - 사용 목적: 사용자 설정에 따라 타이머 알림의 사운드/진동 재생 여부를 제어

import Foundation

final class UserSettings: ObservableObject {
    static let shared = UserSettings()

    @Published var isSoundOn: Bool {
        didSet { UserDefaults.standard.set(isSoundOn, forKey: "isSoundOn") }
    }

    @Published var isVibrationOn: Bool {
        didSet { UserDefaults.standard.set(isVibrationOn, forKey: "isVibrationOn") }
    }

    private init() {
        self.isSoundOn = UserDefaults.standard.object(forKey: "isSoundOn") as? Bool ?? false
        self.isVibrationOn = UserDefaults.standard.object(forKey: "isVibrationOn") as? Bool ?? true
    }
}
