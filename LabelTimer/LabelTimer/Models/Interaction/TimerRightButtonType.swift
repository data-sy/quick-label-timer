//
//  TimerRightButtonType.swift
//  LabelTimer
//
//  Created by 이소연 on 8/10/25.
//
/// 우측 버튼 타입 정의
/// - 사용 목적: 타이머 상태 변화(재생/일시정지/재시작)를 단일 인터페이스로 연결하기 위한 열거형

import Foundation

public enum TimerRightButtonType: Equatable {
    /// 타이머 시작 또는 재개
    case play
    /// 실행 중 → 일시정지
    case pause
    /// 중단된 타이머 재시작
    case restart
}
