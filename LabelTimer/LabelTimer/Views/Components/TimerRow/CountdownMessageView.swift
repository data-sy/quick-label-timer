//
//  CountdownMessageView.swift
//  LabelTimer
//
//  Created by 이소연 on 8/14/25.
//
/// 완료 후 자동 삭제/보관까지 남은 시간을 표시하는 뷰
///
/// - 사용 목적: TimelineView를 사용해 1초마다 스스로 뷰를 갱신하며 카운트다운 메시지를 표시

import SwiftUI

struct CountdownMessageView: View {
    let pendingAt: Date?
    let isFavorite: Bool
    let presetId: UUID?
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            if let message = dynamicMessage(now: context.date) {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 2)
            }
        }
    }
    
    /// 완료 후 n초 카운트다운 안내 메시지를 계산하는 함수
    private func dynamicMessage(now: Date) -> String? {
        guard let pendingAt = pendingAt else { return nil }
        
        let remaining = Int(pendingAt.timeIntervalSince(now))
        guard remaining > 0 else { return nil }
        
        if presetId == nil {
            return isFavorite
                ? "\(remaining)초 후 즐겨찾기로 저장됩니다"
                : "\(remaining)초 후 삭제됩니다"
        } else {
            return isFavorite
                ? "\(remaining)초 후 즐겨찾기로 돌아갑니다"
                : "\(remaining)초 후 삭제됩니다"
        }
    }
}
