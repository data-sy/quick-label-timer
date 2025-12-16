//
//  TimerRowDesignLabV58.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//


//
//  TimerRowDesignLabV58.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//

import SwiftUI

// MARK: - 🎛️ 디자인 실험실 V5~V8 - 버튼 스타일 비교
struct TimerRowDesignLabV58: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.pageBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // Option D: iOS Clock Style
                        DesignSection(title: "Option D: iOS Clock Style", description: "시계 앱처럼 메인 버튼 1개 + 일시정지 시 리셋 버튼") {
                            VStack(spacing: 12) {
                                CardStyleRowV8(
                                    timer: makeDummyTimer(label: "업무 집중 시간", time: "1:25:00", state: .running)
                                )
                                CardStyleRowV8(
                                    timer: makeDummyTimer(label: "긴 라벨 테스트", time: "0:05:30", state: .paused)
                                )
                            }
                        }
//                        
//                        // Option C: Capsule Button
//                        DesignSection(title: "Option C: Capsule Button", description: "캡슐형 버튼에 텍스트로 명확한 액션 표시") {
//                            VStack(spacing: 12) {
//                                CardStyleRowV7(
//                                    timer: makeDummyTimer(label: "업무 집중 시간", time: "1:25:00", state: .running)
//                                )
//                                CardStyleRowV7(
//                                    timer: makeDummyTimer(label: "매우 긴 라벨 테스트: 라벨이 길어져도 자연스럽게 줄바꿈됩니다.", time: "0:00:00", state: .completed)
//                                )
//                            }
//                        }
                        
                        // Option B: Outlined Circle
                        DesignSection(title: "Option B: Outlined Circle", description: "윤곽선 원형 버튼으로 시각적 무게 감소") {
                            VStack(spacing: 12) {
                                CardStyleRowV6(
                                    timer: makeDummyTimer(label: "업무 집중 시간", time: "1:25:00", state: .running)
                                )
                                CardStyleRowV6(
                                    timer: makeDummyTimer(label: "긴 라벨 테스트", time: "0:00:00", state: .completed)
                                )
                            }
                        }
//                        
//                        // Option A: iOS Native
//                        DesignSection(title: "Option A: iOS Native", description: "Apple 표준 텍스트 버튼 스타일") {
//                            VStack(spacing: 12) {
//                                CardStyleRowV5(
//                                    timer: makeDummyTimer(label: "업무 집중 시간", time: "1:25:00", state: .running)
//                                )
//                                CardStyleRowV5(
//                                    timer: makeDummyTimer(label: "매우 긴 라벨 테스트", time: "0:00:00", state: .completed)
//                                )
//                            }
//                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Design Lab V2")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // 🛠 더미 데이터 생성 헬퍼
    func makeDummyTimer(label: String, time: String, state: TimerStatus) -> TimerData {
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
            isSoundOn: true, isVibrationOn: true,
            createdAt: Date(),
            endDate: Date().addingTimeInterval(TimeInterval(totalSeconds)),
            remainingSeconds: totalSeconds,
            status: state,
            presetId: nil,
            endAction: .discard
        )
    }
}

// MARK: - Preview
#Preview {
    TimerRowDesignLabV58()
        .environmentObject(TimerService(
            timerRepository: TimerRepository(),
            presetRepository: PresetRepository(),
            deleteCountdownSeconds: 10
        ))
}
