//
//  NotificationDebug.swift
//  LabelTimer
//
//  Created by 이소연 on 8/12/25.
//


import UserNotifications

enum NotificationDebug {
    /// 미발송(예약) 알림 목록 덤프
    static func dumpPending(prefix: String? = nil) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { reqs in
            let filtered = reqs
                .filter { r in
                    guard let p = prefix else { return true }
                    return r.identifier.hasPrefix(p)
                }
                .sorted(by: { lhs, rhs in
                    (nextDate(of: lhs.trigger) ?? .distantFuture) <
                    (nextDate(of: rhs.trigger) ?? .distantFuture)
                })

            print("PENDING=\(filtered.count)")
            for r in filtered {
                let tStr = triggerDescription(r.trigger)
                let ntd  = nextDate(of: r.trigger)
                let date = ntd.map { ISO8601DateFormatter().string(from: $0) } ?? "nil"
                let sound = (r.content.sound as? UNNotificationSound)?.description ?? "\(String(describing: r.content.sound))"
                print("• id=\(r.identifier)  fireAt=\(date)  trigger=\(tStr)  sound=\(sound)")
            }
        }
    }

    /// 이미 표시된(딜리버드) 알림 목록 덤프
    static func dumpDelivered(prefix: String? = nil) {
        UNUserNotificationCenter.current().getDeliveredNotifications { notis in
            let filtered = notis.filter { n in
                guard let p = prefix else { return true }
                return n.request.identifier.hasPrefix(p)
            }
            print("DELIVERED=\(filtered.count)")
            for n in filtered {
                let id = n.request.identifier
                let date = ISO8601DateFormatter().string(from: n.date)
                let tStr = triggerDescription(n.request.trigger)
                let sound = (n.request.content.sound as? UNNotificationSound)?.description
                    ?? "\(String(describing: n.request.content.sound))"
                print("• id=\(id)  deliveredAt=\(date)  trigger=\(tStr)  sound=\(sound)")
            }
        }
    }

    /// 특정 prefix로 예약/발송 모두 제거
    static func clearAll(prefix: String? = nil) {
        // 예약 제거
        UNUserNotificationCenter.current().getPendingNotificationRequests { reqs in
            let ids = reqs
                .map(\.identifier)
                .filter { id in
                    guard let p = prefix else { return true }
                    return id.hasPrefix(p)
                }
            UNUserNotificationCenter.current()
                .removePendingNotificationRequests(withIdentifiers: ids)
            print("Removed PENDING ids: \(ids)")
        }
        // 발송된 알림 제거(알림센터에서 숨김)
        UNUserNotificationCenter.current()
            .removeAllDeliveredNotifications()
        print("Removed all DELIVERED notifications")
    }

    // MARK: - Helpers

    private static func triggerDescription(_ trigger: UNNotificationTrigger?) -> String {
        switch trigger {
        case let t as UNTimeIntervalNotificationTrigger:
            return "timeInterval=\(t.timeInterval)s repeats=\(t.repeats)"
        case let t as UNCalendarNotificationTrigger:
            return "calendar nextDate? \(String(describing: t.nextTriggerDate())) repeats=\(t.repeats)"
        case let t as UNLocationNotificationTrigger:
            return "location repeats=\(t.repeats)"
        default:
            return "unknown"
        }
    }

    private static func nextDate(of trigger: UNNotificationTrigger?) -> Date? {
        if let t = trigger as? UNTimeIntervalNotificationTrigger {
            // 대략적인 예상치(정확한 “예약 시각” 추정용)
            return Date().addingTimeInterval(t.timeInterval)
        }
        if let t = trigger as? UNCalendarNotificationTrigger {
            return t.nextTriggerDate()
        }
        return nil
    }
    func debugNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { s in
            print("""
            [NotifSettings]
            authorizationStatus=\(s.authorizationStatus.rawValue)
            alertSetting=\(s.alertSetting.rawValue)
            soundSetting=\(s.soundSetting.rawValue)   // 🔴 여기 OFF면 소리 안 남
            announcementSetting=\(s.announcementSetting.rawValue)
            timeSensitiveSetting=\(s.timeSensitiveSetting.rawValue)
            criticalAlertSetting=\(s.criticalAlertSetting.rawValue)
            """)
            
            // 참고: 기기 측 상태 (무음 스위치/볼륨/포커스)는 코드로 못 읽음 → 사람이 확인
        }
    }
}
