import SwiftUI

//
//  TimerRowView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 타이머 정보(레이블 + 시간 + 버튼)를 표시하는 공통 뷰
///
/// - 사용 목적: 실행 중 타이머, 프리셋 타이머 등 다양한 타이머 항목을 동일한 레이아웃으로 표현함

struct TimerRowView: View {
    let label: String
    let timeText: String
    let leftButton: AnyView?
    let rightButton: AnyView?
    let state: TimerInteractionState

    var body: some View {
        let style = TimerRowStateStyle(state: state)

        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(style.labelFont)

                    Text(timeText)
                        .font(style.timeFont)
                }

                Spacer()

                HStack(spacing: 12) {
                    if let leftButton = leftButton {
                        leftButton
                    }

                    if let rightButton = rightButton {
                        rightButton
                    }
                }
            }
            .padding()
            .modifier(style) // 배경색 및 텍스트 색 적용
        }

    }
}
