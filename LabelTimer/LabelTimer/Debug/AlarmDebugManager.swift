//
//  AlarmDebugManager.swift
//  LabelTimer
//
//  Created by 이소연 on 8/20/25.
//
/// 알림 기능 테스트 시나리오를 실행하고 관리하는 유틸리티
///
/// - 사용 목적: 다양한 조건의 로컬 알림을 생성하고 검증하기 위한 테스트 로직 모음

import Foundation
import UserNotifications

@MainActor
enum AlarmDebugManager {
    
    // MARK: - Properties
    
    // TODO: 테스트용 prefix와 interval 상수 구현
    
    /// 앱 진입점에서 주입받을 실제 TimerService 인스턴스
    static var timerService: TimerServiceProtocol!
    
    // MARK: - 0. 유틸리티 기능
    
    // TODO: 유틸리티 함수 구현: 권한 요청, 테스트 알림 전체 삭제, 덤프(설정, 예약, 도착)
    
    // MARK: - 1. 소리 기본 동작 검증 (연속 로컬)
    
    // TODO: 소리 동작 테스트 함수 구현: 커스텀, 시스템, 무음, nil
    
    // MARK: - 2. 배너 기본 동작 검증
    
    // TODO: 배너 동작 테스트 함수 구현: 소리만
    
    // MARK: - 3. 연속 알림 성능 및 UX 검증
    
    // TODO: 연속 알림 테스트 함수 구현: 간격(barrage), 취소
    
    // MARK: - 4. 최종 정책 조합 검증
    
    // TODO: 최종 정책 조합 테스트 함수 구현: 소리/진동 조합
}
