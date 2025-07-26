//
//  AlarmSoundPlayer.swift
//  LabelTimer
//
//  Created by 이소연 on 7/25/25.
//
/// 타이머 종료 시 반복 알람 소리를 재생하는 클래스
///
/// - 사용 목적: 백그라운드 및 포그라운드에서 반복적으로 울리는 알람 사운드 재생
/// - 기능: AVAudioSession 설정, 타이머별 알람 사운드 재생 및 정지

import Foundation
import AVFoundation

final class AlarmSoundPlayer {
    static let shared = AlarmSoundPlayer()

    private var players: [UUID: AVAudioPlayer] = [:]
    private let session = AVAudioSession.sharedInstance()

    private init() {}

    /// 특정 타이머에 대한 알람 사운드 재생
    func playAlarmSound(for id: UUID, named soundFileName: String, withExtension ext: String = "caf", loop: Bool = true) {
        guard let url = Bundle.main.url(forResource: soundFileName, withExtension: ext) else {
            #if DEBUG
            print("사운드 파일을 찾을 수 없음: \(soundFileName).\(ext)")
            #endif
            return
        }

        do {
            try session.setCategory(.playback, options: [.duckOthers])
            try session.setActive(true)

            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = loop ? -1 : 0
            player.volume = 1.0
            player.prepareToPlay()
            player.play()

            players[id] = player
        } catch {
            #if DEBUG
            print("사운드 재생 실패: \(error)")
            #endif
        }
    }

    /// 특정 타이머의 사운드 정지
    func stopAlarm(for id: UUID) {
        if let player = players[id] {
            player.stop()
            players.removeValue(forKey: id)
        }

        if players.isEmpty {
            try? session.setActive(false)
        }
    }

    /// 모든 타이머의 사운드 정지
    func stopAll() {
        for (_, player) in players {
            player.stop()
        }
        players.removeAll()
        try? session.setActive(false)
    }

    /// 현재 재생 중인지 확인 (옵션)
    func isPlaying(for id: UUID) -> Bool {
        return players[id]?.isPlaying ?? false
    }
}
