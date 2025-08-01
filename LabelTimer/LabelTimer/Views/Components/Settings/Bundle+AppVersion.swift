//
//  Bundle+AppVersion.swift
//  LabelTimer
//
//  Created by 이소연 on 8/1/25.
//
/// 앱 버전과 빌드 넘버를 제공하는 Bundle 확장
/// - 사용 목적:
///     1. 사용자 UI용: 기본 버전 문자열 (v1.1.1)
///     2. 디버깅용: 빌드 넘버 포함 (v1.1.1 (3))

import Foundation

extension Bundle {
    /// 사용자 UI용
    static var appVersion: String {
        "v\(appVersionOnly)"
    }

    /// 디버깅용
    static var fullVersion: String {
        "v\(appVersionOnly) (\(buildNumber))"
    }

    static var appVersionOnly: String {
        main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    static var buildNumber: String {
        main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
