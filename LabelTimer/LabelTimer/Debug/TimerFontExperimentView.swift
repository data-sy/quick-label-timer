//
//  TimerFontExperimentView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/24/25.
//
/// 다양한 타이머 디자인 조합(배경/폰트 색상/굵기)을 실험하는 뷰
///
/// - 사용 목적: 텍스트 색상, 배경, 폰트 웨이트 등의 조합을 시각적으로 비교하여 타이머 UI 개선에 참고

#if DEBUG

import SwiftUI

struct TimerFontExperimentView: View {
    @State private var remainingTime = Constants.timerStartSeconds
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let activeGroups: [FontSampleGroup] = [
        .blackTime,
        .whiteOnBlack,
        .orangeOnWhite,
        .orangeOnBlack
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(activeGroups, id: \.self) { group in
                    ForEach(Array(group.variants.enumerated()), id: \.1.label) { index, variant in
                        TimerFontSample(
                            label: variant.label,
                            weight: variant.weight,
                            size: variant.size,
                            labelColor: group.labelColor,
                            timeColor: group.timeColor,
                            background: group.background,
                            remainingTime: remainingTime
                        )

                        if index < group.variants.count - 1 {
                            Divider()
                        }
                    }
                }
            }
            .padding()
        }
        .onReceive(timer) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            }
        }
    }
}

private struct TimerFontSample: View {
    var label: String
    var weight: Font.Weight
    var size: CGFloat
    var labelColor: Color
    var timeColor: Color
    var background: Color
    var remainingTime: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
//            Text(label)
//                .font(.caption)
//                .foregroundColor(.secondary)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("양치 타이머")
                        .font(.headline)
                        .foregroundColor(labelColor)

                    Text(formatTime(remainingTime))
                        .font(.system(size: size, weight: weight))
                        .foregroundColor(timeColor)
                }

                Spacer()

                HStack(spacing: 12) {
//                    TimerActionButton(type: .stop) {}
//                    TimerActionButton(type: .play) {}
                }
            }
            .padding()
            .background(background)
            .cornerRadius(8)
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

private struct FontVariant {
    let label: String
    let weight: Font.Weight
    let size: CGFloat
}

private enum FontSampleGroup: CaseIterable {
    case grayTime
    case blackTime
    case whiteOnBlack
    case orangeOnWhite
    case orangeOnBlack
    case blackLabelOrangeTime
    case whiteLabelOrangeTime
    case orangeLabelBlackTime
    case orangeLabelWhiteTime

    var labelColor: Color {
        switch self {
        case .grayTime, .blackTime, .blackLabelOrangeTime:
            return .black
        case .whiteOnBlack, .whiteLabelOrangeTime:
            return .white
        case .orangeOnWhite, .orangeOnBlack, .orangeLabelBlackTime, .orangeLabelWhiteTime:
            return .orange
        }
    }

    var timeColor: Color {
        switch self {
        case .grayTime:
            return .gray
        case .blackTime, .orangeLabelBlackTime:
            return .black
        case .whiteOnBlack, .orangeLabelWhiteTime:
            return .white
        case .orangeOnWhite, .orangeOnBlack, .blackLabelOrangeTime, .whiteLabelOrangeTime:
            return .orange
        }
    }

    var background: Color {
        switch self {
        case .whiteOnBlack, .orangeOnBlack, .whiteLabelOrangeTime, .orangeLabelWhiteTime:
            return .black
        default:
            return .white
        }
    }

    var labelPrefix: String {
        switch self {
        case .grayTime: return "1. Gray"
        case .blackTime: return "2. Black"
        case .whiteOnBlack: return "3. White/Black"
        case .orangeOnWhite: return "4. Orange/White"
        case .orangeOnBlack: return "5. Orange/Black"
        case .blackLabelOrangeTime: return "6. BlackLabel/OrangeTime"
        case .whiteLabelOrangeTime: return "7. WhiteLabel/OrangeTime"
        case .orangeLabelBlackTime: return "8. OrangeLabel/BlackTime"
        case .orangeLabelWhiteTime: return "9. OrangeLabel/WhiteTime"
        }
    }

    var variants: [FontVariant] {
        [
//            FontVariant(label: "\(labelPrefix) - Regular Size34", weight: .regular, size: 34),
            FontVariant(label: "\(labelPrefix) - Regular Size44", weight: .regular, size: 44),
//            FontVariant(label: "\(labelPrefix) - Semibold Size34", weight: .semibold, size: 34),
            FontVariant(label: "\(labelPrefix) - Semibold Size44", weight: .semibold, size: 44)
        ]
    }
}

private enum Constants {
    static let timerStartSeconds = 180
}

#endif
