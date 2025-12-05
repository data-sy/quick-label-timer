# QuickLabelTimer - Architecture Overview

## Executive Summary

QuickLabelTimer is an iOS SwiftUI timer application following an **MVVM (Model-View-ViewModel)** architecture pattern with a clear separation of concerns. The app manages multiple concurrent timers, presets, and notifications, emphasizing user experience through a sophisticated state management system and smart completion handling.

**Key Technologies:**
- SwiftUI (UI Framework)
- Combine (Reactive Programming)
- UserDefaults (Data Persistence)
- UserNotifications Framework (Local Notifications)
- OSLog (Logging)
- Firebase (Crash Reporting)

**Architecture Score: Mature**
- Protocols-based dependencies for testability
- Clean separation of UI, business logic, and data layers
- Observable objects with Combine publishers for reactivity
- Explicit state management with enum-based state models

---

## 1. Overall Architecture Pattern: MVVM

The application follows a strict MVVM architecture with an additional Service/Repository layer:

```
┌─────────────────────────────────────────────────────────────────┐
│                          VIEWS (SwiftUI)                        │
│              (Presentational Components Only)                   │
└──────────────────────────┬──────────────────────────────────────┘
                           │ @EnvironmentObject / @Published
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│                     VIEWMODELS (@MainActor)                     │
│  - AddTimerViewModel (Handles timer creation input)             │
│  - RunningListViewModel (Manages running timers UI state)       │
│  - FavoriteListViewModel (Manages presets UI state)             │
│  - SettingsViewModel (App settings)                             │
│  - EditPresetViewModel (Preset editing)                         │
└──────────────────────────┬──────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
┌───────▼────────┐  ┌──────▼─────────┐  ┌───▼──────────────┐
│ TimerService   │  │   TimerRepo    │  │ PresetRepository │
│ (@MainActor)   │  │ (@MainActor)   │  │ (@MainActor)     │
└──────┬─────────┘  └────┬───────────┘  └────┬─────────────┘
       │                 │                    │
       └─────────────────┼────────────────────┘
                         │
              ┌──────────▼─────────────┐
              │    Data Models         │
              │ - TimerData            │
              │ - TimerPreset          │
              │ - Interaction State    │
              │ - AlarmNotificationPolicy
              │ - AlarmMode            │
              └────────────────────────┘
```

### Key MVVM Characteristics:

1. **View Layer (SwiftUI Components)**
   - Pure presentational components (no business logic)
   - Bind to @Published properties from ViewModels
   - Dispatch user actions to ViewModel methods
   - Located in `/Views` folder

2. **ViewModel Layer (@MainActor)**
   - Inherits `ObservableObject` for SwiftUI integration
   - Marked `@MainActor` to ensure UI updates on main thread
   - Uses `@Published` properties for reactive updates
   - Handles user interactions (button clicks, input)
   - Coordinates between Views and Services
   - Manages local UI state (alerts, selection, etc.)

3. **Service Layer**
   - `TimerService`: Orchestrates timer lifecycle, state transitions, notifications
   - `TimerCompletionHandler`: Handles post-completion logic
   - `AlarmHandler`: Bridges to alarm capabilities (now deprecated, using notifications)
   - `AlarmPlayer`: Audio playback (deprecated, kept for potential future use)

4. **Repository Layer**
   - `TimerRepository`: CRUD operations and persistence for running timers
   - `PresetRepository`: CRUD operations and persistence for timer presets
   - Both implement protocols for testing/dependency injection
   - Persist to UserDefaults (JSON-encoded)

---

## 2. Timer Management System

### Core Timer Model: `TimerData`

```swift
struct TimerData: Identifiable, Hashable, Codable {
    // Identity & Configuration
    let id: UUID
    let label: String
    let hours, minutes, seconds: Int
    let isSoundOn: Bool
    let isVibrationOn: Bool
    let createdAt: Date
    let presetId: UUID?  // nil = instant timer, non-nil = preset-based
    
    // Runtime State
    var status: TimerStatus           // .running, .paused, .stopped, .completed
    var endDate: Date                 // When timer should reach 0
    var remainingSeconds: Int         // Current countdown
    var pendingDeletionAt: Date?      // Scheduled deletion (10-sec countdown)
    var endAction: TimerEndAction     // .preserve or .discard
}
```

#### Timer Lifecycle States:

