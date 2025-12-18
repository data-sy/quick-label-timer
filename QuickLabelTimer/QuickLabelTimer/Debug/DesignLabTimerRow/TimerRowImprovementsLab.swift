////
////  TimerRowImprovementsLab.swift
////  QuickLabelTimer
////
////  Created by 이소연 on 12/16/25.
////
//
//import SwiftUI
//
//// MARK: - 🎯 타이머 행 단계적 개선 실험실
//struct TimerRowImprovementsLab: View {
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
//                        // Phase 1: Redesign Only
//                        DesignSection(
//                            title: "Phase 1: Redesign Only",
//                            description: "실행 상태 반전 디자인만 적용 (인라인 편집 없음)"
//                        ) {
//                            VStack(spacing: 12) {
//                                ForEach(timers) { timer in
//                                    TimerRowRedesign(
//                                        timer: timer,
//                                        isRunning: runningStates[timer.id] ?? false,
//                                        onToggleRunning: {
//                                            runningStates[timer.id]?.toggle()
//                                        }
//                                    )
//                                }
//                            }
//                        }
//                        
//                        // Phase 2: Redesign + Inline Edit
//                        DesignSection(
//                            title: "Phase 2: Redesign + Inline Edit",
//                            description: "디자인 + 인라인 편집 기능 추가 (최종)"
//                        ) {
//                            VStack(spacing: 12) {
//                                ForEach(timers) { timer in
//                                    TimerRowInlineEdit(
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
//                        // 개선 단계 가이드
//                        DesignSection(
//                            title: "단계적 개선 전략",
//                            description: ""
//                        ) {
//                            VStack(alignment: .leading, spacing: 12) {
//                                GuideItem(
//                                    icon: "1.circle.fill",
//                                    text: "Phase 1 (Redesign): 실행 상태 시각적 피드백 - 파란 배경 반전, 흰색 텍스트"
//                                )
//                                GuideItem(
//                                    icon: "2.circle.fill",
//                                    text: "Phase 2 (Inline Edit): 인라인 라벨 편집 - 연필 아이콘, 탭하여 즉시 수정"
//                                )
//                                
//                                Divider().padding(.vertical, 4)
//                                
//                                VStack(alignment: .leading, spacing: 6) {
//                                    Text("🎯 브랜치 전략")
//                                        .font(.caption)
//                                        .fontWeight(.semibold)
//                                    
//                                    Text("1. feature/timer-row-redesign")
//                                        .font(.caption)
//                                        .foregroundColor(.secondary)
//                                    
//                                    Text("2. feature/timer-row-inline-edit")
//                                        .font(.caption)
//                                        .foregroundColor(.secondary)
//                                }
//                            }
//                            .padding()
//                            .background(AppTheme.contentBackground)
//                            .cornerRadius(12)
//                        }
//                    }
//                    .padding()
//                }
//            }
//            .navigationTitle("Timer Row Improvements")
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
//    TimerRowImprovementsLab()
//}
