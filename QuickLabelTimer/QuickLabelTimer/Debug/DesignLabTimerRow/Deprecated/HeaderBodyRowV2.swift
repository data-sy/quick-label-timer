//
//  HeaderBodyRow.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//

import SwiftUI

// MARK: - 2. Header & Body Style
struct HeaderBodyRow: View {
    let timer: TimerData
    @State private var isEditing = false // UI 테스트용
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // [Header] 아이콘 + 라벨
            HStack(alignment: .top, spacing: 8) {
                FavoriteToggleButton(endAction: timer.endAction, onToggle: {})
                    .scaleEffect(0.8) // 헤더에 맞게 조금 작게
                
                Text(timer.label)
                    .font(.headline)
                    .foregroundColor(AppTheme.controlForegroundColor) // 앱 테마 컬러 사용
                    .lineLimit(nil) // 줄바꿈 허용
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 10) // 아이콘과 높이 맞춤
                
                Spacer()
            }
            
            // [Body] 시간 + 컨트롤 버튼
            HStack(alignment: .bottom) {
                // 시간 & 상태 아이콘
                VStack(alignment: .leading, spacing: 4) {
                    Text(timer.formattedTime)
                        .font(.system(size: 40, weight: .light)) // 기존보다 조금 작지만 깔끔하게
                        .foregroundColor(timer.status == .running ? .primary : .secondary)
                        .monospacedDigit()
                    
                    HStack(spacing: 4) {
                        AlarmModeIndicatorView(iconName: "bell.fill", color: .gray)
                        Text(timer.status == .running ? "10:30 종료" : "일시정지됨")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // 버튼 영역 (기존 컴포넌트 재사용)
                HStack(spacing: 12) {
                    TimerLeftButtonView(type: .stop, action: {})
                    TimerRightButtonView(type: .pause, action: {})
                }
                .padding(.bottom, 6)
            }
            .padding(.leading, 4) // 라벨보다 살짝 들여쓰기
        }
        .padding(12)
    }
}
