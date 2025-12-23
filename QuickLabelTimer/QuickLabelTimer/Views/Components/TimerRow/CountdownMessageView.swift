//
//  CountdownMessageView.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/14/25.
//
/// 완료 후 자동 삭제/보관까지 남은 시간을 표시하는 뷰
///
/// - 사용 목적: TimelineView를 사용해 1초마다 스스로 뷰를 갱신하며 카운트다운 메시지를 표시

import SwiftUI

struct CountdownMessageView: View {
    let timer: TimerData
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            if let pendingAt = timer.pendingDeletionAt {
                let remaining = Int(pendingAt.timeIntervalSince(context.date))
                if remaining > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: iconName)
                            .font(.caption)
                        
                        Text(dynamicMessage(remaining: remaining))
                            .font(.footnote)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(timer.endAction.isPreserve ? .yellow : .red)
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    /// endAction에 따라 적절한 아이콘 반환
    private var iconName: String {
        switch timer.endAction {
        case .preserve:
            return "bookmark.circle.fill"
        case .discard:
            return "trash.circle.fill"  
        }
    }
    
    /// 완료 후 n초 카운트다운 안내 메시지를 계산하는 함수
    private func dynamicMessage(remaining: Int) -> String {
        let messageKey: String
        switch (timer.presetId, timer.endAction) {
        case (.none, .preserve): messageKey = "ui.countdown.saveToFavorites"
        case (.some, .preserve): messageKey = "ui.countdown.returnToFavorites"
        case (.none, .discard):  messageKey = "ui.countdown.deleteTimer"
        case (.some, .discard):  messageKey = "ui.countdown.removeFromFavorites"
        }
        return String(format: String(localized: String.LocalizationValue(messageKey)), remaining)
    }
}