```
.running → .paused → .running → .stopped ↘
   ↓                                       → .completed → (10s countdown) → deleted
   └──────────────────────────────────────↗
```

**State Meanings:**
- `.running`: Timer is actively counting down
- `.paused`: Timer is paused, can be resumed
- `.stopped`: User stopped it, can be restarted
- `.completed`: Timer reached 0, in 10-second deletion countdown
- Deleted: Removed from list (either immediately or after countdown)

### Timer Repository: Data Persistence

**Location:** `/Repositories/TimerRepository.swift`

```swift
@MainActor
final class TimerRepository: ObservableObject, TimerRepositoryProtocol {
    @Published var timers: [TimerData] = []
    
    // Core CRUD Operations
    func addTimer(_ timer: TimerData)
    func getTimer(byId id: UUID) -> TimerData?
    func updateTimer(_ timer: TimerData)
    func removeTimer(byId id: UUID) -> TimerData?
    
    // Persistence
    private func saveTimers()    // UserDefaults via JSONEncoder
    private func loadTimers()    // UserDefaults via JSONDecoder
}
```

**Key Features:**
- Single source of truth for running timers
- Automatic persistence to UserDefaults on every change
- Uses Codable for JSON serialization
- `@Published` for reactive updates to ViewModels via Combine

### Timer Service: Business Logic & Orchestration

**Location:** `/Services/TimerService.swift`

```swift
@MainActor
final class TimerService: ObservableObject, TimerServiceProtocol {
    private let timerRepository: TimerRepositoryProtocol
    private let presetRepository: PresetRepositoryProtocol
    private var timer: Timer?  // 1Hz tick loop
    
    // CRUD
    func addTimer(label:...) -> Bool
    func runTimer(from preset: TimerPreset) -> Bool
    func removeTimer(id: UUID) -> TimerData?
    
    // Control
    func pauseTimer(id: UUID)
    func resumeTimer(id: UUID)
    func stopTimer(id: UUID)
    func restartTimer(id: UUID)
    
    // Completion
    func userDidConfirmCompletion(for timerId: UUID)
    func userDidRequestDelete(for timerId: UUID)
    
    // Scene Lifecycle
    func updateScenePhase(_ phase: ScenePhase)
}
```

**Core Mechanism: Tick Loop**
```swift
func startTicking() {
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        Task { await self?.tick() }
    }
}

func tick() {
    updateTimerStates()  // Every second: compute remaining, trigger completion
}
```

The app updates all running timers every second by calculating `max(0, Int(endDate.timeIntervalSince(now)))`.

**Key Responsibilities:**
1. Manage 1Hz ticker for countdown updates
2. Transition timers through states based on elapsed time
3. Trigger completion process when timer reaches 0
4. Handle app lifecycle (foreground/background transitions)
5. Schedule/cancel local notifications
6. Coordinate with TimerCompletionHandler for post-completion logic

---

## 3. Alarm & Notification System

### Alarm Modes

**Location:** `/Models/AlarmMode.swift`

User-facing options in UI:
```swift
enum AlarmMode: String, CaseIterable {
    case sound       // "소리"
    case vibration   // "진동"
    case silent      // "무음"
}
```

### Alarm Notification Policy

**Location:** `/Models/AlarmNotificationPolicy.swift`

Maps user settings to technical implementation:
```swift
enum AlarmNotificationPolicy {
    case soundAndVibration    // System default + haptics
    case vibrationOnly        // Silent audio file + haptics
    case silent              // Visual banner only
    
    static func determine(soundOn: Bool, vibrationOn: Bool) -> Self
    static func from(mode: AlarmMode) -> Self
}
```

**Bridge between UI and notifications:**
- `AlarmMode` (UI selector) ↔ `AlarmNotificationPolicy` (technical policy) ↔ `UNNotificationSound` (system)

### Local Notification Strategy

**Architecture:**
- Moved from in-app audio playback to iOS local notifications (UserNotifications framework)
- Decreases power usage and respects system settings
- Supports notification while app is in background/suspended

**Repeating Notification Pattern:**
```
When timer completes, schedule N notifications (default 12):
- First: immediate (first alert)
- 2nd-12th: every 3 seconds with escalating visual indicator
  └─ "눌러서 알람 끄기 ⏰"
  └─ "눌러서 알람 끄기 ⏰⏰"
  └─ "눌러서 알람 끄기 ⏰⏰⏰"
  ...
```

