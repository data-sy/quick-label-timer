//
//  LabelSanitizer.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 9/1/25.
//
/// 라벨 문자열을 정리(sanitize)하는 유틸리티
///
/// - 사용 목적: 사용자가 입력한 라벨 문자열을 최종 저장/실행 시점에 깨끗하게 정리

enum LabelSanitizer {

    static func sanitizeOnSubmit(_ input: String, maxLength: Int) -> String {
        var result = input
            // 줄바꿈을 공백으로 (복붙 대비)
            .replacingOccurrences(of: #"\s*\n+\s*"#, with: " ", options: .regularExpression)
            // 연속 공백을 하나로
            .replacingOccurrences(of: #"\s{2,}"#, with: " ", options: .regularExpression)
            // 앞뒤 공백 제거
            .trimmingCharacters(in: .whitespacesAndNewlines)
        // 최대 길이 넘지 못하게
        if result.count > maxLength {
            result = String(result.prefix(maxLength))
        }
        return result
    }
}
