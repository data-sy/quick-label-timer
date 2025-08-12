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
                .foregroundColor(isFavorite ? .yellow : .gray)
                .imageScale(.medium)
                .padding(8)
                .background(
                    Circle()
                        .stroke(
                            isFavorite ? Color.yellow : Color.gray.opacity(0.6),
                            lineWidth: 1.5
                        )
                )
        }
        .buttonStyle(.plain)
        // 접근성 라벨 등 추가 가능
    }
}
