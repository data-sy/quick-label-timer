import SwiftUI

//
//  QuickStartTimerGridView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/12/25.
//
/// 즉시 시작 가능한 타이머 프리셋 목록을 표시하는 컴포넌트
///
/// - 사용 목적: 입력 없이 빠르게 시작 가능한 타이머 프리셋을 시각적으로 제공
/// - 기능: 탭 시 즉시 타이머를 시작할 수 있는 프리셋 목록을 버튼으로 구성
///

struct QuickStartTimerGridView: View {
    let presets: [TimerPreset]
    let onSelect: (TimerPreset) -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            
//            Spacer()

            Text("⚡️ 퀵스타트")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)

            // 제목 줄
            HStack {
                Text("□ 분 뒤")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("□ 분 동안")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            // 버튼 줄
            HStack(alignment: .top, spacing: 0) {
                VStack(spacing: 12) {
                    ForEach(planPresets) { preset in
                        button(for: preset)
                    }
                }
                .frame(maxWidth: .infinity)

                Rectangle() // 구분선
                    .fill(Color(.systemGray4))
                    .frame(width: 1)
                    .padding(.horizontal, 8)

                VStack(spacing: 12) {
                    ForEach(activePresets) { preset in
                        button(for: preset)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(16)
    }

    private var planPresets: [TimerPreset] {
        presets.filter { $0.usageType == .plan }
    }

    private var activePresets: [TimerPreset] {
        presets.filter { $0.usageType == .active }
    }

    @ViewBuilder
    private func button(for preset: TimerPreset) -> some View {
        Button {
            onSelect(preset)
        } label: {
            HStack {
                Text(timeText(for: preset))
                    .frame(width: 40, alignment: .trailing)
                    .foregroundColor(.gray)
                Text(preset.emoji)
                Text(preset.label)
                    .lineLimit(1)
                Spacer()
            }
            .font(.body)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    private func timeText(for preset: TimerPreset) -> String {
        var parts: [String] = []
        if preset.hours > 0 { parts.append("\(preset.hours)시간") }
        if preset.minutes > 0 { parts.append("\(preset.minutes)분") }
        if preset.seconds > 0 { parts.append("\(preset.seconds)초") }
        return parts.joined()
    }
}


#Preview {
    QuickStartTimerGridView(
        presets: [
            TimerPreset(hours: 0, minutes: 10, seconds: 0, label: "회의 입장", emoji: "📅", usageType: .plan),
            TimerPreset(hours: 0, minutes: 15, seconds: 0, label: "출발하기", emoji: "🚗", usageType: .plan),
            TimerPreset(hours: 0, minutes: 30, seconds: 0, label: "약 먹기", emoji: "💊", usageType: .plan),
            TimerPreset(hours: 0, minutes: 5, seconds: 0, label: "명상", emoji: "🧘", usageType: .active),
            TimerPreset(hours: 0, minutes: 10, seconds: 0, label: "낮잠", emoji: "😴", usageType: .active),
            TimerPreset(hours: 0, minutes: 20, seconds: 0, label: "휴식", emoji: "📱", usageType: .active)
        ],
        onSelect: { preset in
            print("Selected: \(preset)")
        }
    )
    .padding()
}
