//
//  TimerInputStartButton.swift
//  LabelTimer
//
//  Created by 이소연 on 7/19/25.
//
/// 타이머 입력 섹션에서 사용하는 시작 버튼
/// 
/// 사용 목적: 사용자가 시간과 라벨을 입력한 뒤, 타이머를 시작하도록 트리거하는 액션 버튼

import SwiftUI

struct TimerInputStartButton: View {
    var isDisabled: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: "play.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding(20)
                .background(Circle().fill(.blue))
        }
        .disabled(isDisabled)
    }
}
