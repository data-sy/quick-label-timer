//
//  AlarmModeSelectorView.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/22/25.
//
/// 알림 방식 선택 세그먼트 컴포넌트
///
/// - 사용 목적: 사용자가 '소리+진동 / 진동만 / 무음' 중 하나를 직관적으로 선택하도록 제공
///         선택 결과는 AlarmMode로 바인딩되어 정책 결정 로직(AlarmNotificationPolicy)과 연동됨

import SwiftUI

struct AlarmModeSelectorView: View {
    @Binding var selectedMode: AlarmMode
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AlarmMode.allCases) { mode in
                ZStack {
                    if selectedMode == mode {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppTheme.controlBackgroundColor)
                            .matchedGeometryEffect(id: "selection", in: animation)
                    }
                    
                    Image(systemName: mode.iconName)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 6)
                }
                .frame(width: 44)
                .font(.callout)
                .foregroundStyle(selectedMode == mode ? AppTheme.controlForegroundColor : .gray)
                .onTapGesture {
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                        selectedMode = mode
                    }
                }
                if mode != AlarmMode.allCases.last {
                    Divider().frame(height: 20)
                }
            }
        }
        .padding(2) // 회색 영역과 하얀 버튼 사이 간격
        .background(Color(UIColor.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
