//
//  TimerLeftButtonView.swift
//  LabelTimer
//
//  Created by 이소연 on 8/10/25.
//
/// 좌측 버튼 공통 컴포넌트
///
/// - 사용 목적: 좌측 버튼 타입을 실제 버튼으로 렌더 (공통 스타일/매핑 적용)

import SwiftUI

struct TimerLeftButtonView: View {
    let type: TimerLeftButtonType
    let action: () -> Void

    var body: some View {
        if let m = ui(for: type) {
            Button(role: m.role, action: action) {
                Image(systemName: m.systemImage)
                    .imageScale(.large)
            }
            .timerButton(color: m.tint)
            .accessibilityLabel(m.accessibilityLabel)
        } else {
            EmptyView()
        }
    }
}
