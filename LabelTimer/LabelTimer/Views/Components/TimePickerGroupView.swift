import SwiftUI

//
//  TimePickerGroupView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/11/25.
//
/// 시/분/초를 선택하는 휠 스타일의 타이머 입력 컴포넌트
///
/// - 사용 목적: 시/분/초 입력 UI 제공
///

struct TimePickerGroupView: View {
    @Binding var hours: Int
    @Binding var minutes: Int
    @Binding var seconds: Int

    var body: some View {
        HStack(spacing: 16) {
            timePickerInline(value: $hours, range: 0..<24, label: "시")
            timePickerInline(value: $minutes, range: 0..<60, label: "분")
            timePickerInline(value: $seconds, range: 0..<60, label: "초")
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func timePickerInline(value: Binding<Int>, range: Range<Int>, label: String) -> some View {
        HStack(spacing: 4) {
            Picker("", selection: value) {
                ForEach(range, id: \.self) { Text("\($0)") }
            }
            .pickerStyle(.wheel)
            .frame(width: 60, height: 90)
            .clipped()

            Text(label)
                .font(.headline)
                .foregroundColor(.primary)
        }
//        .background(Color.green) // 시각화 영역 확인
    }
}
