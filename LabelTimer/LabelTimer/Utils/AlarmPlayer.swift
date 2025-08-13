//
//  AlarmPlayer.swift
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

protocol AlarmPlayable {
    func play(for id: UUID, sound: AlarmSound, needsVibration: Bool)
    func playDefault(for id: UUID, needsVibration: Bool)
    func stop(for id: UUID)
    func stopAll()
}

final class AlarmPlayer: AlarmPlayable {
    static let shared = AlarmPlayer()

    private var players: [UUID: AVAudioPlayer] = [:]
    private var vibrationTimers: [UUID: Timer] = [:]
    
    private var autoStopTasks: [UUID: DispatchWorkItem] = [:]
    private let autoStopInterval: TimeInterval = 900 // 15분 (900초)
    
    // 싱글톤 패턴을 위한 기본 private init
    private init() {}
    
    /// 저장된 사용자 기본 사운드로 알람 재생
    func playDefault(for id: UUID, needsVibration: Bool) {
        let soundID = UserDefaults.standard.string(forKey: "defaultSound") ?? AlarmSound.lowBuzz.id
        let sound = AlarmSound.from(id: soundID)
        play(for: id, sound: sound, needsVibration: needsVibration)
    }

    /// 특정 타이머에 대한 알람(소리/진동) 재생
    func play(for id: UUID, sound: AlarmSound, needsVibration: Bool) {
        func ts() -> String { ISO8601DateFormatter().string(from: Date()) }
        print("[\(ts())][AlarmPlayer][play] id=\(id.uuidString) sound=\(sound) needsVibration=\(needsVibration)")

        // 1. 소리가 '없음'이 아닐 경우에만 재생 로직 실행
        if sound != .none {
            var urlToPlay: URL?
            
            // 2. 사용자가 선택한 사운드 파일이 있는지 먼저 확인
            if let primaryUrl = Bundle.main.url(forResource: sound.fileName, withExtension: sound.fileExtension) {
                urlToPlay = primaryUrl
            } else {
                // 3. 파일이 없다면, 경고를 출력하고 '대체 사운드'로 전환
                print("[\(ts())][AlarmPlayer][play][WARN] 주 사운드 파일(\(sound.fileName))을 찾을 수 없어 대체 사운드를 재생합니다.")
                urlToPlay = Bundle.main.url(forResource: AlarmSound.fallback.fileName, withExtension: AlarmSound.fallback.fileExtension)
            }

            // 4. 재생할 최종 URL이 확정되었다면 재생 시도
            if let finalUrl = urlToPlay {
                do {                    
                    let player = try AVAudioPlayer(contentsOf: finalUrl)
                    player.numberOfLoops = -1
                    
                    if player.play() {
                        players[id] = player
                        print("[\(ts())][AlarmPlayer][play] AVAudioPlayer started=true")
                        let task = schedule(after: autoStopInterval) { [weak self] in
                            print("⏰ 15분이 지나 알람을 자동으로 끕니다: \(id)")
                            self?.stop(for: id)
                        }
                        autoStopTasks[id] = task
                    } else {
                        print("[\(ts())][AlarmPlayer][play] AVAudioPlayer started=false. Playback failed.")
                        // 5. 재생 실패 시, 로컬의 사운드 알람 기능 사용 (예) 다른 사운드 재생 중)
                        // TODO: 추가 예정
                    }
                } catch {
                    print("[\(ts())][AlarmPlayer][play][ERROR] 세션 설정 또는 플레이어 초기화 실패: \(error)")
                }
            } else {
                print("[\(ts())][AlarmPlayer][play][FATAL] 대체 사운드 파일마저 찾을 수 없습니다.")
            }
        } else {
            print("[\(ts())][AlarmPlayer][play] sound is .none → skip sound")
        }
         
        // 진동 재생 시도 (사운드 재생 성공 여부와 독립적으로 실행)
        if needsVibration {
            print("[\(ts())][AlarmPlayer][play] starting vibration for id=\(id.uuidString)")
            startVibration(for: id)
        } else {
            print("[\(ts())][AlarmPlayer][play] vibration disabled")
        }
    }

    /// 특정 타이머의 알람(소리/진동) 정지
    func stop(for id: UUID) {
        if let task = autoStopTasks.removeValue(forKey: id) {
            cancel(task: task)
            print("🚫 '자동 끄기' 예약을 취소합니다: \(id)")
        }
        // 사운드 정지
        players[id]?.stop()
        players.removeValue(forKey: id)
        // 진동 타이머 정지
        stopVibration(for: id)
    }

    /// 모든 알람(소리/진동) 정지
    func stopAll() {
        autoStopTasks.values.forEach { cancel(task: $0) }
        autoStopTasks.removeAll()
        print("🚫 모든 '자동 끄기' 예약을 취소합니다.")
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
