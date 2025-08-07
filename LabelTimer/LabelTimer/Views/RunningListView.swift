//
//  RunningListView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 실행 중인 타이머 목록을 표시하는 뷰
///
/// - 사용 목적: 생성된 타이머를 리스트 형태로 보여주고, 남은 시간을 실시간으로 업데이트

import SwiftUI

struct RunningListView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var presetManager: PresetManager
    
    @StateObject private var viewModel: RunningTimerListViewModel
        
    init(timerManager: TimerManager, presetManager: PresetManager) {
        _viewModel = StateObject(wrappedValue: RunningTimerListViewModel(
            timerManager: timerManager,
            presetManager: presetManager
        ))
    }

    var body: some View {
        TimerListContainerView(
            title: "실행중인 타이머",
            items: timerManager.timers.sorted(by: { $0.createdAt > $1.createdAt }),
            emptyMessage: "아직 실행 중인 타이머가 없습니다.",
        ) { timer in
            RunningTimerRowView(
                timer: timer,
                deleteCountdownSeconds: viewModel.deleteCountdownSeconds,
                onAction: { action in
                    viewModel.handleAction(action, for: timer)
                },
                onToggleFavorite: {
                    viewModel.toggleFavorite(for: timer.id)
                }
            )
        }
    }
}
