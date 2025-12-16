//
//  TimerRowGlassLabV14.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//

import SwiftUI

// MARK: - 🪟 Glass Material Lab (V14)
struct TimerRowGlassLabV14: View {
    @State private var timers: [TimerData] = []
    
    var body: some View {
        NavigationStack {
            GlassBackgroundContainer {
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // V14 Section
                        DesignSection(
                            title: "V14: State-based Glass",
                            description: "Running / Paused 상태에서만 Glass Overlay 적용"
                        ) {
                            VStack(spacing: 12) {
                                ForEach(timers) { timer in
                                    TimerRowGlassV14(
                                        timer: timer,
                                        onLabelChange: { newLabel in
                                            updateTimerLabel(
                                                timerId: timer.id,
                                                newLabel: newLabel
                                            )
                                        }
                                    )
                                }
                            }
                        }
                        
                        // 가이드
                        DesignSection(
                            title: "V14 실험 포인트",
                            description: ""
                        ) {
                            VStack(alignment: .leading, spacing: 12) {
                                GuideItem(
                                    icon: "sparkles",
                                    text: "기본 상태는 Solid, 상태 전환 시에만 Glass 노출"
                                )
                                GuideItem(
                                    icon: "playpause",
                                    text: "Running / Paused 상태 인지 강화"
                                )
                                GuideItem(
                                    icon: "eye",
                                    text: "리스트 가독성 유지 여부 관찰"
                                )
                                GuideItem(
                                    icon: "moon.stars",
                                    text: "다크모드 대비 및 피로도 확인 필요"
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
                    }
                    .padding()
                }
            }
            .navigationTitle("Glass Lab V14")
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
            let t = timers[index]
            timers[index] = TimerData(
                id: t.id,
                label: newLabel,
                hours: t.hours,
                minutes: t.minutes,
                seconds: t.seconds,
                isSoundOn: t.isSoundOn,
                isVibrationOn: t.isVibrationOn,
                createdAt: t.createdAt,
                endDate: t.endDate,
                remainingSeconds: t.remainingSeconds,
                status: t.status,
                presetId: t.presetId,
                endAction: t.endAction
            )
        }
    }
    
    // MARK: - Hardcoded Data
    private func makeHardcodedTimers() -> [TimerData] {
        let now = Date()
        return [
            TimerData(
                id: UUID(),
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
                id: UUID(),
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
                id: UUID(),
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

// MARK: - Preview
#Preview {
    TimerRowGlassLabV14()
}
