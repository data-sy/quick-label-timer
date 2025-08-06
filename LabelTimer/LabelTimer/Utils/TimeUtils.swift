//
//  TimeUtils.swift
//  LabelTimer
//
//  Created by 이소연 on 8/6/25.
//
/// 딜레이 후 실행 유틸 함수
///
/// - 사용 목적: 특정 시간 후 지정한 클로저를 실행할 때 사용
import Foundation

/// 일정 시간(초) 후에 클로저를 메인 스레드에서 실행
func scheduleAfter(seconds: Int, execute: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: execute)
}
