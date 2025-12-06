# QuickLabelTimer - Developer Guide

> **Purpose:** This document serves as the complete reference for developing QuickLabelTimer with Claude Code. A junior iOS developer should be able to safely contribute to this project by reading only this document.

## Quick Start Guide

### For New Contributors

1. **Understand the Core Architecture** → Read Section 1 (MVVM Pattern)
2. **Learn the Data Flow** → Read Section 2 (Timer Management)
3. **See Practical Examples** → Read Section 18 (Common Development Tasks)
4. **Avoid Common Pitfalls** → Read Section 19 (Critical Rules & Warnings)

### Technology Stack
- **SwiftUI** - Declarative UI framework
- **Combine** - Reactive programming for state management
- **UserDefaults** - Data persistence (JSON-encoded)
- **UserNotifications** - Local notifications
- **OSLog** - Structured logging
- **Firebase** - Crash reporting (Crashlytics)

**Minimum iOS Version:** iOS 16.0
**Target Devices:** iPhone only (not iPad)

---

## 1. Architecture Pattern: MVVM + Service/Repository

The app follows a strict **MVVM architecture** with additional Service and Repository layers:

```
┌─────────────────────────────────────────────────────────────────┐
│                     VIEWS (SwiftUI)                             │
│         Pure presentational components only                     │
│         NO business logic, NO direct data manipulation          │
└──────────────────────────┬──────────────────────────────────────┘
                           │ @EnvironmentObject / @Published
                           │ (One-way data binding)
┌──────────────────────────▼──────────────────────────────────────┐
│                  VIEWMODELS (@MainActor)                        │
│  • AddTimerViewModel - Timer creation form                      │
│  • RunningListViewModel - Running timers list                   │
│  • FavoriteListViewModel - Presets list                         │
│  • SettingsViewModel - App settings                             │
│  • EditPresetViewModel - Preset editing                         │
│                                                                  │
│  Responsibilities:                                               │
│  ✓ Handle user interactions (button taps, input)                │
│  ✓ Manage UI state (alerts, selection)                          │
│  ✓ Transform data for display                                   │
│  ✗ NO direct data persistence                                   │
│  ✗ NO timer state manipulation                                  │
└──────────────────────────┬──────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
┌───────▼────────┐  ┌──────▼─────────┐  ┌───▼──────────────┐
│ TimerService   │  │ TimerRepo      │  │ PresetRepo       │
│ (@MainActor)   │  │ (@MainActor)   │  │ (@MainActor)     │
│                │  │                │  │                  │
│ Business logic │  │ CRUD + persist │  │ CRUD + persist   │
│ Orchestration  │  │ Single source  │  │ Single source    │
│ Notifications  │  │ of truth       │  │ of truth         │
└──────┬─────────┘  └────┬───────────┘  └────┬─────────────┘
       │                 │                    │
       └─────────────────┼────────────────────┘
                         │
              ┌──────────▼─────────────┐
              │    DATA MODELS         │
              │  (Immutable structs)   │
              │                        │
              │  • TimerData           │
              │  • TimerPreset         │
              │  • Interaction State   │
              └────────────────────────┘
```

### Layer Responsibilities

| Layer | Responsibilities | What NOT to do |
|-------|-----------------|----------------|
| **View** | Display data, dispatch user actions | No business logic, no data manipulation |
| **ViewModel** | UI state, user interaction handling, data transformation | No persistence, no timer state changes |
| **Service** | Business logic, orchestration, notifications | No UI concerns, no direct persistence |
| **Repository** | CRUD operations, persistence, single source of truth | No business logic, no UI concerns |
| **Model** | Data structures (immutable) | Should be pure data, no logic |

### Critical Architecture Rules

🚨 **NEVER modify TimerData or TimerPreset directly in Views or ViewModels**
- ✅ CORRECT: `timerService.pauseTimer(id: timer.id)`
- ❌ WRONG: `timer.status = .paused` (Will not persist, will break state)

🚨 **NEVER create TimerService or Repository instances in ViewModels**
- ✅ CORRECT: Inject via `init(timerService: any TimerServiceProtocol)`
- ❌ WRONG: `let timerService = TimerService()` (Breaks single instance)

🚨 **ALL UI updates must happen on @MainActor**
- All ViewModels, Services, and Repositories are already `@MainActor`
- If you add async operations, ensure you stay on `@MainActor`

---

## 2. Timer Management System

### Core Data Model: TimerData

**Location:** `/Models/TimerData.swift`

```swift
struct TimerData: Identifiable, Hashable, Codable {
    // IMMUTABLE Configuration (set at creation)
    let id: UUID                      // Unique identifier
    let label: String                 // Display name
    let hours: Int                    // Initial duration
    let minutes: Int
    let seconds: Int
    let isSoundOn: Bool              // Alarm sound enabled
    let isVibrationOn: Bool          // Alarm vibration enabled
    let createdAt: Date              // Creation timestamp
    let presetId: UUID?              // nil = instant timer, non-nil = from preset

    // MUTABLE Runtime State (changes during execution)
    var status: TimerStatus          // .running, .paused, .stopped, .completed
    var endDate: Date                // When timer should reach 0
    var remainingSeconds: Int        // Current countdown value
    var pendingDeletionAt: Date?     // Scheduled deletion time (10-sec countdown)
    var endAction: TimerEndAction    // .preserve or .discard (favorite toggle)
}

enum TimerStatus: String, Codable {
    case running   // Actively counting down
    case paused    // Paused, can be resumed
    case stopped   // User stopped, can be restarted
    case completed // Reached 0, in deletion countdown
}

enum TimerEndAction: String, Codable {
    case preserve  // Save as preset (star icon ON)
    case discard   // Don't save as preset (star icon OFF)

    var isPreserve: Bool { self == .preserve }
}
```

### Timer Lifecycle State Machine

```
┌─────────┐
│ Created │ (status = .running, endDate = now + duration)
└────┬────┘
     │
     ▼
┌──────────┐  pause   ┌─────────┐  resume  ┌──────────┐
│ .running ├─────────►│ .paused ├─────────►│ .running │
└────┬─────┘          └────┬────┘          └────┬─────┘
     │                     │                     │
     │ stop                │ stop                │
     │                     │                     │
     └─────────────────────┴─────────────────────┘
                           │
                           ▼
                     ┌──────────┐  restart  ┌──────────┐
                     │ .stopped ├──────────►│ .running │
                     └──────────┘           └──────────┘

When remaining reaches 0:
┌──────────┐
│ .running │ (remainingSeconds = 0)
└────┬─────┘
     │
     ▼
┌─────────────┐  10-second countdown  ┌─────────┐
│ .completed  ├──────────────────────►│ Deleted │
└─────────────┘  (automatic or manual)└─────────┘
     │
     │ user confirms deletion
     │
     └──────────────────────────────────────────►
```

### Timer Repository: Single Source of Truth

**Location:** `/Repositories/TimerRepository.swift`

```swift
@MainActor
final class TimerRepository: ObservableObject, TimerRepositoryProtocol {
    @Published var timers: [TimerData] = []  // ⚠️ ONLY source of timer data

    // CRUD Operations
    func addTimer(_ timer: TimerData)        // Add and persist
    func getTimer(byId id: UUID) -> TimerData?
    func updateTimer(_ timer: TimerData)     // Update and persist
    func removeTimer(byId id: UUID) -> TimerData?
    func getAllTimers() -> [TimerData]

    // Persistence (automatic)
    private func saveTimers()    // JSONEncoder → UserDefaults
    private func loadTimers()    // UserDefaults → JSONDecoder
}
```

**Key Characteristics:**
- `@Published var timers` automatically notifies ViewModels of changes
- Every mutation triggers `saveTimers()` → UserDefaults
- **Thread Safety:** All methods are `@MainActor` - NEVER access from background thread
- **Single Instance:** Created in App init, shared via `@EnvironmentObject`

**UserDefaults Key:** `"running_timers"`

### Timer Service: Business Logic Orchestrator

**Location:** `/Services/TimerService.swift`

