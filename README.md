# QuickLabelTimer

A production-ready iOS timer application built with SwiftUI, implementing MVVM architecture with state machine patterns for robust state management and comprehensive notification handling.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Project Structure](#project-structure)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)

## Overview

QuickLabelTimer provides a multi-timer management system with preset support, designed for reliability and accessibility. The application handles concurrent timers with deterministic state transitions, background persistence, and comprehensive notification scheduling within iOS constraints.

Built for iOS 16.0+, iPhone only.

## Features

### Core Functionality

- **Concurrent Timer Management**: Run up to 5 simultaneous timers with independent configurations
- **Preset System**: Save frequently used timer configurations with soft-delete support
- **Notification Scheduling**: Escalating notification pattern (12 notifications over 36 seconds) with sound and vibration controls
- **State Machine**: Deterministic timer state transitions with flexible UI button mapping
- **Background Reconciliation**: Automatic state synchronization when returning to foreground
- **Persistence**: UserDefaults-backed JSON storage with graceful error handling

### Accessibility

- **VoiceOver Support**: Full screen reader compatibility with semantic accessibility labels
- **Dynamic Type**: Text scaling support across all interfaces
- **High Contrast**: Compatible with system accessibility display modes
- **Localization**: English and Korean language support

### Technical Features

- Protocol-based dependency injection
- Combine-based reactive state management
- Structured logging with OSLog
- Firebase Crashlytics integration
- Testable architecture with Swift Testing support

## Architecture

### Pattern: MVVM + Service/Repository

```
View (SwiftUI) → ViewModel (@MainActor) → Service → Repository → UserDefaults
                                             ↓
                                        Notifications
```

### Single Source of Truth

- `TimerRepository.timers`: Active timer state
- `PresetRepository.userPresets`: Saved configurations

### State Management

Timer state transitions follow a state machine pattern with UI state decoupled from data model state:

```
TimerData.status → TimerInteractionState → makeButtonSet() → UI Buttons
```

This separation enables flexible button combinations while maintaining deterministic state transitions.

### Data Flow

1. User interaction triggers ViewModel method
2. ViewModel calls Service protocol method
3. Service orchestrates business logic (notifications, validation)
4. Repository performs CRUD operations and persists to UserDefaults
5. Repository publishes changes via Combine
6. ViewModel subscribes and updates UI state

See `QuickLabelTimer/docs/ARCHITECTURE_DEEP_DIVE.md` for detailed design decisions.

## Tech Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| UI Framework | SwiftUI | Declarative interface |
| State Management | Combine | Reactive updates |
| Persistence | UserDefaults | JSON serialization |
| Notifications | UserNotifications | Local scheduling |
| Logging | OSLog | Structured diagnostics |
| Crash Reporting | Firebase Crashlytics | Production monitoring |
| Testing | Swift Testing | iOS 18+ test framework |

**Minimum Deployment Target**: iOS 16.0

## Getting Started

### Prerequisites

- Xcode 15.0 or later
- iOS 16.0+ deployment target
- CocoaPods or Swift Package Manager for Firebase

### Installation

1. Clone the repository:
```bash
git clone https://github.com/data-sy/quick-label-timer.git
cd quick-label-timer
```

2. Install dependencies:
```bash
# If using CocoaPods
pod install

# Open workspace
open QuickLabelTimer.xcworkspace
```

3. Configure Firebase:
   - Add `GoogleService-Info.plist` to the project
   - Ensure Crashlytics is configured in `AppDelegate.swift`

4. Build and run:
   - Select target device/simulator
   - Product → Run (⌘R)

### First Run

The app initializes with:
- Empty timer list
- Empty preset list
- Notification authorization prompt on first timer creation

## Configuration

### Application Constants

Configuration values are centralized in `Configuration/AppConfig.swift`:

```swift
maxConcurrentTimers = 5                    // Maximum simultaneous timers
maxPresets = 20                            // Maximum saved presets
maxLabelLength = 100                       // Timer label character limit
repeatingNotificationCount = 12            // Notifications per timer completion
notificationRepeatingInterval = 3.0        // Seconds between notifications
notificationSystemLimit = 64               // iOS platform limit
deleteCountdownSeconds = 10                // Completion state duration
```

### UserDefaults Keys

- `"running_timers"`: Serialized `[TimerData]`
- `"user_presets"`: Serialized `[TimerPreset]`

### Localization

Strings are managed in `Localizable.xcstrings` with support for:
- English (en)
- Korean (ko)

Pattern: `"a11y.{context}.{element}"` for accessibility, `"ui.{screen}.{element}"` for UI text.

## Project Structure

```
QuickLabelTimer/
├── QuickLabelTimerApp.swift          # App entry point, dependency injection
├── AppDelegate.swift                 # Notification setup, Firebase config
├── Configuration/
│   └── AppConfig.swift               # Constants
├── Models/
│   ├── TimerData.swift               # Running timer model
│   ├── TimerPreset.swift             # Preset template model
│   ├── AlarmMode.swift               # Sound/vibration settings
│   ├── AlarmNotificationPolicy.swift # Notification behavior
│   └── Interaction/                  # State machine (5 files)
├── Repositories/
│   ├── TimerRepository.swift         # Timer CRUD + persistence
│   └── PresetRepository.swift        # Preset CRUD + persistence
├── Services/
│   ├── TimerService.swift            # Business logic orchestration
│   └── TimerCompletionHandler.swift  # Completion countdown
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

### Key Files

- **QuickLabelTimerApp.swift**: Single-instance creation of repositories and services
- **TimerRepository.swift**: Source of truth for timer state with Combine publishers
- **TimerService.swift**: 1Hz tick loop, state transitions, notification coordination
- **Models/Interaction/**: State machine implementation with button mapping logic

## Documentation

### Developer Guides

- **`QuickLabelTimer/CLAUDE.md`**: Fast reference for AI-assisted development
- **`QuickLabelTimer/docs/ARCHITECTURE_DEEP_DIVE.md`**: Design decisions and historical context
- **`QuickLabelTimer/docs/STATE_MACHINE_GUIDE.md`**: Complete state machine specification
- **`QuickLabelTimer/docs/NOTIFICATION_SYSTEM.md`**: Notification scheduling strategy
- **`QuickLabelTimer/docs/DEVELOPMENT_GUIDE.md`**: Extended examples and debugging

### Additional Resources

- **`CONTRIBUTING.md`**: Contribution guidelines and workflow
- **`CHANGELOG.md`**: Version history and release notes
- **`Docs/privacy-policy-*.md`**: Privacy policy (en, kr)

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for:

- Development workflow
- Code style guidelines
- Branching strategy
- Commit message conventions
- Pull request process

## License

[License information to be added]

---

**Project Status**: Active development
**Maintained by**: [@data-sy](https://github.com/data-sy)
