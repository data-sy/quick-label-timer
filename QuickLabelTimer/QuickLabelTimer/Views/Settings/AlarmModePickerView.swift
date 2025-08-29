//
//  AlarmModePickerView.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/25/25.
//
/// 사용자가 타이머 종료 시 적용할 기본 알림 방식을 선택하는 뷰
///
/// - 사용 목적: 소리+진동 / 진동만 / 무음 중 하나를 기본값으로 지정하여, 타이머 생성 시 초기 알람 모드로 반영되도록 설정

import SwiftUI

struct AlarmModePickerView: View {
    @AppStorage("defaultAlarmMode") private var defaultAlarmMode: AlarmMode = .sound
    private let iconAreaWidth: CGFloat = 64
    
    private func displayName(for mode: AlarmMode) -> String {
        switch mode {
        case .sound: return "소리 O, 진동 O"
        case .vibration: return "소리 X, 진동 O"
        case .silent: return "소리 X, 진동 X"
        }
    }

    var body: some View {
        List(AlarmMode.allCases) { mode in
            HStack(spacing: 10) {
                ZStack {
                    Image(systemName: mode.iconName)
                }
                .foregroundColor(AppTheme.controlForegroundColor)
                .frame(width: iconAreaWidth, alignment: .center)

                Text(displayName(for: mode))

                Spacer()

                if mode == defaultAlarmMode {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                defaultAlarmMode = mode
            }
        }
        .navigationTitle("기본 알림 방식")
    }
}
