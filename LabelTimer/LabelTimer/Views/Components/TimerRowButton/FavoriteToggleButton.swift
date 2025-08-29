//
//  FavoriteToggleButton.swift
//  LabelTimer
//
//  Created by 이소연 on 8/5/25.
//
/// 즐겨찾기(별) 토글 버튼
///
/// - 사용 목적: 즐겨찾기 상태를 표시하고 토글함

import SwiftUI

struct FavoriteToggleButton: View {
    let endAction: TimerEndAction
    let onToggle: () -> Void
    
//    private var isOn: Bool { endAction.isPreserve } // ✅
    
    var body: some View {
        Button(action: onToggle) {
            Image(systemName: endAction.isPreserve ? "star.fill" : "star")
                .foregroundColor(endAction.isPreserve ? .yellow : .gray.opacity(0.6))
                .font(.title2)
                .frame(width: 44, height: 44) // 탭 영역 확보
//                .accessibilityLabel("즐겨찾기") // ✅ 접근성 만들 때 주석 풀기
//                .accessibilityValue(isOn ? "켜짐" : "꺼짐")
//                .accessibilityHint("상태를 전환합니다")
//                .accessibilityAddTraits(isOn ? .isSelected : [])
                .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.7), value: endAction)
        }
        .buttonStyle(.plain)
    }
}