```swift
@MainActor
final class TimerService: ObservableObject, TimerServiceProtocol {
    private let timerRepository: TimerRepositoryProtocol
    private let presetRepository: PresetRepositoryProtocol
    private let completionHandler: TimerCompletionHandler
    private var timer: Timer?  // 1Hz tick loop (Foundation.Timer)

    // CRUD
    func addTimer(label: String, hours: Int, minutes: Int, seconds: Int,
                  isSoundOn: Bool, isVibrationOn: Bool) -> Bool
    func runTimer(from preset: TimerPreset) -> Bool
    func removeTimer(id: UUID) -> TimerData?

    // Control Operations
    func pauseTimer(id: UUID)    // .running → .paused
    func resumeTimer(id: UUID)   // .paused → .running (recalculate endDate)
    func stopTimer(id: UUID)     // .running/.paused → .stopped
    func restartTimer(id: UUID)  // .stopped/.completed → .running (reset to original duration)

    // Completion
    func userDidConfirmCompletion(for timerId: UUID)  // Immediate deletion
    func userDidRequestDelete(for timerId: UUID)      // Immediate deletion

    // Notifications
    func scheduleNotification(for timer: TimerData)
    func scheduleRepeatingNotifications(for timer: TimerData, count: Int, interval: TimeInterval)
    func stopTimerNotifications(for baseId: String)

    // Lifecycle
    func updateScenePhase(_ phase: ScenePhase)  // Handle app foreground/background

    // Other
    func toggleFavorite(for id: UUID) -> Bool   // Toggle endAction
}
```

**Core Mechanism: 1Hz Tick Loop**

```swift
private func startTicking() {
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        Task { @MainActor in
            await self?.tick()
        }
    }
}

private func tick() {
    let now = Date()
    let timers = timerRepository.getAllTimers()

    for timer in timers where timer.status == .running {
        let remaining = max(0, Int(timer.endDate.timeIntervalSince(now)))

        if remaining != timer.remainingSeconds {
            var updated = timer
            updated.remainingSeconds = remaining
            timerRepository.updateTimer(updated)
        }

        if remaining == 0 && timer.status == .running {
            // Trigger completion
            var completed = timer
            completed.status = .completed
            completed.remainingSeconds = 0
            timerRepository.updateTimer(completed)

            startCompletionProcess(for: completed)
        }
    }
}
```

**⚠️ Performance Note:** The 1Hz timer is efficient because:
- Only updates UI when `remainingSeconds` actually changes
- Uses `Date` math (not accumulating errors)
- Automatically pauses when no timers are running

---

## 3. Notifications System

### Architecture Overview

QuickLabelTimer uses **iOS Local Notifications** (not in-app audio) for alarms:

**Benefits:**
✅ Works when app is in background/suspended
✅ Respects system Do Not Disturb settings
✅ Lower power consumption
✅ System handles interruptions (calls, etc.)

**Trade-offs:**
⚠️ Limited to 64 pending notifications per app
⚠️ Cannot guarantee exact delivery timing
⚠️ User can disable notifications in Settings

### Alarm Mode Architecture

**3-Layer Translation:**

```
┌─────────────────────────┐
│   AlarmMode (UI)        │  User selects in UI
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
│   UNNotificationSound           │  iOS system
│   - .default                    │
│   - .defaultCritical            │
│   - nil                         │
└─────────────────────────────────┘
```

**Location:** `/Models/AlarmMode.swift`, `/Models/AlarmNotificationPolicy.swift`

```swift
enum AlarmMode: String, CaseIterable {
    case sound       // "소리" - Sound + vibration
    case vibration   // "진동" - Vibration only
    case silent      // "무음" - Visual banner only
}

enum AlarmNotificationPolicy {
    case soundAndVibration
    case vibrationOnly
    case silent

    static func from(mode: AlarmMode) -> Self {
        switch mode {
        case .sound: return .soundAndVibration
        case .vibration: return .vibrationOnly
        case .silent: return .silent
        }
    }
}
```

### Repeating Notification Pattern

**Problem:** User might dismiss a single notification and forget about the completed timer.

**Solution:** Schedule 12 notifications over 36 seconds (3-second intervals) with escalating visual indicators:

```
Timer Completes (remaining = 0)
    ↓
Schedule 12 Notifications:
    t=0s:  "눌러서 알람 끄기 ⏰"
    t=3s:  "눌러서 알람 끄기 ⏰⏰"
    t=6s:  "눌러서 알람 끄기 ⏰⏰⏰"
    t=9s:  "눌러서 알람 끄기 ⏰⏰⏰⏰"
    ...
    t=33s: "눌러서 알람 끄기 ⏰⏰⏰⏰⏰⏰⏰⏰⏰⏰⏰⏰"
```

**Configuration:**
- `AppConfig.repeatingNotificationCount = 12`
- `AppConfig.notificationRepeatingInterval = 3.0` (seconds)
- Total window: 36 seconds

**Notification ID Format:** `"{timerId}_{index}"`
- Example: `"A1B2C3D4-1234-5678-90AB-CDEF01234567_0"` (first notification)
- Example: `"A1B2C3D4-1234-5678-90AB-CDEF01234567_11"` (12th notification)
- This format enables batch cancellation: `cancelNotifications(withPrefix: timerId.uuidString)`

### Notification Utilities

**Location:** `/Notifications/NotificationUtils.swift`

```swift
enum NotificationUtils {
    // Request authorization (called in AppDelegate)
    static func requestAuthorization() async

    // Schedule single notification
    static func scheduleNotification(
        id: String,
        title: String,
        body: String,
        interval: TimeInterval,
        sound: UNNotificationSound?
    )

    // Batch cancellation
    static func cancelNotifications(withPrefix: String)  // All (pending + delivered)
    static func cancelPending(withPrefix: String)        // Pending only
    static func cancelDelivered(withPrefix: String)      // Delivered only
}
```

**Usage Example:**
```swift
// Schedule repeating notifications
for i in 0..<AppConfig.repeatingNotificationCount {
    let interval = TimeInterval(i) * AppConfig.notificationRepeatingInterval
    let clocks = String(repeating: "⏰", count: i + 1)

    NotificationUtils.scheduleNotification(
        id: "\(timer.id)_\(i)",
        title: "타이머 완료",
        body: "눌러서 알람 끄기 \(clocks)",
        interval: interval,
        sound: sound
    )
}

// Cancel all notifications for a timer
NotificationUtils.cancelNotifications(withPrefix: timer.id.uuidString)
```

### Notification Delegate

**Location:** `/Notifications/LocalNotificationDelegate.swift`

Handles foreground and user interaction:

```swift
class LocalNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    // Called when notification arrives while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        let id = notification.request.identifier

        // Only show first notification (index 0)
        if id.hasSuffix("_0") {
            return [.banner, .sound]
        } else {
            return []  // Suppress subsequent notifications to prevent spam
        }
    }

    // Called when user taps notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let id = response.notification.request.identifier
        let timerIdPrefix = id.split(separator: "_").first.map(String.init) ?? ""

        // User tapped → cancel all related notifications
        NotificationUtils.cancelNotifications(withPrefix: timerIdPrefix)
    }
}
```

**Setup in AppDelegate:**
```swift
func application(_ application: UIApplication,
                didFinishLaunchingWithOptions: [...]) -> Bool {
    NotificationUtils.requestAuthorization()

    let delegate = LocalNotificationDelegate()
    UNUserNotificationCenter.current().delegate = delegate

    return true
}
```

---

## 4. Preset (Favorites) System

### Preset Data Model

**Location:** `/Models/TimerPreset.swift`

```swift
struct TimerPreset: Identifiable, Codable, Hashable {
    let id: UUID
    let label: String
    let hours: Int
    let minutes: Int
    let seconds: Int
    let isSoundOn: Bool
    let isVibrationOn: Bool
    let createdAt: Date

    var lastUsedAt: Date        // Updated when timer runs from this preset
    var isHiddenInList: Bool    // Soft delete flag

    // Computed: total duration in seconds
    var totalSeconds: Int {
        hours * 3600 + minutes * 60 + seconds
    }
}
```

### Preset Repository

**Location:** `/Repositories/PresetRepository.swift`

```swift
@MainActor
final class PresetRepository: ObservableObject, PresetRepositoryProtocol {
    @Published var userPresets: [TimerPreset] = []  // ⚠️ ONLY source of preset data

    // CRUD
    func addPreset(from timer: TimerData) -> Bool
    func addPreset(label: String, hours: Int, minutes: Int, seconds: Int,
                   isSoundOn: Bool, isVibrationOn: Bool) -> Bool
    func updatePreset(_ preset: TimerPreset, label: String, hours: Int,
                      minutes: Int, seconds: Int, isSoundOn: Bool,
                      isVibrationOn: Bool) -> Bool
    func deletePreset(_ preset: TimerPreset)  // Soft delete (sets isHiddenInList)

    // Visibility (soft delete)
    func hidePreset(withId id: UUID)
    func showPreset(withId id: UUID)

    // Queries
    var allPresets: [TimerPreset]              // All (including hidden)
    var visiblePresets: [TimerPreset]          // Only isHiddenInList = false
    var visiblePresetsCount: Int
}
```

