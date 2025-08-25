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
    let isFavorite: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .foregroundColor(isFavorite ? .yellow : .gray.opacity(0.6))
                .font(.title2)
                .frame(width: 44, height: 44) // 탭 영역 확보
        }
        .buttonStyle(.plain)
        // 접근성 라벨 등 추가 가능
    }
}
