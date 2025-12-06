# Notification System Guide

> **Purpose:** Complete reference for the notification scheduling and handling system
>
> **Quick Reference:** See `/CLAUDE.md` for critical patterns

## Overview

QuickLabelTimer uses **iOS Local Notifications** (UserNotifications framework) for timer completion alerts instead of in-app audio playback.

**Key Characteristics:**
- Works when app is backgrounded/suspended
- Respects system Do Not Disturb
- Lower power consumption
- System-managed audio interruptions
- **Limitation:** 64 pending notifications per app (iOS constraint)

---

## Notification ID Strategy

### Format

```
"{timerId}_{index}"
```

**Examples:**
- `"550E8400-E29B-41D4-A716-446655440000_0"` - First notification
- `"550E8400-E29B-41D4-A716-446655440000_1"` - Second notification
- `"550E8400-E29B-41D4-A716-446655440000_11"` - 12th notification

### Why This Format?

**Batch Cancellation:**
```swift
// Cancel all notifications for a timer
NotificationUtils.cancelNotifications(withPrefix: timerId.uuidString)

// Internally uses:
let allPending = await UNUserNotificationCenter.current()
    .pendingNotificationRequests()
let matching = allPending.filter { $0.identifier.hasPrefix(prefix) }
// Cancel matching...
```

**Without prefix:**
```swift
// ❌ Would need to cancel individually
for i in 0..<12 {
    UNUserNotificationCenter.current()
        .removePendingNotificationRequests(withIdentifiers: ["\(timerId)_\(i)"])
}
```

---

## Repeating Notification Pattern

### The Problem

**Single notification can fail:**
- User dismisses accidentally
- iOS attention management suppresses it
- System busy (call, alarm, etc.)
- User doesn't notice immediately

**Result:** Timer completed but user doesn't know.

### The Solution

Schedule **12 notifications over 36 seconds** (every 3 seconds) with escalating visual indicators:

```
Timer completes (remaining = 0)
    ↓
t=0s:  "눌러서 알람 끄기 ⏰"      [Notification #0]
t=3s:  "눌러서 알람 끄기 ⏰⏰"    [Notification #1]
t=6s:  "눌러서 알람 끄기 ⏰⏰⏰"  [Notification #2]
...
t=33s: "눌러서 알람 끄기 ⏰⏰⏰⏰⏰⏰⏰⏰⏰⏰⏰⏰" [Notification #11]
```

**Visual escalation:** More clock emojis = more urgent

**Total window:** 36 seconds (gives user ample time to acknowledge)

### Configuration

**Location:** `/Configuration/AppConfig.swift`

```swift
enum AppConfig {
    static let repeatingNotificationCount = 12
    static let notificationRepeatingInterval: TimeInterval = 3.0  // seconds
    static let notificationSystemLimit = 64  // iOS max
}
```

**Math:**
- 12 notifications per timer
- Max 5 concurrent timers
- Total: 60 notifications (within 64 limit ✅)

### Implementation

**Location:** `/Services/TimerService.swift`

```swift
func scheduleRepeatingNotifications(
    for timer: TimerData,
    count: Int,
    interval: TimeInterval,
    sound: UNNotificationSound?
) {
    for i in 0..<count {
        let notificationId = "\(timer.id)_\(i)"
        let triggerInterval = TimeInterval(i) * interval
        let clocks = String(repeating: "⏰", count: i + 1)

        NotificationUtils.scheduleNotification(
            id: notificationId,
            title: "타이머 완료",
            body: "눌러서 알람 끄기 \(clocks)",
            interval: triggerInterval,
            sound: i == 0 ? sound : nil  // Only first has sound
        )
    }
}
```

**Key Detail:** Only first notification has sound to prevent audio spam.

---

## Alarm Notification Policy

### 3-Layer Translation

User-facing options → Technical implementation → iOS system:

```
┌─────────────────────────┐
│   AlarmMode (UI)        │  User selects in Settings/AddTimer
│   - sound               │
│   - vibration           │
│   - silent              │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│   AlarmNotificationPolicy       │  Technical mapping
│   - soundAndVibration           │
│   - vibrationOnly               │
│   - silent                      │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│   UNNotificationSound           │  iOS system API
│   - .default                    │
│   - .defaultCritical            │
│   - nil (no sound)              │
└─────────────────────────────────┘
```

### AlarmMode (User-Facing)

**Location:** `/Models/AlarmMode.swift`

```swift
enum AlarmMode: String, CaseIterable {
    case sound       // "소리" - Sound + vibration
    case vibration   // "진동" - Vibration only
    case silent      // "무음" - Visual banner only
}
```

