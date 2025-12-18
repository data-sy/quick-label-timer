//
//  TimerRowGlassV14.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//

import SwiftUI

// MARK: - V14: State-based Glass Overlay
struct TimerRowGlassV14: View {
    let timer: TimerData
    let onLabelChange: (String) -> Void
    
    private var showsGlass: Bool {
        timer.status == .running || timer.status == .paused
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // [상단] 북마크 + 라벨 + 삭제
            HStack(alignment: .center, spacing: 8) {
                FavoriteToggleButton(endAction: timer.endAction, onToggle: {})
                
//                EditableTimerLabel(
//                    timer: timer,
//                    onLabelChange: onLabelChange
//                )
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 44, height: 44)
                }
            }
            
            Divider().padding(.vertical, 4)
            
            // [중단] 시간 + 버튼
            HStack(alignment: .center, spacing: 16) {
                Text(timer.formattedTime)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(timer.status == .completed ? .red : .primary)
                    .minimumScaleFactor(0.5)
                
                Spacer()
                
                HStack(spacing: 12) {
                    if timer.status == .paused {
                        Button(action: {}) {
                            Image(systemName: "arrow.clockwise")
                                .font(.footnote)
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.blue.opacity(0.3), lineWidth: 1.5)
                                        .frame(width: 32, height: 32)
                                )
                        }
                    }
                    
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
                
                Text(timer.status == .completed
                     ? "timer-completed"
                     : "오전 10:30 종료 예정")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding()
        .background(
            ZStack {
                AppTheme.contentBackground
                
                if showsGlass {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .transition(.opacity)
                }
            }
        )
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.25), value: showsGlass)
    }
}
