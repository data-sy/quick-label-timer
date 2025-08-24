//
//  TimerRowView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 타이머 정보(레이블 + 시간 + 버튼)를 표시하는 공통 뷰
///
/// - 사용 목적: 실행 중 타이머, 프리셋 타이머 등 다양한 타이머 항목을 동일한 레이아웃으로 표현함

import SwiftUI

struct TimerRowView: View {
    let timer: TimerData
    let state: TimerInteractionState
    let statusText: String?
    let onToggleFavorite: (() -> Void)?
    let onLeftTap: (() -> Void)?
    let onRightTap: (() -> Void)?

    init(
        timer: TimerData,
        state: TimerInteractionState,
        statusText: String? = nil,
        onToggleFavorite: (() -> Void)? = nil,
        onLeftTap: (() -> Void)? = nil,
        onRightTap: (() -> Void)? = nil,
    ) {
        self.timer = timer
        self.state = state
        self.statusText = statusText
        self.onToggleFavorite = onToggleFavorite
        self.onLeftTap = onLeftTap
        self.onRightTap = onRightTap
    }
    
    /// 상태 × 즐겨찾기 → 좌/우 버튼 타입
    private var buttonTypes: TimerButtonSet {
        makeButtonSet(for: state, isFavorite: timer.isFavorite)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 6) {
                FavoriteToggleButton(
                    isFavorite: timer.isFavorite,
                    onToggle: { onToggleFavorite?() }
                )
                
                Text(timer.label)
                    .font(.headline)

                if let statusText = statusText {
                    Text(statusText)
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.7))
                }
                Spacer()
            }
            HStack {
                VStack(alignment: .leading, spacing: 0){
                    Text(timer.formattedTime)
                        .font(.system(size: 44, weight: .light))
                }
                
                Spacer()

                HStack(spacing: 12) {
                    if buttonTypes.left != .none {
                        TimerLeftButtonView(type: buttonTypes.left) {
                            onLeftTap?()
                        }
                    }
                    TimerRightButtonView(type: buttonTypes.right) {
                        onRightTap?()
                    }
                }
            }
            CountdownMessageView(timer: timer)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
