////
////  TimerRowRunningLabV22V24.swift
////  QuickLabelTimer
////
////  Created by 이소연 on 12/16/25.
////
//
//import SwiftUI
//
//// MARK: - 🏃 타이머 재생 중 스타일 실험실 V22-V24
//struct TimerRowRunningLabV22V24: View {
//    @State private var timers: [TimerData] = []
//    @State private var runningStates: [UUID: Bool] = [:]
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                AppTheme.pageBackground.ignoresSafeArea()
//                
//                ScrollView {
//                    VStack(spacing: 32) {
//                        
//                        // V22: Strong Background Inversion
//                        DesignSection(
//                            title: "V22: Strong Background Inversion",
//                            description: "재생 중 파란 배경 + 흰색 텍스트 (강한 강조)"
//                        ) {
//                            VStack(spacing: 12) {
//                                ForEach(timers) { timer in
//                                    TimerRowRunningV22(
//                                        timer: timer,
//                                        onLabelChange: { newLabel in
//                                            updateTimerLabel(timerId: timer.id, newLabel: newLabel)
//                                        },
//                                        isRunning: runningStates[timer.id] ?? false,
//                                        onToggleRunning: {
//                                            runningStates[timer.id]?.toggle()
//                                        }
//                                    )
//                                }
//                            }
//                        }
//                        
//                        // V23: Border Emphasis
//                        DesignSection(
//                            title: "V23: Border Emphasis",
//                            description: "재생 중 파란 테두리 (중간 강조)"
//                        ) {
//                            VStack(spacing: 12) {
//                                ForEach(timers) { timer in
//                                    TimerRowRunningV23(
//                                        timer: timer,
//                                        onLabelChange: { newLabel in
//                                            updateTimerLabel(timerId: timer.id, newLabel: newLabel)
//                                        },
//                                        isRunning: runningStates[timer.id] ?? false,
//                                        onToggleRunning: {
//                                            runningStates[timer.id]?.toggle()
//                                        }
//                                    )
//                                }
//                            }
//                        }
//                        
//                        // V24: Subtle Background + Border
//                        DesignSection(
//                            title: "V24: Subtle Background + Border",
//                            description: "재생 중 연한 배경 + 테두리 (약한 강조)"
//                        ) {
//                            VStack(spacing: 12) {
//                                ForEach(timers) { timer in
//                                    TimerRowRunningV24(
//                                        timer: timer,
//                                        onLabelChange: { newLabel in
//                                            updateTimerLabel(timerId: timer.id, newLabel: newLabel)
//                                        },
//                                        isRunning: runningStates[timer.id] ?? false,
//                                        onToggleRunning: {
//                                            runningStates[timer.id]?.toggle()
//                                        }
//                                    )
//                                }
//                            }
//                        }
//                        
//                        // 비교 가이드
//                        DesignSection(
//                            title: "재생 중 스타일 비교",
//                            description: ""
//                        ) {
//                            VStack(alignment: .leading, spacing: 12) {
//                                GuideItem(
//                                    icon: "paintbrush.fill",
//                                    text: "V22: 파란 배경 + 흰색 텍스트 (가장 강한 시각적 피드백)"
//                                )
//                                GuideItem(
//                                    icon: "rectangle.portrait.on.rectangle.portrait",
//                                    text: "V23: 파란 테두리만 (깔끔하고 전문적)"
//                                )
//                                GuideItem(
//                                    icon: "circle.dotted",
//                                    text: "V24: 연한 배경 + 테두리 (미묘하고 세련됨)"
//                                )
//                                
//                                Divider().padding(.vertical, 4)
//                                
//                                Text("💡 Tip: Play 버튼을 눌러 각 스타일의 재생 모드를 확인하세요")
//                                    .font(.caption)
//                                    .foregroundColor(.secondary)
//                            }
//                            .padding()
//                            .background(AppTheme.contentBackground)
//                            .cornerRadius(12)
//                        }
//                    }
//                    .padding()
//                }
//            }
//            .navigationTitle("Running Style V22-V24")
//            .navigationBarTitleDisplayMode(.inline)
//            .onAppear {
//                if timers.isEmpty {
//                    timers = makeDummyTimers()
//                    // Initialize running states
//                    for timer in timers {
//                        runningStates[timer.id] = false
//                    }
//                }
//            }
//        }
//    }
//    
//    // MARK: - Timer Update Logic
//    private func updateTimerLabel(timerId: UUID, newLabel: String) {
//        if let index = timers.firstIndex(where: { $0.id == timerId }) {
//            let updatedTimer = timers[index]
//            timers[index] = TimerData(
//                id: updatedTimer.id,
//                label: newLabel,
//                hours: updatedTimer.hours,
//                minutes: updatedTimer.minutes,
//                seconds: updatedTimer.seconds,
//                isSoundOn: updatedTimer.isSoundOn,
//                isVibrationOn: updatedTimer.isVibrationOn,
//                createdAt: updatedTimer.createdAt,
//                endDate: updatedTimer.endDate,
//                remainingSeconds: updatedTimer.remainingSeconds,
//                status: updatedTimer.status,
//                presetId: updatedTimer.presetId,
//                endAction: updatedTimer.endAction
//            )
//        }
//    }
//    
//    // MARK: - Dummy Data
//    private func makeDummyTimers() -> [TimerData] {
//        return [
//            makeDummyTimer(
//                label: "라면 끓이기",
//                time: "0:03:00",
//                state: .running,
//                endAction: .preserve,
//                isSoundOn: true,
//                isVibrationOn: false
//            ),
//            makeDummyTimer(
//                label: "업무 집중 타이머",
//                time: "0:25:00",
//                state: .paused,
//                endAction: .discard,
//                isSoundOn: false,
//                isVibrationOn: true
//            )
//        ]
//    }
//    
//    // 🛠 더미 데이터 생성 헬퍼
//    func makeDummyTimer(
//        label: String,
//        time: String,
//        state: TimerStatus,
//        endAction: TimerEndAction,
//        isSoundOn: Bool,
//        isVibrationOn: Bool
//    ) -> TimerData {
//        let parts = time.split(separator: ":").map { Int($0) ?? 0 }
//        let totalSeconds: Int
//        
//        if parts.count == 3 {
//            totalSeconds = parts[0] * 3600 + parts[1] * 60 + parts[2]
//        } else if parts.count == 2 {
//            totalSeconds = parts[0] * 60 + parts[1]
//        } else {
//            totalSeconds = 0
//        }
//        
//        let hours = parts.count == 3 ? parts[0] : 0
//        let minutes = parts.count == 3 ? parts[1] : (parts.count == 2 ? parts[0] : 0)
//        let seconds = parts.last ?? 0
//        
//        return TimerData(
//            id: UUID(),
//            label: label,
//            hours: hours, minutes: minutes, seconds: seconds,
//            isSoundOn: isSoundOn,
//            isVibrationOn: isVibrationOn,
//            createdAt: Date(),
//            endDate: Date().addingTimeInterval(TimeInterval(totalSeconds)),
//            remainingSeconds: totalSeconds,
//            status: state,
//            presetId: nil,
//            endAction: endAction
//        )
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    TimerRowRunningLabV22V24()
//}
