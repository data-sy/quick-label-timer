//
//  TimerFontDebugView.swift
//  LabelTimer
//
//  Created by 이소연 on 8/22/25.
//
/// 타이머의 라벨과 시간 폰트 조합을 테스트하기 위한 디버그용 뷰
///
/// - 사용 목적: 다양한 폰트(크기, 두께) 조합을 한 화면에 렌더링하여 최적의 가독성 및 디자인을 시각적으로 확인하고 결정

#if DEBUG

import SwiftUI

// MARK: - 테스트에 필요한 컴포넌트 (독립된 환경)

// --- 1. 최종 결정된 외곽선 버튼 스타일 ---
fileprivate struct FinalTimerButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        // AppTheme에서 결정한 최종 값들을 여기에 정의
        let diameter: CGFloat = 52
        let lineWidth: CGFloat = 1.5
        let iconFont: Font = .title3
        let iconWeight: Font.Weight = .bold

        return configuration.label
            .font(iconFont.weight(iconWeight))
            .foregroundColor(color)
            .frame(width: diameter, height: diameter)
            .background(Circle().fill(Color.clear))
            .overlay(
                Circle().strokeBorder(color, lineWidth: lineWidth)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

// --- 2. 폰트 조합을 테스트하기 위한 RowView ---
fileprivate struct DebugTimerRowView: View {
    let timer: TimerData
    let labelFont: Font
    let timeWeight: Font.Weight // 👈 시계 폰트 두께를 받도록 추가

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: timer.endAction.isPreserve ? "star.fill" : "star")
                    .foregroundColor(timer.endAction.isPreserve ? .yellow : .gray.opacity(0.6))
                    .font(.title2)
                    .frame(width: 44, height: 44)

                Text(timer.label)
                    .font(labelFont)
                Spacer()
            }
            HStack {
                Text(timer.formattedTime)
                    .font(.system(size: 44, weight: timeWeight)) // 👈 전달받은 시계 두께 적용
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                
                HStack(spacing: 12) {
                    Button {} label: { Image(systemName: "pencil") }
                        .buttonStyle(FinalTimerButtonStyle(color: .teal))
                    
                    Button {} label: { Image(systemName: "play.fill") }
                        .buttonStyle(FinalTimerButtonStyle(color: .accentColor))
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
}


// MARK: - 실제 테스트 화면

struct TimerFontDebugView: View {
    // --- 테스트할 폰트 조합 정의 ---
    let labelTextStyles: [Font.TextStyle] = [.headline, .title3]
    let labelWeights: [Font.Weight] = [.regular, .semibold, .bold]
    let timeWeights: [Font.Weight] = [.thin, .light]

    private func createSampleTimer(label: String) -> TimerData {
        return TimerData(label: label, hours: 0, minutes: 5, seconds: 25, createdAt: Date(), endDate: Date(), remainingSeconds: 325, status: .stopped, endAction: .preserve)
    }
    
    // --- 폰트 스타일/두께를 설명하는 헬퍼 함수 ---
    private func describe(style: Font.TextStyle) -> String {
        switch style {
        case .headline: return "Headline"
        case .title3: return "Title 3"
        default: return "Unknown"
        }
    }
    
    private func describe(weight: Font.Weight) -> String {
        switch weight {
        case .regular: return "Regular"
        case .semibold: return "Semibold"
        case .bold: return "Bold"
        case .thin: return "Thin"
        case .light: return "Light"
        default: return "Unknown"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // --- 12가지 조합을 보여주기 위한 3중 ForEach ---
                ForEach(labelTextStyles, id: \.self) { labelStyle in
                    Section(header: Text("Label Size: \(describe(style: labelStyle))").font(.title)) {
                        
                        ForEach(labelWeights, id: \.self) { labelWeight in
                            ForEach(timeWeights, id: \.self) { timeWeight in
                                let combinedLabelFont = Font.system(labelStyle).weight(labelWeight)
                                let timerLabel = "L: \(describe(weight: labelWeight)) / T: \(describe(weight: timeWeight))"
                                
                                DebugTimerRowView(
                                    timer: createSampleTimer(label: timerLabel),
                                    labelFont: combinedLabelFont,
                                    timeWeight: timeWeight
                                )
                            }
                        }
                    }
                    Divider().padding(.vertical, 10)
                }
            }
            .padding()
        }
        .navigationTitle("라벨/시간 폰트 테스트")
    }
}


// MARK: - Xcode Preview
#if DEBUG
struct TimerFontDebugView_Previews:  PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimerFontDebugView()
        }
    }
}
#endif

#endif
