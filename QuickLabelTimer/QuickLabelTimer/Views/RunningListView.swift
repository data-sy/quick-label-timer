//
//  RunningListView.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 실행 중인 타이머 목록을 표시하는 뷰
///
/// - 사용 목적: 생성된 타이머를 리스트 형태로 보여주고, 남은 시간을 실시간으로 업데이트

import SwiftUI

struct RunningListView: View {
    @ObservedObject var viewModel: RunningListViewModel
                
    var body: some View {
        TimerListContainerView(
            title: "실행중인 타이머",
            items: viewModel.sortedTimers,
            emptyMessage: A11yText.RunningList.emptyMessage,
            stateProvider: { timer in
                return timer.interactionState
            }
        ) { timer in
            RunningTimerRowView(
                timer: timer,
                onToggleFavorite: {
                    viewModel.toggleFavorite(for: timer.id)
                },
                onLeftTap: {
                    viewModel.handleLeft(for: timer)
                },
                onRightTap: {
                    viewModel.handleRight(for: timer)
                }
            )
            .id(timer.id)
        }
        .appAlert(item: $viewModel.activeAlert)
    }
}
