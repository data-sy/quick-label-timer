//
//  FavoritePresetRowView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 프리셋 타이머에 대한 UI를 제공하는 래퍼 뷰
///
/// - 사용 목적: 미리 정의된 타이머의 전체 시간과 실행 버튼을 표시함

import SwiftUI

struct FavoritePresetRowView: View {
    @Environment(\.editMode) private var editMode
    let preset: TimerPreset
    let onToggleFavorite: (() -> Void)?
    let onLeftTap: (() -> Void)?
    let onRightTap: (() -> Void)?
    
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }
    
    /// 전체 시간을 포맷된 문자열로 반환
    private var tempTimer: TimerData {
        TimerData(
            id: preset.id,
            label: preset.label,
            hours: preset.hours,
            minutes: preset.minutes,
            seconds: preset.seconds,
            isSoundOn: preset.isSoundOn,
            isVibrationOn: preset.isVibrationOn,
            createdAt: Date(),
            endDate: Date(),
            remainingSeconds: preset.totalSeconds,
            status: .stopped,
            pendingDeletionAt: nil,
            presetId: preset.id,
            endAction: .preserve
        )
    }

    var body: some View {
        TimerRowView(
            timer: tempTimer,
            state: TimerInteractionState.preset,
            onToggleFavorite: onToggleFavorite,
            onLeftTap: onLeftTap,
            onRightTap: onRightTap
        )
        .opacity(isEditing ? 0.5 : 1.0)
        .allowsHitTesting(!isEditing)
        .animation(.easeInOut(duration: 0.2), value: isEditing)
    }
}
