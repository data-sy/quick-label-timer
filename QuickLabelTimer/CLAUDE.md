# QuickLabelTimer - AI Collaboration Guide

> **Purpose:** Fast, actionable reference for Claude Code. For detailed explanations, see `/docs/*.md`.

## Tech Stack

- **SwiftUI** - UI framework
- **Combine** - Reactive state management
- **UserDefaults** - Persistence (JSON)
- **UserNotifications** - Local notifications
- **OSLog** - Logging
- **Firebase** - Crashlytics
- **Target:** iOS 16.0+, iPhone only

## Build & Development Commands

```bash
# Open project
open QuickLabelTimer/QuickLabelTimer.xcodeproj

# Build (in Xcode)
Product → Build (⌘B)

# Run (in Xcode)
Product → Run (⌘R)

# Run tests (in Xcode)
Product → Test (⌘U)
```

**Note:** Project uses `.xcodeproj` (not `.xcworkspace`)

## Architecture: MVVM + Service/Repository

```
View (SwiftUI) → ViewModel (@MainActor) → Service → Repository → UserDefaults
                                             ↓
                                        Notifications
```

**Single Source of Truth:**
- `TimerRepository.timers` - Running timers
- `PresetRepository.userPresets` - Saved presets

**Dependencies:** Protocol-based, injected via `init()`, shared as `@EnvironmentObject`

## 🚨 CRITICAL RULES - NEVER BREAK THESE

### 1. Data Modification
❌ **NEVER** modify `TimerData`/`TimerPreset` directly in Views/ViewModels
```swift
// ❌ WRONG
timer.status = .paused

// ✅ CORRECT
timerService.pauseTimer(id: timer.id)
```

### 2. Service/Repository Instances
❌ **NEVER** create new instances in ViewModels
```swift
// ❌ WRONG
let timerService = TimerService()

// ✅ CORRECT
init(timerService: any TimerServiceProtocol) { ... }
```

### 3. Thread Safety
❌ **NEVER** access Repository from background thread
```swift
// ❌ WRONG
Task.detached { timerRepository.addTimer(...) }

// ✅ CORRECT
Task { @MainActor in timerRepository.addTimer(...) }
```

### 4. Notifications
❌ **NEVER** schedule >64 notifications (iOS limit)
❌ **NEVER** skip cancelling notifications on timer removal
```swift
// ✅ ALWAYS cancel first
NotificationUtils.cancelNotifications(withPrefix: timerId.uuidString)
timerRepository.removeTimer(byId: id)
```

### 5. Persistence
❌ **NEVER** use `try!` for Codable - use `do/catch` with fallback to `[]`

## Core Data Models

### TimerData (Running Timer)
```swift
struct TimerData: Identifiable, Codable {
    let id, label, hours, minutes, seconds: ...
    let isSoundOn, isVibrationOn: Bool
    let presetId: UUID?  // nil = instant timer

    var status: TimerStatus  // .running, .paused, .stopped, .completed
    var endDate: Date
    var remainingSeconds: Int
    var endAction: TimerEndAction  // .preserve (save as preset) or .discard
}
```

### TimerPreset (Saved Template)
```swift
struct TimerPreset: Identifiable, Codable {
    let id, label, hours, minutes, seconds: ...
    var isHiddenInList: Bool  // Soft delete
}
```

**UserDefaults Keys:**
- `"running_timers"` → `[TimerData]`
- `"user_presets"` → `[TimerPreset]`

## State Machine: TimerInteractionState

**Purpose:** Separate UI state from data model state for flexible button combinations.

```
TimerData.status → TimerInteractionState → makeButtonSet() → UI Buttons
```

**Key Pattern:**
```swift
let state = timer.interactionState
let buttons = makeButtonSet(for: state, endAction: timer.endAction)

// Use buttons.left and buttons.right to determine UI
```

**Location:** `/Models/Interaction/*`
**Details:** See `docs/STATE_MACHINE_GUIDE.md`

## Timer Lifecycle

```
.running → .paused → .running → .stopped → .running
    ↓                                          ↓
.completed (10s countdown) → deleted
```

**Tick Loop:** 1Hz update via `TimerService.tick()`, only updates when `remainingSeconds` changes

**Completion:** Handled by `TimerCompletionHandler` with 10-second countdown

## Notifications

**Pattern:** 12 notifications over 36 seconds (every 3s) with escalating visual indicators

**ID Format:** `"{timerId}_{index}"` for batch cancellation

**Critical:**
- Always cancel on timer removal: `NotificationUtils.cancelNotifications(withPrefix: timerId.uuidString)`
- Check iOS 64-notification limit
- Delegate suppresses foreground notifications (except first)

