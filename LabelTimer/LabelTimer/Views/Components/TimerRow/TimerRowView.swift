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

    // 폰트 크기 및 두께 (고정값)
    private let labelFont: Font = .headline
    private let timeFont: Font = .system(size: 44, weight: .regular)
    // 폰트 및 배경 색상 (타이머 상태에 따라 변함)
    let state: TimerInteractionState
    
    var body: some View {
        HStack {
            // 라벨 및 시간
            VStack(alignment: .leading) {
                Text(label)
                    .font(labelFont)
                Text(timeText)
                    .font(timeFont)
            }

            Spacer()

            if let leftButton = leftButton {
                leftButton
            }

            if let rightButton = rightButton {
                rightButton
            }
        }
        .padding()
        .cornerRadius(8)
        .timerRowStateStyle(for: state)
    }
}