**Limit:** Maximum 20 presets
**UserDefaults Key:** `"user_presets"`

### Timer → Preset Conversion

When a timer completes, it can be saved as a preset based on `endAction`:

```swift
// In TimerCompletionHandler
switch (timer.presetId, timer.endAction) {

case (.none, .preserve):
    // Instant timer with favorite toggle ON
    // → Create new preset
    presetRepository.addPreset(from: timer)
    timerService.removeTimer(id: timer.id)

case (.none, .discard):
    // Instant timer with favorite toggle OFF
    // → Just delete
    timerService.removeTimer(id: timer.id)

case (.some(let presetId), .preserve):
    // Preset-based timer with favorite toggle ON
    // → Just delete timer (preset already exists)
    timerService.removeTimer(id: timer.id)

case (.some(let presetId), .discard):
    // Preset-based timer with favorite toggle OFF
    // → Hide preset AND delete timer
    presetRepository.hidePreset(withId: presetId)
    timerService.removeTimer(id: timer.id)
}
```

---

## 5. State Management: TimerInteractionState System

**Problem:** UI button combinations depend on multiple factors:
- Timer status (.running, .paused, .stopped, .completed)
- Source (preset vs instant)
- User preference (endAction: .preserve vs .discard)

**Solution:** Separate **data model state** from **UI interaction state**.

### Architecture

```
┌─────────────────────────┐
│   TimerData.status      │  Internal model state
│   - .running            │  (Persisted to UserDefaults)
│   - .paused             │
│   - .stopped            │
│   - .completed          │
└────────┬────────────────┘
         │
         │ Convert for UI
         ▼
┌─────────────────────────────────┐
│   TimerInteractionState         │  UI presentation state
│   - .preset (only in favorites) │  (Not persisted)
│   - .running                    │
│   - .paused                     │
│   - .stopped                    │
│   - .completed                  │
└─────────────────────────────────┘
         │
         │ Determine buttons
         ▼
┌─────────────────────────────────┐
│   TimerButtonSet                │  What buttons to show
│   - left: TimerLeftButtonType   │
│   - right: TimerRightButtonType │
└─────────────────────────────────┘
```

**Location:** `/Models/Interaction/`

### 1. Interaction State Enum

```swift
enum TimerInteractionState {
    case preset     // Only used in FavoriteListView (not a TimerData state)
    case running
    case paused
    case stopped
    case completed
}
```

### 2. State Conversion

```swift
extension TimerData {
    var interactionState: TimerInteractionState {
        switch status {
        case .running: return .running
        case .paused: return .paused
        case .stopped: return .stopped
        case .completed: return .completed
        }
    }
}

extension TimerPreset {
    var interactionState: TimerInteractionState {
        return .preset  // Presets always show as .preset state
    }
}
```

### 3. Button Mapping (Pure Function)

**Location:** `/Models/Interaction/TimerButtonMapping.swift`

```swift
func makeButtonSet(
    for state: TimerInteractionState,
    endAction: TimerEndAction
) -> TimerButtonSet {
    switch state {
    case .preset:
        return TimerButtonSet(left: .edit, right: .play)

    case .running:
        return TimerButtonSet(left: .stop, right: .pause)

    case .paused:
        return TimerButtonSet(left: .stop, right: .play)

    case .stopped, .completed:
        // Left button depends on endAction
        let leftButton: TimerLeftButtonType =
            endAction.isPreserve ? .moveToFavorite : .delete
        return TimerButtonSet(left: leftButton, right: .restart)
    }
}
```

**Button Types:**

```swift
enum TimerLeftButtonType: Equatable {
    case none
    case stop             // Stop running timer
    case moveToFavorite   // Save instant timer as preset
    case delete           // Delete timer
    case edit             // Edit preset
}

enum TimerRightButtonType: Equatable {
    case play      // Start or resume
    case pause     // Pause running timer
    case restart   // Restart stopped/completed timer
}
```

### 4. State Transitions (Pure Functions)

**Location:** `/Models/Interaction/TimerInteractionTransition.swift`

```swift
// Right button transitions
func nextState(
    from current: TimerInteractionState,
    right button: TimerRightButtonType
) -> TimerInteractionState {
    switch (current, button) {
    case (.preset, .play):       return .running
    case (.running, .pause):     return .paused
    case (.paused, .play):       return .running
    case (.stopped, .restart):   return .running
    case (.completed, .restart): return .running
    default:                     return current
    }
}

// Left button transitions
func nextState(
    from current: TimerInteractionState,
    left button: TimerLeftButtonType
) -> TimerInteractionState {
    switch (current, button) {
    case (.running, .stop):  return .stopped
    // Most left buttons trigger data changes, not state changes
    default:                 return current
    }
}
```

### Why This Pattern?

✅ **Type Safety:** Enums prevent invalid button combinations
✅ **Testability:** Pure functions (no side effects)
✅ **Maintainability:** Central definition of valid transitions
✅ **Decoupling:** UI state separate from data model
✅ **Reusability:** Same logic for RunningListViewModel and FavoriteListViewModel

---

## 6. Timer Completion & 10-Second Countdown

### The Problem

When a timer completes (remaining = 0), we need to:
1. Show completion notification
2. Give user 10 seconds to review
3. Execute final action based on `presetId` and `endAction`
4. Handle user cancellation

### The Solution: TimerCompletionHandler

**Location:** `/Services/TimerCompletionHandler.swift`

```swift
@MainActor
final class TimerCompletionHandler {
    private let timerService: any TimerServiceProtocol
    private let presetRepository: any PresetRepositoryProtocol
    private var countdownTasks: [UUID: Task<Void, Never>] = [:]

    // Callback for UI countdown display (10, 9, 8, ...)
    var onTick: ((UUID) -> Void)?

    /// Start 10-second countdown
    func scheduleCompletion(for timer: TimerData, after seconds: Int) {
        cancelCountdown(for: timer.id)  // Cancel existing if any

        countdownTasks[timer.id] = Task {
            for _ in 0..<seconds {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                onTick?(timer.id)  // Update UI countdown
            }

            await handle(timerId: timer.id)
        }
    }

    /// User confirmed deletion immediately
    func handleCompletionImmediately(timerId: UUID) {
        cancelCountdown(for: timerId)
        Task { await handle(timerId: timerId) }
    }

    /// Cancel countdown (user restarted timer)
    func cancelCountdown(for timerId: UUID) {
        countdownTasks[timerId]?.cancel()
        countdownTasks.removeValue(forKey: timerId)
    }

    @MainActor
    private func handle(timerId: UUID) {
        guard let timer = timerService.getTimer(byId: timerId) else { return }

        switch (timer.presetId, timer.endAction) {
        case (.none, .preserve):
            // Instant timer, favorite ON → Save as preset
            presetRepository.addPreset(from: timer)
            timerService.removeTimer(id: timerId)

        case (.none, .discard):
            // Instant timer, favorite OFF → Delete
            timerService.removeTimer(id: timerId)

        case (.some, .preserve):
            // Preset-based, favorite ON → Just delete (preset exists)
            timerService.removeTimer(id: timerId)

        case (.some(let presetId), .discard):
            // Preset-based, favorite OFF → Hide preset + delete
            presetRepository.hidePreset(withId: presetId)
            timerService.removeTimer(id: timerId)
        }

        countdownTasks.removeValue(forKey: timerId)
    }
}
```

### Completion Flow

```
Timer reaches 0
    ↓
TimerService.tick() detects remaining = 0
    ↓
Update status to .completed
    ↓
Call completionHandler.scheduleCompletion(timer, after: 10)
    ↓
Start Task countdown (10 seconds)
    │
    ├─ Every second: call onTick?(timerId) → UI updates countdown display
    │
    └─ After 10 seconds: call handle(timerId)
         ↓
         Execute final action based on presetId + endAction
         ↓
         Remove timer from repository

User can interrupt:
- Tap delete button → handleCompletionImmediately(timerId)
- Tap restart button → cancelCountdown(timerId) + restart
```

