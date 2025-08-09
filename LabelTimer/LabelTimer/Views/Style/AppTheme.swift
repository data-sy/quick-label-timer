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
    // (리이트/다크) 연한 회색/완점 검은색 , 흰색/짙은 회색

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
}
