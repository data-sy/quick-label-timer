import SwiftUI
import UserNotifications
import AVFoundation

struct NotificationTestView: View {
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing: 16) {
            Text("Notification Test").font(.title2).padding(.top, 12)

            Button("권한 요청") {
                log("권한 요청")
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { g, e in
                    log("권한 결과 granted=\(g) err=\(String(describing: e))")
                }
            }
            Button("melody.caf 확인") {
                if let url = Bundle.main.url(forResource: "melody", withExtension: "caf") {
                    print("[CHECK] found:", url.lastPathComponent)
                    if let f = try? AVAudioFile(forReading: url) {
                        let dur = Double(f.length) / f.processingFormat.sampleRate
                        print("[CHECK] duration ≈", dur, "sec")
                    }
                } else {
                    print("[CHECK][MISS] melody.caf not in main bundle (Target/Copy Bundle Resources 확인)")
                }
            }
            Button("백그라운드 기본음 (5초 뒤)") {
                log("BG default sound 예약")
                scheduleBackgroundAlarm(sound: nil, after: 5)
            }
            Button("백그라운드 멜로디 (5초 뒤)") {
                log("BG melody 예약")
                scheduleBackgroundAlarmTest()
            }
            
            Group {
                Button("Low Buzz (5초 뒤)") { scheduleBackgroundAlarm(sound: .lowBuzz, after: 5) }
                Button("High Buzz (5초 뒤)") { scheduleBackgroundAlarm(sound: .highBuzz, after: 5) }
                Button("Siren (5초 뒤)")    { scheduleBackgroundAlarm(sound: .siren,   after: 5) }
                Button("Melody (5초 뒤)")   { scheduleBackgroundAlarm(sound: .melody,  after: 5) }
            }

            Divider().padding(.vertical, 6)

            Button("해당 테스트 예약 모두 제거") {
                let ids = [AlarmSound.lowBuzz, .highBuzz, .siren, .melody].map { "BGTest_\($0.id)_single" }
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
                print("[BGTest] removed pending ids: \(ids)")
                        }
            
            Button("Pending 덤프") { NotificationDebug.dumpPending() }
            Button("Delivered 덤프") { NotificationDebug.dumpDelivered() }
            Button("모든 예약/표시 제거") { NotificationDebug.clearAll() }

            Spacer()
        }
        .padding()
        .onAppear { log("NotificationTestView onAppear") }
        .onChange(of: scenePhase) { newPhase in log("scenePhase → \(newPhase)") }
    }
}

private func log(_ msg: String) {
    let ts = ISO8601DateFormatter().string(from: Date())
    print("[\(ts)][NotificationTestView] \(msg)")
}

// MARK: - 알림 예약

