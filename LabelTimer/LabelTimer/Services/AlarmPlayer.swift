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
    func playCustomSound(for id: UUID, sound: AlarmSound)
    func playContinuousVibration(for id: UUID)
    func playSystemSound()
    func playSingleVibration()
    func stop(for id: UUID)
    func stopAll()
}

final class AlarmPlayer: AlarmPlayable {
    static let shared = AlarmPlayer()

    private var players: [UUID: AVAudioPlayer] = [:]
    private var feedbackPlayers: [UUID: AVAudioPlayer] = [:]
    private var vibrationTimers: [UUID: Timer] = [:]
    private var autoStopTasks: [UUID: DispatchWorkItem] = [:]
    private let autoStopInterval: TimeInterval = 900 // 15분 (900초)
    
    // 싱글톤 패턴을 위한 기본 private init
    private init() {}
    
    // MARK: - Public Play Sound Methods

    /// 커스텀 알람(소리/진동) 재생
    func playCustomSound(for id: UUID, sound: AlarmSound) {
        func ts() -> String { ISO8601DateFormatter().string(from: Date()) }
        print("[\(ts())][AlarmPlayer][play] id=\(id.uuidString) sound=\(sound)")

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
                    /*
                     player.numberOfLoops 프로퍼티 설명
                     
                     오디오 재생이 끝난 후 반복될 횟수 설정
                     - 0 (기본값): 반복 없이 총 1회만 재생
                     - 양수(n): 기본 재생 후 n번 더 반복하여 총 n+1회 재생 (예: 1을 입력하면 총 2회 재생)
                     - -1: stop() 메서드가 호출될 때까지 무한 반복
                    */
//                    player.numberOfLoops = -1
                    player.numberOfLoops = 0
                    
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
    }
    
    /// 시스템 사운드 재생
    /// - 실제 iOS 시스템 사운드가 아님
    /// - 앱 번들에 포함된 짧은 음원을 재생해 시스템 사운드와 유사한 효과를 냄
    func playSystemSound() {
        // TODO: .feedback 음원 추가 시 교체
        let feedbackSound: AlarmSound = .lowBuzz
        
        guard let url = Bundle.main.url(forResource: feedbackSound.fileName, withExtension: feedbackSound.fileExtension) else {
            print("[AlarmPlayer][playSystemSound] 피드백 사운드 파일을 찾을 수 없습니다.")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = 0
            player.play()
            
            let tempID = UUID()
            feedbackPlayers[tempID] = player
            
            DispatchQueue.main.asyncAfter(deadline: .now() + player.duration) { [weak self] in
                self?.feedbackPlayers.removeValue(forKey: tempID)
            }
        } catch {
            print("[AlarmPlayer][playSystemSound] 피드백 플레이어 생성 실패: \(error)")
        }
    }
    
    // MARK: - Public Vibration Methods

    // 연속 진동 재생
    func playContinuousVibration(for id: UUID) {
        guard vibrationTimers[id] == nil else { return } // 이미 진동 중이면 중복
        
        // n초마다 진동을 실행하는 타이머 생성
        let timer = Timer.scheduledTimer(withTimeInterval: 1.7, repeats: true) { _ in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        vibrationTimers[id] = timer
    }
    
    /// 1회성 진동 재생
    func playSingleVibration() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    // MARK: - Stop Methods

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

    /// 모든 타이머의 알람(소리/진동) 정지
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
    
    /// 진동을 멈추는 private 함수
    private func stopVibration(for id: UUID) {
        vibrationTimers[id]?.invalidate() // 타이머 무효화
        vibrationTimers.removeValue(forKey: id)
    }
}
