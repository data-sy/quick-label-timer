//
//  CardStyleRowTwoButton.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//

import SwiftUI

// MARK: - 4. Modern Card Style (2-Button)
struct CardStyleRowTwoButton: View {
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
                
                // 버튼 2개 (원형, 그림자 적용)
                HStack(spacing: 12) {
                    // 왼쪽 버튼 (stop/reset)
                    Button(action: {}) {
                        Image(systemName: timer.status == .running ? "stop.fill" : "arrow.clockwise")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(Circle().fill(Color.red))
                            .shadow(radius: 4)
                    }
                    
                    // 오른쪽 버튼 (pause/resume)
                    Button(action: {}) {
                        Image(systemName: timer.status == .running ? "pause.fill" : "play.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(Circle().fill(Color.blue))
                            .shadow(radius: 4)
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
