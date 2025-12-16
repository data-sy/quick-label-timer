//
//  TimerRowV17.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//


//
//  TimerRowV17.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//

import SwiftUI

// MARK: - V17: Enhanced Shadow (Deeper Lift)
struct TimerRowV17: View {
    let timer: TimerData
    let onLabelChange: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // [상단] 북마크 + 라벨 + 삭제
            HStack(alignment: .center, spacing: 8) {
                FavoriteToggleButton(endAction: timer.endAction, onToggle: {})
                    .frame(width: 44, height: 44)
                
                EditableTimerLabel(
                    timer: timer,
                    onLabelChange: onLabelChange
                )
                
                Spacer()
                
                // 삭제 버튼 (X)
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
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
                HStack(spacing: 16) {
                    // 리셋 버튼 (일시정지 시에만 표시)
                    if timer.status == .paused {
                        Button(action: {}) {
                            Image(systemName: "arrow.clockwise")
                                .font(.footnote)
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44)
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
            
            // [하단] 알람 모드 + 종료 시간
            HStack(spacing: 4) {
                Image(systemName: timer.alarmMode.iconName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(timer.status == .completed ? "timer-completed" : "오전 10:30 종료 예정")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding()
        .background(AppTheme.contentBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}