**Details:** See `docs/NOTIFICATION_SYSTEM.md`

## 🔧 Common Tasks - Quick Recipes

### Add New Timer Property
1. Update `TimerData` struct
2. Add migration in `init(from:)` with default value
3. Update `TimerService.addTimer()` parameter
4. Update `AddTimerViewModel` with `@Published` var
5. Update `AddTimerView` UI

### Add New Button Action
1. Add case to `TimerLeftButtonType` or `TimerRightButtonType`
2. Update `makeButtonSet()` in `TimerButtonMapping.swift`
3. Add service method (e.g., `TimerService.duplicateTimer()`)
4. Handle in ViewModel's `handleLeft()`/`handleRight()`
5. Update button view component

### Add New Timer State
1. Add case to `TimerStatus`
2. Update `TimerInteractionState` conversion
3. Update `makeButtonSet()` logic
4. Update state transition functions in `TimerInteractionTransition.swift`
5. Handle in `TimerService.tick()` if needed

### Debug Timer Not Updating
- [ ] Check tick loop started: Log in `TimerService.tick()`
- [ ] Check status is `.running`
- [ ] Check ViewModel subscribes to `timerRepository.timersPublisher`
- [ ] Check `@EnvironmentObject` injected in View
- [ ] Check Console for errors

### Debug Notification Not Firing
- [ ] Check authorization in AppDelegate
- [ ] Check notification scheduled: `UNUserNotificationCenter.current().getPendingNotificationRequests()`
- [ ] Check ID format: `"{timerId}_{index}"`
- [ ] Check app state (delegate suppresses foreground)

## File Structure

```
QuickLabelTimer/
├── QuickLabelTimerApp.swift      # App entry, single instance creation
├── AppDelegate.swift             # Notification setup
├── Configuration/AppConfig.swift # Constants (max timers, notification count)
├── Models/
│   ├── TimerData.swift
│   ├── TimerPreset.swift
│   ├── AlarmMode.swift           # UI: .sound, .vibration, .silent
│   ├── AlarmNotificationPolicy.swift
│   └── Interaction/              # State machine (5 files)
├── Repositories/
│   ├── TimerRepository.swift     # CRUD + persistence
│   └── PresetRepository.swift
├── Services/
│   ├── TimerService.swift        # Orchestration + tick loop
│   └── TimerCompletionHandler.swift  # 10s countdown logic
├── ViewModels/
│   ├── AddTimerViewModel.swift
│   ├── RunningListViewModel.swift
│   ├── FavoriteListViewModel.swift
│   └── EditPresetViewModel.swift
├── Views/
│   └── (organized by feature)
├── Notifications/
│   ├── NotificationUtils.swift
│   └── LocalNotificationDelegate.swift
└── Utils/
    ├── Logger+Extension.swift
    └── LabelSanitizer.swift
```

## Key Patterns

### Combine Reactive Updates
```swift
// ViewModel subscribes to repository
timerRepository.timersPublisher
    .map { timers in timers.sorted { $0.createdAt > $1.createdAt } }
    .assign(to: &$sortedTimers)
```

### Dependency Injection
```swift
// App entry point - create once
init() {
    let timerRepo = TimerRepository()
    let presetRepo = PresetRepository()
    let timerService = TimerService(timerRepository: timerRepo, presetRepository: presetRepo)

    _timerRepository = StateObject(wrappedValue: timerRepo)
    // ... inject via .environmentObject()
}
```

### Error Handling - Persistence
```swift
do {
    timers = try JSONDecoder().decode([TimerData].self, from: data)
} catch {
    Logger.persistence.error("Failed: \(error)")
    timers = []  // ✅ Graceful fallback
}
```

### @MainActor with Timer
```swift
timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
    Task { @MainActor in
        await self?.tick()  // ✅ Ensure main thread
    }
}
```

## Constants (AppConfig.swift)

- `maxConcurrentTimers = 5`
- `maxPresets = 20`
- `maxLabelLength = 100`
- `repeatingNotificationCount = 12`
- `notificationRepeatingInterval = 3.0` (seconds)
- `notificationSystemLimit = 64` (iOS max)
- `deleteCountdownSeconds = 10` (in TimerService)

## Logging

```swift
import OSLog

Logger.timer.info("Timer started: \(label)")
Logger.persistence.error("Failed to save: \(error)")
Logger.notification.debug("Scheduled: \(id)")
Logger.ui.notice("User action: \(action)")
```

**Levels:** `.debug` (verbose) → `.info` (important) → `.notice` (significant) → `.error` → `.fault` (critical)