This ensures users don't miss notifications even if they dismiss one.

**Configuration:**
- `AppConfig.repeatingNotificationCount = 12`
- `AppConfig.notificationRepeatingInterval = 3.0` (seconds)
- `AppConfig.notificationSystemLimit = 64` (iOS max per app)

### Notification Utilities

**Location:** `/Notifications/NotificationUtils.swift`

```swift
enum NotificationUtils {
    // Request permissions
    static func requestAuthorization()
    
    // Schedule
    static func scheduleNotification(id:..., interval:, sound:...)
    
    // Cancel by prefix (all notifications for a timer)
    static func cancelNotifications(withPrefix: String)
    static func cancelPending(withPrefix: String)
    static func cancelDelivered(withPrefix: String)
}
```

**Key Detail:** Notification IDs use format `"{timerId}_{index}"` to enable batch operations by prefix.

### Local Notification Delegate

**Location:** `/Notifications/LocalNotificationDelegate.swift`

Handles two events:

1. **Foreground Reception (`willPresent`)**
   - First notification (index=0): Show banner + sound
   - Subsequent notifications: Suppress (prevent spam)
   - Cleanup pending/delivered notifications except current

2. **User Interaction (`didReceive`)**
   - User tapped notification → Cancel all related notifications
   - Prevents continued nagging after dismissal

---

## 4. Preset (Favorites) System

### Preset Model

**Location:** `/Models/TimerPreset.swift`

```swift
struct TimerPreset: Identifiable, Codable, Hashable {
    let id: UUID
    let label: String
    let hours, minutes, seconds: Int
    let isSoundOn: Bool
    let isVibrationOn: Bool
    let createdAt: Date
    
    var lastUsedAt: Date     // For potential "recent" sorting
    var isHiddenInList: Bool // Deleted preset (soft delete)
}
```

### Preset Repository

**Location:** `/Repositories/PresetRepository.swift`

```swift
@MainActor
final class PresetRepository: ObservableObject {
    @Published var userPresets: [TimerPreset] = []
    
    // CRUD
    func addPreset(from timer: TimerData) -> Bool
    func updatePreset(_ preset:..., label:..., hours:...) -> Bool
    func deletePreset(_ preset: TimerPreset)
    
    // Visibility (soft delete)
    func hidePreset(withId id: UUID)
    func showPreset(withId id: UUID)
    
    // Queries
    var allPresets: [TimerPreset]
    var visiblePresetsCount: Int
}
```

**Limit:** Max 20 presets (configurable in app logic)

### Preset Lifecycle & Completion Handling

**Key Flow:**

```
User Creates Instant Timer
         ↓
    Timer Runs
         ↓
    Timer Completes (endAction = ?)
         ↓
    ┌────────────────────┐
    │  endAction Type?   │
    └────────┬───────────┘
             │
    ┌────────┴────────┐
    │                 │
.preserve      .discard
    │                 │
    ↓                 ↓
Save as        Delete
Preset    (or Hide if preset-based)
```

---

## 5. State Management: TimerInteractionState System

This is a sophisticated pattern separating **data model state** from **UI interaction state**.

### Data Model State vs. UI State

```
TimerData.status (Internal Model State)
    ├─ .running
    ├─ .paused
    ├─ .stopped
    └─ .completed
                ↓
        [CONVERSION]
                ↓
TimerInteractionState (UI Presentation State)
    ├─ .preset      (Special: for favorites list)
    ├─ .running
    ├─ .paused
    ├─ .stopped
    └─ .completed
```

**Location:** `/Models/Interaction/`

### 1. Core State Enum

**`TimerInteractionState.swift`:**
```swift
enum TimerInteractionState {
    case preset        // Favorites list display (unique to UI)
    case running
    case paused
    case stopped
    case completed
}
```

### 2. State Conversion Extension

**`TimerData+InteractionState.swift`:**
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
```

### 3. State Transitions

**`TimerInteractionTransition.swift`:**

Defines valid state transitions based on user button presses:

```swift
// Right button transitions (play/pause/restart)
func nextState(
    from current: TimerInteractionState,
    right button: TimerRightButtonType
) -> TimerInteractionState {
    switch (current, button) {
    case (.preset, .play):                 return .running
    case (.running, .pause):               return .paused
    case (.paused, .play):                 return .running
    case (.stopped, .restart):             return .running
    case (.completed, .restart):           return .running
    default:                               return current
    }
}

