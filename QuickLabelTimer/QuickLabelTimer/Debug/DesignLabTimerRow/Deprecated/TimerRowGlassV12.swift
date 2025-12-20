////
////  TimerRowGlassV12.swift
////  QuickLabelTimer
////
////  Created by 이소연 on 12/16/25.
////
//
//import SwiftUI
//
//// MARK: - V12: Glass Material Style
//struct TimerRowGlassV12: View {
//    let timer: TimerData
//    let onLabelChange: (String) -> Void
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            // [상단] 북마크 + 라벨 + 삭제
//            HStack(alignment: .center, spacing: 8) {
//                FavoriteToggleButton(endAction: timer.endAction, onToggle: {})
//                
////                EditableTimerLabel(
////                    timer: timer,
////                    onLabelChange: onLabelChange
////                )
//                
//                Spacer()
//                
//                // 삭제 버튼 (X)
//                Button(action: {}) {
//                    Image(systemName: "xmark")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                        .frame(width: 24, height: 24)
//                }
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
//                // 버튼 영역
//                HStack(spacing: 12) {
//                    // 리셋 버튼 (일시정지 시에만 표시)
//                    if timer.status == .paused {
//                        Button(action: {}) {
//                            Image(systemName: "arrow.clockwise")
//                                .font(.footnote)
//                                .foregroundColor(.blue)
//                                .frame(width: 32, height: 32)
//                                .background(
//                                    Circle()
//                                        .strokeBorder(Color.blue.opacity(0.3), lineWidth: 1.5)
//                                )
//                        }
//                    }
//                    
//                    // Play/Pause 토글 버튼 (메인)
//                    Button(action: {}) {
//                        Image(systemName: timer.status == .running ? "pause.fill" : "play.fill")
//                            .font(.title2)
//                            .foregroundColor(.white)
//                            .frame(width: 56, height: 56)
//                            .background(Circle().fill(Color.blue))
//                            .shadow(radius: 4)
//                    }
//                }
//            }
//            
//            // [하단] 알람 모드 + 종료 시간
//            HStack(spacing: 4) {
//                Image(systemName: timer.alarmMode.iconName)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                
//                Text(timer.status == .completed ? "timer-completed" : "오전 10:30 종료 예정")
//                    .font(.footnote)
//                    .foregroundColor(.secondary)
//                
//                Spacer()
//            }
//        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(.regularMaterial)
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 20)
//                .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
//        )
//        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
//    }
//}
//
//// MARK: - Glass Background Container
//// 이 뷰로 ScrollView를 감싸서 사용하세요
//struct GlassBackgroundContainer<Content: View>: View {
//    let content: Content
//    
//    init(@ViewBuilder content: () -> Content) {
//        self.content = content()
//    }
//    
//    var body: some View {
//        ZStack {
//            // 배경 그라데이션
//            LinearGradient(
//                colors: [
//                    Color(hex: "E8EAF6"), // 연한 인디고
//                    Color(hex: "F3E5F5")  // 연한 보라
//                ],
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
//            
//            content
//        }
//    }
//}
//
//// MARK: - Color Extension for Hex
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (1, 1, 1, 0)
//        }
//        
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue:  Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    GlassBackgroundContainer {
//        ScrollView {
//            VStack(spacing: 16) {
//                TimerRowGlassV12(
//                    timer: TimerData(
//                        id: UUID(),
//                        label: "라면 끓이기",
//                        hours: 0, minutes: 3, seconds: 0,
//                        isSoundOn: true,
//                        isVibrationOn: false,
//                        createdAt: Date(),
//                        endDate: Date().addingTimeInterval(180),
//                        remainingSeconds: 180,
//                        status: .running,
//                        presetId: nil,
//                        endAction: .preserve
//                    ),
//                    onLabelChange: { _ in }
//                )
//                
//                TimerRowGlassV12(
//                    timer: TimerData(
//                        id: UUID(),
//                        label: "업무 집중 타이머",
//                        hours: 0, minutes: 25, seconds: 0,
//                        isSoundOn: false,
//                        isVibrationOn: true,
//                        createdAt: Date(),
//                        endDate: Date().addingTimeInterval(1500),
//                        remainingSeconds: 1500,
//                        status: .paused,
//                        presetId: nil,
//                        endAction: .discard
//                    ),
//                    onLabelChange: { _ in }
//                )
//            }
//            .padding()
//        }
//    }
//}
