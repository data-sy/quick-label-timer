//
//  Route.swift
//  LabelTimer
//
//  Created by 이소연 on 7/10/25.
//


import Foundation

enum Route: Hashable {
    case timerInput
    case runningTimer(TimerData)
    case alarm(data: TimerData)
}