// Left button (mostly data changes, minimal state transition)
func nextState(
    from current: TimerInteractionState,
    left button: TimerLeftButtonType
) -> TimerInteractionState {
    switch (current, button) {
    case (.running, .stop):                return .stopped
    case (_, .moveToFavorite), (_, .delete): return current  // No state change
    default:                               return current
    }
}
```

### 4. Button Mapping

**`TimerButtonMapping.swift`:**

Pure function to determine which buttons should appear:

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
        let leftButton: TimerLeftButtonType = 
            endAction.isPreserve ? .moveToFavorite : .delete
        return TimerButtonSet(left: leftButton, right: .restart)
    }
}
```

### 5. Button Types

**`TimerLeftButtonType.swift`:**
```swift
enum TimerLeftButtonType: Equatable {
    case none
    case stop           // Stop running timer
    case moveToFavorite // Convert instant timer to preset
    case delete         // Delete timer
    case edit           // Edit preset
}
```

**`TimerRightButtonType.swift`:**
```swift
enum TimerRightButtonType: Equatable {
    case play           // Start or resume
    case pause          // Pause running timer
    case restart        // Restart stopped/completed
}
```

### Why This Pattern?

1. **Decouples UI from data model:** UI state can differ from storage state
2. **Type safety:** Enums prevent invalid button combinations
3. **Testability:** Pure functions (no side effects)
4. **Maintainability:** Central place to define valid transitions
5. **Reusability:** ButtonMapping is used by both RunningListViewModel and FavoriteListViewModel

---

## 6. Timer Completion & Deletion Countdown

### The Completion Handler

**Location:** `/Services/TimerCompletionHandler.swift`

Separate class that handles the complex 10-second deletion countdown:

```swift
@MainActor
final class TimerCompletionHandler {
    private var countdownTasks: [UUID: Task<Void, Never>] = [:]
    
    /// When timer reaches 0, start 10-second countdown
    func scheduleCompletion(for timer: TimerData, after seconds: Int) {
        countdownTasks[timerId] = Task {
            for _ in 0..<seconds {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                onTick?(timerId)  // Callback for UI countdown display
            }
            await handle(timerId: timerId)  // Execute final logic
        }
    }
    
    /// Handle deletion immediately (user confirms)
    func handleCompletionImmediately(timerId: UUID) {
        Task { await handle(timerId: timerId) }
    }
    
    @MainActor
    private func handle(timerId: UUID) {
        // Determine what to do based on preset vs instant, preserve vs discard
        switch (latestTimer.presetId, latestTimer.endAction) {
        case (.none, .preserve):
            // Instant timer with .preserve → Save as new preset
            presetRepository.addPreset(from: latestTimer)
            timerService.removeTimer(id: timerId)
        
        case (.none, .discard):
            // Instant timer with .discard → Just delete
            timerService.removeTimer(id: timerId)
        
        case (.some, .preserve):
            // Preset-based with .preserve → Just delete timer
            timerService.removeTimer(id: timerId)
        
        case (.some(let presetId), .discard):
            // Preset-based with .discard → Hide preset
            presetRepository.hidePreset(withId: presetId)
            timerService.removeTimer(id: timerId)
        }
    }
}
```

### Why Separate?

1. **Single Responsibility:** TimerService handles runtime, CompletionHandler handles finalization
2. **Async Management:** Uses Swift Concurrency (Task) for clean countdown
3. **Testability:** Can mock callbacks
4. **Cancellation:** Easy to cancel pending deletions

---

## 7. Key Services and Their Responsibilities

### TimerService (@MainActor, ObservableObject)

**Responsibilities:**
1. Manage 1Hz tick loop
2. Coordinate timer state transitions
3. Route timer lifecycle events
4. Manage notifications (schedule/cancel)
5. Handle scene lifecycle changes
6. Reconcile timers on app launch
7. Toggle favorite status (endAction)

