////
////  TimerRowDesignLabV14.swift
////  QuickLabelTimer
////
////  Created by 이소연 on 12/16/25.
////
//
//import SwiftUI
//
//// MARK: - 🎛️ 디자인 실험실 V1~V4 비교
//struct TimerRowDesignLabV14: View {
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                AppTheme.pageBackground.ignoresSafeArea()
//                
//                ScrollView {
//                    VStack(spacing: 32) {
////                        
////                        // 4. Modern Card (2-Button) - LATEST
////                        DesignSection(title: "4. Modern Card (2-Button)", description: "3번 디자인에 stop/pause 두 버튼을 추가했습니다.") {
////                            VStack(spacing: 12) {
////                                CardStyleRowTwoButton(
////                                    timer: makeDummyTimer(label: "업무 집중 시간", time: "1:25:00", state: .running)
////                                )
////                                CardStyleRowTwoButton(
////                                    timer: makeDummyTimer(label: "매우 긴 라벨 테스트: 라벨이 길어져도 버튼이나 시간을 밀어내지 않고 자연스럽게 줄바꿈됩니다.", time: "0:00:00", state: .completed)
////                                )
////                            }
////                        }
//                        
//                        // 3. Modern Card Style
//                        DesignSection(title: "3. Modern Card Style", description: "각 타이머를 독립된 카드로 분리하여 강조합니다.") {
//                            VStack(spacing: 12) {
//                                CardStyleRow(
//                                    timer: makeDummyTimer(label: "매우 긴 라벨 테스트: 라벨이 길어져도 버튼이나 시간을 밀어내지 않고 자연스럽게 줄바꿈됩니다.", time: "40:00", state: .running)
//                                )
//                                CardStyleRow(
//                                    timer: makeDummyTimer(label: "긴 라벨 테스트: 아이들이 깨지 않도록 조용히 설거지하고 정리하기", time: "00:00", state: .completed)
//                                )
//                            }
//                        }
////                        
////                        // 2. Header & Body Style
////                        DesignSection(title: "2. Header & Body Style", description: "라벨을 상단에 단독 배치하여 가독성을 높였습니다.") {
////                            VStack(spacing: 0) {
////                                HeaderBodyRow(
////                                    timer: makeDummyTimer(label: "업무 집중 시간", time: "25:00", state: .running)
////                                )
////                                Divider().padding(.leading)
////                                HeaderBodyRow(
////                                    timer: makeDummyTimer(label: "매우 긴 라벨 테스트: 라벨이 길어져도 버튼이나 시간을 밀어내지 않고 자연스럽게 줄바꿈됩니다.", time: "12:00", state: .stopped)
////                                )
////                            }
////                            .background(AppTheme.contentBackground)
////                            .cornerRadius(12)
////                        }
////                        
////                        // 1. Current Design
////                        DesignSection(title: "1. Current Design", description: "현재 적용된 TimerRowView입니다.") {
////                            VStack(spacing: 0) {
////                                CurrentDesignRow(
////                                    timer: makeDummyTimer(label: "파스타 삶기", time: "10:00", state: .running)
////                                )
////                                Divider().padding(.leading)
////                                CurrentDesignRow(
////                                    timer: makeDummyTimer(label: "긴 라벨 테스트: 아이들이 깨지 않도록 조용히 설거지하고 정리하기", time: "05:30", state: .paused)
////                                )
////                            }
////                        }
//                    }
//                    .padding()
//                }
//            }
//            .navigationTitle("Design Lab")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//    
//    // 🛠 더미 데이터 생성 헬퍼
//    func makeDummyTimer(label: String, time: String, state: TimerStatus) -> TimerData {
//        // "1:25:00" 또는 "10:00" -> seconds 변환 로직
//        let parts = time.split(separator: ":").map { Int($0) ?? 0 }
//        let totalSeconds: Int
//        
//        if parts.count == 3 {
//            // 시:분:초
//            totalSeconds = parts[0] * 3600 + parts[1] * 60 + parts[2]
//        } else if parts.count == 2 {
//            // 분:초
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
//            isSoundOn: true, isVibrationOn: true,
//            createdAt: Date(),
//            endDate: Date().addingTimeInterval(TimeInterval(totalSeconds)),
//            remainingSeconds: totalSeconds,
//            status: state,
//            presetId: nil,
//            endAction: .discard
//        )
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    TimerRowDesignLabV14()
//        .environmentObject(TimerService(
//            timerRepository: TimerRepository(),
//            presetRepository: PresetRepository(),
//            deleteCountdownSeconds: 10
//        ))
//}
