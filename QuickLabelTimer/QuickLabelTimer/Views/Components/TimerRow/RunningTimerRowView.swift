//
//  RunningTimerRowView.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 실행 중인 타이머에 대한 UI를 제공하는 래퍼 뷰
///
/// - 사용 목적: 실행 중 타이머의 정보와 동작 버튼(일시정지, 정지 등)을 표시

import SwiftUI

struct RunningTimerRowView: View {
    let timer: TimerData
    let onToggleFavorite: (() -> Void)?
    let onPlayPause: (() -> Void)?
    let onReset: (() -> Void)?
    let onDelete: (() -> Void)?
    let onLabelChange: ((String) -> Void)?

    var body: some View {
        TimerRow(
            timer: timer,
            scrollProxy: nil,
            onToggleFavorite: onToggleFavorite ?? {},
            onPlayPause: onPlayPause ?? {},
            onReset: onReset ?? {},
            onDelete: onDelete ?? {},
            onEdit: nil,
            onLabelChange: onLabelChange ?? { _ in },
            trailingContent: {
                AnyView(
                    DeleteTimerButton(
                        status: timer.status,
                        onTap: onDelete ?? {}
                    )
                )
            }
        )
        .id(timer.id) // 삭제 후 뷰 리프레시 보장
    }

}