**External Interface:**
```swift
// Queries
func getTimer(byId: UUID) -> TimerData?

// CRUD
func addTimer(label:..., hours:, minutes:, seconds:, ...) -> Bool
func runTimer(from preset: TimerPreset) -> Bool
func removeTimer(id: UUID) -> TimerData?

// Control
func pauseTimer(id: UUID)
func resumeTimer(id: UUID)
func stopTimer(id: UUID)
func restartTimer(id: UUID)

// Completion
func userDidConfirmCompletion(for timerId: UUID)
func userDidRequestDelete(for timerId: UUID)
func toggleFavorite(for id: UUID) -> Bool

// Notifications
func scheduleNotification(for timer: TimerData)
func scheduleRepeatingNotifications(...)
func stopTimerNotifications(for baseId: String)

// Lifecycle
func updateScenePhase(_ phase: ScenePhase)
```

### TimerCompletionHandler

Separated to handle post-completion logic:
- 10-second deletion countdown management
- Preset creation from instant timers
- Preset hiding
- Cancellation of pending operations

### PresetRepository (@MainActor, ObservableObject)

Manages preset persistence and CRUD.

### AlarmHandler (Deprecated)

Originally handled in-app audio playback. Now disabled in favor of local notifications. Code retained for potential future use (e.g., "silent sound" tricks).

### NotificationUtils (Static Utility)

Centralized notification management:
- Request permissions
- Schedule individual notifications
- Cancel by prefix (for batch timer cleanup)
- Create appropriate sounds based on policy

### LocalNotificationDelegate

Handles two system callbacks:
- `willPresent`: Foreground notification display
- `didReceive`: User interaction (tapped notification)

---

## 8. ViewModels

All ViewModels are `@MainActor` and `ObservableObject`.

### AddTimerViewModel

**Responsibility:** Manage timer creation form input

```swift
@MainActor
class AddTimerViewModel: ObservableObject {
    @Published var label = ""
    @Published var hours = 0, minutes = 0, seconds = 0
    @Published var selectedMode: AlarmMode
    
    func startTimer()  // Validate and call timerService.addTimer()
}
```

### RunningListViewModel

**Responsibility:** Manage running timers list UI

```swift
@MainActor
class RunningListViewModel: ObservableObject {
    @Published var sortedTimers: [TimerData] = []  // Sorted newest first
    @Published var activeAlert: AppAlert?
    
    // Button action handlers
    func handleLeft(for timer: TimerData)
    func handleRight(for timer: TimerData)
    func toggleFavorite(for id: UUID)
    func handleMoveToPreset(for timer: TimerData)
}
```

Uses Combine to subscribe to `timerRepository.timersPublisher` and automatically sorts/transforms.

### FavoriteListViewModel

**Responsibility:** Manage presets list UI

```swift
@MainActor
class FavoriteListViewModel: ObservableObject {
    @Published var visiblePresets: [TimerPreset] = []
    @Published var runningPresetIds: Set<UUID> = []  // Which presets have running timers
    
    func handleLeft(for preset: TimerPreset)  // Edit
    func handleRight(for preset: TimerPreset) // Run
    func startEditing(for preset: TimerPreset)
    func runTimer(from preset: TimerPreset)
}
```

Uses Combine to:
1. Subscribe to `presetRepository.userPresetsPublisher` → filter visible, sort
2. Subscribe to `timerRepository.timersPublisher` → extract running preset IDs

### SettingsViewModel

Manages app-level settings (dark mode, etc.).

### EditPresetViewModel

Manages preset editing form.

---

## 9. Data Flow: Example - User Creates & Runs Timer

```
┌─ View: AddTimerView (form input)
│
└─→ ViewModel: AddTimerViewModel
    - Captures: label, hours, minutes, seconds, selectedMode
    - On "Create" button:
      1. Sanitize label
      2. Convert AlarmMode to AlarmNotificationPolicy bools
      3. Call timerService.addTimer(...)
      4. If success: reset form, close view
      5. If fail: show alert
    
    └─→ Service: TimerService.addTimer()
        - Validate concurrent timer limit (max 5)
        - Create new TimerData:
          * status = .running
          * endDate = now + duration
          * remainingSeconds = duration
          * presetId = nil (instant timer)
          * endAction = .discard
        - Add to timerRepository
        - Schedule repeating notifications
        - Return success
        
        └─→ Repository: TimerRepository.addTimer()
            - Append to @Published timers array
            - Save to UserDefaults
            - Trigger @Published update
            
            └─→ View: Automatically updates via @EnvironmentObject
                - Display in RunningTimerListView
```

---

