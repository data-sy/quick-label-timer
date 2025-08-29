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
    
    /// 폼 내부 보조 컨트롤의 배경색 (0.75 * 0.1 = 0.075)
    static let controlBackgroundColor = Color.primary.opacity(0.075)
    /// 폼 내부 보조 컨트롤의 아이콘/텍스트 색상
    static let controlForegroundColor = Color.primary.opacity(0.75)

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
        /// 원형 버튼 기본 지름 (접근성 최소 44 권장)
        static let diameter: CGFloat = 52
        /// 외곽선 두께
        static let lineWidth: CGFloat = 1.5
        /// 아이콘 폰트 크기
        static let iconFont: Font = .headline
        /// 아이콘 폰트 두께
        static let iconWeight: Font.Weight = .bold
    }
}
