//
//  TimerRightButtonView.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/10/25.
//
/// 우측 버튼 공통 컴포넌트
/// 
/// - 사용 목적: 우측 버튼 타입을 실제 버튼으로 렌더 (공통 스타일/매핑 적용)

import SwiftUI

struct TimerRightButtonView: View {
    let type: TimerRightButtonType
    let action: () -> Void

    var body: some View {
        let m = ui(for: type)
        return Button(role: m.role, action: action) {
            Image(systemName: m.systemImage)
                .imageScale(.large)
        }
        .timerButton(color: m.tint)
        .accessibilityLabel(m.accessibilityLabel)
    }
}
