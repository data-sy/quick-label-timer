# State Machine Guide: TimerInteractionState System

> **Purpose:** Complete reference for the TimerInteractionState system
>
> **Quick Reference:** See `/CLAUDE.md` for minimal patterns

## Overview

The TimerInteractionState system separates **data model state** from **UI presentation state**, enabling flexible button combinations based on multiple factors:
- Timer status (.running, .paused, .stopped, .completed)
- Source (instant timer vs preset-based)
- User preference (endAction: .preserve vs .discard)

## The Problem

Without separation, button logic becomes complex and brittle:

```swift
// ❌ MESSY: UI logic mixed with data model
func leftButton(for timer: TimerData) -> ButtonType {
    if timer.status == .running {
        return .stop
    } else if timer.status == .stopped || timer.status == .completed {
        if timer.presetId == nil && timer.endAction == .preserve {
            return .moveToFavorite
        } else {
            return .delete
        }
    } else if timer.status == .paused {
        return .stop
    }
    // ... gets worse with each new state
}
```

## The Solution

Three-layer system:

```
TimerData.status (Internal State)
    ↓ conversion
TimerInteractionState (UI State)
    ↓ button mapping
TimerButtonSet (What to Display)
```

---

## Layer 1: TimerData.status (Internal State)

**Location:** `/Models/TimerData.swift`

```swift
enum TimerStatus: String, Codable {
    case running   // Timer is actively counting down
    case paused    // Timer is paused, can be resumed
    case stopped   // User manually stopped, can be restarted
    case completed // Timer reached 0, in deletion countdown
}
```

**Persisted to UserDefaults** - This is the source of truth.

### State Transitions

```
                    ┌─────────────────────────┐
                    │                         │
                    ▼                         │
              ┌──────────┐              ┌──────────┐
       ┌─────►│ .running │◄─────────────│ .stopped │
       │      └────┬─────┘              └──────────┘
       │           │                          ▲
       │           │ pause                    │
       │           │                          │
       │           ▼                          │
       │      ┌─────────┐                    │
       │      │ .paused │                    │
       │      └────┬────┘                    │
       │           │                          │
       │           │ resume                   │
       │           │                          │
       │           └──────────────────────────┘
       │                                      ▲
       │                                      │
       │           ┌──────────┐              │
       └───────────│.completed│──────────────┘
                   └──────────┘
                   (after 10s countdown OR user confirms)
                         │
                         ▼
                   [DELETED]
```

**Valid Transitions:**
- `.running` → `.paused` (user pauses)
- `.paused` → `.running` (user resumes)
- `.running` → `.stopped` (user stops)
- `.paused` → `.stopped` (user stops)
- `.stopped` → `.running` (user restarts)
- `.running` → `.completed` (time reaches 0)
- `.completed` → `.running` (user restarts)
- `.completed` → [deleted] (after 10s or user confirms)

---

## Layer 2: TimerInteractionState (UI State)

**Location:** `/Models/Interaction/TimerInteractionState.swift`

```swift
enum TimerInteractionState {
    case preset     // Only used in FavoriteListView (not a TimerData state)
    case running
    case paused
    case stopped
    case completed
}
```

**NOT persisted** - Computed at runtime from `TimerData.status` or `TimerPreset`.

### Conversion Extension

**Location:** `/Models/Interaction/TimerData+InteractionState.swift`

