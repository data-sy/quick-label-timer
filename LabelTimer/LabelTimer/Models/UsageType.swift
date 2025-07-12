import Foundation

//
//  UsageType.swift
//  LabelTimer
//
//  Created by 이소연 on 7/12/25.
//
/// 타이머 사용 목적을 나타내는 열거형
///
/// - 사용 목적: 타이머가 끝났을 때 어떤 행동을 해야 하는지를 기준으로 분류
/// - case:
///     - plan: 타이머가 끝나면 특정 작업을 시작해야 하는 경우 (ex: 5분 뒤 출발)
///     - active: 타이머가 진행되는 동안 특정 작업을 수행하는 경우 (ex: 25분 동안 집중)

enum UsageType: String, Codable {
    case plan
    case active
}
