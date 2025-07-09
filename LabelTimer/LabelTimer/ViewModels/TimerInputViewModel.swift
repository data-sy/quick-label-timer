import Foundation
import SwiftUI

//
//  TimerInputViewModel.swift
//  LabelTimer
//
//  Created by 이소연 on 7/9/25.
//
//
/// 입력된 시/분/초/라벨 값을 바인딩하는 ViewModel
///
/// - 연결: TimerInputView
/// - 역할: 시/분/초 및 라벨 입력값을 바인딩하고, TimeData 모델로 변환함

class TimerInputViewModel: ObservableObject {
    @Published var selectedHour: Int = 0
    @Published var selectedMinute: Int = 0
    @Published var selectedSecond: Int = 0
}