```swift
extension TimerData {
    var interactionState: TimerInteractionState {
        switch status {
        case .running:   return .running
        case .paused:    return .paused
        case .stopped:   return .stopped
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

**Why separate?**
- `.preset` exists only in UI (not a `TimerData.status`)
- Allows UI-specific states without changing data model
- Enables future UI variations without persistence changes

---

## Layer 3: Button Mapping (What to Display)

### Button Types

**Location:** `/Models/Interaction/TimerLeftButtonType.swift`

```swift
enum TimerLeftButtonType: Equatable {
    case none
    case stop             // Stop running timer
    case moveToFavorite   // Save instant timer as preset
    case delete           // Delete timer
    case edit             // Edit preset (only for .preset state)
}
```

**Location:** `/Models/Interaction/TimerRightButtonType.swift`

```swift
enum TimerRightButtonType: Equatable {
    case play      // Start timer (from preset) or resume (from paused)
    case pause     // Pause running timer
    case restart   // Restart stopped/completed timer
}
```

### Button Set Container

**Location:** `/Models/Interaction/TimerButtonSet.swift`

```swift
struct TimerButtonSet: Equatable {
    let left: TimerLeftButtonType
    let right: TimerRightButtonType
}
```

### Button Mapping Logic

**Location:** `/Models/Interaction/TimerButtonMapping.swift`

This is the **core decision function** - a pure function that determines which buttons to show:

```swift
func makeButtonSet(
    for state: TimerInteractionState,
    endAction: TimerEndAction
) -> TimerButtonSet {
    switch state {
    case .preset:
        // Presets in favorites list
        return TimerButtonSet(left: .edit, right: .play)

    case .running:
        // Running timer
        return TimerButtonSet(left: .stop, right: .pause)

    case .paused:
        // Paused timer
        return TimerButtonSet(left: .stop, right: .play)

    case .stopped, .completed:
        // Stopped or completed timer
        // Left button depends on endAction (favorite toggle)
        let leftButton: TimerLeftButtonType =
            endAction.isPreserve ? .moveToFavorite : .delete

        return TimerButtonSet(left: leftButton, right: .restart)
    }
}
```

**Key Insight:** `.stopped` and `.completed` share same buttons - they're functionally identical from UI perspective.

### Button Combination Table

| State | Left Button | Right Button | Use Case |
|-------|------------|--------------|----------|
| `.preset` | Edit | Play | Preset in favorites list |
| `.running` | Stop | Pause | Active countdown |
| `.paused` | Stop | Play (resume) | Paused countdown |
| `.stopped` | MoveToFavorite OR Delete* | Restart | User manually stopped |
| `.completed` | MoveToFavorite OR Delete* | Restart | Timer reached 0 |

\* Depends on `endAction`: `.preserve` → MoveToFavorite, `.discard` → Delete

---

## State Transitions (UI Actions)

**Location:** `/Models/Interaction/TimerInteractionTransition.swift`

Pure functions that define valid state transitions based on button presses.

### Right Button Transitions

```swift
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
    default:                     return current  // Invalid transition, no change
    }
}
```

**Transition Table:**

| Current State | Button | Next State | Action |
|--------------|--------|------------|--------|
| `.preset` | `.play` | `.running` | Start new timer from preset |
| `.running` | `.pause` | `.paused` | Pause countdown |
| `.paused` | `.play` | `.running` | Resume countdown |
| `.stopped` | `.restart` | `.running` | Restart from original duration |
| `.completed` | `.restart` | `.running` | Restart from original duration |

### Left Button Transitions

```swift
func nextState(
    from current: TimerInteractionState,
    left button: TimerLeftButtonType
) -> TimerInteractionState {
    switch (current, button) {
    case (.running, .stop):      return .stopped
    case (_, .moveToFavorite):   return current  // Data change, no state change
    case (_, .delete):           return current  // Data removed, timer deleted
    case (_, .edit):             return current  // Navigate to edit screen
    default:                     return current
    }
}
```

**Key Insight:** Most left button actions trigger **data changes** rather than state changes:
- `.moveToFavorite` → Creates preset, deletes timer (removal, not state change)
- `.delete` → Deletes timer (removal)
- `.edit` → Opens edit sheet (no state change)
- `.stop` → Only left button that changes state

---

## EndAction: The Favorite Toggle

**Location:** `/Models/TimerData.swift`

```swift
enum TimerEndAction: String, Codable {
    case preserve  // Save as preset when completed (star icon ON)
    case discard   // Don't save as preset (star icon OFF)