## Localization

- **Files:**
  - `/Localizable.xcstrings` - Main string catalog
  - `/Localizable.stringsdict` - Pluralization rules
  - `/Utils/Accessibility+Helpers.swift` - Centralized accessibility strings
- **Languages:** English (en, source), Korean (ko)
- **Key Naming:** `{category}.{screen/component}.{element}`
  - `ui.*` - User interface text
  - `a11y.*` - Accessibility labels

**Quick Patterns:**
```swift
// Static text
Text("ui.timer.title")

// String variables
let msg = String(localized: "ui.alert.ok")

// Formatted strings (with dynamic values)
let label = String(format: String(localized: "%@, 남은 시간 %@"), name, time)

// Pluralization (uses .stringsdict)
let msg = String(format: String(localized: "ui.countdown.deleteTimer"), seconds)

// Accessibility (centralized in A11yText)
.accessibilityLabel(A11yText.TimerRow.startLabel)
```

**📖 For complete localization patterns and guidelines, see [`I18N_GUIDE.md`](I18N_GUIDE.md)**

## Testing

- **Framework:** Swift Testing (iOS 18+)
- **Location:** `/QuickLabelTimerTests/`

**Testable Patterns:**
- Protocol-based dependencies → Mock services
- Pure functions (`makeButtonSet`, state transitions) → Unit test
- Dependency injection → Test ViewModels in isolation

## Common Gotchas & Solutions

### 1. Retain Cycle in Combine
```swift
// ❌ WRONG
.sink { self.value = $0 }

// ✅ CORRECT (option 1)
.assign(to: &$value)

// ✅ CORRECT (option 2)
.sink { [weak self] in self?.value = $0 }
```

### 2. Migration for New Properties
```swift
// ✅ Provide default
init(from decoder: Decoder) throws {
    newProp = try container.decodeIfPresent(String.self, forKey: .newProp) ?? "default"
}
```

### 3. Notification ID Prefix for Batch Cancel
```swift
// Schedule with consistent prefix
let id = "\(timer.id)_\(index)"

// Cancel all at once
NotificationUtils.cancelNotifications(withPrefix: timer.id.uuidString)
```

### 4. Scene Phase Reconciliation
App reconciles on `.active` phase:
- Updates `remainingSeconds` for running timers
- Completes expired timers
- Resumes 10s countdown if needed

### 5. Soft Delete Pattern
Presets use `isHiddenInList` flag instead of deletion:
```swift
preset.isHiddenInList = true  // ✅ Can restore
```

## Performance Notes

- **Tick Loop:** Stops when no running timers (saves battery)
- **Persistence:** Saves on every mutation (acceptable for <100 items)
- **Combine:** Only sorts on repository change, not every render
- **Notifications:** Batch cancel by prefix (more efficient)

## App Lifecycle Events

**AppDelegate:**
- Firebase.configure()
- Request notification authorization
- Set notification delegate

**Scene Phase `.active`:**
- Reconcile timer states (check expired)
- Resume completion countdowns
- Clean up orphaned notifications

## Additional Documentation

- **`I18N_GUIDE.md`** - Complete internationalization guide: localization patterns, pluralization, accessibility strings, testing
- **`docs/ARCHITECTURE_DEEP_DIVE.md`** - Detailed MVVM explanation, design decisions, historical context
- **`docs/STATE_MACHINE_GUIDE.md`** - Complete TimerInteractionState system, all transitions, button mapping logic
- **`docs/NOTIFICATION_SYSTEM.md`** - Notification scheduling strategy, delegate handling, iOS limitations
- **`docs/DEVELOPMENT_GUIDE.md`** - Extended examples, debugging walkthroughs, common development scenarios

---

**Quick Reference Checklist:**

**Before modifying timers:**
- [ ] Route through `TimerService` (not Repository)
- [ ] Cancel notifications if removing
- [ ] Use `@MainActor` for all mutations

**Before adding features:**
- [ ] Update Model + Migration
- [ ] Update Service method
- [ ] Update ViewModel `@Published`
- [ ] Update View UI
- [ ] Update state machine if needed

**Before committing:**
- [ ] Test with multiple timers
- [ ] Test app backgrounding/foregrounding
- [ ] Check notification count (<64)
- [ ] Verify persistence works
- [ ] Check accessibility labels
- [ ] ❌ **Do NOT** add Claude Code signatures to commit messages

---

**Document Version:** 3.0 (AI-Optimized)
**Last Updated:** 2025-01-06
**Lines:** ~450 (optimized for Claude Code context efficiency)
