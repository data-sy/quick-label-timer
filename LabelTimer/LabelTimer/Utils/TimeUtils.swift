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

/// 일정 시간(초) 후에 클로저를 실행하고, 취소할 수 있는 작업을 반환
/// - Parameters:
///   - seconds: 지연할 시간 (초 단위, 소수점 가능)
///   - execute: 지연 후 실행할 클로저
/// - Returns: 나중에 취소할 수 있는 DispatchWorkItem (예약표)
func schedule(
    after seconds: TimeInterval,
    execute: @escaping () -> Void
) -> DispatchWorkItem {
    
    let task = DispatchWorkItem(block: execute)
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: task)
    
    return task
}

// 예약된 작업을 취소
func cancel(task: DispatchWorkItem?) {
    task?.cancel()
}
