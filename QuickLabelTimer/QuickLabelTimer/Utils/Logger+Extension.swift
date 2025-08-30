//
//  Logger+Extension.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/30/25.
//
/// OSLog.Logger를 앱 전역에서 일관된 방식으로 생성하고 사용하기 위한 확장 파일
///
/// - 사용 목적:
///   - 모든 Logger 인스턴스가 동적으로 가져온 번들 ID를 subsystem으로 공유하도록 보장
///   - 각기 다른 파일(category)에서 Logger를 간편하게 생성
///   - 로거 초기화와 관련된 코드 중복 방지 및 하드코딩 제거

import Foundation
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static func withCategory(_ category: String) -> Logger {
        
        #if DEBUG
        // 추가한 곳 --- Logger 생성 값 직접 확인 ---
        print("✅ Logger Subsystem: \(subsystem)")
        print("✅ Logger Category: \(category)")
        // --------------------------------
        #endif

        return Logger(subsystem: subsystem, category: category)
    }
}
