import SwiftUI

//
//  TimerInputView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/9/25.
//
/// 시/분/초 및 라벨을 입력받는 타이머 설정 화면
///
/// - 사용 목적: 타이머 시간과 라벨 입력 처리
/// - ViewModel: TimerInputViewModel

struct TimerInputView: View {
    @StateObject private var viewModel = TimerInputViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            Text("시간을 입력하세요.")
                .font(.title)

            Picker("시", selection: $viewModel.selectedHour) {
                ForEach(0..<24) { Text("\($0)시") }
            }.pickerStyle(.menu)

            Picker("분", selection: $viewModel.selectedMinute) {
                ForEach(0..<60) { Text("\($0)분") }
            }.pickerStyle(.menu)

            Picker("초", selection: $viewModel.selectedSecond) {
                ForEach(0..<60) { Text("\($0)초") }
            }.pickerStyle(.menu)
            
        }
        .padding()
        .presentationDetents([.medium])
    }
}