## 10. App Lifecycle & Scene Phase Handling

### App Entry Point

**Location:** `/QuickLabelTimerApp.swift`

```swift
@main
struct QuickLabelTimerApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var timerRepository
    @StateObject private var presetRepository
    @StateObject private var timerService
    @StateObject private var settingsViewModel
    
    init() {
        // Deferred initialization to share repository instances
        let timerRepository = TimerRepository()
        let presetRepository = PresetRepository()
        let timerService = TimerService(timerRepository:, presetRepository:)
        
        _timerRepository = StateObject(wrappedValue: timerRepository)
        _presetRepository = StateObject(wrappedValue: presetRepository)
        _timerService = StateObject(wrappedValue: timerService)
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel())
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView(...)
                .environmentObject(timerService)
                .environmentObject(timerRepository)
                .environmentObject(presetRepository)
                .environmentObject(settingsViewModel)
        }
        .onChange(of: scenePhase) { _, newPhase in
            timerService.updateScenePhase(newPhase)
        }
    }
}
```

### App Delegate

**Location:** `/AppDelegate.swift`

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, 
                    didFinishLaunchingWithOptions: [...]) -> Bool {
        // 1. Initialize Firebase
        FirebaseApp.configure()
        
        // 2. Request notification permissions
        NotificationUtils.requestAuthorization()
        
        // 3. Set local notification delegate
        let delegate = LocalNotificationDelegate()
        UNUserNotificationCenter.current().delegate = delegate
        
        return true
    }
}
```

### Scene Phase Transitions

When scenePhase changes to `.active` (app comes to foreground):

```swift
func updateScenePhase(_ phase: ScenePhase) {
    guard phase == .active else { return }
    
    // Debounce: Don't run too frequently
    guard shouldRunActivationCleanup() else { return }
    
    // Collect timers that completed while app was backgrounded
    let candidates = collectCleanupCandidates(now: Date())
    
    // Cancel their pending notifications
    runActivationCleanup(for: candidates) {
        // Then finalize completion for those that weren't already handled
        finalizeCompletedTimers(candidates)
    }
}
```

### App Reconciliation on Launch

When app starts, reconcile saved timers:

```swift
private func reconcileTimersOnLaunch() {
    for timer in timerRepository.getAllTimers() {
        switch timer.status {
        
        case .running:
            let remaining = Int(timer.endDate.timeIntervalSince(now))
            if remaining <= 0 {
                // Timer expired while app was closed
                let completed = timer.updating(remainingSeconds: 0, status: .completed)
                timerRepository.updateTimer(completed)
                startCompletionProcess(for: completed)
            } else {
                // Update remaining seconds
                let updated = timer.updating(remainingSeconds: remaining)
                timerRepository.updateTimer(updated)
            }
        
        case .completed:
            let elapsedTime = now.timeIntervalSince(timer.endDate)
            if elapsedTime > TimeInterval(deleteCountdownSeconds) {
                // Deletion countdown finished, finalize now
                completionHandler.handleCompletionImmediately(timerId: timer.id)
            }
        
        default:
            // .paused, .stopped: no changes needed
            continue
        }
    }
}
```

---

## 11. Localization Setup

### String Catalog

**Location:** `/Localizable.xcstrings`

Modern Swift approach (iOS 16+) using `.xcstrings` file instead of `.strings` files.

**Structure:**
```json
{
  "sourceLanguage": "en",
  "strings": {
    "key": {
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "..." } },
        "ko": { "stringUnit": { "state": "translated", "value": "..." } }
      }
    }
  }
}
```

### Localization Keys

Keys follow pattern: `"a11y.context.element"` for accessibility strings

Examples:
- `"a11y.addTimer.createButton"` → "Create Timer" / "타이머 생성"
- `"%@, 남은 시간 %@"` → "%1$@, %2$@ remaining"

### Usage in Views

```swift
Text("a11y.addTimer.createButton")  // Automatically resolved
Button("Create", action: {})
    .accessibilityLabel("a11y.addTimer.createButton")
```

**Supported Languages:**
- English (en)
- Korean (ko)

---

## 12. Testing Approach

### Current Testing Setup

**Location:** `/QuickLabelTimerTests/QuickLabelTimerTests.swift`

Uses Swift `Testing` framework (iOS 18+):

```swift
import Testing

