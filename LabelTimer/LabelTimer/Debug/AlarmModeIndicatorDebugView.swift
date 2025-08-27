//
//  AlarmModeIndicatorDebugView.swift
//  LabelTimer
//
//  Created by 이소연 on 8/26/25.
//
/// 다양한 알람 모드 인디케이터 디자인을 한 화면에서 비교하기 위한 디버그용 뷰
///
/// - 사용 목적: 최종 인디케이터 디자인을 결정하기 전에, 여러 후보 디자인(단일 아이콘, 단일 점, 링 스타일 등)이
///   각 알람 모드(소리, 진동, 무음)에 따라 어떻게 보이는지 시각적으로 비교

import SwiftUI

// MARK: - 4가지 인디케이터 디자인 (테스트 대상)

/// 디자인 1: 단일 아이콘
fileprivate struct IndicatorDesign1_SingleIcon: View {
    let isSoundOn: Bool
    let isVibrationOn: Bool
    private var currentMode: AlarmMode { AlarmNotificationPolicy.getMode(soundOn: isSoundOn, vibrationOn: isVibrationOn) }

    var body: some View {
        Image(systemName: currentMode.iconName)
            .font(.caption.weight(.bold))
//            .foregroundStyle(currentMode.color)
            .frame(width: 30, height: 30, alignment: .center)
    }
}

/// 디자인 2: 단일 색상 점
fileprivate struct IndicatorDesign2_SingleDot: View {
    let isSoundOn: Bool
    let isVibrationOn: Bool
    private var currentMode: AlarmMode { AlarmNotificationPolicy.getMode(soundOn: isSoundOn, vibrationOn: isVibrationOn) }

    var body: some View {
        Circle()
//            .fill(currentMode.color)
            .frame(width: 12, height: 12)
    }
}

/// 디자인 3: 3개 아이콘 (활성/비활성)
fileprivate struct IndicatorDesign3_ThreeIcons: View {
    let isSoundOn: Bool
    let isVibrationOn: Bool
    private var currentMode: AlarmMode { AlarmNotificationPolicy.getMode(soundOn: isSoundOn, vibrationOn: isVibrationOn) }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(AlarmMode.allCases) { mode in
                Image(systemName: mode.iconName)
                    .font(.caption.weight(.semibold))
//                    .foregroundStyle(mode == currentMode ? mode.color : Color(UIColor.systemGray3))
            }
        }
        .frame(width: 60, alignment: .trailing)
    }
}

/// 디자인 4: 채워진 링
fileprivate struct IndicatorDesign4_FilledRing: View {
    let isSoundOn: Bool
    let isVibrationOn: Bool
    private var currentMode: AlarmMode { AlarmNotificationPolicy.getMode(soundOn: isSoundOn, vibrationOn: isVibrationOn) }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(AlarmMode.allCases) { mode in
                Circle()
                    .frame(width: 12, height: 12)
//                    .foregroundStyle(mode == currentMode ? mode.color : .clear)
                    .overlay(
                        Circle().stroke(Color(UIColor.systemGray4), lineWidth: 1.5)
                    )
            }
        }
    }
}

// MARK: - 테스트 화면

/// 4가지 알람 모드 인디케이터 디자인을 실제 UI 틀 안에서 비교하기 위한 뷰
struct AlarmModeIndicatorDebugView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {

                Section(header: Text("디자인 1: 단일 아이콘").font(.title2).padding(.bottom, 5)) {
                    VStack(spacing: 15) {
                        DebugTimerRow(indicator: { IndicatorDesign1_SingleIcon(isSoundOn: true, isVibrationOn: true) })
                        DebugTimerRow(indicator: { IndicatorDesign1_SingleIcon(isSoundOn: false, isVibrationOn: true) })
                        DebugTimerRow(indicator: { IndicatorDesign1_SingleIcon(isSoundOn: false, isVibrationOn: false) })
                    }
                }
                
                Divider()

