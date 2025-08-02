//
//  PresetTimerRowView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 프리셋 타이머에 대한 UI를 제공하는 래퍼 뷰
///
/// - 사용 목적: 미리 정의된 타이머의 전체 시간과 실행 버튼을 표시함

import SwiftUI

struct PresetTimerRowView: View {
    let preset: TimerPreset
    let onAction: (TimerButtonType) -> Void
    var onTap: (() -> Void)? = nil
    
    /// 전체 시간을 포맷된 문자열로 반환
    private var tempTimer: TimerData {
        TimerData(
            label: preset.label,
            hours: preset.hours,
            minutes: preset.minutes,
            seconds: preset.seconds,
            isSoundOn: preset.isSoundOn,
            isVibrationOn: preset.isVibrationOn,
            createdAt: Date(),
            endDate: Date(),
            remainingSeconds: preset.totalSeconds,
            status: .completed
        )
    }

    var body: some View {
        TimerRowView(
            timer: tempTimer,
            leftButton: AnyView(
                TimerActionButton(type: .delete) {
                    onAction(.delete)
                }
                .buttonStyle(.plain) // 셀 전체 터치 방지용 (List + Button 이슈)
            ),
            rightButton: AnyView(
                TimerActionButton(type: .play) {
                    onAction(.play)
                }
                .buttonStyle(.plain) // 셀 전체 터치 방지용 (List + Button 이슈)
            ),
            state: TimerInteractionState.preset
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
}
