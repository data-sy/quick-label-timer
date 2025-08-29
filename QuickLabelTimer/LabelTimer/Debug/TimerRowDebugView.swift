//
//  TimerRowDebugView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/24/25.
//
/// 타이머 목록의 행(Row) UI 컴포넌트 테스트용 뷰
///
/// - 사용 목적: 타이머의 각 상태(기본, 실행 중, 완료)에 따른 행(Row)의 UI와 버튼 스타일(채움/외곽선)을 시각적으로 검증

#if DEBUG

import SwiftUI

// MARK: - 테스트용 컴포넌트 (독립된 환경)

fileprivate enum DebugButtonEmphasis {
    case primary, secondary
}

fileprivate struct DebugTimerButtonStyle: ButtonStyle {
    let color: Color
    let emphasis: DebugButtonEmphasis

    func makeBody(configuration: Configuration) -> some View {
        let isPrimary = (emphasis == .primary)
        let font: Font = isPrimary ? .body : .title2
        let fontWeight: Font.Weight = isPrimary ? .semibold : .bold
        
        let diameter: CGFloat = 50

        return configuration.label
            .font(font.weight(fontWeight)) // 수정된 폰트 적용
            .foregroundColor(isPrimary ? .white : color)
            .frame(width: diameter, height: diameter)
            .background(
                Circle().fill(isPrimary ? color : Color.clear)
            )
            .overlay(
                Circle().strokeBorder(color, lineWidth: isPrimary ? 0 : 2.0)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

fileprivate struct DebugTimerRowView: View {
    let timer: TimerData
    let leftButtonIcon: String?
    let leftButtonColor: Color
    let rightButtonIcon: String
    let rightButtonColor: Color
    let buttonEmphasis: DebugButtonEmphasis
    let labelWeight: Font.Weight

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: timer.endAction.isPreserve ? "star.fill" : "star")
                    .foregroundColor(timer.endAction.isPreserve ? .yellow : .gray.opacity(0.6))
                    .font(.title2)
                    .frame(width: 44, height: 44)

                Text(timer.label)
                    .font(.system(.headline, weight: labelWeight))
                Spacer()
            }
            HStack {
                Text(timer.formattedTime)
                    .font(.system(size: 44, weight: .light))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                
                HStack(spacing: 12) {
                    if let icon = leftButtonIcon {
                        Button {} label: { Image(systemName: icon) }
                            .buttonStyle(DebugTimerButtonStyle(color: leftButtonColor, emphasis: buttonEmphasis))
                    }
                    Button {} label: { Image(systemName: rightButtonIcon) }
                        .buttonStyle(DebugTimerButtonStyle(color: rightButtonColor, emphasis: buttonEmphasis))
                }
            }
        }
        .padding(.vertical, 8)
    }
}


// MARK: - 실제 테스트 화면

struct TimerRowDebugView: View {
    private func createSampleTimer(label: String, endAction: TimerEndAction = .preserve) -> TimerData {
        return TimerData(label: label, hours: 0, minutes: 5, seconds: 25, createdAt: Date(), endDate: Date(), remainingSeconds: 325, status: .stopped, endAction: endAction)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                
                Section(header: Text("기본 상태 (수정 / 재생)").font(.title2)) {
                    DebugTimerRowView(timer: createSampleTimer(label: "Primary (채움)"), leftButtonIcon: "pencil", leftButtonColor: .teal, rightButtonIcon: "play.fill", rightButtonColor: .accentColor, buttonEmphasis: .primary, labelWeight: .semibold)
                    DebugTimerRowView(timer: createSampleTimer(label: "Secondary (외곽선)"), leftButtonIcon: "pencil", leftButtonColor: .teal, rightButtonIcon: "play.fill", rightButtonColor: .accentColor, buttonEmphasis: .secondary, labelWeight: .semibold)
                }
                
                Divider()

                Section(header: Text("실행 중 (멈춤 / 일시정지)").font(.title2)) {
                    DebugTimerRowView(timer: createSampleTimer(label: "Primary (채움)"), leftButtonIcon: "stop.fill", leftButtonColor: .red, rightButtonIcon: "pause.fill", rightButtonColor: .orange, buttonEmphasis: .primary, labelWeight: .semibold)
                    DebugTimerRowView(timer: createSampleTimer(label: "Secondary (외곽선)"), leftButtonIcon: "stop.fill", leftButtonColor: .red, rightButtonIcon: "pause.fill", rightButtonColor: .orange, buttonEmphasis: .secondary, labelWeight: .semibold)
                }
                
                Divider()
                
                Section(header: Text("완료됨 (즐겨찾기 이동 / 재시작)").font(.title2)) {
                     DebugTimerRowView(timer: createSampleTimer(label: "Primary (채움)"), leftButtonIcon: "chevron.right", leftButtonColor: .yellow, rightButtonIcon: "gobackward", rightButtonColor: .accentColor, buttonEmphasis: .primary, labelWeight: .semibold)
                     DebugTimerRowView(timer: createSampleTimer(label: "Secondary (외곽선)"), leftButtonIcon: "chevron.right", leftButtonColor: .yellow, rightButtonIcon: "gobackward", rightButtonColor: .accentColor, buttonEmphasis: .secondary, labelWeight: .semibold)
                }
            }
            .padding()
        }
        .navigationTitle("UI 컴포넌트 테스트")
    }
}


// MARK: - Xcode Preview
#if DEBUG
struct TimerRowDebugView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimerRowDebugView()
        }
    }
}
#endif

#endif
