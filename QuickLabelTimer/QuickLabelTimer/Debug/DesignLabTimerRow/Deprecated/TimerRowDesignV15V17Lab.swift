////
////  TimerRowDesignV15V17Lab.swift
////  QuickLabelTimer
////
////  Created by 이소연 on 12/16/25.
////
//
//import SwiftUI
//
//// MARK: - 🎨 디자인 개선 실험실 V15-V17
//struct TimerRowDesignV15V17Lab: View {
//    @State private var timers: [TimerData] = []
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                AppTheme.pageBackground.ignoresSafeArea()
//                
//                ScrollView {
//                    VStack(spacing: 32) {
//                        
//                        // V15: Enhanced Touch Targets (Base)
//                        DesignSection(
//                            title: "V15: Enhanced Touch Targets",
//                            description: "터치 타겟 44x44 + 버튼 간격 16pt"
//                        ) {
//                            VStack(spacing: 12) {
//                                ForEach(timers) { timer in
//                                    TimerRowV15(
//                                        timer: timer,
//                                        onLabelChange: { newLabel in
//                                            updateTimerLabel(timerId: timer.id, newLabel: newLabel)
//                                        }
//                                    )
//                                }
//                            }
//                        }
//                        
////                        // V16: No Divider
////                        DesignSection(
////                            title: "V16: No Divider (Spacing Only)",
////                            description: "디바이더 제거 - 여백만으로 섹션 분리"
////                        ) {
////                            VStack(spacing: 12) {
////                                ForEach(timers) { timer in
////                                    TimerRowV16(
////                                        timer: timer,
////                                        onLabelChange: { newLabel in
////                                            updateTimerLabel(timerId: timer.id, newLabel: newLabel)
////                                        }
////                                    )
////                                }
////                            }
////                        }
//                        
//                        // V17: Enhanced Shadow
//                        DesignSection(
//                            title: "V17: Enhanced Shadow (Deeper Lift)",
//                            description: "그림자 강화 - opacity 0.1, radius 8"
//                        ) {
//                            VStack(spacing: 12) {
//                                ForEach(timers) { timer in
//                                    TimerRowV17(
//                                        timer: timer,
//                                        onLabelChange: { newLabel in
//                                            updateTimerLabel(timerId: timer.id, newLabel: newLabel)
//                                        }
//                                    )
//                                }
//                            }
//                        }
//                        
//                        // 비교 가이드
//                        DesignSection(
//                            title: "주요 개선사항",
//                            description: ""
//                        ) {
//                            VStack(alignment: .leading, spacing: 12) {
//                                GuideItem(
//                                    icon: "hand.tap.fill",
//                                    text: "V15: 모든 터치 타겟 44x44pt로 확대"
//                                )
//                                GuideItem(
//                                    icon: "arrow.left.and.right",
//                                    text: "V15: 리셋-재생 버튼 간격 16pt로 증가"
//                                )
//                                GuideItem(
//                                    icon: "minus.circle",
//                                    text: "V16: 디바이더 제거로 시각적 흐름 개선"
//                                )
//                                GuideItem(
//                                    icon: "light.max",
//                                    text: "V17: 그림자 강화로 카드의 떠있는 느낌 향상"
//                                )
//                            }
//                            .padding()
//                            .background(AppTheme.contentBackground)
//                            .cornerRadius(12)
//                        }
//                    }
//                    .padding()
//                }
//            }
//            .navigationTitle("Design V15-V17 Lab")
//            .navigationBarTitleDisplayMode(.inline)
//            .onAppear {
//                if timers.isEmpty {
//                    timers = makeDummyTimers()
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
//    TimerRowDesignV15V17Lab()
//}
