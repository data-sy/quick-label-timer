//
//  EditAffordanceLabV18V21.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//

import SwiftUI

// MARK: - 🖊️ 편집 암시 실험실 V18-V21
struct EditAffordanceLabV18V21: View {
    @State private var timers: [TimerData] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.pageBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // V18: Gray Border Only
                        DesignSection(
                            title: "V18: Edit Mode Gray Border",
                            description: "편집 시 회색 테두리만 표시"
                        ) {
                            VStack(spacing: 12) {
                                ForEach(timers) { timer in
                                    TimerRowEditAffordanceV18(
                                        timer: timer,
                                        onLabelChange: { newLabel in
                                            updateTimerLabel(timerId: timer.id, newLabel: newLabel)
                                        }
                                    )
                                }
                            }
                        }
                        
                        // V19: Pencil + Gray Border
                        DesignSection(
                            title: "V19: Pencil Icon + Gray Border",
                            description: "연필 아이콘 + 편집 시 회색 테두리"
                        ) {
                            VStack(spacing: 12) {
                                ForEach(timers) { timer in
                                    TimerRowEditAffordanceV19(
                                        timer: timer,
                                        onLabelChange: { newLabel in
                                            updateTimerLabel(timerId: timer.id, newLabel: newLabel)
                                        }
                                    )
                                }
                            }
                        }
                        
                        // V20: Pencil + Cursor Only
                        DesignSection(
                            title: "V20: Pencil Icon + Cursor Only",
                            description: "연필 아이콘 + 편집 시 커서만 표시"
                        ) {
                            VStack(spacing: 12) {
                                ForEach(timers) { timer in
                                    TimerRowEditAffordanceV20(
                                        timer: timer,
                                        onLabelChange: { newLabel in
                                            updateTimerLabel(timerId: timer.id, newLabel: newLabel)
                                        }
                                    )
                                }
                            }
                        }
                        
                        // V21: No Hint
                        DesignSection(
                            title: "V21: No Hint, Cursor Only",
                            description: "힌트 없음 - 탭하면 커서만 표시"
                        ) {
                            VStack(spacing: 12) {
                                ForEach(timers) { timer in
                                    TimerRowEditAffordanceV21(
                                        timer: timer,
                                        onLabelChange: { newLabel in
                                            updateTimerLabel(timerId: timer.id, newLabel: newLabel)
                                        }
                                    )
                                }
                            }
                        }
                        
                        // 비교 가이드
                        DesignSection(
                            title: "편집 암시 (Affordance) 비교",
                            description: ""
                        ) {
                            VStack(alignment: .leading, spacing: 12) {
                                GuideItem(
                                    icon: "rectangle.dashed",
                                    text: "V18: 편집 모드 진입 시 회색 테두리"
                                )
                                GuideItem(
                                    icon: "pencil",
                                    text: "V19: 연필 아이콘 + 편집 시 회색 테두리"
                                )
                                GuideItem(
                                    icon: "pencil.line",
                                    text: "V20: 연필 아이콘 + 편집 시 커서만"
                                )
                                GuideItem(
                                    icon: "hand.tap",
                                    text: "V21: 힌트 없음 - 탭하면 커서만"
                                )
                            }
                            .padding()
                            .background(AppTheme.contentBackground)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Affordance V18-V21")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if timers.isEmpty {
                    timers = makeDummyTimers()
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
    
    // MARK: - Dummy Data
    private func makeDummyTimers() -> [TimerData] {
        return [
            makeDummyTimer(
                label: "라면 끓이기",
                time: "0:03:00",
                state: .running,
                endAction: .preserve,
                isSoundOn: true,
                isVibrationOn: false
            ),
            makeDummyTimer(
                label: "업무 집중 타이머",
                time: "0:25:00",
                state: .paused,
                endAction: .discard,
                isSoundOn: false,
                isVibrationOn: true
            )
        ]
    }
    
    // 🛠 더미 데이터 생성 헬퍼
    func makeDummyTimer(
        label: String,
        time: String,
        state: TimerStatus,
        endAction: TimerEndAction,
        isSoundOn: Bool,
        isVibrationOn: Bool
    ) -> TimerData {
        let parts = time.split(separator: ":").map { Int($0) ?? 0 }
        let totalSeconds: Int
        
        if parts.count == 3 {
            totalSeconds = parts[0] * 3600 + parts[1] * 60 + parts[2]
        } else if parts.count == 2 {
            totalSeconds = parts[0] * 60 + parts[1]
        } else {
            totalSeconds = 0
        }
        
        let hours = parts.count == 3 ? parts[0] : 0
        let minutes = parts.count == 3 ? parts[1] : (parts.count == 2 ? parts[0] : 0)
        let seconds = parts.last ?? 0
        
        return TimerData(
            id: UUID(),
            label: label,
            hours: hours, minutes: minutes, seconds: seconds,
            isSoundOn: isSoundOn,
            isVibrationOn: isVibrationOn,
            createdAt: Date(),
            endDate: Date().addingTimeInterval(TimeInterval(totalSeconds)),
            remainingSeconds: totalSeconds,
            status: state,
            presetId: nil,
            endAction: endAction
        )
    }
}

// MARK: - Preview
#Preview {
    EditAffordanceLabV18V21()
}
