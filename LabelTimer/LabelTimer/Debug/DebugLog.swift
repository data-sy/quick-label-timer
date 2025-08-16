//
//  DebugLog.swift
//  LabelTimer
//
//  Created by 이소연 on 8/17/25.
//
/// 디버그 전용 로깅 유틸리티 모음
///
/// - 사용 목적: 타이머, 저장소, 뷰, 알림 등 각 계층에서의 상태 변화를
///   개발 중 콘솔에 추적하기 위함
///   릴리즈 빌드에는 포함되지 않으며, 디버깅/테스트 시에만 사용됨

import Foundation
import os

#if DEBUG

// MARK: - Loggers

enum DLog {
    static let timer = Logger(subsystem: "LabelTimer", category: "Timer")
    static let repo  = Logger(subsystem: "LabelTimer", category: "Repo")
    static let vm    = Logger(subsystem: "LabelTimer", category: "VM")
    static let notif = Logger(subsystem: "LabelTimer", category: "Notification")
    static let alarm = Logger(subsystem: "LabelTimer", category: "Alarm")
}

// MARK: - Common Helpers

@inline(__always) func ts() -> String {
    ISO8601DateFormatter().string(from: Date())
}

@inline(__always) func short(_ id: UUID) -> String {
    String(id.uuidString.prefix(8))
}

/// 개발 중 가벼운 가드용 Assert (런타임 크래시는 내지 않고 로그만 남김)
@inline(__always) func DAssert(_ condition: @autoclosure () -> Bool,
                               _ message: @autoclosure () -> String,
                               file: StaticString = #fileID,
                               line: UInt = #line) {
    if !condition() {
        os_log("ASSERT FAILED: %{public}@ (%{public}@:%{public}u)", message(), String(describing: file), line)
    }
}

// MARK: - One-liner Logging Shortcuts

/// 타이머 틱(1초 루프) 로그
@inline(__always) func logTick() {
    DLog.timer.debug("[\(ts())] tick()")
}

/// 타이머 0초 도달 로그
@inline(__always) func logReachedZero(id: UUID, scene: String) {
    DLog.timer.info("[\(ts())] reached 0 id=\(short(id)) scene=\(scene)")
}

/// 완료 처리 예약 로그
@inline(__always) func logScheduleCompletion(id: UUID, at deadline: Date) {
    DLog.timer.info("[\(ts())] schedule completion id=\(short(id)) at \(deadline.ISO8601Format())")
}

/// Repo 업데이트 변화 로그 (status/remaining/pending 변화 추적)
@inline(__always) func logRepoUpdate(id: UUID,
                                     oldStatus: String, newStatus: String,
                                     oldRemain: Int, newRemain: Int,
                                     oldPending: Date?, newPending: Date?) {
    let op = oldPending?.ISO8601Format() ?? "nil"
    let np = newPending?.ISO8601Format() ?? "nil"
    DLog.repo.debug("[\(ts())] update id=\(short(id)) status \(oldStatus)->\(newStatus) remaining \(oldRemain)->\(newRemain) pending \(op)->\(np)")
}

/// CMV(카운트다운 뷰) 표시/변경 로그
@inline(__always) func logCMVAppear(id: UUID, pending: Date?) {
    let p = pending?.ISO8601Format() ?? "nil"
    DLog.vm.debug("[\(ts())] CMV appear id=\(short(id)) pendingAt=\(p)")
}

@inline(__always) func logCMVChange(id: UUID, pending: Date?) {
    let p = pending?.ISO8601Format() ?? "nil"
    DLog.vm.debug("[\(ts())] CMV pending change id=\(short(id)) -> \(p)")
}

/// 포그라운드 알림 델리게이트 로그
@inline(__always) func logNotifWillPresent(idString: String) {
    DLog.notif.info("[\(ts())] willPresent id=\(idString)")
}

#endif // DEBUG

/* =========================
   Usage examples (DEBUG만)
   =========================

 // TimerService.swift
 logTick()
 logReachedZero(id: timer.id, scene: String(describing: scenePhase))
 logScheduleCompletion(id: timer.id, at: deadline)

 // TimerRepository.swift (updateTimer 내)
 logRepoUpdate(id: updatedTimer.id,
               oldStatus: old.status.rawValue, newStatus: updatedTimer.status.rawValue,
               oldRemain: old.remainingSeconds, newRemain: updatedTimer.remainingSeconds,
               oldPending: old.pendingDeletionAt, newPending: updatedTimer.pendingDeletionAt)

 // CountdownMessageView.swift
 .onAppear { logCMVAppear(id: timer.id, pending: timer.pendingDeletionAt) }
 .onChange(of: timer.pendingDeletionAt) { new in logCMVChange(id: timer.id, pending: new) }

 // NotificationDelegate.swift
 logNotifWillPresent(idString: notification.request.identifier)

 // 임시 가드
 DAssert(timer.remainingSeconds >= 0, "remainingSeconds should be non-negative")

*/