---

## 7. ViewModels

All ViewModels follow this pattern:
- `@MainActor` for UI thread safety
- `ObservableObject` for SwiftUI integration
- `@Published` properties for reactive UI updates
- Injected dependencies (Services, Repositories)

### AddTimerViewModel

**Location:** `/ViewModels/AddTimerViewModel.swift`
**Responsibility:** Manage timer creation form input

```swift
@MainActor
final class AddTimerViewModel: ObservableObject {
    @Published var label: String = ""
    @Published var hours: Int = 0
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    @Published var selectedMode: AlarmMode = .sound

    private let timerService: any TimerServiceProtocol

    init(timerService: any TimerServiceProtocol) {
        self.timerService = timerService
    }

    func startTimer() -> Bool {
        let sanitizedLabel = LabelSanitizer.sanitize(label)
        let (isSoundOn, isVibrationOn) = AlarmNotificationPolicy.from(mode: selectedMode).toBools()

        let success = timerService.addTimer(
            label: sanitizedLabel,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            isSoundOn: isSoundOn,
            isVibrationOn: isVibrationOn
        )

        if success {
            resetForm()
        }

        return success
    }

    private func resetForm() {
        label = ""
        hours = 0
        minutes = 0
        seconds = 0
        selectedMode = .sound
    }
}
```

### RunningListViewModel

**Location:** `/ViewModels/RunningListViewModel.swift`
**Responsibility:** Manage running timers list UI state

```swift
@MainActor
final class RunningListViewModel: ObservableObject {
    @Published var sortedTimers: [TimerData] = []
    @Published var activeAlert: AppAlert?

    private let timerService: any TimerServiceProtocol
    private let timerRepository: any TimerRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    init(timerService: any TimerServiceProtocol,
         timerRepository: any TimerRepositoryProtocol) {
        self.timerService = timerService
        self.timerRepository = timerRepository

        // Subscribe to repository changes
        timerRepository.timersPublisher
            .map { timers in
                timers.sorted { $0.createdAt > $1.createdAt }  // Newest first
            }
            .assign(to: &$sortedTimers)
    }

    func handleLeft(for timer: TimerData) {
        let state = timer.interactionState
        let buttonSet = makeButtonSet(for: state, endAction: timer.endAction)

        switch buttonSet.left {
        case .stop:
            timerService.stopTimer(id: timer.id)
        case .delete:
            timerService.userDidRequestDelete(for: timer.id)
        case .moveToFavorite:
            handleMoveToPreset(for: timer)
        default:
            break
        }
    }

    func handleRight(for timer: TimerData) {
        let state = timer.interactionState
        let buttonSet = makeButtonSet(for: state, endAction: timer.endAction)

        switch buttonSet.right {
        case .play:
            timerService.resumeTimer(id: timer.id)
        case .pause:
            timerService.pauseTimer(id: timer.id)
        case .restart:
            timerService.restartTimer(id: timer.id)
        }
    }

    func toggleFavorite(for id: UUID) {
        let _ = timerService.toggleFavorite(for: id)
    }
}
```

**Key Pattern:** Uses Combine to reactively update `sortedTimers` whenever repository changes.

### FavoriteListViewModel

**Location:** `/ViewModels/FavoriteListViewModel.swift`
**Responsibility:** Manage presets list UI state

```swift
@MainActor
final class FavoriteListViewModel: ObservableObject {
    @Published var visiblePresets: [TimerPreset] = []
    @Published var runningPresetIds: Set<UUID> = []  // Which presets have running timers

    private let timerService: any TimerServiceProtocol
    private let presetRepository: any PresetRepositoryProtocol
    private let timerRepository: any TimerRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    init(...) {
        // Subscribe to preset changes
        presetRepository.userPresetsPublisher
            .map { presets in
                presets
                    .filter { !$0.isHiddenInList }
                    .sorted { $0.createdAt > $1.createdAt }
            }
            .assign(to: &$visiblePresets)

        // Subscribe to running timers to show which presets are active
        timerRepository.timersPublisher
            .map { timers in
                Set(timers.compactMap { $0.presetId })
            }
            .assign(to: &$runningPresetIds)
    }

    func runTimer(from preset: TimerPreset) {
        let _ = timerService.runTimer(from: preset)
    }
}
```

**Key Pattern:** Two Combine subscriptions:
1. `presetRepository.userPresetsPublisher` → Filter visible, sort
2. `timerRepository.timersPublisher` → Extract running preset IDs

---

## 8. App Lifecycle & Scene Phase Handling

### App Entry Point

**Location:** `/QuickLabelTimerApp.swift`

```swift
@main
struct QuickLabelTimerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var timerRepository: TimerRepository
    @StateObject private var presetRepository: PresetRepository
    @StateObject private var timerService: TimerService
    @StateObject private var settingsViewModel: SettingsViewModel

    init() {
        // ⚠️ Create instances ONCE, share everywhere
        let timerRepository = TimerRepository()
        let presetRepository = PresetRepository()
        let timerService = TimerService(
            timerRepository: timerRepository,
            presetRepository: presetRepository
        )

        _timerRepository = StateObject(wrappedValue: timerRepository)
        _presetRepository = StateObject(wrappedValue: presetRepository)
        _timerService = StateObject(wrappedValue: timerService)
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel())
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(timerService)
                .environmentObject(timerRepository)
                .environmentObject(presetRepository)
                .environmentObject(settingsViewModel)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            timerService.updateScenePhase(newPhase)
        }
    }
}
```

**Critical Pattern:** Deferred initialization in `init()` to share single instances.

### App Delegate

**Location:** `/AppDelegate.swift`

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 1. Initialize Firebase
        FirebaseApp.configure()

        // 2. Request notification permissions
        Task {
            await NotificationUtils.requestAuthorization()
        }

        // 3. Set notification delegate
        let delegate = LocalNotificationDelegate()
        UNUserNotificationCenter.current().delegate = delegate

        return true
    }
}
```

### Scene Phase Transitions

**Location:** `/Services/TimerService.swift`

```swift
func updateScenePhase(_ phase: ScenePhase) {
    switch phase {
    case .active:
        // App came to foreground
        handleActivation()
    case .background:
        // App went to background (nothing to do, notifications handle it)
        break
    case .inactive:
        // Transitioning (nothing to do)
        break
    @unknown default:
        break
    }
}

private func handleActivation() {
    let now = Date()

    // Debounce: don't run too frequently (0.8s)
    guard shouldRunActivationCleanup(now: now) else { return }

    // Reconcile timers that may have completed while app was closed
    reconcileTimersOnLaunch()

    // Clean up notifications for completed timers
    let completedTimers = timerRepository.getAllTimers()
        .filter { $0.status == .completed }

    runActivationCleanup(for: completedTimers) {
        finalizeCompletedTimers(completedTimers)
    }
}
```

### App Reconciliation Logic

```swift
private func reconcileTimersOnLaunch() {
    let now = Date()
    let timers = timerRepository.getAllTimers()

    for timer in timers {
        switch timer.status {
        case .running:
            let remaining = max(0, Int(timer.endDate.timeIntervalSince(now)))

            if remaining == 0 {
                // Timer expired while app was closed
                var completed = timer
                completed.status = .completed
                completed.remainingSeconds = 0
                timerRepository.updateTimer(completed)
                startCompletionProcess(for: completed)
            } else {
                // Just update remaining seconds
                var updated = timer
                updated.remainingSeconds = remaining
                timerRepository.updateTimer(updated)
            }

        case .completed:
            // Check if 10-second countdown already finished
            let elapsedTime = now.timeIntervalSince(timer.endDate)
            if elapsedTime > TimeInterval(deleteCountdownSeconds) {
                completionHandler.handleCompletionImmediately(timerId: timer.id)
            } else {
                // Resume countdown
                let remainingCountdown = deleteCountdownSeconds - Int(elapsedTime)
                completionHandler.scheduleCompletion(for: timer, after: remainingCountdown)
            }

        case .paused, .stopped:
            // No reconciliation needed
            break
        }
    }
}
```

---

## 9. Data Persistence

### Storage Strategy

**Technology:** UserDefaults (JSON-encoded via Codable)
**Why not CoreData/SQLite?** App has <100 items, simple structure, no complex queries

**UserDefaults Keys:**
- `"running_timers"` → `[TimerData]`
- `"user_presets"` → `[TimerPreset]`
- `"did_initialize_presets"` → `Bool` (first launch flag)

### Persistence Flow

```
Repository Property Changed
    ↓
