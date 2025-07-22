
import SwiftUI

//
//  PresetTimerRowView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 프리셋 타이머에 대한 UI를 제공하는 래퍼 뷰
///
/// - 사용 목적: 미리 정의된 타이머의 전체 시간과 실행 버튼을 표시함

struct PresetTimerRowView: View {
    let preset: TimerPreset
    let onAction: (TimerButtonType) -> Void
    
    /// 전체 시간을 포맷된 문자열로 반환
    private var formattedTotalTime: String {
        let total = preset.totalSeconds
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60

        if hours > 0 {
            return String(format: "%01d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    var body: some View {
        TimerRowView(
            label: preset.label,
            timeText: formattedTotalTime,

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
            )
        )
    }
}