    var isPreserve: Bool { self == .preserve }
}
```

**Purpose:** Controls post-completion behavior.

### EndAction Logic Table

| Timer Type | endAction | On Completion |
|-----------|-----------|---------------|
| Instant timer | `.preserve` | → Save as new preset |
| Instant timer | `.discard` | → Delete |
| Preset-based timer | `.preserve` | → Delete timer (preset exists) |
| Preset-based timer | `.discard` | → Hide preset + delete timer |

**Implementation:**

```swift
// In TimerCompletionHandler
switch (timer.presetId, timer.endAction) {
case (.none, .preserve):
    // Instant timer, favorite ON → Save as preset
    presetRepository.addPreset(from: timer)
    timerService.removeTimer(id: timer.id)

case (.none, .discard):
    // Instant timer, favorite OFF → Just delete
    timerService.removeTimer(id: timer.id)

case (.some, .preserve):
    // Preset-based, favorite ON → Just delete (preset exists)
    timerService.removeTimer(id: timer.id)

case (.some(let presetId), .discard):
    // Preset-based, favorite OFF → Hide preset + delete
    presetRepository.hidePreset(withId: presetId)
    timerService.removeTimer(id: timer.id)
}
```

---

## Usage in ViewModels

### Pattern: Determine Buttons

```swift
// In RunningListViewModel or FavoriteListViewModel
func handleLeft(for timer: TimerData) {
    let state = timer.interactionState
    let buttons = makeButtonSet(for: state, endAction: timer.endAction)

    switch buttons.left {
    case .stop:
        timerService.stopTimer(id: timer.id)
    case .delete:
        timerService.userDidRequestDelete(for: timer.id)
    case .moveToFavorite:
        // Show confirmation alert, then create preset
        timerService.userDidConfirmCompletion(for: timer.id)
    case .edit:
        // Show edit sheet for preset
        startEditing(for: preset)
    default:
        break
    }
}

func handleRight(for timer: TimerData) {
    let state = timer.interactionState
    let buttons = makeButtonSet(for: state, endAction: timer.endAction)

    switch buttons.right {
    case .play:
        if state == .preset {
            timerService.runTimer(from: preset)
        } else {
            timerService.resumeTimer(id: timer.id)
        }
    case .pause:
        timerService.pauseTimer(id: timer.id)
    case .restart:
        timerService.restartTimer(id: timer.id)
    }
}
```

### Pattern: Toggle Favorite

```swift
func toggleFavorite(for id: UUID) {
    // Toggles endAction between .preserve and .discard
    let _ = timerService.toggleFavorite(for: id)

    // UI automatically updates because:
    // 1. TimerService updates TimerData.endAction
    // 2. Repository triggers @Published update
    // 3. ViewModel receives update via Combine
    // 4. makeButtonSet() computes new buttons
    // 5. SwiftUI re-renders
}
```

---

## Usage in Views

### Display Button Icons

**Location:** `/Views/Components/TimerRowButton/TimerLeftButton.swift`

```swift
struct TimerLeftButton: View {
    let buttonType: TimerLeftButtonType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            switch buttonType {
            case .none:
                EmptyView()
            case .stop:
                Image(systemName: "stop.fill")
                    .accessibilityLabel("Stop timer")
            case .moveToFavorite:
                Image(systemName: "star")
                    .accessibilityLabel("Save as preset")
            case .delete:
                Image(systemName: "trash")
                    .accessibilityLabel("Delete timer")
            case .edit:
                Image(systemName: "pencil")
                    .accessibilityLabel("Edit preset")
            }
        }
    }
}
```

---

## Testing the State Machine

### Pure Functions → Easy to Test

All state machine logic uses pure functions with no side effects:

```swift
// Test button mapping
func testButtonMapping() throws {
    let result = makeButtonSet(for: .running, endAction: .preserve)

    #expect(result.left == .stop)
    #expect(result.right == .pause)
}

// Test state transitions
func testPauseTransition() throws {
    let result = nextState(from: .running, right: .pause)

    #expect(result == .paused)
}