@Published var triggers willSet
    ↓
private func saveTimers() called
    ↓
JSONEncoder().encode(timers)
    ↓
UserDefaults.standard.set(data, forKey: "running_timers")
    ↓
Automatically synced to disk by iOS

On App Launch:
    ↓
Repository.init() calls loadTimers()
    ↓
UserDefaults.standard.data(forKey: "running_timers")
    ↓
JSONDecoder().decode([TimerData].self, from: data)
    ↓
timers = decoded
```

### Error Handling

```swift
private func saveTimers() {
    do {
        let data = try JSONEncoder().encode(timers)
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    } catch {
        Logger.persistence.error("Failed to save timers: \(error)")
        // ⚠️ Don't crash - just log. User data is still in memory.
    }
}

private func loadTimers() {
    guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
        timers = []
        return
    }

    do {
        timers = try JSONDecoder().decode([TimerData].self, from: data)
    } catch {
        Logger.persistence.error("Failed to load timers: \(error)")
        timers = []  // Start fresh if corrupted
    }
}
```

---

## 10. Localization

### String Catalog

**Location:** `/Localizable.xcstrings`
**Format:** Modern Xcode String Catalog (iOS 16+)

**Supported Languages:**
- English (en) - Source language
- Korean (ko)

### Key Naming Convention

```
"a11y.{context}.{element}"  → Accessibility strings
"ui.{screen}.{element}"     → UI strings
```

**Examples:**
- `"a11y.addTimer.createButton"` → "Create Timer" / "타이머 생성"
- `"ui.timer.remainingTime"` → "Remaining" / "남은 시간"

### Usage in Code

```swift
// In Views
Text("a11y.addTimer.createButton")  // Automatically localized

Button("Create") {
    // ...
}
.accessibilityLabel("a11y.addTimer.createButton")

// With parameters
Text("ui.timer.remainingFormat", comment: "%1$@ remaining")
```

### Adding New Strings

1. Use string key in code (e.g., `"ui.newFeature.title"`)
2. Run app → Xcode auto-detects new key
3. Open `Localizable.xcstrings` in Xcode
4. Add English translation
5. Add Korean translation

---

## 11. Logging Strategy

**Framework:** OSLog (Unified Logging System)

**Location:** `/Utils/Logger+Extension.swift`

```swift
import OSLog

extension Logger {
    static let timer = Logger(subsystem: "com.yourapp.QuickLabelTimer", category: "Timer")
    static let persistence = Logger(subsystem: "com.yourapp.QuickLabelTimer", category: "Persistence")
    static let notification = Logger(subsystem: "com.yourapp.QuickLabelTimer", category: "Notification")
    static let ui = Logger(subsystem: "com.yourapp.QuickLabelTimer", category: "UI")
}
```

### Log Levels

```swift
Logger.timer.debug("Timer tick: \(timer.id) - \(remaining)s remaining")
Logger.timer.info("Timer started: \(timer.label)")
Logger.timer.notice("Timer completed: \(timer.label)")
Logger.timer.error("Failed to start timer: \(error)")
Logger.timer.fault("Critical: Repository instance nil!")
```

**Guidelines:**
- `.debug` → Verbose, frequent events (tick updates)
- `.info` → Important events (timer created)
- `.notice` → Significant events (timer completed)
- `.error` → Recoverable errors
- `.fault` → Critical errors that shouldn't happen

**Viewing Logs:**
```bash
# In Xcode Console
log show --predicate 'subsystem == "com.yourapp.QuickLabelTimer"' --last 1h

# Filter by category
log show --predicate 'category == "Timer"' --last 5m
```

---

## 12. Configuration & Constants

**Location:** `/Configuration/AppConfig.swift`

```swift
enum AppConfig {
    // Input Constraints
    static let maxLabelLength = 100

    // Timer Limits
    static let maxConcurrentTimers = 5

    // Notification Settings
    static let repeatingNotificationCount = 12
    static let notificationRepeatingInterval: TimeInterval = 3.0  // seconds
    static let notificationSystemLimit = 64  // iOS max per app

    // Preset Limits
    static let maxPresets = 20
}
```

**Other Constants:**
- Deletion countdown: 10 seconds (defined in `TimerService`)
- Scene phase debounce: 0.8 seconds

---

## 13. File Structure

```
QuickLabelTimer/
├── QuickLabelTimerApp.swift           # App entry point
├── AppDelegate.swift                  # App lifecycle delegate
│
├── Configuration/
│   ├── AppConfig.swift                # App constants
│   └── AppTheme.swift                 # Theme colors
│
├── Models/
│   ├── TimerData.swift                # Running timer model
│   ├── TimerPreset.swift              # Preset model
│   ├── AlarmMode.swift                # UI alarm mode enum
│   ├── AlarmNotificationPolicy.swift  # Technical notification policy
│   ├── AlarmSound.swift               # Sound definitions
│   └── Interaction/
│       ├── TimerInteractionState.swift     # UI state enum
│       ├── TimerInteractionTransition.swift # State transition logic
│       ├── TimerLeftButtonType.swift       # Left button types
│       ├── TimerRightButtonType.swift      # Right button types
│       ├── TimerButtonSet.swift            # Button combination
│       └── TimerButtonMapping.swift        # State → Button mapping
│
├── Repositories/
│   ├── TimerRepository.swift          # Running timers CRUD + persistence
│   └── PresetRepository.swift         # Presets CRUD + persistence
│
├── Services/
│   ├── TimerService.swift             # Timer orchestration
│   ├── TimerCompletionHandler.swift   # Completion logic
│   ├── AlarmHandler.swift             # (Deprecated)
│   └── AlarmPlayer.swift              # (Deprecated)
│
├── ViewModels/
│   ├── AddTimerViewModel.swift
│   ├── RunningListViewModel.swift
│   ├── FavoriteListViewModel.swift
│   ├── EditPresetViewModel.swift
│   └── SettingsViewModel.swift
│
├── Views/
│   ├── Container/
│   │   └── MainTabView.swift
│   ├── Components/
│   │   ├── TimerRow/
│   │   ├── TimerRowButton/
│   │   ├── Input/
│   │   └── Common/
│   └── Settings/
│
├── Notifications/
│   ├── NotificationUtils.swift         # Notification operations
│   ├── LocalNotificationDelegate.swift # Notification delegate
│   └── NotificationScheduling.swift    # (If exists)
│
├── Utils/
│   ├── TimeUtils.swift                # Time formatting
│   ├── LabelSanitizer.swift           # Input sanitization
│   ├── Logger+Extension.swift         # OSLog categories
│   └── Accessibility+Helpers.swift    # Accessibility utilities
│
├── Data/
│   └── SamplePresetData.swift         # Sample data for testing
│
├── Localizable.xcstrings              # String catalog
│
└── Resources/
    └── (Images, audio files, etc.)
```

---

## 14. Testing Strategy

### Current Status

**Location:** `/QuickLabelTimerTests/`
**Framework:** Swift Testing (iOS 18+)

```swift
import Testing

struct QuickLabelTimerTests {
    @Test func example() async throws {
        // Write tests here
    }
}
```

### Testability Features

✅ **Protocol-Based Dependencies**
```swift
protocol TimerServiceProtocol: ObservableObject {
    func addTimer(...) -> Bool
    // ...
}

// Production
final class TimerService: TimerServiceProtocol { ... }

