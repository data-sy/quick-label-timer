////
////  TimerRowDesignLabV911.swift
////  QuickLabelTimer
////
////  Created by 이소연 on 12/16/25.
////
//
//import SwiftUI
//
//// MARK: - 🎛️ 디자인 실험실 V9-V11 - 북마크 추가 버전
//struct TimerRowDesignLabV911: View {
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                AppTheme.pageBackground.ignoresSafeArea()
//                
//                ScrollView {
//                    VStack(spacing: 32) {
//                        
//                        // V10: iOS Clock Style with Bookmark
//                        DesignSection(title: "V10: iOS Clock Style + Bookmark", description: "북마크 + 단일 토글 버튼 + 조건부 리셋") {
//                            VStack(spacing: 12) {
//                                CardStyleRowV10(
//                                    timer: makeDummyTimer(
//                                        label: "업무 집중 시간",
//                                        time: "1:25:00",
//                                        state: .running,
//                                        endAction: .preserve,
//                                        isSoundOn: true,
//                                        isVibrationOn: true
//                                    )
//                                )
//                                CardStyleRowV10(
//                                    timer: makeDummyTimer(
//                                        label: "매우 긴 라벨 테스트: 아이들이 깨지 않도록 조용히 설거지하고 정리한 다음 내일 아침 도시락 준비까지 완료하기",
//                                        time: "0:05:30",
//                                        state: .paused,
//                                        endAction: .discard,
//                                        isSoundOn: false,
//                                        isVibrationOn: true
//                                    )
//                                )
//                            }
//                        }
//                        
//                        // V9: Outlined Circle with Bookmark
//                        DesignSection(title: "V9: Outlined Circle + Bookmark", description: "북마크 + 윤곽선 버튼 2개") {
//                            VStack(spacing: 12) {
//                                CardStyleRowV9(
//                                    timer: makeDummyTimer(
//                                        label: "업무 집중 시간",
//                                        time: "1:25:00",
//                                        state: .running,
//                                        endAction: .preserve,
//                                        isSoundOn: true,
//                                        isVibrationOn: true
//                                    )
//                                )
//                                CardStyleRowV9(
//                                    timer: makeDummyTimer(
//                                        label: "매우 긴 라벨 테스트: 아이들이 깨지 않도록 조용히 설거지하고 정리한 다음 내일 아침 도시락 준비까지 완료하기",
//                                        time: "0:00:00",
//                                        state: .completed,
//                                        endAction: .discard,
//                                        isSoundOn: false,
//                                        isVibrationOn: false
//                                    )
//                                )
//                            }
//                        }
//                        // V10: iOS Clock Style with Bookmark
//                        DesignSection(title: "V10: iOS Clock Style + Bookmark", description: "북마크 + 단일 토글 버튼 + 조건부 리셋") {
//                            VStack(spacing: 12) {
//                                CardStyleRowV10(
//                                    timer: makeDummyTimer(
//                                        label: "업무 집중 시간",
//                                        time: "1:25:00",
//                                        state: .running,
//                                        endAction: .preserve,
//                                        isSoundOn: true,
//                                        isVibrationOn: true
//                                    )
//                                )
//                                CardStyleRowV10(
//                                    timer: makeDummyTimer(
//                                        label: "매우 긴 라벨 테스트: 아이들이 깨지 않도록 조용히 설거지하고 정리한 다음 내일 아침 도시락 준비까지 완료하기",
//                                        time: "0:05:30",
//                                        state: .paused,
//                                        endAction: .discard,
//                                        isSoundOn: false,
//                                        isVibrationOn: true
//                                    )
//                                )
//                            }
//                        }
//                    }
//                    .padding()
//                }
//            }
//            .navigationTitle("Design Lab V9-V10")
//            .navigationBarTitleDisplayMode(.inline)
//        }
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
//// MARK: - AlarmMode 하드코딩 Extension
//extension TimerData {
//    var alarmMode: (iconName: String, description: String) {
//        if isSoundOn && isVibrationOn {
//            return ("speaker.wave.2.fill", "소리 + 진동")
//        } else if isVibrationOn {
//            return ("iphone.radiowaves.left.and.right", "진동")
//        } else if isSoundOn {
//            return ("speaker.wave.2.fill", "소리")
//        } else {
//            return ("speaker.slash.fill", "무음")
//        }
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    TimerRowDesignLabV911()
//        .environmentObject(TimerService(
//            timerRepository: TimerRepository(),
//            presetRepository: PresetRepository(),
//            deleteCountdownSeconds: 10
//        ))
//}
