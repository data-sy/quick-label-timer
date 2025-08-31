//
//  SupportSymbolsPreviewView.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/31/25.
//
/// 소리·진동 관련 지원 화면에 사용할 수 있는 SF Symbols 아이콘을 한눈에 비교할 수 있는 프리뷰 뷰
///
/// - 사용 목적:
///   - 소리(Speaker)와 진동(iPhone) 심볼의 다양한 변형(기본, 원형, 배지, 무음 등)을 한 화면에서 시각적으로 확인
///   - 지원 화면에서 NavigationLink에 적절한 아이콘을 선택할 때 참고 자료로 활용

#if DEBUG

import SwiftUI

struct SupportSymbolsPreviewView: View {
    // MARK: - Sound (Speaker) symbols
    private let speakerBase: [String] = [
        "speaker", "speaker.fill",
        "speaker.wave.1", "speaker.wave.1.fill",
        "speaker.wave.2", "speaker.wave.2.fill",
        "speaker.wave.3", "speaker.wave.3.fill"
    ]
    private let speakerCircle: [String] = [
        "speaker.wave.2.circle", "speaker.wave.2.circle.fill"
    ]
    private let speakerAttention: [String] = [
        "speaker.badge.exclamationmark", "speaker.badge.exclamationmark.fill"
    ]
    private let speakerQuietAlt: [String] = [
        "speaker.zzz", "speaker.zzz.fill",
        "speaker.slash.circle", "speaker.slash.circle.fill"
    ]

    // MARK: - Vibration (iPhone radiowaves) symbols
    private let vibrationBase: [String] = [
        "iphone", "iphone.circle", "iphone.circle.fill"
    ]
    private let vibrationActive: [String] = [
        "iphone.radiowaves.left.and.right",
        "iphone.radiowaves.left.and.right.circle",
        "iphone.radiowaves.left.and.right.circle.fill"
    ]
    private let vibrationSilent: [String] = [
        "iphone.slash",
        "iphone.slash.circle", "iphone.slash.circle.fill"
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SectionGrid(title: "Sound — Base / Waves", columns: columns, symbols: speakerBase)
                SectionGrid(title: "Sound — Circle (state emphasis)", columns: columns, symbols: speakerCircle)
                SectionGrid(title: "Sound — Attention (badge)", columns: columns, symbols: speakerAttention)
                SectionGrid(title: "Sound — Quiet / Slash (optional)", columns: columns, symbols: speakerQuietAlt)

                SectionGrid(title: "Vibration — Base", columns: columns, symbols: vibrationBase)
                SectionGrid(title: "Vibration — Active (radiowaves)", columns: columns, symbols: vibrationActive)
                SectionGrid(title: "Vibration — Silent / Blocked", columns: columns, symbols: vibrationSilent)
            }
            .padding(16)
        }
        .scrollIndicators(.visible)
        .navigationTitle("Support Symbols")
    }
}

private struct SectionGrid: View {
    let title: String
    let columns: [GridItem]
    let symbols: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(symbols, id: \.self) { name in
                    VStack(spacing: 8) {
                        Image(systemName: name)
                            .font(.system(size: 28))
                            .symbolRenderingMode(.hierarchical)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .accessibilityLabel(Text(name))

                        Text(name)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(8)
                    .background(Color.secondary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
}

#Preview("Support Symbols — Scroll Grid") {
    NavigationStack {
        SupportSymbolsPreviewView()
            .navigationBarTitleDisplayMode(.inline)
    }
    .previewDevice("iPhone 15 Pro")
}

#endif
