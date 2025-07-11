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
        HStack(spacing: 8) {
            Picker("시", selection: $hours) {
                ForEach(0..<24, id: \.self) { Text("\($0)시") }
            }
            .pickerStyle(.wheel)
            .frame(width: 100)
            .clipped()

            Picker("분", selection: $minutes) {
                ForEach(0..<60, id: \.self) { Text("\($0)분") }
            }
            .pickerStyle(.wheel)
            .frame(width: 100)
            .clipped()

            Picker("초", selection: $seconds) {
                ForEach(0..<60, id: \.self) { Text("\($0)초") }
            }
            .pickerStyle(.wheel)
            .frame(width: 100)
            .clipped()
        }
        .frame(height: 150)
    }
}
