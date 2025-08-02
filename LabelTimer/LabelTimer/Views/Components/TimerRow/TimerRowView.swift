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
    let label: String
    let timeText: String
    let leftButton: AnyView?
    let rightButton: AnyView?
    let state: TimerInteractionState

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(label)
                            .font(.headline)
                        if let statusText = statusText(for: state) {
                            Text(statusText)
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.7))
                        }
                    }
                    Text(timeText)
                        .font(.system(size: 44, weight: .light))
                }
                Spacer()
                HStack(spacing: 12) {
                    if let leftButton = leftButton { leftButton }
                    if let rightButton = rightButton { rightButton }
                }
            }
            .padding()
            .timerRowStateStyle(for: state)
        }
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

