//
//  SoundPickerView.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/1/25.
//
/// 사용자가 타이머 종료 시 재생할 기본 사운드를 선택하는 뷰
///
/// - 사용 목적: 사운드 목록 중 기본 알람음을 선택하고, 즉시 미리 듣기 가능하도록 제공

import SwiftUI
import AVFoundation
import OSLog
import FirebaseCrashlytics

struct SoundPickerView: View {
    @AppStorage("defaultSound") private var selectedSoundID: String = AlarmSound.default.id

    private let logger = Logger.withCategory("SoundPickerView")
    
    private let sounds = AlarmSound.selectableSounds
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        List(sounds) { sound in
            HStack {
                Text(sound.displayName)
                Spacer()
                if sound.id == selectedSoundID {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedSoundID = sound.id
                playSound(for: sound)
            }
        }
        .navigationTitle("기본 사운드")
    }

    private func playSound(for sound: AlarmSound) {
            if audioPlayer?.isPlaying == true {
                audioPlayer?.stop()
            }
            guard let url = sound.playableURL else {
                logger.info("'\(sound.displayName)' has no local file to play for preview.")
                return
            }

            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                // (기본 1회 + 반복 9회) = 총 10회 재생
                audioPlayer?.numberOfLoops = 9
                audioPlayer?.play()
            } catch {
                #if DEBUG
                logger.error("⚠️ Failed to play sound: \(error.localizedDescription)")
                Crashlytics.crashlytics().record(error: error)
                #endif
            }
        }
}

#Preview {
    SoundPickerView()
}