// Testing
final class MockTimerService: TimerServiceProtocol { ... }
```

✅ **Pure Functions**
```swift
// Easy to test - no side effects
func makeButtonSet(for state: TimerInteractionState, endAction: TimerEndAction) -> TimerButtonSet
```

✅ **Dependency Injection**
```swift
init(timerService: any TimerServiceProtocol) {
    self.timerService = timerService
}
```

### Recommended Test Coverage

**High Priority (Pure Logic):**
1. `TimerInteractionTransition` - State transition functions
2. `TimerButtonMapping` - Button set generation
3. `LabelSanitizer` - Input validation
4. `TimeUtils` - Time formatting

**Medium Priority (Business Logic):**
1. `TimerService` - Timer state transitions
2. `TimerCompletionHandler` - Completion logic
3. `ViewModels` - User action handlers

**Low Priority (Integration):**
1. Repository persistence roundtrips
2. Notification scheduling

---

## 15. Unique Architectural Patterns

### Pattern 1: Separation of Data State and UI State

**Problem:** UI button logic depends on multiple factors
**Solution:** `TimerInteractionState` system (Section 5)

**Benefits:**
- Type-safe button combinations
- Testable pure functions
- UI changes don't require model changes

### Pattern 2: Repeating Notification Chain

**Problem:** Single notification can be missed
**Solution:** 12 notifications over 36 seconds (Section 3)

**Benefits:**
- Higher reliability
- Visual escalation (more emojis)
- Batch cancellation via ID prefix

### Pattern 3: 10-Second Deletion Countdown

**Problem:** Immediate deletion feels abrupt
**Solution:** `TimerCompletionHandler` with async countdown (Section 6)

**Benefits:**
- User can review completed timer
- Time to favorite instant timer
- Graceful UX

### Pattern 4: Soft Delete for Presets

**Problem:** Hard delete loses user data
**Solution:** `isHiddenInList` flag

**Benefits:**
- Can restore deleted presets
- Maintains history
- No accidental data loss

### Pattern 5: EndAction Toggle

**Problem:** Different completion behaviors for different users
**Solution:** `endAction: TimerEndAction` (.preserve | .discard)

**Benefits:**
- Single toggle controls multiple flows
- User control over preset creation
- Clear intent

### Pattern 6: Scene Phase Debouncing

**Problem:** Rapid background/foreground causes repeated cleanup
**Solution:** 0.8s debounce in `updateScenePhase`

**Benefits:**
- Prevents redundant work
- Better performance
- Smoother UX

---

## 16. Swift/SwiftUI Best Practices in This Codebase

### 1. @MainActor Usage

✅ **Correct Pattern:**
```swift
@MainActor
final class TimerService: ObservableObject {
    func pauseTimer(id: UUID) {
        // Already on main thread, safe to update UI
    }
}
```

⚠️ **When to use Task { @MainActor in }:**
```swift
private var timer: Timer?

func startTicking() {
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        Task { @MainActor in
            await self?.tick()  // Ensure tick() runs on main thread
        }
    }
}
```

### 2. Combine Publishers

✅ **Correct Pattern:**
```swift
timerRepository.timersPublisher
    .map { timers in
        timers.sorted { $0.createdAt > $1.createdAt }
    }
    .assign(to: &$sortedTimers)  // ⚠️ Note: assign(to: &$property) for automatic cancellation
```

❌ **Avoid:**
```swift
timerRepository.timersPublisher
    .sink { [weak self] timers in
        self?.sortedTimers = timers.sorted { ... }
    }
    .store(in: &cancellables)  // ❌ More verbose, manual cancellation management
```

### 3. ObservableObject

✅ **Correct Pattern:**
```swift
@MainActor
final class ViewModel: ObservableObject {
    @Published var state: State = .idle

    // Automatic update triggering:
    func updateState() {
        state = .loading  // SwiftUI automatically observes this
    }
}
```

❌ **Avoid:**
```swift
@MainActor
final class ViewModel: ObservableObject {
    var state: State = .idle  // ❌ Missing @Published

