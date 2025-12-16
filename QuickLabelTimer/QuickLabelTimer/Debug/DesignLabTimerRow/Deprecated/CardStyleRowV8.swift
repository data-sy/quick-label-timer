//
//  CardStyleRowV8.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//

import SwiftUI

// MARK: - Option D: iOS Clock App Style
struct CardStyleRowV8: View {
    let timer: TimerData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // [상단] 라벨 + 삭제
            HStack(alignment: .top) {
                Label(timer.label, systemImage: "timer")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 삭제 버튼 (X)
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color.gray.opacity(0.2)))
                }
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
                
                // 버튼 영역
                HStack(spacing: 12) {
                    // 리셋 버튼 (일시정지 시에만 표시)
                    if timer.status == .paused {
                        Button(action: {}) {
                            Image(systemName: "arrow.clockwise")
                                .font(.footnote)
                                .foregroundColor(.blue)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .strokeBorder(Color.blue.opacity(0.3), lineWidth: 1.5)
                                )
                        }
                    }
                    
                    // Play/Pause 토글 버튼 (메인)
                    Button(action: {}) {
                        Image(systemName: timer.status == .running ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
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
