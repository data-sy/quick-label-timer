//
//  MatchedGeometryTestView.swift
//  LabelTimer
//
//  Created by 이소연 on 8/5/25.
//

import SwiftUI

struct AniTimerPreset: Identifiable, Equatable {
    let id: UUID
    let label: String
    var isHiddenInList: Bool = false
}

struct AniRunningTimer: Identifiable, Equatable {
    let id: UUID
    let label: String
    let presetId: UUID
}

struct AniMatchedGeometryView: View {
    @Namespace private var moveNamespace

    @State private var presets: [AniTimerPreset] = [
        .init(id: UUID(), label: "5분 휴식"),
        .init(id: UUID(), label: "10분 집중"),
        .init(id: UUID(), label: "1시간 공부")
    ]

    @State private var runningTimers: [AniRunningTimer] = []

    var visiblePresets: [AniTimerPreset] {
        presets.filter { !$0.isHiddenInList }
    }

    var body: some View {
        VStack(spacing: 40) {
            // 실행 중 타이머 리스트
            VStack(alignment: .leading) {
                Text("실행 중인 타이머")
                    .font(.headline)
                if runningTimers.isEmpty {
                    Text("실행 중인 타이머 없음")
                        .foregroundColor(.gray)
                        .padding(.vertical, 12)
                } else {
                    ForEach(runningTimers) { timer in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.orange.opacity(0.12))
                            .frame(height: 54)
                            .overlay(
                                HStack {
                                    Text(timer.label)
                                        .font(.title3)
                                        .bold()
                                    Spacer()
                                    Image(systemName: "arrow.down.to.line")
                                        .font(.title3)
                                        .opacity(0.3)
                                }
                                .padding(.horizontal)
                            )
                            .matchedGeometryEffect(id: timer.presetId, in: moveNamespace)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    moveToPreset(timer: timer)
                                }
                            }
                            .padding(.vertical, 3)
                    }
                }
            }
            .padding(.horizontal)

            Divider()
                .padding(.vertical, 10)

            // 프리셋 리스트
            VStack(alignment: .leading) {
                Text("프리셋 목록(즐겨찾기)")
                    .font(.headline)
                if visiblePresets.isEmpty {
                    Text("사용 가능한 프리셋 없음")
                        .foregroundColor(.gray)
                        .padding(.vertical, 12)
                } else {
                    ForEach(visiblePresets) { preset in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.12))
                            .frame(height: 54)
                            .overlay(
                                HStack {
                                    Text(preset.label)
                                        .font(.title3)
                                    Spacer()
                                    Image(systemName: "arrow.up.to.line")
                                        .font(.title3)
                                        .opacity(0.3)
                                }
                                .padding(.horizontal)
                            )
                            .matchedGeometryEffect(id: preset.id, in: moveNamespace)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    moveToRunning(preset: preset)
                                }
                            }
                            .padding(.vertical, 3)
                    }
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 40)
    }

    private func moveToRunning(preset: AniTimerPreset) {
        // 1. 프리셋 숨김 처리
        if let idx = presets.firstIndex(where: { $0.id == preset.id }) {
            presets[idx].isHiddenInList = true
        }
        // 2. 실행 중 타이머 추가
        runningTimers.append(.init(id: UUID(), label: preset.label, presetId: preset.id))
    }

    private func moveToPreset(timer: AniRunningTimer) {
        // 1. 실행 중 타이머 삭제
        runningTimers.removeAll { $0.id == timer.id }
        // 2. 프리셋 다시 보이게
        if let idx = presets.firstIndex(where: { $0.id == timer.presetId }) {
            presets[idx].isHiddenInList = false
        }
    }
}

#Preview {
    AniMatchedGeometryView()
}
