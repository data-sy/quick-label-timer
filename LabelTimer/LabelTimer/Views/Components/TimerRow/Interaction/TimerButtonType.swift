import SwiftUI

//
//  TimerButtonType.swift
//  LabelTimer
//
//  Created by 이소연 on 7/22/25.
//
/// 타이머 UI에서 사용하는 버튼 타입 정의
///
/// - 사용 목적: 각 버튼 상태에 따라 사용할 SF Symbol 아이콘과 배경 색상 지정
///   타이머 항목의 재생, 일시정지, 정지, 삭제, 재시작 등 액션에 일관된 스타일 제공

enum TimerButtonType {
    case play, pause, restart, stop, delete

    var iconName: String {
        switch self {
        case .play: return "play.fill"
        case .pause: return "pause.fill"
        case .restart: return "gobackward"
        case .stop: return "stop.fill"
        case .delete: return "xmark"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .play: return .green
        case .pause: return .orange
        case .restart: return .blue
        case .stop: return .red
        case .delete: return .gray
        }
    }
}
