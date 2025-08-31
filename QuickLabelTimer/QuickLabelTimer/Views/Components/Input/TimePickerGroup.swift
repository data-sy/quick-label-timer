//
//  TimePickerGroup.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 7/19/25.
//
/// 타이머 입력 섹션에서 사용하는 시·분·초 선택 뷰
/// 
/// - 사용 목적: 사용자가 타이머 시간을 입력할 수 있는 휠 제공

import SwiftUI

struct TimePickerGroup: View {
    @Binding var hours: Int
    @Binding var minutes: Int
    @Binding var seconds: Int

    var body: some View {
        HStack(spacing: 0) {
            Picker("", selection: $hours) {
                ForEach(0..<24) { Text("\($0)").tag($0) }
            }
            .pickerStyle(.wheel)
            .frame(width: 55)

            Text("시간")
                .font(.caption2)
                .foregroundColor(.gray)

            Picker("", selection: $minutes) {
                ForEach(0..<60) { Text("\($0)").tag($0) }
            }
            .pickerStyle(.wheel)
            .frame(width: 55)

            Text("분")
                .font(.caption2)
                .foregroundColor(.gray)

            Picker("", selection: $seconds) {
                ForEach(0..<60) { Text("\($0)").tag($0) }
            }
            .pickerStyle(.wheel)
            .frame(width: 55)

            Text("초")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(height: 128)
    }
}
