//
//  CardStyleRowV6.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//


//
//  CardStyleRow_v6.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//

import SwiftUI

// MARK: - Option B: Outlined Circle
struct CardStyleRowV6: View {
    let timer: TimerData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // [상단] 라벨 + 즐겨찾기
            HStack(alignment: .top) {
                Label(timer.label, systemImage: "timer")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                FavoriteToggleButton(endAction: timer.endAction, onToggle: {})
            }
            
            Divider().padding(.vertical, 4)
            
            // [중단] 시간 + 버튼
            HStack(alignment: .center, spacing: 16) {
                // 시간 표시
                Text(timer.formattedTime)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(timer.status == .completed ? .red : .primary)
                    .minimumScaleFactor(0.5)
                
                Spacer()
                
                // Outlined Circle 버튼 2개
                HStack(spacing: 12) {
                    // Stop (윤곽선만)
                    Button(action: {}) {
                        Image(systemName: "stop.fill")
                            .font(.title3)
                            .foregroundColor(.red)
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .strokeBorder(Color.red, lineWidth: 2)
                            )
                    }
                    
                    // Pause/Resume (반투명 배경 + 윤곽선)
                    Button(action: {}) {
                        Image(systemName: timer.status == .running ? "pause.fill" : "play.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .overlay(
                                        Circle().strokeBorder(Color.blue, lineWidth: 2)
                                    )
                            )
                    }
                }
            }
            
            // [하단] 메타 정보
            HStack {
                Text(timer.status == .completed ? "타이머 종료" : "오전 10:30 종료 예정")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding()
        .background(AppTheme.contentBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}