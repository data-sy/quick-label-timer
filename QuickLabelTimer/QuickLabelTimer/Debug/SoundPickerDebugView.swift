// SoundPickerDebugView.swift

/// 시스템 기본 알림 사운드를 테스트하기 위한 디버그용 화면
///
/// - 사용 목적: 3초 간격 알림에 어울리는 사운드를 찾기 위해, 다양한 시스템 사운드를 직접 들어보고 선택

import SwiftUI
import UserNotifications
import AVFoundation // 1. 사운드 파일 길이를 측정하기 위해 AVFoundation을 import합니다.

struct SoundPickerDebugView: View {
    
    var body: some View {
        NavigationStack {
            List(DebugSound.allCases) { sound in
                Button(action: {
                    playSound(sound)
                }) {
                    HStack {
                        Text(sound.displayName)
                        Spacer()
                        // 3. 각 사운드의 길이를 가져와서 표시합니다.
                        Text(getSoundDuration(for: sound))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Image(systemName: "play.circle")
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("사운드 디버그 뷰")
            .onAppear(perform: requestNotificationPermission)
        }
    }
    
    // 2. AVFoundation을 사용하여 사운드 파일의 길이를 가져오는 함수
    private func getSoundDuration(for sound: DebugSound) -> String {
        guard sound != .default else { return "N/A" }

        // 시스템 사운드가 저장된 경로
        let soundURL = URL(fileURLWithPath: "/System/Library/Audio/UISounds/\(sound.rawValue)")
        
        do {
            // AVURLAsset을 사용해 오디오 파일의 정보를 읽어옵니다.
            let asset = AVURLAsset(url: soundURL)
            // duration 속성에서 CMTime 값을 가져와 초(seconds)로 변환합니다.
            let durationInSeconds = CMTimeGetSeconds(asset.duration)
            // 소수점 둘째 자리까지 표시하도록 포맷팅합니다.
            return String(format: "%.2fs", durationInSeconds)
        } catch {
            // 파일을 찾을 수 없는 등 오류가 발생하면 "N/A"를 반환합니다.
            return "N/A"
        }
    }
    
    /// 로컬 알림을 보내 사운드를 재생하는 함수
    private func playSound(_ sound: DebugSound) {
        let content = UNMutableNotificationContent()
        content.title = "알림 테스트"
        content.body = "'\(sound.displayName)' 사운드입니다."
        content.sound = sound.notificationSound

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// 앱 시작 시 알림 권한을 요청하는 함수
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
}

#Preview {
    SoundPickerDebugView()
}