    func updateState() {
        state = .loading  // ❌ Won't trigger UI update
        objectWillChange.send()  // ❌ Manual - use @Published instead
    }
}
```

### 4. Struct vs Class

✅ **Models = Struct (Immutable):**
```swift
struct TimerData: Identifiable, Codable {
    let id: UUID
    var status: TimerStatus  // var for Codable updates, but use .updating() pattern
}
```

✅ **Services/Repositories = Class:**
```swift
@MainActor
final class TimerService: ObservableObject {
    // Reference type, shared instance
}
```

### 5. Swift Concurrency

✅ **Correct Pattern:**
```swift
func scheduleCompletion(for timer: TimerData, after seconds: Int) {
    countdownTasks[timer.id] = Task {
        for _ in 0..<seconds {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
        await handle(timerId: timer.id)
    }
}
```

⚠️ **Cancellation:**
```swift
func cancelCountdown(for timerId: UUID) {
    countdownTasks[timerId]?.cancel()  // ⚠️ Task.sleep respects cancellation
    countdownTasks.removeValue(forKey: timerId)
}
```

---

## 17. Data Flow Example: Creating a Timer

Let's trace a complete flow from user interaction to persistence:

```
┌─────────────────────────────────────────────────────────────────┐
│ USER ACTION: Taps "Create Timer" button                        │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ View: AddTimerView                                              │
│   - Captures: label, hours, minutes, seconds, selectedMode      │
│   - Calls: addTimerViewModel.startTimer()                       │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ ViewModel: AddTimerViewModel                                    │
│   1. Sanitize label (remove extra whitespace, limit length)     │
│   2. Convert AlarmMode → (isSoundOn, isVibrationOn)             │
│   3. Call timerService.addTimer(...)                            │
│   4. If success: resetForm(), dismiss view                      │
│   5. If fail: show alert                                        │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ Service: TimerService.addTimer()                                │
│   1. Validate: concurrent timer limit (max 5)                   │
│   2. Calculate duration: hours*3600 + minutes*60 + seconds      │
│   3. Create TimerData:                                          │
│      - id: UUID()                                               │
│      - label, hours, minutes, seconds, isSoundOn, isVibrationOn │
│      - status: .running                                         │
│      - endDate: Date() + duration                               │
│      - remainingSeconds: duration                               │
│      - presetId: nil (instant timer)                            │
│      - endAction: .discard (default)                            │
│      - createdAt: Date()                                        │
│   4. Call timerRepository.addTimer(newTimer)                    │
│   5. Schedule repeating notifications (12 notifications)        │
│   6. Start tick loop if not running                             │
│   7. Return true (success)                                      │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ Repository: TimerRepository.addTimer()                          │
│   1. Append timer to timers array                               │
│   2. Trigger @Published update (SwiftUI observes)               │
│   3. Call saveTimers()                                          │
│      - JSONEncoder().encode(timers)                             │
│      - UserDefaults.standard.set(data, forKey: "running_timers")│
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ ViewModel: RunningListViewModel (observing)                     │
│   - Receives update via timerRepository.timersPublisher         │
│   - Combine pipeline sorts timers by createdAt                  │
│   - Updates @Published var sortedTimers                         │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ View: RunningTimerListView                                      │
│   - SwiftUI detects @Published change                           │
│   - Re-renders list with new timer                              │
│   - New timer appears at top (sorted newest first)              │
└─────────────────────────────────────────────────────────────────┘

Meanwhile, in parallel:

┌─────────────────────────────────────────────────────────────────┐
│ Service: TimerService (1Hz tick loop)                           │
│   Every 1 second:                                               │
│   1. Get current time                                           │
│   2. For each .running timer:                                   │
│      - Calculate remaining = endDate - now                      │
│      - If remaining changed: update TimerData.remainingSeconds  │
│      - If remaining = 0: transition to .completed               │
│   3. Trigger repository updates                                 │
└─────────────────────────────────────────────────────────────────┘

Notifications scheduled:

┌─────────────────────────────────────────────────────────────────┐
│ iOS UserNotifications                                           │
│   12 notifications scheduled:                                   │
│   - ID: "{timerId}_0" → fires at endDate + 0s                   │
│   - ID: "{timerId}_1" → fires at endDate + 3s                   │
│   - ...                                                         │
│   - ID: "{timerId}_11" → fires at endDate + 33s                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 18. Common Development Tasks

### Task 1: Add a New Timer Property

**Scenario:** Add a `color: String` property to timers.

**Steps:**

1. **Update Model:**
```swift
// Models/TimerData.swift
struct TimerData: Identifiable, Hashable, Codable {
    // ... existing properties
    var color: String  // ✅ Add new property
}
```

2. **Update Creation:**
```swift
// Services/TimerService.swift
func addTimer(..., color: String) -> Bool {  // ✅ Add parameter
    let timer = TimerData(
        // ... existing
        color: color  // ✅ Pass to initializer
    )
    // ...
}
```

3. **Update ViewModel:**
```swift
// ViewModels/AddTimerViewModel.swift
@Published var selectedColor: String = "blue"  // ✅ Add UI state

func startTimer() -> Bool {
    timerService.addTimer(
        // ... existing
        color: selectedColor  // ✅ Pass to service
    )
}
```

4. **Update View:**
```swift
// Views/AddTimerView.swift
Picker("Color", selection: $viewModel.selectedColor) {
    // ...
}
```

5. **Handle Migration:**
```swift
// Models/TimerData.swift
init(from decoder: Decoder) throws {
    // ...
    color = try container.decodeIfPresent(String.self, forKey: .color) ?? "blue"  // ✅ Default for old data
}
```

### Task 2: Add a New Timer Action

**Scenario:** Add a "duplicate" button.

**Steps:**

1. **Add Button Type:**
```swift
// Models/Interaction/TimerLeftButtonType.swift
enum TimerLeftButtonType: Equatable {
    // ... existing
    case duplicate  // ✅ Add new type
}
```

2. **Update Button Mapping:**
```swift
// Models/Interaction/TimerButtonMapping.swift
func makeButtonSet(for state: TimerInteractionState, endAction: TimerEndAction) -> TimerButtonSet {
    switch state {
    case .stopped:
        return TimerButtonSet(left: .duplicate, right: .restart)  // ✅ Use new button
    // ...
    }
}
```

3. **Add Service Method:**
```swift
// Services/TimerService.swift
func duplicateTimer(id: UUID) -> Bool {
    guard let original = getTimer(byId: id) else { return false }

    return addTimer(
        label: original.label,
        hours: original.hours,
        minutes: original.minutes,
        seconds: original.seconds,
        isSoundOn: original.isSoundOn,
        isVibrationOn: original.isVibrationOn
    )
}
```

4. **Update ViewModel Handler:**
```swift
// ViewModels/RunningListViewModel.swift
func handleLeft(for timer: TimerData) {
    let buttonSet = makeButtonSet(for: timer.interactionState, endAction: timer.endAction)

    switch buttonSet.left {
    // ... existing cases
    case .duplicate:
        let _ = timerService.duplicateTimer(id: timer.id)  // ✅ Handle new button
    }
}
```

5. **Update View:**
```swift
// Views/Components/TimerRowButton/TimerLeftButton.swift
switch buttonType {
// ... existing cases
case .duplicate:
    Image(systemName: "doc.on.doc")
        .accessibilityLabel("Duplicate timer")
}
```

### Task 3: Debug a Timer Not Updating

**Problem:** Timer countdown not updating in UI.

**Debugging Steps:**

1. **Check Tick Loop:**
```swift
// Services/TimerService.swift
private func tick() {
    Logger.timer.debug("Tick - Active timers: \(timerRepository.getAllTimers().filter { $0.status == .running }.count)")
    // ... rest of tick logic
}
```

2. **Verify Repository Update:**
```swift
// Repositories/TimerRepository.swift
func updateTimer(_ timer: TimerData) {
    Logger.persistence.debug("Updating timer: \(timer.id) - remaining: \(timer.remainingSeconds)")
    // ... update logic
}
```

3. **Check ViewModel Subscription:**
```swift
// ViewModels/RunningListViewModel.swift
init(...) {
    timerRepository.timersPublisher
        .handleEvents(receiveOutput: { timers in
            Logger.ui.debug("Received timer update: \(timers.count) timers")
        })
        .map { /* ... */ }
        .assign(to: &$sortedTimers)
}
```

4. **Common Issues:**
   - ❌ Tick loop not started → Check `startTicking()` called
   - ❌ Timer status not `.running` → Check state transitions
   - ❌ ViewModel not observing → Check `@EnvironmentObject` injection
   - ❌ Repository not `@Published` → Check `@Published var timers`

### Task 4: Add Analytics Event

**Scenario:** Track when users create timers.

**Steps:**

1. **Create Analytics Service:**
```swift
// Services/AnalyticsService.swift
@MainActor
protocol AnalyticsServiceProtocol {
    func track(event: AnalyticsEvent)
}

enum AnalyticsEvent {
    case timerCreated(duration: Int, source: TimerSource)
    case timerCompleted(duration: Int)
    // ...
}

enum TimerSource {
    case instant
    case preset
}

final class AnalyticsService: AnalyticsServiceProtocol {
    func track(event: AnalyticsEvent) {
        // Send to Firebase Analytics, etc.
    }
}
```

2. **Inject into TimerService:**
```swift
// Services/TimerService.swift
@MainActor
final class TimerService: ObservableObject {
    private let analyticsService: any AnalyticsServiceProtocol

    init(..., analyticsService: any AnalyticsServiceProtocol) {
        self.analyticsService = analyticsService
    }

    func addTimer(...) -> Bool {
        // ... create timer

        analyticsService.track(event: .timerCreated(
            duration: duration,
            source: .instant
        ))

        return true
    }
}
```

3. **Update App Entry Point:**
```swift
// QuickLabelTimerApp.swift
init() {
    let analyticsService = AnalyticsService()
    let timerService = TimerService(
        timerRepository: timerRepository,
        presetRepository: presetRepository,
        analyticsService: analyticsService  // ✅ Inject
    )
    // ...
}
```

---

## 19. Critical Rules & Common Pitfalls

### 🚨 NEVER Do These

#### 1. NEVER Modify TimerData Directly in Views/ViewModels

❌ **WRONG:**
```swift
// In RunningListView
var timer: TimerData
timer.status = .paused  // ❌ Won't persist, breaks single source of truth
```

✅ **CORRECT:**
```swift
// In RunningListViewModel
timerService.pauseTimer(id: timer.id)  // ✅ Goes through proper flow
```

**Why?** Only `TimerRepository` should modify timer data. Direct modification bypasses:
- Persistence to UserDefaults
- Notification to observers
- Business logic validation

#### 2. NEVER Create Service/Repository Instances in ViewModels

❌ **WRONG:**
```swift
@MainActor
final class RunningListViewModel: ObservableObject {
    let timerService = TimerService()  // ❌ Creates duplicate instance!
}
```

✅ **CORRECT:**
```swift
@MainActor
final class RunningListViewModel: ObservableObject {
    private let timerService: any TimerServiceProtocol

    init(timerService: any TimerServiceProtocol) {  // ✅ Inject shared instance
        self.timerService = timerService
    }
}
```

**Why?** The app must have exactly ONE instance of each repository/service. Creating multiple instances causes:
- Data inconsistency
- Missed updates
- Duplicate tick loops

#### 3. NEVER Access Repository from Background Thread

❌ **WRONG:**
```swift
Task.detached {
    timerRepository.addTimer(timer)  // ❌ Crash! Not on @MainActor
}
```

✅ **CORRECT:**
```swift
Task { @MainActor in
    timerRepository.addTimer(timer)  // ✅ Explicit @MainActor
}
```

**Why?** All repositories/services are `@MainActor`. Background access causes:
- Runtime crashes
- Race conditions
- UI update crashes

#### 4. NEVER Schedule >64 Notifications

❌ **WRONG:**
```swift
for i in 0..<100 {
    NotificationUtils.scheduleNotification(...)  // ❌ iOS limit is 64!
}
```

✅ **CORRECT:**
```swift
let maxNotifications = min(count, AppConfig.notificationSystemLimit - currentPendingCount)
for i in 0..<maxNotifications {
    NotificationUtils.scheduleNotification(...)
}
```

**Why?** iOS silently drops notifications >64. Always check:
- Current pending count
- Respect `AppConfig.notificationSystemLimit`

#### 5. NEVER Skip Cancelling Notifications

❌ **WRONG:**
```swift
func removeTimer(id: UUID) {
    timerRepository.removeTimer(byId: id)  // ❌ Notifications still scheduled!
}
```

✅ **CORRECT:**
```swift
func removeTimer(id: UUID) -> TimerData? {
    NotificationUtils.cancelNotifications(withPrefix: id.uuidString)  // ✅ Clean up first
    return timerRepository.removeTimer(byId: id)
}
```

**Why?** Orphaned notifications will fire even after timer is deleted.

### ⚠️ Common Mistakes

#### 1. Forgetting to Update UserDefaults Keys

**Problem:** Changed data structure but forgot to update persistence key.

```swift
// Old code
private let userDefaultsKey = "timers"

// New code (different structure)
struct TimerData {
    var newProperty: String  // ✅ Added property
}

// ❌ FORGOT: Migration or new key
```

**Solution:**
```swift
// Option 1: Migrate
private func loadTimers() {
    if let data = UserDefaults.standard.data(forKey: "timers_v2") {
        // Load new format
    } else if let data = UserDefaults.standard.data(forKey: "timers") {
        // Migrate from old format
    }
}

// Option 2: Version bump (acceptable for dev)
private let userDefaultsKey = "timers_v2"  // ✅ Fresh start
```

#### 2. Not Handling Codable Errors

**Problem:** JSON decoding fails silently.

❌ **WRONG:**
```swift
func loadTimers() {
    guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
    timers = try! JSONDecoder().decode([TimerData].self, from: data)  // ❌ Crash on failure!
}
```

✅ **CORRECT:**
```swift
func loadTimers() {
    guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
        timers = []
        return
    }

    do {
        timers = try JSONDecoder().decode([TimerData].self, from: data)
    } catch {
        Logger.persistence.error("Failed to decode timers: \(error)")
        timers = []  // ✅ Graceful degradation
    }
}
```

#### 3. Retain Cycles with Combine

**Problem:** ViewModel not deallocated.

❌ **WRONG:**
```swift
timerRepository.timersPublisher
    .sink { timers in
        self.sortedTimers = timers  // ❌ Strong reference to self!
    }
    .store(in: &cancellables)
```

✅ **CORRECT:**
```swift
// Option 1: Use assign(to:)
timerRepository.timersPublisher
    .map { /* ... */ }
    .assign(to: &$sortedTimers)  // ✅ No retain cycle

// Option 2: Weak self
timerRepository.timersPublisher
    .sink { [weak self] timers in
        self?.sortedTimers = timers  // ✅ Weak reference
    }
    .store(in: &cancellables)
```

#### 4. Not Reconciling on App Launch

**Problem:** Timer state stale after app restart.

❌ **WRONG:**
```swift
// TimerService.init()
init() {
    startTicking()  // ❌ Just start ticking, don't reconcile
}
```

✅ **CORRECT:**
```swift
// QuickLabelTimerApp.swift
var body: some Scene {
    WindowGroup {
        MainTabView()
            .onAppear {
                // ✅ Reconcile timers on first appear
            }
    }
    .onChange(of: scenePhase) { _, newPhase in
        timerService.updateScenePhase(newPhase)  // ✅ Reconcile on activation
    }
}
```

#### 5. Hardcoding Strings Instead of Localization

❌ **WRONG:**
```swift
Text("Create Timer")  // ❌ Only English
```

✅ **CORRECT:**
```swift
Text("ui.addTimer.createButton")  // ✅ Localized via String Catalog
```

### 🔍 Debugging Checklist

When something doesn't work:

**Timer not appearing in list:**
- [ ] Did you call `timerService.addTimer()`? (not `timerRepository.addTimer()`)
- [ ] Did ViewModel subscribe to `timerRepository.timersPublisher`?
- [ ] Is `@EnvironmentObject` injected correctly?
- [ ] Check Xcode Console for errors

**Timer not counting down:**
- [ ] Is timer status `.running`?
- [ ] Is tick loop started? (Log in `tick()`)
- [ ] Is `endDate` in the future?
- [ ] Is ViewModel updating `sortedTimers`?

**Notification not firing:**
- [ ] Did you request authorization in AppDelegate?
- [ ] Is notification scheduled? (Check pending notifications)
- [ ] Is notification ID correct format? (`"{timerId}_{index}"`)
- [ ] Is app in foreground? (Delegate suppresses most foreground notifications)

**Persistence not working:**
- [ ] Did you call `saveTimers()` after mutation?
- [ ] Check UserDefaults for data: `po UserDefaults.standard.data(forKey: "running_timers")`
- [ ] Is Codable implementation correct?
- [ ] Check Console for persistence errors

---

## 20. Performance Considerations

### 1. Tick Loop Optimization

**Current Implementation:**
- 1Hz (every second)
- Only updates when `remainingSeconds` changes
- Automatically stops when no timers running

**Why It's Efficient:**
```swift
func tick() {
    let runningTimers = timerRepository.getAllTimers().filter { $0.status == .running }

    if runningTimers.isEmpty {
        stopTicking()  // ✅ Stop timer when idle
        return
    }

    for timer in runningTimers {
        let remaining = max(0, Int(timer.endDate.timeIntervalSince(Date())))

        if remaining != timer.remainingSeconds {  // ✅ Only update if changed
            var updated = timer
            updated.remainingSeconds = remaining
            timerRepository.updateTimer(updated)
        }
    }
}
```

**Don't:**
- ❌ Use <1s intervals (unnecessary CPU usage)
- ❌ Update UI every tick (only when value changes)
- ❌ Keep ticking when no timers running

### 2. UserDefaults Persistence

**Current Implementation:**
- Save on every mutation
- JSON encoding (efficient for <100 items)

**Trade-offs:**
- ✅ Simple, no schema migrations
- ✅ Automatic iCloud sync (if enabled)
- ⚠️ Limited to ~100 items (acceptable for this app)
- ❌ Not suitable for >1000 items (use CoreData)

**When to Optimize:**
- If presets >100 → Consider CoreData
- If tick updates lag → Debounce saveTimers()

### 3. Combine Pipeline Optimization

**Current Implementation:**
```swift
timerRepository.timersPublisher
    .map { timers in
        timers.sorted { $0.createdAt > $1.createdAt }  // ✅ O(n log n)
    }
    .assign(to: &$sortedTimers)
```

**Why It's Efficient:**
- Only sorts when repository changes
- SwiftUI's diffing handles incremental updates

**Don't:**
- ❌ Sort in View body (re-sorts every render)
- ❌ Multiple subscriptions to same publisher

### 4. Notification Cleanup

**Current Implementation:**
- Batch cancel by prefix (efficient)
- Cleanup on app activation (debounced)

**Why It's Efficient:**
```swift
// Cancel all 12 notifications at once
NotificationUtils.cancelNotifications(withPrefix: timerId.uuidString)

// vs. ❌ Individual cancellation
for i in 0..<12 {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(timerId)_\(i)"])
}
```

---

## 21. Future Improvements & Architecture Considerations

### Potential Enhancements

**1. WidgetKit Integration**
- Lock screen complications
- Show running timers on widget
- Quick start from widget

**2. Comprehensive Testing**
- Unit tests for state machines
- Integration tests for completion flow
- UI tests for critical paths

**3. Analytics Layer**
- Track user behavior
- Crash reporting (Firebase already integrated)
- Feature usage metrics

**4. Accessibility Improvements**
- VoiceOver optimization
- Dynamic Type support
- Haptic feedback patterns

**5. Advanced Features**
- Timer groups/categories
- Recurring timers
- Custom notification sounds
- Apple Watch companion

### Architecture Strengths

✅ **Clean Separation of Concerns**
- View → ViewModel → Service → Repository → Data
- Each layer has single responsibility

✅ **Protocol-Based Dependencies**
- Testability through mocking
- Flexibility to swap implementations

✅ **Reactive Programming**
- Combine reduces imperative code
- Automatic UI updates

✅ **Explicit State Management**
- Enum-based states prevent invalid states
- Type-safe transitions

✅ **Smart Completion Handling**
- Separate `TimerCompletionHandler` class
- Async countdown with cancellation

### Architecture Trade-offs

⚠️ **UserDefaults Limitation**
- Works for <100 items
- Consider CoreData if scaling

⚠️ **1Hz Tick Loop**
- Simple but not sub-second accuracy
- Consider Combine.Timer for reactive alternative

⚠️ **Local Notifications Only**
- Can't guarantee delivery
- Consider APNs for critical timers

---

## Summary: Quick Reference

### When Adding Features

1. **Add data field** → Update Model + Codable + Migration
2. **Add user action** → Update ButtonType + Mapping + Service + ViewModel
3. **Add screen** → Create View + ViewModel + inject dependencies
4. **Add business logic** → Update Service (not Repository)

### When Debugging

1. **Check logs** → Use OSLog categories (timer, persistence, notification, ui)
2. **Verify data flow** → Repository → Service → ViewModel → View
3. **Inspect persistence** → UserDefaults keys: "running_timers", "user_presets"
4. **Test notifications** → Check pending count, verify IDs

### Critical Rules

🚨 **NEVER:**
- Modify TimerData/TimerPreset outside Repository
- Create Service/Repository instances in ViewModels
- Access Repository from background thread
- Schedule >64 notifications
- Skip notification cleanup

✅ **ALWAYS:**
- Route through TimerService for timer operations
- Inject dependencies via protocols
- Use @MainActor for UI updates
- Localize user-facing strings
- Handle Codable errors gracefully

---

**Document Version:** 2.0
**Last Updated:** 2025-01-06
**iOS Target:** 16.0+
**Swift Version:** 5.9+
