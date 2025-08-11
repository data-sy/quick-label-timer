//
//  TimerLeftButtonType.swift
//  LabelTimer
//
//  Created by 이소연 on 8/10/25.
//
/// 좌측 버튼 타입 정의
/// - 사용 목적: 타이머 상태/즐겨찾기 여부에 따라 좌측 버튼(UI/액션)을 일관되게 매핑하기 위한 열거형

import Foundation

public enum TimerLeftButtonType: Equatable {
    /// 표시하지 않음
    case none
    /// 실행 중 타이머 강제 종료
    case stop
    /// 프리셋(즐겨찾기)으로 이동
    case moveToFavorite
    /// 완료되지 않은 일반 타이머 삭제
    case delete
}