// 1. 기본음 테스트 - 성공!
private func scheduleBackgroundAlarm(sound: AlarmSound?, after seconds: TimeInterval) {
    let content = UNMutableNotificationContent()
    content.title = "백그라운드 사운드 테스트"
    content.body  = "사운드: \(sound?.displayName ?? "기본음")"

    if let s = sound, s != .none {
        let name = "\(s.fileName).\(s.fileExtension)"
        if Bundle.main.url(forResource: s.fileName, withExtension: s.fileExtension) == nil {
            log("[WARN] 파일 없음: \(name) (Target Membership 확인)")
        }
        content.sound = UNNotificationSound(named: .init(name))
    } else {
        content.sound = .default // 기본 시스템 사운드
    }

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
    let req = UNNotificationRequest(identifier: "BGTest_\(UUID().uuidString)", content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(req) { err in
        if let err = err { log("예약 실패: \(err)") }
        else { log("예약 완료: \(seconds)s 뒤, sound=\(sound?.displayName ?? "default")") }
    }
}


// 2. 5초 뒤 특정(melody) 알람 울리기 함수 - 성공!
func scheduleBackgroundAlarmTest() {
    let sound = AlarmSound.lowBuzz
    let fileName = sound.fileName
    let fileExt  = sound.fileExtension

    func ts() -> String { ISO8601DateFormatter().string(from: Date()) }
    print("[\(ts())][BGTest] START sound=\(sound.displayName) file=\(fileName).\(fileExt)")

    // 0) 현재 알림 설정 덤프 (사운드 OFF 여부 확인)
    UNUserNotificationCenter.current().getNotificationSettings { s in
        print("""
        [\(ts())][BGTest][Settings] auth=\(s.authorizationStatus.rawValue) \
        alert=\(s.alertSetting.rawValue) sound=\(s.soundSetting.rawValue) \
        timeSensitive=\(s.timeSensitiveSetting.rawValue) critical=\(s.criticalAlertSetting.rawValue)
        """)
    }

    // 1) 파일 존재/길이/포맷 확인
    if let url = Bundle.main.url(forResource: fileName, withExtension: fileExt) {
        print("[\(ts())][BGTest] file found: \(url.lastPathComponent)")
        do {
            let af = try AVAudioFile(forReading: url)
            let dur = Double(af.length) / af.processingFormat.sampleRate
            print("[\(ts())][BGTest] duration≈\(String(format: "%.2f", dur))s, format=\(af.processingFormat)")
            if dur > 30 {
                print("[\(ts())][BGTest][WARN] duration > 30s → local notification may be silent")
            }
        } catch {
            print("[\(ts())][BGTest][ERROR] AVAudioFile read failed: \(error)")
        }
    } else {
        print("[\(ts())][BGTest][MISS] \(fileName).\(fileExt) not in main bundle (Target/Copy Bundle Resources 확인)")
    }

    // 2) 알림 콘텐츠
    let content = UNMutableNotificationContent()
    content.title = "백그라운드 사운드 테스트"
    content.body  = "사운드: \(sound.displayName)"
    if sound != .none {
        content.sound = UNNotificationSound(named: .init("\(fileName).\(fileExt)"))
    } else {
        content.sound = nil
    }

    // 3) 트리거/요청
    let fireIn: TimeInterval = 5
    let expected = Date().addingTimeInterval(fireIn)
    let fireAt = ISO8601DateFormatter().string(from: expected)
    let id = "BGTest_\(UUID().uuidString)"
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: fireIn, repeats: false)
    let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(req) { err in
        if let err = err {
            print("[\(ts())][BGTest][ERROR] add failed: \(err)")
        } else {
            print("[\(ts())][BGTest] added id=\(id) fireAt≈\(fireAt) sound=\(sound.displayName)")
            // 예약된 목록 간단 확인
            UNUserNotificationCenter.current().getPendingNotificationRequests { reqs in
                let hits = reqs.filter { $0.identifier == id }
                print("[\(ts())][BGTest] pending contains id? \(hits.isEmpty ? "NO" : "YES") (total=\(reqs.count))")
            }
        }
    }

    // 4) 도착 후 결과 덤프(참고: 기기 잠금에서 울린 뒤, 해제하고 콘솔 확인)
    DispatchQueue.main.asyncAfter(deadline: .now() + fireIn + 3) {
        UNUserNotificationCenter.current().getDeliveredNotifications { notis in
            let hit = notis.first { $0.request.identifier == id }
            if let n = hit {
                let deliveredAt = ISO8601DateFormatter().string(from: n.date)
                print("[\(ts())][BGTest] DELIVERED id=\(id) at \(deliveredAt)")
            } else {
                print("[\(ts())][BGTest] DELIVERED not found for id=\(id) (아직 잠금 화면/알림센터에 있을 수 있음)")
            }
        }
    }
}

// 3. n초 뒤 선택한 알람 울리기 함수 (AlarmSound 인자로 받음) - 성공!
func scheduleBackgroundAlarm(sound: AlarmSound, after seconds: TimeInterval = 5) {
    let file = "\(sound.fileName).\(sound.fileExtension)"
    let id   = "BGTest_\(sound.id)_single"   // 사운드별 고정 id → 중복 예약 방지

    // 0) 기존 동일 사운드 예약 제거 (겹침 방지)
    UNUserNotificationCenter.current()
        .removePendingNotificationRequests(withIdentifiers: [id])

    // 1) 파일 존재 간단 확인 (로그)
    if sound != .none,
       Bundle.main.url(forResource: sound.fileName, withExtension: sound.fileExtension) == nil {
        print("[BGTest][MISS] \(file) not found (Target Membership/Copy Bundle Resources 확인)")
    }

    // 2) 알림 콘텐츠
    let c = UNMutableNotificationContent()
    c.title = "백그라운드 사운드 테스트"
    c.body  = "사운드: \(sound.displayName)"
    if sound == .none {
        c.sound = nil
    } else {
        c.sound = UNNotificationSound(named: .init(file))
    }

    // 3) 트리거 & 요청
    let trig = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
    let req  = UNNotificationRequest(identifier: id, content: c, trigger: trig)

    UNUserNotificationCenter.current().add(req) { err in
        if let err = err { print("[BGTest][ERR] add failed: \(err)") }
        else { print("[BGTest] add ok → id=\(id) file=\(file) fireIn=\(seconds)s") }
    }
}
