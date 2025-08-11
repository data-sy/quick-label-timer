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
        guard let m = ui(for: type) else { return AnyView(EmptyView()) }
        return AnyView(
            Button(role: m.role, action: action) {
                if m.showsTitle {
                    Label(m.title, systemImage: m.systemImage)
                } else {
                    Image(systemName: m.systemImage)
                        .imageScale(.large)
                }
            }
            .tint(m.tint)
            .timerButton(emphasis: m.emphasis, size: m.size, color: m.tint, shape: m.shape )
            .accessibilityLabel(m.title)
        )
    }
}
