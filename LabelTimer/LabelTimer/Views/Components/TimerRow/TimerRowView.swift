//
//  TimerRowView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 타이머 정보(레이블 + 시간 + 버튼)를 표시하는 공통 뷰
///
/// - 사용 목적: 실행 중 타이머, 프리셋 타이머 등 다양한 타이머 항목을 동일한 레이아웃으로 표현함

import SwiftUI

struct TimerRowView: View {
    let timer: TimerData
    let state: TimerInteractionState
    let statusText: String?
    let onToggleFavorite: (() -> Void)?
    let onLeftTap: (() -> Void)?
    let onRightTap: (() -> Void)?

    init(
        timer: TimerData,
        state: TimerInteractionState,
        statusText: String? = nil,
        onToggleFavorite: (() -> Void)? = nil,
        onLeftTap: (() -> Void)? = nil,
        onRightTap: (() -> Void)? = nil
    ) {
        self.timer = timer
        self.state = state
        self.statusText = statusText
        self.onToggleFavorite = onToggleFavorite
        self.onLeftTap = onLeftTap
        self.onRightTap = onRightTap
    }
    
    /// 상태 × endAction → 좌/우 버튼 타입
    private var buttonTypes: TimerButtonSet {
        makeButtonSet(for: state, endAction: timer.endAction)
    }
    
    private var labelFont: Font {
        // 완료 상태일 때만 더 큰 폰트를 사용
        switch state {
        case .completed:
            return .system(.title3, weight: .semibold)
        default:
            return .system(.headline, weight: .semibold)
        }
    }
//    private var labelFont: Font { // ✅ 기본 리팩토링 성공을 먼저 확인. 성공하면 위의 labelFont 제거하고 주석 풀자
//        // 완료 상태일 때만 더 큰 폰트를 사용
//        switch state {
//        case .completed:
//            return .system(.title3).weight(.semibold)
//        default:
//            return .system(.headline).weight(.semibold)
//        }
//    }

    
    private var labelColor: Color {
        switch state {
        case .paused, .stopped:
            return .secondary
        default:
            return .primary // 완료일 때도 검은색
        }
    }

    private var timeColor: Color {
        switch state {
        case .paused, .stopped, .completed:
            return .secondary
        default:
            return .primary
        }
    }
    
    private var indicatorInfo: (iconName: String, color: Color) {
        let mode = AlarmNotificationPolicy.getMode(
            soundOn: timer.isSoundOn,
            vibrationOn: timer.isVibrationOn
        )
        let iconName = mode.iconName

        let finalColor: Color
        switch state {
        case .paused, .stopped:
            finalColor = .secondary
        default:
            finalColor = AppTheme.controlForegroundColor
        }
        
        return (iconName, finalColor)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 6) {
                FavoriteToggleButton(
                    endAction: timer.endAction,
                    onToggle: { onToggleFavorite?() }
                )
                
                Text(timer.label)
                    .font(labelFont)
                    .foregroundColor(labelColor)

                if let statusText = statusText {
                    Text(statusText)
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.7))
                }
                
                Spacer()
                
                AlarmModeIndicatorView(
                    iconName: indicatorInfo.iconName,
                    color: indicatorInfo.color
                )
            }
            HStack {
                VStack(alignment: .leading, spacing: 0){
                    Text(timer.formattedTime)
                        .font(.system(size: 44, weight: .light))
                        .foregroundColor(timeColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                
                Spacer()

                HStack(spacing: 12) {
                    if buttonTypes.left != .none {
                        TimerLeftButtonView(type: buttonTypes.left) {
                            onLeftTap?()
                        }
                    }
                    TimerRightButtonView(type: buttonTypes.right) {
                        onRightTap?()
                    }
                }
            }
            CountdownMessageView(timer: timer)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
