//
//  RunningTimerRowView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 실행 중인 타이머에 대한 UI를 제공하는 래퍼 뷰
///
/// - 사용 목적: 실행 중 타이머의 정보와 동작 버튼(일시정지, 정지 등)을 표시

import SwiftUI

struct RunningTimerRowView: View {
    let timer: TimerData
    let deleteCountdownSeconds: Int
    let onAction: (TimerButtonType) -> Void
    let onToggleFavorite: (() -> Void)?
    
    var dynamicMessage: String? {
        guard let pendingAt = timer.pendingDeletionAt else { return nil }
        let remaining = Int(pendingAt.timeIntervalSince(Date()))
        guard remaining > 0 else { return nil }
        // 분기별 메시지 조합
        if timer.presetId == nil {
            return timer.isFavorite
                ? "\(remaining)초 후 즐겨찾기로 저장됩니다"
                : "\(remaining)초 후 삭제됩니다"
        } else {
            if timer.isFavorite {
                return "\(remaining)초 후 즐겨찾기로 돌아갑니다"
            } else {
                // 정상 진입 불가 분기, 방어적 처리
                assertionFailure("Preset 기반 타이머에서 isFavorite: false는 발생하지 않아야 함")
                return nil
            }
        }
    }

    var body: some View {
        let buttons = buttonSet(for: timer.interactionState)
        let statusText = self.statusText(for: timer.interactionState)

        VStack(alignment: .leading, spacing: 4) {
            TimerRowView(
                timer: timer,
                leftButton: AnyView(
                    TimerActionButton(type: buttons.left) {
                        onAction(buttons.left)
                    }
                ),
                rightButton: AnyView(
                    TimerActionButton(type: buttons.right) {
                        onAction(buttons.right)
                    }
                ),
                state: timer.interactionState,
                statusText: statusText,
                onToggleFavorite: onToggleFavorite
            )
            if let msg = dynamicMessage {
                Text(msg)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.top, 2)
            }
        }
        .id(timer.id) // 삭제 후 뷰 리프레시 보장
    }
    
    // 상태별로 보여줄 서브텍스트
    private func statusText(for state: TimerInteractionState) -> String? {
        switch state {
        case .paused:
            return "일시정지"
        case .stopped:
            return "정지"
        case .completed:
            return "종료"
        default:
            return nil
        }
    }
}