struct QuickLabelTimerTests {
    @Test func example() async throws {
        // Write tests here
    }
}
```

**Current Status:** Minimal (placeholder test)

### Testability Architecture

The codebase is designed to be testable:

1. **Protocol-Based Dependencies**
   ```swift
   protocol TimerRepositoryProtocol { ... }
   protocol PresetRepositoryProtocol { ... }
   protocol TimerServiceProtocol: ObservableObject { ... }
   ```
   Allows mocking in tests.

2. **Pure Functions**
   ```swift
   func makeButtonSet(for state: TimerInteractionState, ...) -> TimerButtonSet
   ```
   No side effects, easy to test.

3. **Dependency Injection**
   ```swift
   init(timerService: any TimerServiceProtocol, ...)
   ```
   ViewModels receive dependencies, not create them.

### Recommended Test Cases (Not Yet Implemented)

1. **TimerRepository:**
   - Adding/removing timers
   - Persistence roundtrip (save → load)

2. **TimerService:**
   - Timer countdown accuracy
   - State transitions (running → paused → running)
   - Completion triggering
   - Preset creation on instant timer completion

3. **State Machines:**
   - `TimerInteractionTransition` functions
   - `makeButtonSet` with all state/endAction combinations

4. **PresetRepository:**
   - Preset CRUD
   - Visibility toggling (soft delete)
   - Count limits

5. **ViewModels:**
   - Form validation (empty duration)
   - Button action handlers
   - Alert triggering on limits exceeded

---

## 13. Unique & Complex Patterns

### Pattern 1: TimerInteractionState System

Separates data model state from UI presentation state. This allows:
- Different UI representations without database schema changes
- Flexible button combinations based on multiple factors
- Type-safe transition logic

### Pattern 2: Repeating Notification Chain

Instead of a single notification, the app schedules 12 notifications over 36 seconds (3s apart). This ensures:
- Users don't miss notification in case of iOS's attention management
- Escalating visual emphasis (increasing clock emojis)
- Prevents notification fatigue while improving reliability

### Pattern 3: 10-Second Deletion Countdown

Completed timers aren't deleted immediately. They enter a 10-second state (`pendingDeletionAt`) where users can see the countdown. This:
- Prevents accidental deletion
- Allows users to see what was completed
- Gives time to move instant timer to favorites

Implemented via `TimerCompletionHandler` with Task-based async countdown.

### Pattern 4: Preset Hide vs. Delete (Soft Delete)

Presets aren't permanently deleted, they're hidden (`isHiddenInList`). This:
- Prevents losing user data
- Allows "show" operations to restore
- Maintains history/stats potential

### Pattern 5: EndAction for Intelligent Completion

`endAction: TimerEndAction (.preserve | .discard)` determines post-completion behavior:
- `.preserve`: Save instant timer as preset OR show hidden preset
- `.discard`: Delete instant timer OR hide associated preset

Allows single "favorite" toggle to control multiple completion flows.

### Pattern 6: Deferred ViewModel Initialization

In App entry point, repositories are initialized in `init()` and passed to StateObject:
```swift
let timerRepository = TimerRepository()
_timerRepository = StateObject(wrappedValue: timerRepository)
```

This allows dependency injection and prevents creating multiple instances.

### Pattern 7: Scene Phase Throttling

App activation cleanup is debounced (0.8s) to avoid rapid re-initialization if user quickly backgrounds/foregrounds app.

---

## 14. Configuration & Constants

**Location:** `/Configuration/AppConfig.swift`

```swift
enum AppConfig {
    // Input constraints
    static let maxLabelLength = 100
    
