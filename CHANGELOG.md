# Changelog

All notable changes to QuickLabelTimer will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
### Changed
### Fixed
### Removed

## [1.1.0] - 2025-12-24

**🎨 Complete UI/UX Redesign** - This release features a modern, card-based interface with improved visual hierarchy and interaction patterns.

### Added

#### UI/UX Enhancements
- **Inline label editing**: Tap to edit timer labels directly in timer rows
- **Card-based timer design**: Modern card layout with dynamic shadows and visual feedback
- **Delete buttons**: Context-aware deletion with confirmation alerts
- **Deletion countdown**: Visual countdown before timer removal with context-aware messaging
- **Real-time end time display**: Live updates for estimated completion times across all timer states
- **Tap-to-edit time picker**: Quick access to time adjustment for preset timers
- **Auto-scroll behavior**: Automatic scrolling when editing timer labels for better UX
- **Dedicated alarm buttons**: Separate controls for sound and vibration settings
- **Sample presets**: Pre-configured lifestyle use cases with localized labels

#### Features
- **English language support**: Full internationalization (i18n) implementation alongside Korean
- **Time-based auto-labels**: Auto-generated labels use time format (e.g., "3:30") instead of generic "Timer N"
- **Label persistence**: Timer label changes automatically sync to presets on completion/stop
- **Unified scroll view**: Single vertical scroll replacing tab navigation for better content flow

#### Technical
- `TimeFormatter` utility for consistent time display formatting
- `RowTheme` design system for centralized timer card styling
- `EditableTimerLabel` component for inline editing
- Improved keyboard UX and label input consistency

### Changed

#### UI/UX Overhaul
- **Navigation structure**: Replaced tab-based navigation with unified scrollable view
- **Timer cards**: Reduced visual intensity with refined color scheme and spacing
- **Action controls**: Simplified button layout with explicit action methods
- **Section organization**: Improved layout hierarchy with consistent padding
- **Edit affordance**: Enhanced visual cues for editable elements
- **Running timer style**: Color inversion for better distinction of active timers

#### Terminology
- Replaced "Favorite" with "Bookmark" throughout the app
- Improved timer limit alert messaging to emphasize focus management

#### Notification System
- Redesigned notification content for better clarity
- Updated notification repetition logic
- Removed inconsistent beep sounds
- Updated default notification sound
- Trimmed and normalized all audio files for consistent quality

#### Internal
- View naming for clarity:
  - `RunningListView` → `RunningTimersView`
  - `FavoriteListView` → `FavoriteTimersView`
  - `MainTabView` → `MainView`
- Replaced hardcoded preset limits with `AppConfig` constants
- Refactored action handlers from generic left/right to explicit methods

### Fixed

- Build warnings and errors for production release
- Audio quality issues with notification sounds
- Label update timing (ensures completion before timer starts)
- Bookmark count format specifier in localization strings

### Removed

- Tab-based navigation (`TabView`)
- Nested scroll containers
- Legacy timer row UI components
- Experimental debug code

### Technical Details

#### Architecture Improvements
- VStack-based layout to eliminate nested scroll performance issues
- Conditional rendering replacing overlay patterns for better performance
- Protocol-based design system for timer row theming
- Enhanced separation of concerns in timer lifecycle management

#### Performance
- Improved scroll performance with optimized VStack architecture
- Reduced view hierarchy complexity
- Better memory management with conditional rendering

---

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

[unreleased]: https://github.com/data-sy/quick-label-timer/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/data-sy/quick-label-timer/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/data-sy/quick-label-timer/releases/tag/v1.0.0
