//
//  CardStyleRowV5.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//

import SwiftUI

// MARK: - Option A: iOS Native Style
struct CardStyleRowV5: View {
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
                
                // 텍스트 버튼 2개
                HStack(spacing: 20) {
                    // Stop 버튼 (보조)
                    Button(action: {}) {
                        Label("정지", systemImage: "stop.circle")
                            .font(.body)
                            .foregroundColor(.red)
                    }
                    
                    // Pause/Resume 버튼 (주)
                    Button(action: {}) {
                        Label(timer.status == .running ? "일시정지" : "재개", 
                              systemImage: timer.status == .running ? "pause.circle.fill" : "play.circle.fill")
                            .font(.body)
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
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
