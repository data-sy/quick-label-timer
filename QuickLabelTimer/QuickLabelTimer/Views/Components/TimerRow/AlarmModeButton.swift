//
//  AlarmModeButton.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/23/25.
//
/// 알람 모드를 표시하고 편집 화면을 여는 버튼
///
/// - 사용 목적: 프리셋의 알람 설정을 시각적으로 표시하고 편집 기능 제공

import SwiftUI

struct AlarmModeButton: View {
    let isSoundOn: Bool
    let isVibrationOn: Bool
    let status: TimerStatus
    let onTap: () -> Void
    
    private var alarmMode: AlarmMode {
        AlarmNotificationPolicy.getMode(soundOn: isSoundOn, vibrationOn: isVibrationOn)
    }
    
    private var foregroundColor: Color {
        let colors = RowTheme.colors(for: status)
        return colors.cardForeground.opacity(RowTheme.secondaryOpacity)
    }
    
    var body: some View {
        Button(action: onTap) {
            Image(systemName: alarmMode.iconName)
                .font(.system(size: RowTheme.alarmIconSize))
                .foregroundColor(foregroundColor)
                .frame(width: RowTheme.deleteButtonTapArea, height: RowTheme.deleteButtonTapArea)
        }
        .buttonStyle(.plain)
    }
}
