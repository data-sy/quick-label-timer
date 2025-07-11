import SwiftUI

//
//  AppEntryPoint.swift
//  LabelTimer
//
//  Created by 이소연 on 7/11/25.
//

struct AppEntryPoint: View {
    @State private var path: [Route] = []

    @State private var hours = 0
    @State private var minutes = 0
    @State private var seconds = 0
    @State private var label = ""

    var body: some View {
        NavigationStack(path: $path) {
            TimerInputView(
                path: $path,
                hours: $hours,
                minutes: $minutes,
                seconds: $seconds,
                label: $label
            )
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .timerInput:
                    TimerInputView(
                        path: $path,
                        hours: $hours,
                        minutes: $minutes,
                        seconds: $seconds,
                        label: $label
                    )

                case .runningTimer(let data):
                    RunningTimerView(timerData: data, path: $path)

                case .alarm(let data):
                    AlarmView(timerData: data, path: $path)
                }
            }
        }
        .onAppear {
            NotificationUtils.requestAuthorization()
        }
    }
}
