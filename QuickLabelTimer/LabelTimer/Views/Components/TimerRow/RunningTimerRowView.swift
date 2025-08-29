//
//  RunningTimerRowView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 실행 중인 타이머에 대한 UI를 제공하는 래퍼 뷰
///
/// - 사용 목적: 실행 중 타이머의 정보와 동작 버튼(일시정지, 정지 등)을 표시

import SwiftUI

struct RunningTimerRowView: View {
    let timer: TimerData
    let onToggleFavorite: (() -> Void)?
    let onLeftTap: (() -> Void)?
    let onRightTap: (() -> Void)?

    var body: some View {
        let statusText = self.statusText(for: timer.interactionState)

        VStack(alignment: .leading, spacing: 4) {
            TimerRowView(
                timer: timer,
                state: timer.interactionState,
                statusText: statusText,
                onToggleFavorite: onToggleFavorite,
                onLeftTap: onLeftTap,
                onRightTap: onRightTap
            )
        }
        .id(timer.id) // 삭제 후 뷰 리프레시 보장
    }
    
    // 상태별로 보여줄 서브텍스트
    private func statusText(for state: TimerInteractionState) -> String? {
        switch state {
        case .paused:
            return "일시정지"
        case .stopped:
            return "정지"
        case .completed:
            return "종료"
        default:
            return nil
        }
    }
}
