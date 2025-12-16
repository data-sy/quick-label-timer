# Changelog

All notable changes to QuickLabelTimer will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
### Changed
### Fixed
### Removed

## [Unreleased]

### Added
- Accessibility labels for unified timer view sections (English/Korean)

### Changed
- Unified timer management into single scrollable view
- Replaced tab navigation with vertical scroll
- Renamed views for clarity:
  - RunningListView → RunningTimersView
  - FavoriteListView → FavoriteTimersView
  - MainTabView → MainView
- Improved scroll performance with VStack-based architecture

### Removed
- Tab-based navigation (TabView)
- Nested scroll containers

### Technical
- Implement VStack-based layout to eliminate nested scroll issues
- Add ScrollViewReader for programmatic navigation
- Document architecture decision in ADR 015

## [1.0.0] - 2024-11-15

Initial release with core timer functionality.

### Added

#### Core Features
- Multi-timer support with up to 5 concurrent timers
- Timer preset system with save/edit/delete capabilities
- Configurable sound and vibration settings per timer
- Timer state persistence across app restarts
- Background state reconciliation on app foregrounding

#### Architecture
- MVVM architecture with Service/Repository pattern
- State machine implementation for deterministic timer transitions
- Protocol-based dependency injection
- Combine-based reactive state management
- Structured logging with OSLog categories

#### Notifications
- Escalating notification pattern (12 notifications over 36 seconds)
- Foreground notification suppression (except first notification)
- Automatic notification cleanup on timer removal
- Compliance with iOS 64-notification system limit

#### State Management
- `TimerInteractionState` enum for UI state decoupling
- Dynamic button mapping based on timer state and end action
- Completion countdown with 10-second auto-deletion
- Soft delete for presets via `isHiddenInList` flag

#### Persistence
- UserDefaults-backed JSON storage
- Graceful error handling with fallback to empty state
- Codable migration support for model updates

#### Accessibility
- Full VoiceOver support with semantic labels
- Dynamic Type support across all text elements
- High contrast mode compatibility
- Localization for English and Korean

#### Configuration
- Centralized constants in `AppConfig.swift`
- Configurable limits: timers (5), presets (20), notifications (12)
- Notification timing configuration (3-second intervals)

#### Developer Experience
- `CLAUDE.md`: AI-assisted development quick reference
- `docs/ARCHITECTURE_DEEP_DIVE.md`: Design decisions and rationale
- `docs/STATE_MACHINE_GUIDE.md`: State machine specification
- `docs/NOTIFICATION_SYSTEM.md`: Notification scheduling strategy
- `docs/DEVELOPMENT_GUIDE.md`: Extended examples and debugging

#### Testing
- Swift Testing framework integration (iOS 18+)
- Protocol-based mocks for service layer
- Test coverage for state machine transitions

#### Monitoring
- Firebase Crashlytics integration
- Structured logging categories (timer, persistence, notification, ui)

### Architecture Details

#### Data Models
- `TimerData`: Running timer state with status, end date, remaining time
- `TimerPreset`: Saved timer templates
- `AlarmMode`: Sound/vibration configuration
- `TimerStatus`: State enum (.running, .paused, .stopped, .completed)
- `TimerEndAction`: Completion behavior (.preserve, .discard)

#### Services
- `TimerService`: Business logic orchestration with 1Hz tick loop
- `TimerCompletionHandler`: Completion countdown management
- `NotificationUtils`: Notification scheduling and cancellation
- `LocalNotificationDelegate`: Foreground notification handling

#### Repositories
- `TimerRepository`: Timer CRUD with Combine publishers
- `PresetRepository`: Preset CRUD with soft delete

#### ViewModels
- `AddTimerViewModel`: Timer creation logic
- `RunningListViewModel`: Active timer list management
- `FavoriteListViewModel`: Preset list management
- `EditPresetViewModel`: Preset editing logic

### Technical Specifications

- **Platform**: iOS 16.0+
- **Architecture**: MVVM + Service/Repository
- **UI Framework**: SwiftUI
- **Reactive Framework**: Combine
- **Persistence**: UserDefaults (JSON)
- **Notifications**: UserNotifications framework
- **Logging**: OSLog
- **Crash Reporting**: Firebase Crashlytics
- **Testing**: Swift Testing

### Known Limitations

- Maximum 5 concurrent timers (configurable in AppConfig)
- Maximum 20 presets (configurable in AppConfig)
- iPhone only (no iPad support)
- iOS notification limit of 64 total scheduled notifications
- 1-second tick granularity (sufficient for timer use case)

[unreleased]: https://github.com/data-sy/quick-label-timer/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/data-sy/quick-label-timer/releases/tag/v1.0.0
