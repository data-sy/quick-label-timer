//
//  TimerButtonMapping.swift
//  LabelTimer
//
//  Created by 이소연 on 8/10/25.
//
/// 버튼 세트 매핑 유틸리티
///
/// - 사용 목적: 타이머 상태(`TimerState`)와 즐겨찾기 여부를 입력받아
///   좌/우 버튼 조합(`TimerButtonSet`)을 일관되게 결정하여 View에 주입하기 위함
///   UI에 의존하지 않는 순수 로직으로 분리해 테스트와 재사용성을 높임

import Foundation

// MARK: - Pure function

/// 상태 × 즐겨찾기 여부 → 좌/우 버튼 조합
func makeButtonSet(for state: TimerInteractionState, isFavorite: Bool) -> TimerButtonSet {
    switch state {
    case .preset:
        return .init(left: .none, right: .play)

    case .running:
        return .init(left: .stop, right: .pause)

    case .paused:
        return .init(left: .stop, right: .play)

    case .stopped, .completed:
        return .init(left: isFavorite ? .moveToFavorite : .delete,
                     right: .restart)
    }
}

// MARK: - Convenience

extension TimerInteractionState {
    /// 편의 확장: `timer.interactionState.buttonSet(isFavorite:)`
    func buttonSet(isFavorite: Bool) -> TimerButtonSet {
        makeButtonSet(for: self, isFavorite: isFavorite)
    }
}