// Test endAction logic
func testEndActionPreserve() throws {
    let timer = TimerData(... presetId: nil, endAction: .preserve)
    let state = timer.interactionState
    let buttons = makeButtonSet(for: state, endAction: timer.endAction)

    #expect(buttons.left == .moveToFavorite)  // Because endAction = .preserve
}
```

---

## Common Patterns

### Pattern 1: Adding a New State

**Example:** Add `.expired` state for timers that expired while app was backgrounded.

**Steps:**
1. Add to `TimerStatus` enum (if persisted) or `TimerInteractionState` (if UI-only)
2. Update `TimerData.interactionState` conversion
3. Add case to `makeButtonSet()` function
4. Add transition rules to `nextState()` functions
5. Update ViewModel button handlers
6. Update View button rendering

### Pattern 2: Adding a New Button

**Example:** Add "Duplicate" button.

**Steps:**
1. Add to `TimerLeftButtonType` or `TimerRightButtonType`
2. Update `makeButtonSet()` to return new button for specific state
3. Add service method (`timerService.duplicateTimer()`)
4. Update ViewModel handlers
5. Update View rendering (icon + accessibility label)

### Pattern 3: Changing Button Based on Multiple Conditions

**Example:** Show "Archive" instead of "Delete" for old timers.

**Current:**
```swift
case .completed:
    let leftButton = endAction.isPreserve ? .moveToFavorite : .delete
```

**Enhanced:**
```swift
case .completed:
    let leftButton: TimerLeftButtonType
    if endAction.isPreserve {
        leftButton = .moveToFavorite
    } else if isOld(timer) {  // New condition
        leftButton = .archive
    } else {
        leftButton = .delete
    }
```

**Challenge:** Pure function can't access timer directly - need to pass additional parameter:
```swift
func makeButtonSet(
    for state: TimerInteractionState,
    endAction: TimerEndAction,
    isOld: Bool  // New parameter
) -> TimerButtonSet
```

---

## Why This Pattern?

### Benefits

✅ **Type Safety:** Enums prevent invalid button combinations
✅ **Testability:** Pure functions → easy to unit test
✅ **Maintainability:** Single source of truth for button logic
✅ **Flexibility:** Add states/buttons without touching data model
✅ **Decoupling:** UI concerns separate from business logic
✅ **Reusability:** Same logic for RunningListViewModel and FavoriteListViewModel

### Costs

⚠️ **Indirection:** Extra layer between data and UI (but worth it)
⚠️ **Learning Curve:** Need to understand 3-layer system
⚠️ **Boilerplate:** More files and types (but better organized)

### When to Use This Pattern

**Use when:**
- UI has complex, context-dependent button combinations
- Multiple factors determine button visibility/behavior
- Need to add new states frequently
- High test coverage desired

**Don't use when:**
- Simple, static button layout
- Buttons never change based on state
- Very small app with few states

---

## Visual State Diagram

```
                  ┌──────────┐
                  │ .preset  │ (Favorites list only)
                  └────┬─────┘
                       │ [Edit] [Play]
                       │
                       │ User taps Play
                       ▼
                  ┌──────────┐
            ┌────►│ .running │
            │     └────┬─────┘
            │          │ [Stop] [Pause]
            │          │
            │          │ User pauses
            │          ▼
            │     ┌─────────┐
            │     │ .paused │
            │     └────┬────┘
            │          │ [Stop] [Play]
            │          │
            │          │ User resumes
            │          └──────┐
            │                 │
   Restart  │                 │
            │          ┌──────▼──────┐
            │          │             │
            │     User stops    Time reaches 0
            │          │             │
            │          ▼             ▼
            │     ┌──────────┐  ┌─────────────┐
            │     │ .stopped │  │ .completed  │
            │     └────┬─────┘  └──────┬──────┘
            │          │ [★/🗑] [⟳]     │ [★/🗑] [⟳]
            │          │                │
            │          └────────┬───────┘
            │                   │
            └───────────────────┘

Legend:
★ = Move to Favorite (if endAction = .preserve)
🗑 = Delete (if endAction = .discard)
⟳ = Restart
```

---

## Summary

The TimerInteractionState system is a **state machine** that:

1. **Separates concerns:** Data model state vs UI presentation state
2. **Uses pure functions:** Easy to test, no side effects
3. **Provides type safety:** Impossible to show invalid button combinations
4. **Enables flexibility:** Add UI states without changing persistence
5. **Centralizes logic:** Single source of truth for button mapping

**Core principle:** "Make invalid states unrepresentable" through enums and pure functions.

**Location summary:**
- `/Models/Interaction/` - All state machine files (5 files)
- `makeButtonSet()` - Core decision function (most important)
- ViewModels - Use `makeButtonSet()` to determine UI
- Views - Render buttons based on `ButtonType` enums

**When in doubt:** Consult `makeButtonSet()` - it's the source of truth for all button logic.
