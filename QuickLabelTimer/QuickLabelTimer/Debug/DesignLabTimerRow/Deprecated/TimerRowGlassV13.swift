//
//  TimerRowGlassV13.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//


//
//  TimerRowGlassV13.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//

import SwiftUI

// MARK: - V13: Deep Focus Glass Style (Dark Mode Optimized)
struct TimerRowGlassV13: View {
    let timer: TimerData
    let onLabelChange: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) { // 여유로운 간격
            
            // [상단] 북마크 + 라벨 + 삭제
            HStack(alignment: .top, spacing: 8) {
                FavoriteToggleButton(endAction: timer.endAction, onToggle: {})
                    .frame(width: 44, height: 44) // 터치 영역 확보
                
                EditableTimerLabel(
                    timer: timer,
                    onLabelChange: onLabelChange
                )
                .padding(.top, 10) // 시각적 정렬 보정
                .foregroundColor(.white) // 다크 모드용 명시적 컬러 (필요시)
                
                Spacer()
                
                // 삭제 버튼 (X)
                Button(action: {}) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color.white.opacity(0.3)) // 배경에 녹아드는 컬러
                }
                .frame(width: 44, height: 44, alignment: .topTrailing)
            }
            .padding(.top, -8)
            
            // Divider 제거 (Glass 디자인에서는 면의 질감으로 구분)
            
            // [중단] 시간 + 버튼
            HStack(alignment: .center, spacing: 0) {
                // 시간 표시
                Text(timer.formattedTime)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(timer.status == .completed ? .red : .white) // 기본 텍스트 화이트
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                Spacer()
                
                // 버튼 영역
                HStack(spacing: 16) {
                    // 리셋 버튼
                    if timer.status == .paused {
                        Button(action: {}) {
                            Image(systemName: "arrow.clockwise")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Main Play/Pause 버튼
                    Button(action: {}) {
                        Image(systemName: timer.status == .running ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(Color.blue.gradient) // 깊이감 있는 그라디언트
                            )
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
            }
            
            // [하단] 메타 정보
            HStack(spacing: 6) {
                Image(systemName: timer.alarmMode.iconName)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                
                Text(timer.status == .completed ? "타이머 종료" : "오전 10:30 종료 예정")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
            }
        }
        .padding(20)
        // ✨ Glass Material (Ultra Thin)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        // ✨ Glass Edge (빛 반사 효과)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
        )
        // 그림자는 부드럽게
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}