                Section(header: Text("디자인 2: 단일 색상 점").font(.title2).padding(.bottom, 5)) {
                    VStack(spacing: 15) {
                        DebugTimerRow(indicator: { IndicatorDesign2_SingleDot(isSoundOn: true, isVibrationOn: true) })
                        DebugTimerRow(indicator: { IndicatorDesign2_SingleDot(isSoundOn: false, isVibrationOn: true) })
                        DebugTimerRow(indicator: { IndicatorDesign2_SingleDot(isSoundOn: false, isVibrationOn: false) })
                    }
                }
                
                Divider()
                
                Section(header: Text("디자인 3: 3개 아이콘").font(.title2).padding(.bottom, 5)) {
                    VStack(spacing: 15) {
                        DebugTimerRow(indicator: { IndicatorDesign3_ThreeIcons(isSoundOn: true, isVibrationOn: true) })
                        DebugTimerRow(indicator: { IndicatorDesign3_ThreeIcons(isSoundOn: false, isVibrationOn: true) })
                        DebugTimerRow(indicator: { IndicatorDesign3_ThreeIcons(isSoundOn: false, isVibrationOn: false) })
                    }
                }
                
                Divider()
                
                Section(header: Text("디자인 4: 채워진 링").font(.title2).padding(.bottom, 5)) {
                    VStack(spacing: 15) {
                        DebugTimerRow(indicator: { IndicatorDesign4_FilledRing(isSoundOn: true, isVibrationOn: true) })
                        DebugTimerRow(indicator: { IndicatorDesign4_FilledRing(isSoundOn: false, isVibrationOn: true) })
                        DebugTimerRow(indicator: { IndicatorDesign4_FilledRing(isSoundOn: false, isVibrationOn: false) })
                    }
                }
            }
            .padding()
        }
        .navigationTitle("인디케이터 디자인 비교")
    }
}


// MARK: - 헬퍼 컴포넌트

/// 실제 TimerRowView의 '틀'을 유지하면서 인디케이터만 교체할 수 있는 테스트용 뷰
fileprivate struct DebugTimerRow<Indicator: View>: View {
    let indicator: Indicator
    
    init(@ViewBuilder indicator: () -> Indicator) {
        self.indicator = indicator()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                    .frame(width: 44, height: 44)

                Text("샘플 타이머")
                    .font(.system(.headline, weight: .semibold))
                
                Spacer()
                
                indicator
                    .padding(.horizontal)
            }
            HStack {
                Text("00:05:25")
                    .font(.system(size: 44, weight: .light))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Spacer()
                
                // 결정된 버튼 스타일을 하드코딩
                HStack(spacing: 12) {
                    Button {} label: { Image(systemName: "pencil") }
                        .buttonStyle(DebugTimerButtonStyle(color: .teal, emphasis: .secondary))
                    Button {} label: { Image(systemName: "play.fill") }
                        .buttonStyle(DebugTimerButtonStyle(color: .accentColor, emphasis: .secondary))
                }
            }
        }
        .padding(.vertical, 8)
    }
}


// MARK: - 코드 실행에 필요한 나머지 컴포넌트

fileprivate enum DebugButtonEmphasis { case primary, secondary }

fileprivate struct DebugTimerButtonStyle: ButtonStyle {
    let color: Color
    let emphasis: DebugButtonEmphasis

    func makeBody(configuration: Configuration) -> some View {
        let isPrimary = (emphasis == .primary)
        let font: Font = isPrimary ? .body : .title2
        let fontWeight: Font.Weight = isPrimary ? .semibold : .bold
        let diameter: CGFloat = 50

        return configuration.label
            .font(font.weight(fontWeight))
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

// Xcode Preview를 위한 코드
#if DEBUG
struct AlarmModeIndicatorDebugView_Previews: PreviewProvider {
    static var previews: some View {
        // 실제 데이터 모델이 필요 없으므로, 미리보기에 필요한 최소한의 코드만 남깁니다.
        // AlarmMode, AlarmNotificationPolicy 등은 실제 프로젝트 파일에 있어야 합니다.
        NavigationView {
            AlarmModeIndicatorDebugView()
        }
    }
}
#endif