**Usage:** In UI pickers, settings, timer creation

### AlarmNotificationPolicy (Technical)

**Location:** `/Models/AlarmNotificationPolicy.swift`

```swift
enum AlarmNotificationPolicy {
    case soundAndVibration    // UNNotificationSound.default + haptics
    case vibrationOnly        // Silent audio file + haptics (iOS limitation workaround)
    case silent              // No sound, visual banner only

    static func from(mode: AlarmMode) -> Self {
        switch mode {
        case .sound:      return .soundAndVibration
        case .vibration:  return .vibrationOnly
        case .silent:     return .silent
        }
    }

    func toNotificationSound() -> UNNotificationSound? {
        switch self {
        case .soundAndVibration: return .default
        case .vibrationOnly:     return .defaultCritical  // Forces vibration even in silent mode
        case .silent:            return nil
        }
    }
}
```

**iOS Limitation:** Can't request vibration without sound, so `vibrationOnly` uses critical sound (which forces vibration even in silent mode).

---

## NotificationUtils

**Location:** `/Notifications/NotificationUtils.swift`

Static utility functions for notification operations.

### Request Authorization

```swift
static func requestAuthorization() async {
    do {
        let granted = try await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])

        if granted {
            Logger.notification.info("Notification authorization granted")
        } else {
            Logger.notification.warning("Notification authorization denied")
        }
    } catch {
        Logger.notification.error("Authorization error: \(error)")
    }
}
```

**Called in:** `AppDelegate.application(_:didFinishLaunchingWithOptions:)`

### Schedule Notification

```swift
static func scheduleNotification(
    id: String,
    title: String,
    body: String,
    interval: TimeInterval,
    sound: UNNotificationSound?
) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = sound

    let trigger = UNTimeIntervalNotificationTrigger(
        timeInterval: interval,
        repeats: false
    )

    let request = UNNotificationRequest(
        identifier: id,
        content: content,
        trigger: trigger
    )

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            Logger.notification.error("Failed to schedule: \(error)")
        }
    }
}
```

### Cancel Notifications

```swift
// Cancel all (pending + delivered)
static func cancelNotifications(withPrefix prefix: String) {
    cancelPending(withPrefix: prefix)
    cancelDelivered(withPrefix: prefix)
}

// Cancel only pending
static func cancelPending(withPrefix prefix: String) {
    Task {
        let requests = await UNUserNotificationCenter.current()
            .pendingNotificationRequests()

        let matchingIds = requests
            .filter { $0.identifier.hasPrefix(prefix) }
            .map { $0.identifier }

        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: matchingIds)

        Logger.notification.debug("Cancelled \(matchingIds.count) pending notifications")
    }
}

// Cancel only delivered (in notification center)
static func cancelDelivered(withPrefix prefix: String) {
    Task {
        let notifications = await UNUserNotificationCenter.current()
            .deliveredNotifications()

        let matchingIds = notifications
            .filter { $0.request.identifier.hasPrefix(prefix) }
            .map { $0.request.identifier }

        UNUserNotificationCenter.current()
            .removeDeliveredNotifications(withIdentifiers: matchingIds)

        Logger.notification.debug("Cancelled \(matchingIds.count) delivered notifications")
    }
}
```

**Critical:** Always cancel both pending AND delivered to fully clean up.

---

## LocalNotificationDelegate

**Location:** `/Notifications/LocalNotificationDelegate.swift`

Handles notification events when app is running.

### Setup

```swift
// In AppDelegate.application(_:didFinishLaunchingWithOptions:)
let delegate = LocalNotificationDelegate()
UNUserNotificationCenter.current().delegate = delegate
```

### Foreground Reception

**Problem:** By default, notifications don't show when app is in foreground.

**Solution:** Implement delegate to selectively show:

```swift
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification
) async -> UNNotificationPresentationOptions {
    let id = notification.request.identifier

    // Only show first notification (index 0)
    if id.hasSuffix("_0") {
        return [.banner, .sound]
    } else {
        // Suppress subsequent notifications to prevent spam
        return []
    }
}
```

**Why suppress subsequent?**
- If user is in app, they can see the timer completed in UI
- 12 notifications firing every 3 seconds would be annoying
- First notification is enough to alert user

**Edge case:** If user backgrounds app after first notification, subsequent notifications fire normally (delegate only suppresses when app is foreground).

### User Interaction

**Called when:** User taps notification (app in any state)

