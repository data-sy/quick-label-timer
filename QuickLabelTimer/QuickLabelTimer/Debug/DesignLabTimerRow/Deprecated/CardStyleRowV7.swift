////
////  CardStyleRowV7.swift
////  QuickLabelTimer
////
////  Created by 이소연 on 12/16/25.
////
//
//import SwiftUI
//
//// MARK: - Option C: Capsule Button
//struct CardStyleRowV7: View {
//    let timer: TimerData
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            // [상단] 라벨 + 즐겨찾기
//            HStack(alignment: .top) {
//                Label(timer.label, systemImage: "timer")
//                    .font(.headline)
//                    .foregroundColor(.primary)
//                
//                Spacer()
//                
//                FavoriteToggleButton(endAction: timer.endAction, onToggle: {})
//            }
//            
//            Divider().padding(.vertical, 4)
//            
//            // [중단] 시간 + 버튼
//            HStack(alignment: .center, spacing: 16) {
//                // 시간 표시
//                Text(timer.formattedTime)
//                    .font(.system(size: 48, weight: .bold, design: .rounded))
//                    .foregroundColor(timer.status == .completed ? .red : .primary)
//                    .minimumScaleFactor(0.5)
//                
//                Spacer()
//                
//                // Capsule 버튼 2개
//                HStack(spacing: 8) {
//                    // Stop
//                    Button(action: {}) {
//                        HStack(spacing: 4) {
//                            Image(systemName: "stop.fill")
//                            Text("정지")
//                                .font(.footnote)
//                        }
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 8)
//                        .background(Capsule().fill(Color.red))
//                    }
//                    
//                    // Pause/Resume
//                    Button(action: {}) {
//                        HStack(spacing: 4) {
//                            Image(systemName: timer.status == .running ? "pause.fill" : "play.fill")
//                            Text(timer.status == .running ? "일시정지" : "재개")
//                                .font(.footnote)
//                        }
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 8)
//                        .background(Capsule().fill(Color.blue))
//                    }
//                }
//            }
//            
//            // [하단] 메타 정보
//            HStack {
//                Text(timer.status == .completed ? "타이머 종료" : "오전 10:30 종료 예정")
//                    .font(.footnote)
//                    .foregroundColor(.secondary)
//                Spacer()
//            }
//        }
//        .padding()
//        .background(AppTheme.contentBackground)
//        .cornerRadius(20)
//        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
//    }
//}
