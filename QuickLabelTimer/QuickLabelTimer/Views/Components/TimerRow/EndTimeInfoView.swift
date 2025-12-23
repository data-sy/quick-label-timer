//
//  EndTimeInfoView.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/23/25.
//
/// 알람 아이콘과 종료 예정 시각을 표시하는 뷰
///
/// - 사용 목적: 타이머의 종료 예정 시각과 알람 모드를 표시

import SwiftUI

struct EndTimeInfoView: View {
    let timer: TimerData
    let foregroundColor: Color
    
    var body: some View {
        HStack(spacing: 4) {
            let alarmMode = AlarmNotificationPolicy.getMode(
                soundOn: timer.isSoundOn,
                vibrationOn: timer.isVibrationOn
            )
            Image(systemName: alarmMode.iconName)
                .font(.caption)
                .foregroundColor(foregroundColor.opacity(RowTheme.secondaryOpacity))
            
            if timer.status == .paused || timer.status == .stopped {
                TimelineView(.periodic(from: .now, by: 60)) { _ in
                    Text(timer.formattedEndTime)
                        .font(.footnote)
                        .foregroundColor(foregroundColor.opacity(RowTheme.secondaryOpacity))
                }
            } else {
                Text(timer.formattedEndTime)
                    .font(.footnote)
                    .foregroundColor(foregroundColor.opacity(RowTheme.secondaryOpacity))
            }
        }
    }
}
