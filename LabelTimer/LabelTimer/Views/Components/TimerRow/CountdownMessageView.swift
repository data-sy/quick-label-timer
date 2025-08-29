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
    let timer: TimerData
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            if let pendingAt = timer.pendingDeletionAt {
                let remaining = Int(pendingAt.timeIntervalSince(context.date))
                if remaining > 0 {
                    Text(dynamicMessage(remaining: remaining))
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 2)
                }
            }
        }
    }
    
    /// 완료 후 n초 카운트다운 안내 메시지를 계산하는 함수
    private func dynamicMessage(remaining: Int) -> String {
        if timer.presetId == nil {
            return timer.endAction.isPreserve ? "\(remaining)초 후 즐겨찾기로 저장됩니다"
                                   : "\(remaining)초 후 삭제됩니다"
        } else {
            return timer.endAction.isPreserve ? "\(remaining)초 후 즐겨찾기로 돌아갑니다"
                                   : "\(remaining)초 후 삭제됩니다"
        }
    }
//    private func dynamicMessage(remaining: Int) -> String { ✅ 개선된 로직. 기본 리팩토링 성공을 먼저 확인. 성공하면 위의 dynamicMessage 함수 삭제하고 주석 풀자
//        let phrase: String
//        switch (timer.presetId == nil, timer.endAction) {
//        case (true,  .preserve): phrase = "즐겨찾기로 저장됩니다"
//        case (false, .preserve): phrase = "즐겨찾기로 돌아갑니다"
//        case (_,     .discard):  phrase = "삭제됩니다"
//        }
//        return "\(remaining)초 후 \(phrase)"
//    }

}
