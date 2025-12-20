////
////  TimerRowRedesign.swift
////  QuickLabelTimer
////
////  Created by 이소연 on 12/16/25.
////
//
//import SwiftUI
//
//// MARK: - Phase 1: Redesign Only (No Inline Edit)
//struct TimerRowRedesign: View {
//    let timer: TimerData
//    let isRunning: Bool
//    let onToggleRunning: () -> Void
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            // [상단] 북마크 + 라벨 (읽기 전용) + 삭제
//            HStack(alignment: .center, spacing: 8) {
//                FavoriteToggleButton(endAction: timer.endAction, onToggle: {})
//                    .frame(width: 44, height: 44)
//                
//                // 읽기 전용 라벨
//                Text(timer.label)
//                    .font(.headline)
//                    .foregroundColor(isRunning ? .white : .primary)
//                    .lineLimit(nil)
//                    .fixedSize(horizontal: false, vertical: true)
//                
//                Spacer()
//                
//                // 삭제 버튼 (X)
//                Button(action: {}) {
//                    Image(systemName: "xmark")
//                        .font(.caption)
//                        .foregroundColor(isRunning ? .white.opacity(0.8) : .secondary)
//                        .frame(width: 44, height: 44)
//                        .contentShape(Rectangle())
//                }
//            }
//            
//            Divider()
//                .background(isRunning ? Color.white : Color.secondary.opacity(0.3))
//                .padding(.vertical, 4)
//            
//            // [중단] 시간 + 버튼
//            HStack(alignment: .center, spacing: 16) {
//                // 시간 표시
//                Text(timer.formattedTime)
//                    .font(.system(size: 48, weight: .bold, design: .rounded))
//                    .foregroundColor(isRunning ? .white : (timer.status == .completed ? .red : .primary))
//                    .minimumScaleFactor(0.5)
//                
//                Spacer()
//                
//                // 버튼 영역
//                HStack(spacing: 16) {
//                    // 리셋 버튼 (일시정지 시에만 표시)
//                    if timer.status == .paused {
//                        Button(action: {}) {
//                            Image(systemName: "arrow.clockwise")
//                                .font(.footnote)
//                                .foregroundColor(isRunning ? .white : .blue)
//                                .frame(width: 44, height: 44)
//                                .background(
//                                    Circle()
//                                        .strokeBorder(isRunning ? Color.white.opacity(0.5) : Color.blue.opacity(0.3), lineWidth: 1.5)
//                                )
//                        }
//                    }
//                    
//                    // Play/Pause 토글 버튼 (메인)
//                    Button(action: onToggleRunning) {
//                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
//                            .font(.title2)
//                            .foregroundColor(isRunning ? .blue : .white)
//                            .frame(width: 56, height: 56)
//                            .background(Circle().fill(isRunning ? Color.white : Color.blue))
//                            .shadow(radius: 4)
//                    }
//                }
//            }
//            
//            // [하단] 알람 모드 + 종료 시간
//            HStack(spacing: 4) {
//                Image(systemName: timer.alarmMode.iconName)
//                    .font(.caption)
//                    .foregroundColor(isRunning ? .white.opacity(0.8) : .secondary)
//                
//                Text(timer.status == .completed ? "timer-completed" : "오전 10:30 종료 예정")
//                    .font(.footnote)
//                    .foregroundColor(isRunning ? .white.opacity(0.8) : .secondary)
//                
//                Spacer()
//            }
//        }
//        .padding()
//        .background(isRunning ? Color.blue : AppTheme.contentBackground)
//        .cornerRadius(20)
//        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
//    }
//}
