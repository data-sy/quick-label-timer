//
//  AlarmModeDebugView.swift
//  LabelTimer
//
//  Created by 이소연 on 8/22/25.
//
/// 알림 방식 선택 세그먼트 컴포넌트
///
/// - 사용 목적: 사용자가 '소리+진동 / 진동만 / 무음' 중 하나를 직관적으로 선택하도록 제공
///         선택 결과는 AlarmMode로 바인딩되어 정책 결정 로직(AlarmNotificationPolicy)과 연동됨

import SwiftUI

// MARK: - 1. 기본 Picker를 사용한 세그먼트 컨트롤

/// SwiftUI 기본 Picker를 사용한 세그먼트 컨트롤 (디자인 제약 확인용)
struct BasicSegmentedControl: View {
    @Binding var selectedMode: AlarmMode

    var body: some View {
        Picker("알림 방식 (기본)", selection: $selectedMode) {
            ForEach(AlarmMode.allCases) { mode in
                // symbolNames 배열의 첫 번째 아이콘만 표시
                Label(mode.title, systemImage: mode.symbolNames.first ?? "questionmark.circle")
                    .tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }
}

// MARK: - 2. 커스텀 디자인을 적용한 세그먼트 컨트롤

/// 기본 Segmented Control과 유사한 디자인을 가진 커스텀 알림 방식 선택 뷰
struct AlarmModeDebugView: View {
    @Binding var selectedMode: AlarmMode
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AlarmMode.allCases) { mode in
                ZStack {
                    if selectedMode == mode {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white)
                            .matchedGeometryEffect(id: "selection", in: animation)
                    }
                    
                    HStack(spacing: 5) {
                        ForEach(mode.symbolNames, id: \.self) { name in
                            Image(systemName: name)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 8)
                }
                .font(.callout)
                .foregroundStyle(selectedMode == mode ? mode.color : .gray)
                .onTapGesture {
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                        selectedMode = mode
                    }
                }
                if mode != AlarmMode.allCases.last {
                    Divider().frame(height: 20)
                }
            }
        }
        .fixedSize()
        .padding(2) // 회색 영역과 내부 흰색 박스 사이 간격
        .background(Color(UIColor.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .frame(height: 40)
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var mode: AlarmMode = .soundAndVibration
        
        var body: some View {
            VStack(spacing: 50) {
                VStack(spacing: 15) {
                    Text("기본 Picker 세그먼트")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    BasicSegmentedControl(selectedMode: $mode)
                }

                Divider()

                VStack(spacing: 15) { // VStack에 정렬 추가
                    Text("커스텀 세그먼트 컨트롤")
                        .font(.headline)
                    
                    HStack {
                        Text("타이머 생성")
                            .font(.title2.bold())
                        Spacer()
                        AlarmModeDebugView(selectedMode: $mode)
                    }
                }
            }
            .padding()
        }
    }
    
    return PreviewWrapper()
}