```swift
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse
) async {
    let id = response.notification.request.identifier

    // Extract timer ID from notification ID
    let timerIdPrefix = id.split(separator: "_").first.map(String.init) ?? ""

    // User acknowledged → cancel all related notifications
    NotificationUtils.cancelNotifications(withPrefix: timerIdPrefix)

    Logger.notification.info("User dismissed notifications for timer: \(timerIdPrefix)")
}
```

**Why cancel all?**
- User tapped notification = acknowledged timer completion
- No need to continue nagging with remaining notifications
- Keeps notification center clean

---

## Notification Lifecycle Example

### Scenario: User creates 5-minute timer

**1. Timer Created:**
```swift
// TimerService.addTimer()
let timer = TimerData(...)
timerRepository.addTimer(timer)

// Schedule 12 notifications
scheduleRepeatingNotifications(
    for: timer,
    count: 12,
    interval: 3.0,
    sound: .default
)
```

**iOS has 12 pending notifications:**
- `{timerId}_0` → fires at `endDate + 0s`
- `{timerId}_1` → fires at `endDate + 3s`
- ...
- `{timerId}_11` → fires at `endDate + 33s`

**2. Timer Completes (5 minutes later):**

**App in foreground:**
```
t=0s:  Notification fires
       ↓
       LocalNotificationDelegate.willPresent() called
       ↓
       Returns [.banner, .sound] (because index = 0)
       ↓
       User sees banner + hears sound
       ↓
       User taps banner
       ↓
       LocalNotificationDelegate.didReceive() called
       ↓
       Cancels all 12 notifications
       ↓
       Remaining 11 notifications never fire
```

**App in background:**
```
t=0s:  Notification fires → Banner shows
t=3s:  Notification fires → Banner updates
t=6s:  Notification fires → Banner updates
...
t=12s: User taps notification
       ↓
       App opens (if not already open)
       ↓
       LocalNotificationDelegate.didReceive() called
       ↓
       Cancels remaining notifications
```

**User ignores all notifications:**
```
t=0s:  Notification fires
t=3s:  Notification fires
...
t=33s: Last notification fires
t=36s: All 12 notifications delivered
       ↓
       Notifications remain in notification center
       ↓
       User eventually swipes to clear (manual dismissal)
```

**3. User Deletes Timer (Before Completion):**

```swift
// User taps delete button
timerService.removeTimer(id: timerId)
    ↓
    Cancels notifications first
    ↓
    NotificationUtils.cancelNotifications(withPrefix: timerId.uuidString)
    ↓
    Removes from repository
```

**Result:** All 12 pending notifications cancelled, won't fire.

---

## Notification Count Management

### The 64-Notification Limit

**iOS Constraint:** Max 64 pending notifications per app, system silently drops excess.

**QuickLabelTimer Math:**
- 12 notifications per timer
- Max 5 concurrent timers
- Total: 60 notifications (✅ within limit)

**Potential Issues:**
- If user creates 6th timer: `6 × 12 = 72` notifications (❌ exceeds limit!)
- iOS drops 8 oldest notifications silently
- Result: Some timers won't have full 12-notification sequence

**Current Protection:**
```swift
// In TimerService.addTimer()
guard timerRepository.timers.count < AppConfig.maxConcurrentTimers else {
    return false  // Reject 6th timer
}
```

**Future Enhancement:** Dynamic notification count based on available slots:
```swift
let pendingCount = await UNUserNotificationCenter.current()
    .pendingNotificationRequests().count

let availableSlots = AppConfig.notificationSystemLimit - pendingCount
let notificationsPerTimer = min(12, availableSlots / (timers.count + 1))

// Schedule only what fits
scheduleRepeatingNotifications(for: timer, count: notificationsPerTimer, ...)
```

---

## Notification Cleanup Strategy

### When to Cancel

**1. Timer Removed (any state):**
```swift
func removeTimer(id: UUID) -> TimerData? {
    NotificationUtils.cancelNotifications(withPrefix: id.uuidString)  // ← First
    return timerRepository.removeTimer(byId: id)
}
```

**2. User Taps Notification:**
```swift
// LocalNotificationDelegate.didReceive()
NotificationUtils.cancelNotifications(withPrefix: timerIdPrefix)
```

**3. App Activation (Reconciliation):**
```swift
// TimerService.updateScenePhase(.active)
let completedTimers = timerRepository.timers.filter { $0.status == .completed }

runActivationCleanup(for: completedTimers) {
    // Cancel orphaned notifications for completed timers
    for timer in completedTimers {
        NotificationUtils.cancelNotifications(withPrefix: timer.id.uuidString)
    }
}
```

