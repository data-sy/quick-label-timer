import Foundation

//
//  Route.swift
//  LabelTimer
//
//  Created by 이소연 on 7/10/25.
//

enum Route: Hashable {
    case timerInput
    case runningTimer(data: TimerData)
    case alarm(data: TimerData)
}
