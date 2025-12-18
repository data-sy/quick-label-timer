//
//  RowTheme.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/18/25.
//
///  타이머 행(Row) 관련 디자인 시스템
///
/// - 사용 목적: 타이머 행의 디자인 요소를 한 곳에서 관리

import SwiftUI

enum RowTheme {
    // MARK: - Layout
    /// 행 모서리 둥글기
    static let cornerRadius: CGFloat = 20
    /// 행 내부 패딩
    static let padding: CGFloat = 16
    
    // MARK: - Shadow
    /// 행 그림자 색깔
    static let shadowColor = Color.primary.opacity(0.12)
    /// 행 그림자 반경
    static let shadowRadius: CGFloat = 8
    /// 행 그림자 Y 오프셋
    static let shadowY: CGFloat = 4
    
    // MARK: - Typography
    /// 시간 텍스트 크기
    static let timeTextSize: CGFloat = 48
    
    // MARK: - Buttons
    /// 주 버튼 크기 (Play/Pause)
    static let primaryButtonSize: CGFloat = 56
    /// 보조 버튼 크기 (Reset)
    static let secondaryButtonSize: CGFloat = 44
    /// 북마크 버튼 크기
    static let bookmarkButtonSize: CGFloat = 44
    /// 액션 버튼 간격
    static let actionButtonSpacing: CGFloat = 16
    /// 버튼 그림자 반경
    static let buttonShadowRadius: CGFloat = 4
    /// 버튼 아이콘 기본 색상
    static let buttonIconDefaultColor = Color.white
    
    // MARK: - Opacity (중앙 관리)
    /// 보조 요소 투명도 (아이콘, 서브텍스트 등)
    static let secondaryOpacity: CGFloat = 0.8
    /// Divider 투명도
    static let dividerOpacity: CGFloat = 0.3
    /// 비활성 버튼 외곽선 투명도
    static let inactiveStrokeOpacity: CGFloat = 0.3
    /// 활성 버튼 외곽선 투명도
    static let activeStrokeOpacity: CGFloat = 0.5
    
    // MARK: - State Colors
    /// 타이머 상태별 색상 정의
    /// - cardBackground: 카드 배경색
    /// - cardForeground: 카드 내 텍스트 색상 (시간, 라벨, 종료시간 등)
    /// - buttonBackground: 버튼 동그라미 배경색
    /// - buttonForeground: 버튼 내부 아이콘 색상
    /// 시작 전 (준비 상태)
    enum Stopped {
        static let cardBackground = Color(.systemBackground)
        static let cardForeground = Color.primary
        static let buttonBackground = Color.blue
        static let buttonForeground = Color.white
    }
    
    /// 일시정지 상태
    enum Paused {
        static let cardBackground = Color.blue.opacity(0.15)
        static let cardForeground = Color.primary
        static let buttonBackground = Color.blue
        static let buttonForeground = Color.white
    }
    
    /// 실행 중 상태
    enum Running {
        static let cardBackground = Color.blue.opacity(0.8)
        static let cardForeground = Color.white
        static let buttonBackground = Color.white
        static let buttonForeground = Color.blue
    }
    
    /// 완료 상태
    enum Completed {
        static let cardBackground = Color.green.opacity(0.8)
        static let cardForeground = Color.white
        static let buttonBackground = Color.white
        static let buttonForeground = Color.green
    }
    
    // MARK: - Helper
    ///  타이머 상태에 따른 색상 가져오기 (4가지 색상 반환)
    static func colors(for status: TimerStatus) -> (
        cardBackground: Color,
        cardForeground: Color,
        buttonBackground: Color,
        buttonForeground: Color
    ) {
        switch status {
        case .stopped:
            return (
                Stopped.cardBackground,
                Stopped.cardForeground,
                Stopped.buttonBackground,
                Stopped.buttonForeground
            )
        case .paused:
            return (
                Paused.cardBackground,
                Paused.cardForeground,
                Paused.buttonBackground,
                Paused.buttonForeground
            )
        case .running:
            return (
                Running.cardBackground,
                Running.cardForeground,
                Running.buttonBackground,
                Running.buttonForeground
            )
        case .completed:
            return (
                Completed.cardBackground,
                Completed.cardForeground,
                Completed.buttonBackground,
                Completed.buttonForeground
            )
        }
    }
}
