//
//  RepeatMode.swift
//  LabelTimer
//
//  Created by 이소연 on 8/20/25.
//
/// 오디오 재생의 반복 방식을 정의하는 Enum
///
/// - 사용 목적: -1, 0과 같은 숫자(Magic Number) 대신 .infinite, .once처럼 의미가 명확한 타입으로 재생 방식을 지정하고 실수를 방지하기 위함
///
/// ---
/// ### `player.numberOfLoops` 프로퍼티 참고
/// - **0 (기본값):** 반복 없이 총 1회만 재생
/// - **양수(n):** 기본 재생 후 n번 더 반복하여 총 n+1회 재생 (예: 1을 입력하면 총 2회 재생)
/// - **-1:** stop() 메서드가 호출될 때까지 무한 반복

enum RepeatMode {
    case once
    case `repeat`(times: Int)
    case infinite
    
    /// AVAudioPlayer의 numberOfLoops 프로퍼티에 할당할 Int 값 계산
    var loopValue: Int {
        switch self {
        case .once:
            return 0
        case .repeat(let times):
            return max(0, times - 1)
        case .infinite:
            return -1
        }
    }
}
