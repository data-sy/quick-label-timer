//
//  TimerRowGlassLabV12.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//

import SwiftUI

// MARK: - 🪟 Glass Material 실험실
struct TimerRowGlassLabV12: View {
    @State private var timers: [TimerData] = []
    
    var body: some View {
        NavigationStack {
            GlassBackgroundContainer {
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // V12: Glass Material 적용
                        DesignSection(
                            title: "V12: Glass Material (iOS 18 Style)",
                            description: "regularMaterial + 그라데이션 배경"
                        ) {
                            VStack(spacing: 12) {
                                ForEach(timers) { timer in
                                    TimerRowGlassV12(
                                        timer: timer,
                                        onLabelChange: { newLabel in
                                            updateTimerLabel(timerId: timer.id, newLabel: newLabel)
                                        }
                                    )
                                }
                            }
                        }
                        
                        // 사용 가이드
                        DesignSection(
                            title: "Glass Material 특징",
                            description: ""
                        ) {
                            VStack(alignment: .leading, spacing: 12) {
                                GuideItem(
                                    icon: "sparkles",
                                    text: "배경 그라데이션이 카드를 통해 은은하게 비침"
                                )
                                GuideItem(
                                    icon: "rectangle.on.rectangle",
                                    text: "스크롤 시 깊이감 있는 레이어 효과"
                                )
                                GuideItem(
                                    icon: "moon.stars",
                                    text: "라이트/다크 모드 자동 대응 (현재는 라이트만 테스트)"
                                )
                                GuideItem(
                                    icon: "hand.tap",
                                    text: "44x44pt 터치 타겟 + 접근성 레이블 적용"
                                )
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.regularMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // 배경 색상 정보
                        DesignSection(
                            title: "배경 그라데이션",
                            description: ""
                        ) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Color(hex: "E8EAF6")
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Start Color")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("#E8EAF6")
                                            .font(.system(.body, design: .monospaced))
                                            .foregroundColor(.primary)
                                        Text("연한 인디고")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                
                                Divider()
                                
                                HStack(spacing: 12) {
                                    Color(hex: "F3E5F5")
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("End Color")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("#F3E5F5")
                                            .font(.system(.body, design: .monospaced))
                                            .foregroundColor(.primary)
                                        Text("연한 보라")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.regularMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Glass Material Lab")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if timers.isEmpty {
                    timers = makeHardcodedTimers()
                }
            }
        }
    }
    
    // MARK: - Timer Update Logic
    private func updateTimerLabel(timerId: UUID, newLabel: String) {
        if let index = timers.firstIndex(where: { $0.id == timerId }) {
            let updatedTimer = timers[index]
            timers[index] = TimerData(
                id: updatedTimer.id,
                label: newLabel,
                hours: updatedTimer.hours,
                minutes: updatedTimer.minutes,
                seconds: updatedTimer.seconds,
                isSoundOn: updatedTimer.isSoundOn,
                isVibrationOn: updatedTimer.isVibrationOn,
                createdAt: updatedTimer.createdAt,
                endDate: updatedTimer.endDate,
                remainingSeconds: updatedTimer.remainingSeconds,
                status: updatedTimer.status,
                presetId: updatedTimer.presetId,
                endAction: updatedTimer.endAction
            )
        }
    }
    
    // MARK: - Hardcoded Data (외부 영향 없음)
    private func makeHardcodedTimers() -> [TimerData] {
        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()
        
        let now = Date()
        
        return [
            TimerData(
                id: id1,
                label: "라면 끓이기",
                hours: 0, minutes: 3, seconds: 0,
                isSoundOn: true,
                isVibrationOn: false,
                createdAt: now,
                endDate: now.addingTimeInterval(180),
                remainingSeconds: 180,
                status: .running,
                presetId: nil,
                endAction: .preserve
            ),
            TimerData(
                id: id2,
                label: "업무 집중 타이머",
                hours: 0, minutes: 25, seconds: 0,
                isSoundOn: false,
                isVibrationOn: true,
                createdAt: now,
                endDate: now.addingTimeInterval(1500),
                remainingSeconds: 1500,
                status: .paused,
                presetId: nil,
                endAction: .discard
            ),
            TimerData(
                id: id3,
                label: "운동",
                hours: 0, minutes: 30, seconds: 0,
                isSoundOn: true,
                isVibrationOn: true,
                createdAt: now,
                endDate: now,
                remainingSeconds: 0,
                status: .completed,
                presetId: nil,
                endAction: .preserve
            )
        ]
    }
}

//// MARK: - Guide Item Component
//struct GuideItem: View {
//    let icon: String
//    let text: String
//    
//    var body: some View {
//        HStack(alignment: .top, spacing: 12) {
//            Image(systemName: icon)
//                .font(.body)
//                .foregroundColor(.blue)
//                .frame(width: 24)
//            
//            Text(text)
//                .font(.body)
//                .foregroundColor(.primary)
//                .fixedSize(horizontal: false, vertical: true)
//            
//            Spacer()
//        }
//    }
//}

// MARK: - Preview
#Preview {
    TimerRowGlassLabV12()
}
