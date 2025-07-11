import SwiftUI

//
//  TimerTitleView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/11/25.
//
/// 타이머 화면 상단에 표시되는 타이틀 컴포넌트
///
/// - 사용 목적: "타이머 실행 중", "타이머 종료" 등 상태 메시지를 표시

struct TimerTitleView: View {
    let text: String

    var body: some View {
        Text("⏱ \(text)")
            .font(.title3)
            .fontWeight(.regular)
    }
}
