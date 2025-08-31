//
//  AlarmModeIndicatorView.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/26/25.
//
/// 타이머에 설정된 알람 모드를 아이콘과 색상으로 표시하는 뷰
///
/// - 사용 목적: 사용자가 목록에서 각 타이머의 알람 설정을 한눈에 파악할 수 있도록 하기 위함

import SwiftUI

struct AlarmModeIndicatorView: View {
    let iconName: String
    let color: Color

    var body: some View {
        Image(systemName: iconName)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .frame(width: 30, height: 30)
    }
}
