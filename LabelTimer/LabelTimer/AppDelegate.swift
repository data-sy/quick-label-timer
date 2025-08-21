//
//  AppDelegate.swift
//  LabelTimer
//
//  Created by 이소연 on 8/13/25.
//
/// 앱의 생명주기 이벤트를 관리하고, 앱 시작 시 필요한 전역 설정을 초기화하는 클래스
///
/// - 사용 목적: 앱 실행에 필요한 오디오 세션, 전역 UI, 알림 권한 등을 초기화

import UIKit
import AVFoundation

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var notifDelegate: LocalNotificationDelegate?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        setupAudioSession()

        UIPageControl.appearance().currentPageIndicatorTintColor = .label
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray4

        NotificationUtils.requestAuthorization()

        let delegate = LocalNotificationDelegate()
        UNUserNotificationCenter.current().delegate = delegate
        self.notifDelegate = delegate

        return true
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            /*
             [AVAudioSession.CategoryOptions]

             - []: 다른 앱 소리 중지 (알람)
             - .mixWithOthers: 다른 앱 소리와 함께 재생 (게임, 사운드보드)
             - .duckOthers: 다른 앱 소리 볼륨 줄임 (내비게이션 안내)
             - .allowBluetooth: 블루투스 기기로 소리 전송
             - .defaultToSpeaker: 이어폰 연결 시에도 스피커로 출력 (알람)
             - .interruptSpokenAudioAndMixWithOthers: 말소리(팟캐스트 등)는 중단, 음악과는 믹싱
            */
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
            print("✅ AVAudioSession is active and set to non-mixing playback.")
        } catch {
            print("🚨 Failed to set up AVAudioSession: \(error)")
        }
    }
}
