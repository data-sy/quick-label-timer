# Development Guide

> **Purpose:** Extended examples, debugging walkthroughs, and common development scenarios
>
> **Quick Reference:** See `/CLAUDE.md` for quick recipes

## Table of Contents

1. [Development Environment Setup](#development-environment-setup)
2. [Common Development Scenarios](#common-development-scenarios)
3. [Debugging Walkthroughs](#debugging-walkthroughs)
4. [Code Review Checklist](#code-review-checklist)
5. [Performance Profiling](#performance-profiling)
6. [Migration Guide](#migration-guide)

---

## Development Environment Setup

### Prerequisites

- Xcode 15.0+
- iOS 16.0+ (deployment target)
- macOS 13.0+ (for development)
- CocoaPods or SPM (for Firebase)

### First-Time Setup

1. **Clone repository:**
```bash
cd /path/to/quick-label-timer
```

2. **Open project:**
```bash
open QuickLabelTimer.xcodeproj
```

3. **Install dependencies:**
Firebase is already configured via SPM in the project.

4. **Configure Firebase:**
- Download `GoogleService-Info.plist` from Firebase Console
- Add to project root (already done if cloned)

5. **Build and run:**
- Select target: QuickLabelTimer
- Select device: iPhone simulator or physical device
- Press ⌘R

### Recommended Xcode Settings

**Editor:**
- Indent: 4 spaces (not tabs)
- Line length: 120 characters
- Trim trailing whitespace

**Build Settings:**
- Swift Language Version: Swift 5.9
- iOS Deployment Target: 16.0

---

## Common Development Scenarios

### Scenario 1: Add New Timer Property - Complete Walkthrough

**Goal:** Add `color: String` property to timers for visual categorization.

#### Step 1: Update Data Model

**File:** `/Models/TimerData.swift`

```swift
struct TimerData: Identifiable, Hashable, Codable {
    // ... existing properties ...

    var color: String  // ✅ Add new property

    // ... rest of struct ...
}
```

#### Step 2: Add Migration Logic

**Still in:** `/Models/TimerData.swift`

```swift
extension TimerData {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Existing properties
        id = try container.decode(UUID.self, forKey: .id)
        label = try container.decode(String.self, forKey: .label)
        // ... other existing properties ...

        // ✅ New property with migration
        color = try container.decodeIfPresent(String.self, forKey: .color) ?? "blue"
    }
}
```

**Why?** Old timers in UserDefaults don't have `color`, so provide default.

#### Step 3: Update Service

**File:** `/Services/TimerService.swift`

```swift
func addTimer(
    label: String,
    hours: Int,
    minutes: Int,
    seconds: Int,
    isSoundOn: Bool,
    isVibrationOn: Bool,
    color: String  // ✅ Add parameter
) -> Bool {
    // Validation...

    let timer = TimerData(
        id: UUID(),
        label: sanitizedLabel,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        isSoundOn: isSoundOn,
        isVibrationOn: isVibrationOn,
        createdAt: Date(),
        presetId: nil,
        status: .running,
        endDate: endDate,
        remainingSeconds: duration,
        pendingDeletionAt: nil,
        endAction: .discard,
        color: color  // ✅ Pass new property
    )

    // ...
}
```

#### Step 4: Update ViewModel

**File:** `/ViewModels/AddTimerViewModel.swift`

```swift
@MainActor
final class AddTimerViewModel: ObservableObject {
    @Published var label: String = ""
    @Published var hours: Int = 0
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    @Published var selectedMode: AlarmMode = .sound
    @Published var selectedColor: String = "blue"  // ✅ Add UI state

    // ...

    func startTimer() -> Bool {
        // ...
        let success = timerService.addTimer(
            label: sanitizedLabel,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            isSoundOn: isSoundOn,
            isVibrationOn: isVibrationOn,
            color: selectedColor  // ✅ Pass to service
        )
        // ...
    }
}
```

#### Step 5: Update View

**File:** `/Views/AddTimerView.swift`

```swift
struct AddTimerView: View {
    @ObservedObject var viewModel: AddTimerViewModel

    var body: some View {
        Form {
            // ... existing fields ...

            // ✅ Add color picker
            Section("Color") {
                Picker("Select Color", selection: $viewModel.selectedColor) {
                    Text("Blue").tag("blue")
                    Text("Red").tag("red")
                    Text("Green").tag("green")
                    Text("Yellow").tag("yellow")
                }
                .pickerStyle(.segmented)
            }
        }
    }
}
```

#### Step 6: Display in UI

**File:** `/Views/Components/TimerRow/TimerRow.swift`

```swift
struct TimerRow: View {
    let timer: TimerData

    var body: some View {
        HStack {
            // ✅ Show color indicator
            Circle()
                .fill(Color(timer.color))
                .frame(width: 12, height: 12)

            Text(timer.label)
            Spacer()
            Text(timeString)
        }
    }
}
```

#### Step 7: Test Migration

**Before deployment:**

1. **Test with existing data:**
   - Run app with old version (no `color` property)
   - Create timer
   - Upgrade to new version
   - Verify timer loads with default color "blue"

2. **Test new timers:**
   - Create timer with color "red"
   - Kill and restart app
   - Verify color persists

**Debugging migration:**
```swift
// Add temporary logging in TimerRepository.loadTimers()
do {
    timers = try JSONDecoder().decode([TimerData].self, from: data)
    Logger.persistence.debug("Loaded \(timers.count) timers")
    timers.forEach { Logger.persistence.debug("Timer \($0.id): color=\($0.color)") }
} catch {
    Logger.persistence.error("Migration failed: \(error)")
    timers = []
}
```

---

### Scenario 2: Add New Button Action - "Duplicate Timer"

**Goal:** Add duplicate button for stopped timers.

#### Step 1: Add Button Type

**File:** `/Models/Interaction/TimerLeftButtonType.swift`

```swift
enum TimerLeftButtonType: Equatable {
    case none
    case stop
    case moveToFavorite
    case delete
    case edit
    case duplicate  // ✅ New type
}
```

#### Step 2: Update Button Mapping

**File:** `/Models/Interaction/TimerButtonMapping.swift`

```swift
func makeButtonSet(
    for state: TimerInteractionState,
    endAction: TimerEndAction
) -> TimerButtonSet {
    switch state {
    // ... existing cases ...

    case .stopped:
        // ✅ Show duplicate instead of moveToFavorite/delete
        return TimerButtonSet(left: .duplicate, right: .restart)

    // ... other cases ...
    }
}
```

#### Step 3: Add Service Method

**File:** `/Services/TimerService.swift`

```swift
func duplicateTimer(id: UUID) -> Bool {
    guard let original = timerRepository.getTimer(byId: id) else {
        Logger.timer.error("Cannot duplicate: timer not found")
        return false
    }

    // Validate limit
    guard timerRepository.timers.count < AppConfig.maxConcurrentTimers else {
        Logger.timer.warning("Cannot duplicate: limit reached")
        return false
    }

    // Create duplicate with new ID
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

#### Step 4: Handle in ViewModel

**File:** `/ViewModels/RunningListViewModel.swift`

```swift
func handleLeft(for timer: TimerData) {
    let state = timer.interactionState
    let buttons = makeButtonSet(for: state, endAction: timer.endAction)

    switch buttons.left {
    // ... existing cases ...

    case .duplicate:
        let success = timerService.duplicateTimer(id: timer.id)
        if success {
            Logger.ui.info("Timer duplicated: \(timer.label)")
        } else {
            activeAlert = .timerLimitReached
        }

    // ... other cases ...
    }
}
```

#### Step 5: Update Button View

**File:** `/Views/Components/TimerRowButton/TimerLeftButton.swift`

```swift
struct TimerLeftButton: View {
    let buttonType: TimerLeftButtonType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            switch buttonType {
            // ... existing cases ...

            case .duplicate:
                Image(systemName: "doc.on.doc")
                    .accessibilityLabel("Duplicate timer")

            // ... other cases ...
            }
        }
    }
}
```

---

## Debugging Walkthroughs

### Debug: Timer Not Counting Down

**Symptom:** Timer created but `remainingSeconds` doesn't update in UI.

#### Investigation Steps

**1. Check Tick Loop:**

```swift
// Add to TimerService.tick()
func tick() {
    let runningTimers = timerRepository.getAllTimers().filter { $0.status == .running }

    Logger.timer.debug("🔄 Tick - Running: \(runningTimers.count)")  // ✅ Add

    if runningTimers.isEmpty {
        Logger.timer.debug("⏹ Stopping tick loop")  // ✅ Add
        stopTicking()
        return
    }

    // ...
}
```

**Run app and check Console:**
- If no `🔄 Tick` logs → Tick loop not started
- If `⏹ Stopping tick loop` → Timer status not `.running`

**2. Verify Tick Loop Started:**

```swift
// Add to TimerService.addTimer()
func addTimer(...) -> Bool {
    // ... create timer ...

    timerRepository.addTimer(timer)

    Logger.timer.debug("✅ Timer added: \(timer.id)")  // ✅ Add

    if !isTickerActive {
        Logger.timer.debug("▶️ Starting tick loop")  // ✅ Add
        startTicking()
    }

    return true
}
```

**Check Console:**
- Should see `▶️ Starting tick loop` when first timer added

**3. Check Timer Status:**

```swift
// In RunningListViewModel
timerRepository.timersPublisher
    .handleEvents(receiveOutput: { timers in
        Logger.ui.debug("📊 Received \(timers.count) timers")  // ✅ Add
        timers.forEach { timer in
            Logger.ui.debug("  - \(timer.label): \(timer.status), \(timer.remainingSeconds)s")  // ✅ Add
        }
    })
    .map { /* ... */ }
    .assign(to: &$sortedTimers)
```

**Check Console:**
- Status should be `.running`
- `remainingSeconds` should decrease each second

**4. Check ViewModel Subscription:**

```swift
// Verify @EnvironmentObject injection
struct RunningTimerListView: View {
    @EnvironmentObject var timerRepository: TimerRepository

    var body: some View {
        // ✅ Add debug print
        let _ = Logger.ui.debug("📱 RunningTimerListView rendered with \(viewModel.sortedTimers.count) timers")

        List(viewModel.sortedTimers) { timer in
            TimerRow(timer: timer)
        }
    }
}
```

**Check Console:**
- Should see re-render logs every second (as `remainingSeconds` changes)

#### Common Causes & Solutions

| Symptom | Cause | Solution |
|---------|-------|----------|
| No tick logs | Tick loop not started | Check `startTicking()` called in `addTimer()` |
| Tick logs but status = .paused | Wrong status set | Check timer creation in `addTimer()` |
| Status = .running but UI not updating | ViewModel not subscribed | Check `@EnvironmentObject` injection |
| Subscription works but UI stale | SwiftUI not detecting change | Verify `@Published` on repository |

---

### Debug: Notification Not Firing

**Symptom:** Timer completes but no notification appears.

#### Investigation Steps

**1. Check Authorization:**

```swift
// In AppDelegate or debugging code
Task {
    let settings = await UNUserNotificationCenter.current().notificationSettings()
    Logger.notification.debug("Authorization status: \(settings.authorizationStatus.rawValue)")
    // 0 = notDetermined, 1 = denied, 2 = authorized, 3 = provisional
}
```

**If denied:** User must enable in Settings > Notifications > QuickLabelTimer

**2. Check Notification Scheduled:**

```swift
// After scheduleRepeatingNotifications() call
Task {
    let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
    let matching = pending.filter { $0.identifier.hasPrefix(timerIdString) }

    Logger.notification.debug("📅 Scheduled \(matching.count) notifications for timer")
    matching.forEach { Logger.notification.debug("  - \($0.identifier) at \($0.trigger)") }
}
```

**Expected:** 12 notifications with IDs `{timerId}_0` through `{timerId}_11`

**3. Verify ID Format:**

```swift
// In scheduleRepeatingNotifications()
for i in 0..<count {
    let notificationId = "\(timer.id)_\(i)"  // ✅ Must match this format

    Logger.notification.debug("📢 Scheduling: \(notificationId)")  // ✅ Add

    NotificationUtils.scheduleNotification(/* ... */)
}
```

**4. Test with Immediate Notification:**

```swift
// Force trigger in 1 second (testing)
NotificationUtils.scheduleNotification(
    id: "test_immediate",
    title: "Test",
    body: "This should fire immediately",
    interval: 1.0,
    sound: .default
)
```

**Expected:** Notification appears in 1 second

**If doesn't appear:** Notification system broken (check authorization, restart device)

#### Common Causes & Solutions

| Symptom | Cause | Solution |
|---------|-------|----------|
| No notification at all | Authorization denied | Guide user to Settings |
| Notification silent | Sound set to nil | Check `AlarmNotificationPolicy` |
| Only first notification fires | Subsequent notifications cancelled | Check delegate not over-suppressing |
| Notification delayed | System busy | Normal iOS behavior, can't fix |

---

### Debug: Persistence Not Working

**Symptom:** Create timer, kill app, relaunch - timer gone.

#### Investigation Steps

**1. Verify Save Called:**

```swift
// In TimerRepository.saveTimers()
private func saveTimers() {
    Logger.persistence.debug("💾 Saving \(timers.count) timers")  // ✅ Add

    do {
        let data = try JSONEncoder().encode(timers)
        UserDefaults.standard.set(data, forKey: userDefaultsKey)

        Logger.persistence.debug("✅ Saved \(data.count) bytes")  // ✅ Add
    } catch {
        Logger.persistence.error("❌ Save failed: \(error)")
    }
}
```

**Check Console:**
- Should see `💾 Saving` after every timer mutation
- Should see `✅ Saved X bytes`

**2. Verify Load Called:**

```swift
// In TimerRepository.init()
init() {
    Logger.persistence.debug("📂 Loading timers...")  // ✅ Add
    loadTimers()
    Logger.persistence.debug("📂 Loaded \(timers.count) timers")  // ✅ Add
}
```

**Check Console:**
- Should see `📂 Loading timers...` on app launch
- Should show count of loaded timers

**3. Check UserDefaults Directly:**

```swift
// In debugging code or Console
if let data = UserDefaults.standard.data(forKey: "running_timers") {
    Logger.persistence.debug("📊 UserDefaults has \(data.count) bytes")

    if let timers = try? JSONDecoder().decode([TimerData].self, from: data) {
        Logger.persistence.debug("✅ Can decode \(timers.count) timers")
    } else {
        Logger.persistence.error("❌ Cannot decode")
    }
} else {
    Logger.persistence.error("❌ No data in UserDefaults")
}
```

**4. Verify Codable Implementation:**

```swift
// Test encoding/decoding
let timer = TimerData(/* ... */)

do {
    let encoded = try JSONEncoder().encode(timer)
    let decoded = try JSONDecoder().decode(TimerData.self, from: encoded)

    Logger.persistence.debug("✅ Codable works")
} catch {
    Logger.persistence.error("❌ Codable broken: \(error)")
}
```

#### Common Causes & Solutions

| Symptom | Cause | Solution |
|---------|-------|----------|
| saveTimers() not called | Missing trigger | Check addTimer/updateTimer/removeTimer call saveTimers() |
| Encoding fails | Codable broken | Check all properties are Codable |
| UserDefaults empty | Wrong key | Verify `userDefaultsKey = "running_timers"` |
| Data exists but load fails | Schema changed | Add migration in `init(from:)` |

---

## Code Review Checklist

### Before Submitting PR

#### Architecture Compliance

- [ ] Views don't contain business logic
- [ ] ViewModels don't access Repository directly
- [ ] Services don't access Views
- [ ] All Services/Repositories are `@MainActor`
- [ ] Dependencies injected via protocols

#### Data Safety

- [ ] No direct modification of `TimerData`/`TimerPreset` outside Repository
- [ ] Notifications cancelled before timer removal
- [ ] UserDefaults writes wrapped in do/catch
- [ ] Migration provided for new Codable properties

#### State Management

- [ ] State transitions use `makeButtonSet()` function
- [ ] Button handlers in ViewModel, not View
- [ ] `@Published` properties for all UI state
- [ ] Combine subscriptions don't create retain cycles

#### Thread Safety

- [ ] No `Task.detached` accessing Repository
- [ ] Timer callbacks use `Task { @MainActor in }`
- [ ] Background operations explicitly marked

#### Localization

- [ ] User-facing strings use String Catalog keys
- [ ] No hardcoded English strings
- [ ] Accessibility labels provided

#### Testing

- [ ] Pure functions have unit tests
- [ ] ViewModels testable with mock services
- [ ] Edge cases considered (empty timers, limit reached, etc.)

---

## Performance Profiling

### Instruments - Time Profiler

**Measure tick loop performance:**

1. Open Instruments (⌘I)
2. Select "Time Profiler"
3. Run app with 5 running timers
4. Filter call tree to `TimerService.tick`

**Expected:**
- `tick()` takes <1ms per call
- Called every 1 second
- Total CPU: <0.1% with 5 timers

### Measure Persistence Performance

```swift
// In TimerRepository.saveTimers()
let start = Date()
// ... encode and save ...
let duration = Date().timeIntervalSince(start)

Logger.persistence.debug("💾 Save took \(duration * 1000)ms")
```

**Expected:** <10ms for 5 timers

### Memory Leaks

**Check for retain cycles:**

1. Run app in Instruments (Leaks)
2. Create timers
3. Navigate between screens
4. Check for growing memory

**Common leak sources:**
- Combine subscriptions without `[weak self]`
- Timer callbacks without `[weak self]`
- Notification observers not removed

---

## Migration Guide

### Adding New Property to TimerData

**Template:**

```swift
// 1. Add property to struct
struct TimerData {
    var newProperty: Type  // ✅ Add
}

// 2. Provide migration
extension TimerData {
    init(from decoder: Decoder) throws {
        // ... existing properties ...

        // ✅ New property with default
        newProperty = try container.decodeIfPresent(Type.self, forKey: .newProperty) ?? defaultValue
    }
}

// 3. Update all initializers
let timer = TimerData(
    // ... existing ...
    newProperty: value  // ✅ Add
)
```

### Changing UserDefaults Key

**Don't break existing installations:**

```swift
// ❌ WRONG: Just change key
private let userDefaultsKey = "timers_v2"

// ✅ CORRECT: Migrate old data
init() {
    if let newData = UserDefaults.standard.data(forKey: "timers_v2") {
        // Load new format
        timers = decode(newData)
    } else if let oldData = UserDefaults.standard.data(forKey: "timers") {
        // Migrate from old format
        timers = decode(oldData)
        saveTimers()  // Save in new format
        UserDefaults.standard.removeObject(forKey: "timers")  // Clean up
    } else {
        timers = []
    }
}
```

---

## Summary

**Key Development Principles:**

1. **Follow Architecture:** MVVM + Service + Repository strictly
2. **Test Persistence:** Always test migration before releasing
3. **Debug Systematically:** Use logging at every layer
4. **Profile Performance:** Measure tick loop and persistence
5. **Review Checklist:** Follow before submitting PR

**Common Patterns:**
- Add property → Update Model + Migration + Service + ViewModel + View
- Add button → Update ButtonType + Mapping + Service + ViewModel + View
- Debug → Log at View → ViewModel → Service → Repository layers

**Remember:** "Make it work, make it right, make it fast" - in that order.