**Why needed:** If app was killed while timer was completing, notifications might still be pending.

### Cleanup on Scene Activation

**Debounced:** 0.8 seconds to prevent rapid cleanup on quick background/foreground cycles.

```swift
private var lastActivationCleanup: Date?

func shouldRunActivationCleanup(now: Date) -> Bool {
    guard let last = lastActivationCleanup else { return true }
    return now.timeIntervalSince(last) > 0.8  // 800ms debounce
}
```

---

## Testing Notifications

### Check Pending Notifications

```swift
// In Xcode debug console
let center = UNUserNotificationCenter.current()
let pending = await center.pendingNotificationRequests()
print("Pending: \(pending.count)")
pending.forEach { print($0.identifier) }
```

### Check Delivered Notifications

```swift
let delivered = await center.deliveredNotifications()
print("Delivered: \(delivered.count)")
delivered.forEach { print($0.request.identifier) }
```

### Force Trigger Notification (Testing)

```swift
// Schedule immediate notification
NotificationUtils.scheduleNotification(
    id: "test",
    title: "Test",
    body: "Testing",
    interval: 1.0,  // 1 second from now
    sound: .default
)
```

---

## Common Issues & Solutions

### Issue 1: Notifications Don't Fire

**Symptoms:** Timer completes but no notification appears.

**Checklist:**
- [ ] Authorization granted? Check in Settings > Notifications > QuickLabelTimer
- [ ] Notifications scheduled? Check pending count
- [ ] Correct ID format? Should be `"{UUID}_{index}"`
- [ ] App not suspended? iOS may delay notifications if system is busy

**Debug:**
```swift
// Check if notifications were scheduled
let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
let matching = pending.filter { $0.identifier.hasPrefix(timerId.uuidString) }
print("Found \(matching.count) notifications for timer")
```

### Issue 2: Notifications Fire After Timer Deleted

**Symptoms:** Notification appears for deleted timer.

**Cause:** Forgot to cancel notifications before removing timer.

**Solution:**
```swift
// ✅ ALWAYS cancel first
NotificationUtils.cancelNotifications(withPrefix: timerId.uuidString)
timerRepository.removeTimer(byId: timerId)

// ❌ WRONG (notifications orphaned)
timerRepository.removeTimer(byId: timerId)
```

### Issue 3: Too Many Notifications

**Symptoms:** User gets spammed with notifications.

**Cause:** Delegate not suppressing foreground notifications.

**Check:**
```swift
// In LocalNotificationDelegate.willPresent()
if id.hasSuffix("_0") {
    return [.banner, .sound]  // Show first only
} else {
    return []  // ✅ Suppress rest
}
```

### Issue 4: Notifications Don't Cancel on Tap

**Symptoms:** User taps notification but more keep firing.

**Cause:** Delegate not cancelling on user interaction.

**Check:**
```swift
// In LocalNotificationDelegate.didReceive()
NotificationUtils.cancelNotifications(withPrefix: timerIdPrefix)  // ✅ Must be here
```

---

## Performance & Battery Impact

### Notification Scheduling

**Cost:** ~5ms per notification scheduled

**Total for timer:** `12 notifications × 5ms = 60ms` (imperceptible)

### Notification Firing

**Cost:** System-managed, minimal impact

**Battery:** Negligible (system optimizes notification delivery)

### Cleanup

**Cost:** `await getPendingNotificationRequests()` can take 50-100ms if many pending

**Optimization:** Debounce cleanup to avoid repeated calls

---

## Summary

**Key Principles:**

1. **ID Format:** `"{timerId}_{index}"` enables batch cancellation
2. **Repeating Pattern:** 12 notifications over 36 seconds for reliability
3. **Always Cancel:** Before removing timer, on user dismissal, on app activation
4. **Suppress Spam:** Delegate suppresses foreground notifications (except first)
5. **Respect Limit:** Max 60 notifications (5 timers × 12) within iOS 64 limit

**Critical Rules:**

🚨 **NEVER** schedule without cancelling on removal
🚨 **NEVER** exceed 64 pending notifications
🚨 **ALWAYS** use prefix-based batch cancellation
🚨 **ALWAYS** handle both pending AND delivered notifications

**Files Summary:**
- `/Notifications/NotificationUtils.swift` - Utility functions
- `/Notifications/LocalNotificationDelegate.swift` - Foreground/interaction handling
- `/Models/AlarmNotificationPolicy.swift` - Sound policy mapping
- `/Services/TimerService.swift` - Scheduling orchestration
- `/Configuration/AppConfig.swift` - Notification constants
