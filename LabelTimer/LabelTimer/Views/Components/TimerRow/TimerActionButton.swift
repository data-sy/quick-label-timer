import SwiftUI

//
//  TimerActionButton.swift
//  LabelTimer
//
//  Created by 이소연 on 7/22/25.
//
/// 타이머용 동작 버튼(재생, 일시정지, 삭제 등)을 공통 컴포넌트로 제공
///
/// - 사용 목적: 각 버튼 상태에 따라 아이콘 및 색상을 자동 적용하며, 스타일을 일관되게 유지

struct TimerActionButton: View {
    let type: TimerButtonType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: type.iconName)
                .foregroundColor(.white)
                .padding(8)
                .background(type.backgroundColor)
                .clipShape(Circle())
        }
    }
}
