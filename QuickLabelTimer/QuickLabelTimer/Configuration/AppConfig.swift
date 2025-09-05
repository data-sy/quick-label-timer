//
//  AppConfig.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/31/25.
//
/// 앱의 기능적 설정 및 정책을 관리하는 중앙 저장소
///
/// - 사용 목적: 앱의 동작과 관련된 상수들을 한 곳에서 관리

import Foundation

enum AppConfig {
    
    // MARK: - Input Policy
    static let maxLabelLength = 100
    
    // MARK: - Timer & Notification Policy
    /// 동시에 실행 가능한 최대 타이머 개수
    static let maxConcurrentTimers = 5
    /// 타이머 하나당 예약되는 반복 알림의 개수
    static let repeatingNotificationCount = 12
    /// 연속 알림의 반복 간격 (초)
    static let notificationRepeatingInterval: TimeInterval = 3.0
    /// iOS 시스템이 허용하는 앱당 최대 알림 예약 개수
    static let notificationSystemLimit = 64
    
}
