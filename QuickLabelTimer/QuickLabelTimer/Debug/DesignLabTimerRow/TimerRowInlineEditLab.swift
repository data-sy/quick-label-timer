//
//  TimerRowInlineEditLab.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//

import SwiftUI

// MARK: - 🎛️ 인라인 편집 실험실
struct TimerRowInlineEditLab: View {
    @State private var timers: [TimerData] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.pageBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // V11: EditableTimerLabel 적용
                        DesignSection(
                            title: "V11: Inline Edit (Tap to Edit)",
                            description: "라벨을 탭하면 편집 모드로 전환"
                        ) {
                            VStack(spacing: 12) {
                                ForEach(timers) { timer in
                                    CardStyleRowV11(
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
                            title: "사용 방법",
                            description: ""
                        ) {
                            VStack(alignment: .leading, spacing: 12) {
                                GuideItem(
                                    icon: "hand.tap.fill",
                                    text: "라벨을 탭하면 편집 모드로 전환됩니다"
                                )
                                GuideItem(
                                    icon: "keyboard",
                                    text: "Return 키를 누르면 편집이 완료됩니다"
                                )
                                GuideItem(
                                    icon: "xmark.circle",
                                    text: "빈 값으로 제출하면 원래 값이 유지됩니다"
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
            .navigationTitle("Inline Edit Lab")
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
            // TimerData의 복사본을 만들어서 새 라벨로 재생성
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
                label: "업무 집중 시간",
                time: "1:25:00",
                state: .running,
                endAction: .preserve,
                isSoundOn: true,
                isVibrationOn: true
            ),
            makeDummyTimer(
                label: "점심 준비",
                time: "0:15:30",
                state: .paused,
                endAction: .discard,
                isSoundOn: false,
                isVibrationOn: true
            ),
            makeDummyTimer(
                label: "매우 긴 라벨 테스트: 아이들이 깨지 않도록 조용히 설거지하고 정리한 다음 내일 아침 도시락 준비까지 완료하기",
                time: "0:05:00",
                state: .running,
                endAction: .preserve,
                isSoundOn: true,
                isVibrationOn: false
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

// MARK: - Guide Item Component
struct GuideItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    TimerRowInlineEditLab()
}