    // Timer & notification policies
    static let maxConcurrentTimers = 5
    static let repeatingNotificationCount = 12
    static let notificationRepeatingInterval: TimeInterval = 3.0
    static let notificationSystemLimit = 64
}
```

**Also in code:**
- `QuickLabelTimerApp.deleteCountdownSeconds = 10` (deletion countdown)
- Notification repetition: 12 × 3 = 36 second window

---

## 15. Key Dependencies & Frameworks

| Framework | Purpose |
|-----------|---------|
| **SwiftUI** | UI framework |
| **Combine** | Reactive programming (Publishers) |
| **AVFoundation** | Audio playback (now deprecated/unused) |
| **UserNotifications** | Local notifications |
| **AudioToolbox** | Vibration (deprecated) |
| **OSLog** | Structured logging |
| **Firebase** | Crash reporting (Crashlytics) |

---

## 16. File Structure Summary

```
QuickLabelTimer/
├── QuickLabelTimerApp.swift          # App entry point
├── AppDelegate.swift                 # App lifecycle
├── Configuration/
│   ├── AppConfig.swift              # Constants
│   └── AppTheme.swift               # Theme colors
├── Models/
│   ├── TimerData.swift              # Timer data model
│   ├── TimerPreset.swift            # Preset model
│   ├── AlarmMode.swift              # UI mode enum
│   ├── AlarmNotificationPolicy.swift # Policy enum
│   ├── AlarmSound.swift             # Sound definitions
│   └── Interaction/
│       ├── TimerInteractionState.swift
│       ├── TimerInteractionTransition.swift
│       ├── TimerLeftButtonType.swift
│       ├── TimerRightButtonType.swift
│       ├── TimerButtonSet.swift
│       └── TimerButtonMapping.swift
├── Repositories/
│   ├── TimerRepository.swift        # Running timers storage
│   └── PresetRepository.swift       # Presets storage
├── Services/
│   ├── TimerService.swift           # Main timer orchestration
│   ├── TimerCompletionHandler.swift # Completion logic
│   ├── AlarmHandler.swift           # (Deprecated)
│   ├── AlarmPlayer.swift            # (Deprecated)
│   └── TimerCompletionHandler.swift # Deletion countdown
├── ViewModels/
│   ├── AddTimerViewModel.swift
│   ├── RunningListViewModel.swift
│   ├── FavoriteListViewModel.swift
│   ├── EditPresetViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── Container/
│   │   └── MainTabView.swift
│   ├── Components/
│   │   ├── TimerRow/
│   │   ├── TimerRowButton/
│   │   ├── Input/
│   │   └── Common/
│   ├── Settings/
│   └── ...
├── Notifications/
│   ├── NotificationUtils.swift
│   ├── LocalNotificationDelegate.swift
│   └── NotificationScheduling.swift
├── Utils/
│   ├── TimeUtils.swift
│   ├── LabelSanitizer.swift
│   ├── Logger+Extension.swift
│   └── Accessibility+Helpers.swift
├── Data/
│   └── SamplePresetData.swift
├── Localizable.xcstrings           # String catalog
└── Resources/
    └── (Images, audio files, etc.)
```

---

## 17. Data Persistence Strategy

### UserDefaults Keys

- `"running_timers"`: Array of `TimerData` (JSON-encoded)
- `"user_presets"`: Array of `TimerPreset` (JSON-encoded)
- `"did_initialize_presets"`: Boolean flag for first launch

### Persistence Flow

```
Model Changes
    ↓
Repository detects change
    ↓
Encodes to JSON via Codable
    ↓
Stores in UserDefaults
    ↓
On app restart, loads and decodes
```

**Note:** No CoreData or SQLite. UserDefaults is sufficient for this app's scope.

---

## Key Takeaways for Future Development

1. **State Management:** Always route through TimerService and repositories, never modify TimerData outside
2. **UI Updates:** Use `@Published` properties and Combine publishers for reactive updates
3. **Notifications:** Use `NotificationUtils` for all local notification operations
4. **Scene Transitions:** Handle foreground/background via `updateScenePhase()`
5. **Completion Logic:** Coordinate via `TimerCompletionHandler` for complex post-completion flows
6. **Testing:** Use protocol-based dependencies and pure functions
7. **Localization:** Add new strings to `Localizable.xcstrings` with both en/ko translations
8. **Button Logic:** Use `makeButtonSet()` to determine UI based on state + endAction

---

## Architecture Strengths

- Clean separation of concerns (View → ViewModel → Service → Repository → Data)
- Protocol-based dependencies enable testing and flexibility
- Reactive programming (Combine) reduces imperative code
- Explicit state management (enums) prevents invalid states
- Smart completion handling with separate handler class
- Comprehensive notification system with fallback strategies
- Well-organized file structure matching architectural layers

## Potential Improvements

- Add comprehensive unit tests (currently minimal)
- Consider adding integration tests for complex flows
- Migrate AlertPresentation to newer iOS 17+ Alert APIs
- Consider WidgetKit for lock screen complications
- Add analytics layer
- Consider Core Spotlight indexing for timers
