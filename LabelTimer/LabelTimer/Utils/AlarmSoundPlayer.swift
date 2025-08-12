//
//  AlarmSoundPlayer.swift
//  LabelTimer
//
//  Created by 이소연 on 7/25/25.
//
/// 타이머 종료 시 반복 알람(소리,진동)을 재생하는 클래스
///
/// - 사용 목적: 백그라운드에서 반복적으로 울리는 알람 소리/진동 재생

import Foundation
import AVFoundation
import AudioToolbox

protocol AlarmSoundPlayable {
    func play(for id: UUID, sound: AlarmSound, needsVibration: Bool)
    func playDefault(for id: UUID, needsVibration: Bool)
    func stop(for id: UUID)
    func stopAll()
}

final class AlarmSoundPlayer: AlarmSoundPlayable {
    static let shared = AlarmSoundPlayer()

    private var players: [UUID: AVAudioPlayer] = [:]
    private var vibrationTimers: [UUID: Timer] = [:]
    
    private let session = AVAudioSession.sharedInstance()

    private init() {
        // 오디오 세션 설정 (초기화 시점에 한 번 설정함으로써, 백그라운드 전환 등의 상황에서도 오디오 재생이 가능하도록 앱이 항상 준비됨)
        do {
            try session.setCategory(.playback, options: [.duckOthers, .mixWithOthers])
            try session.setActive(true)
        } catch {
            #if DEBUG
            print("오디오 세션 초기화 실패: \(error)")
            #endif
        }
    }
    
    /// 저장된 사용자 기본 사운드로 알람 재생
    func playDefault(for id: UUID, needsVibration: Bool) {
        let soundID = UserDefaults.standard.string(forKey: "defaultSound") ?? AlarmSound.lowBuzz.id
        let sound = AlarmSound.from(id: soundID)
        play(for: id, sound: sound, needsVibration: needsVibration)
    }

    /// 특정 타이머에 대한 알람(소리/진동) 재생
    func play(for id: UUID, sound: AlarmSound, needsVibration: Bool) {
        // 사운드 재생 시도
        if sound != .none {
            let fileName = sound.fileName
            let fileExtension = sound.fileExtension
            // 사운드 파일이 존재하는 경우에만 재생 로직 실행
            if let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.numberOfLoops = -1
                    player.play()
                    players[id] = player
                } catch {
                    #if DEBUG
                    print("사운드 재생 실패: \(error)")
                    #endif
                }
            } else {
                #if DEBUG
                print("사운드 파일을 찾을 수 없음: \(fileName).\(fileExtension)")
                #endif
            }
        }
        // 진동 재생 시도 (사운드 재생 성공 여부와 독립적으로 실행)
        if needsVibration {
            startVibration(for: id)
        }
    }

    /// 특정 타이머의 알람(소리/진동) 정지
    func stop(for id: UUID) {
        // 사운드 정지
        players[id]?.stop()
        players.removeValue(forKey: id)
        // 진동 타이머 정지
        stopVibration(for: id)
    }

    /// 모든 알람(소리/진동) 정지
    func stopAll() {
        // 모든 사운드 정지
        players.values.forEach { $0.stop() }
        players.removeAll()
        // 모든 진동 타이머 정지
        vibrationTimers.values.forEach { $0.invalidate() }
        vibrationTimers.removeAll()
    }
    
    // MARK: - Private Vibration Helpers
    
    /// 반복적인 진동을 시작하는 private 함수
    private func startVibration(for id: UUID) {
        guard vibrationTimers[id] == nil else { return } // 이미 진동 중이면 중복 실행 방지
        
        // 2초마다 진동을 실행하는 타이머 생성
        let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        vibrationTimers[id] = timer
    }
    
    /// 진동을 멈추는 private 함수
    private func stopVibration(for id: UUID) {
        vibrationTimers[id]?.invalidate() // 타이머 무효화
        vibrationTimers.removeValue(forKey: id)
    }
}
