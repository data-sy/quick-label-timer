//
//  AppTheme.swift
//  LabelTimer
//
//  Created by 이소연 on 8/10/25.
//
/// 앱의 전반적인 디자인 시스템(색상, 폰트 등)을 관리하는 중앙 저장소
///
/// - 사용 목적: 디자인 요소를 한 곳에서 관리
///

import SwiftUI

enum AppTheme {
    
    // MARK: - Colors
    // .systemGroupedBackground , .secondarySystemGroupedBackground
    // (라이트/다크) 연한 회색/완점 검은색 , 흰색/짙은 회색
    /// 앱의 가장 바깥쪽 페이지 배경색
    static let pageBackground = Color(.secondarySystemGroupedBackground)
    /// 콘텐츠가 담기는 영역의 배경색
    static let contentBackground = Color(.secondarySystemGroupedBackground)
    
    // MARK: - Fonts (예시)
    /*
    static let titleFont = Font.system(size: 24, weight: .bold)
    static let bodyFont = Font.system(size: 16)
    */
    
    // MARK: - Spacing (예시)
    /*
    static let defaultPadding: CGFloat = 16
    */
    
    // MARK: - Buttons (중앙 관리)
    enum Buttons {
        /// 원형 버튼 기본 지름(접근성 최소 44 권장)
        static var diameter: CGFloat = 50
        /// 채움 방식 전역 설정 (모든 버튼 공통)
        /// .primary(채움),  .secondary(외곽선), nil(각 매핑값 사용)
        static var emphasis: TimerButtonEmphasis? = .primary
    }
}
