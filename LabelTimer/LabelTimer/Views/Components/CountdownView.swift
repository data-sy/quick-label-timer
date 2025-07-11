import SwiftUI

//
//  CountdownView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/11/25.
//
/// 타이머의 남은 시간을 표시하는 카운트다운 컴포넌트
///
/// - 사용 목적: 시:분:초 형식으로 시간 출력

struct CountdownView: View {
    let seconds: Int

    var body: some View {
        Text(timeString(from: seconds))
            .font(.system(size: 48, weight: .bold))
            .monospacedDigit()
            .foregroundColor(Color(.systemGray))
    }

    private func timeString(from seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
