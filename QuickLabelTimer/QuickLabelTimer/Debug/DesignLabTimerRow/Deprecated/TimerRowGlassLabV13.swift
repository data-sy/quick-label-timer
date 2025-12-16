//
//  TimerRowGlassLabV13.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//


//
//  TimerRowGlassLabV13.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//

import SwiftUI

// MARK: - 🌑 Glass Material V13 실험실 (Deep Focus)
struct TimerRowGlassLabV13: View {
    @State private var timers: [TimerData] = []
    
    var body: some View {
        NavigationStack {
            // V13 전용 Dark Background Container 사용
            GlassBackgroundContainerV13 {
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // V13: Deep Focus Style
                        DesignSection(
                            title: "V13: Deep Focus Glass",
                            description: "ultraThinMaterial + Dark Gradient"
                        ) {
                            VStack(spacing: 12) {
                                ForEach(timers) { timer in
                                    TimerRowGlassV13(
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
                            title: "V13 디자인 특징",
                            description: "어두운 환경에서의 몰입감 강조"
                        ) {
                            VStack(alignment: .leading, spacing: 12) {
                                GuideItem(
                                    icon: "sparkles",
                                    text: "0.5pt 화이트 스트로크로 유리 엣지 표현"
                                )
                                GuideItem(
                                    icon: "drop.fill",
                                    text: "UltraThinMaterial로 배경색 투과율 높임"
                                )
                                GuideItem(
                                    icon: "circle.lefthalf.filled",
                                    text: "화이트 텍스트 + 불투명도 조절로 계층 구분"
                                )
                                GuideItem(
                                    icon: "hand.tap",
                                    text: "버튼 터치 영역 44pt 확장 적용 완료"
                                )
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        // 배경 색상 정보 (Dark Theme)
                        DesignSection(
                            title: "Deep Sea Gradient",
                            description: "심해/우주 느낌의 그라데이션"
                        ) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Color(hex: "0F2027")
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.2)))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Start Color").font(.caption).foregroundColor(.white.opacity(0.7))
                                        Text("#0F2027").font(.system(.body, design: .monospaced)).foregroundColor(.white)
                                        Text("Deep Blue Black").font(.caption).foregroundColor(.white.opacity(0.5))
                                    }
                                    Spacer()
                                }
                                
                                Divider().background(.white.opacity(0.2))
                                
                                HStack(spacing: 12) {
                                    Color(hex: "2C5364")
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.2)))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("End Color").font(.caption).foregroundColor(.white.opacity(0.7))
                                        Text("#2C5364").font(.system(.body, design: .monospaced)).foregroundColor(.white)
                                        Text("Slate Blue").font(.caption).foregroundColor(.white.opacity(0.5))
                                    }
                                    Spacer()
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Glass Lab V13")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if timers.isEmpty {
                    timers = makeHardcodedTimers()
                }
            }
        }
        // 네비게이션 바 등 전체적인 테마를 다크로 강제
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Helper Logic (기존과 동일)
    private func updateTimerLabel(timerId: UUID, newLabel: String) {
        if let index = timers.firstIndex(where: { $0.id == timerId }) {
            var updatedTimer = timers[index]
            // Struct가 immutable이면 새로 생성해야 함 (TimerData 구조에 따라 다름)
            // 여기서는 간단히 로직만 표현
             updatedTimer = TimerData(
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
            timers[index] = updatedTimer
        }
    }
    
    private func makeHardcodedTimers() -> [TimerData] {
        let now = Date()
        return [
            TimerData(id: UUID(), label: "야간 집중 모드", hours: 0, minutes: 45, seconds: 0, isSoundOn: true, isVibrationOn: false, createdAt: now, endDate: now.addingTimeInterval(2700), remainingSeconds: 2700, status: .running, presetId: nil, endAction: .preserve),
            TimerData(id: UUID(), label: "명상", hours: 0, minutes: 15, seconds: 0, isSoundOn: false, isVibrationOn: true, createdAt: now, endDate: now.addingTimeInterval(900), remainingSeconds: 900, status: .paused, presetId: nil, endAction: .discard),
            TimerData(id: UUID(), label: "스트레칭", hours: 0, minutes: 5, seconds: 0, isSoundOn: true, isVibrationOn: true, createdAt: now, endDate: now, remainingSeconds: 0, status: .completed, presetId: nil, endAction: .preserve)
        ]
    }
}

// MARK: - V13 전용 Background Container (Dark Theme)
struct GlassBackgroundContainerV13<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Deep Focus Gradient
            LinearGradient(
                colors: [
                    Color(hex: "0F2027"), // Deep Black Blue
                    Color(hex: "203A43"), // Dark Slate
                    Color(hex: "2C5364")  // Blue Grey
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            content
        }
    }
}

// MARK: - Preview
#Preview {
    TimerRowGlassLabV13()
}
