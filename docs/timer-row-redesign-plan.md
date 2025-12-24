# TimerRow Redesign - Implementation Plan

## Overview

Complete redesign of timer row from simple list layout to modern card-based design with new interaction patterns. Implementation follows a safe, incremental 3-phase approach.

**Design Reference**: `/Debug/DesignLabTimerRow/TimerRowRedesign.swift`

## Phase Strategy

```
Phase 1: Layout Restructuring (Modern Card)
    ↓
Phase 2: Running State Visual Feedback
    ↓
Phase 3: Button System Redesign
```

**Note**: Inline label editing excluded - will be handled in separate branch.

---

## Policy Decisions (Confirmed)

1. ✅ **Stop Button Removal**: Remove entirely. Users pause first, then reset.
2. ✅ **Reset Button**: Show only when `status == .paused`
3. ✅ **Delete Button (X)**: Always show confirmation dialog before deletion
4. ✅ **Phased Approach**: 3 phases (Layout → Running State → Buttons)

---

## Phase 1: Layout Restructuring (Modern Card)

### Goal
Transform to new 3-section card layout while keeping all existing functionality intact.

### Changes

#### 1. Card Styling
```swift
.padding(16)
.background(AppTheme.contentBackground)  // Running state color comes in Phase 2
.cornerRadius(20)
.shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
```

#### 2. Layout Restructure (3 Sections)
```
VStack(alignment: .leading, spacing: 12) {
    // [TOP] Bookmark + Label + Delete Button
    HStack {
        FavoriteToggleButton (44x44)
        Text(label) - .headline, read-only
        Spacer()
        Delete Button (X) - 44x44 tap area
    }

    // Divider
    Divider()
        .background(Color.secondary.opacity(0.3))  // White in Phase 2
        .padding(.vertical, 4)

    // [MIDDLE] Time + Buttons
    HStack {
        Text(formattedTime) - 48pt bold rounded (changed from 44pt light)
        Spacer()
        [Existing 2-button system] - Keep as-is
    }

    // [BOTTOM] Alarm Icon + End Time
    HStack(spacing: 4) {
        Image(systemName: alarmMode.iconName) - .caption
        Text(formattedEndTime) - .footnote
        Spacer()
    }
}
```

#### 3. Delete Button Implementation
```swift
Button(action: { showDeleteConfirmation = true }) {
    Image(systemName: "xmark")
        .font(.caption)
        .foregroundColor(.secondary)
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
}
.confirmationDialog("Delete timer?", isPresented: $showDeleteConfirmation) {
    Button("Delete", role: .destructive) { onDelete() }
    Button("Cancel", role: .cancel) { }
}
```

#### 4. End Time Display
```swift
// Add computed property to TimerData extension
var formattedEndTime: String {
    if status == .completed {
        return String(localized: "ui.timer.completed")
    }
    let formatter = DateFormatter()
    formatter.dateFormat = "a h:mm"
    formatter.locale = Locale.current
    return String(format: String(localized: "ui.timer.endTimeFormat"),
                  formatter.string(from: endDate))
}

// Localization keys needed:
// "ui.timer.endTimeFormat" = "%@ 종료 예정"
// "ui.timer.completed" = "종료됨"
```

#### 5. Alarm Mode Property
```swift
// Add to TimerData extension
var alarmMode: AlarmMode {
    AlarmNotificationPolicy.getMode(
        soundOn: isSoundOn,
        vibrationOn: isVibrationOn
    )
}
```

#### 6. CountdownMessageView
- Hide when not in completion state
- Or integrate into bottom section (conditional display)

### Files to Modify

**Primary**:
- `/QuickLabelTimer/QuickLabelTimer/Views/Components/TimerRow/TimerRowView.swift`
  - Complete layout restructure
  - Add delete button with confirmation dialog
  - Update time font to 48pt bold rounded
  - Add divider between sections
  - Move alarm indicator to bottom
  - Add end time display

**Extensions**:
- `/QuickLabelTimer/QuickLabelTimer/Models/TimerData.swift`
  - Add `var alarmMode: AlarmMode` computed property
  - Add `var formattedEndTime: String` computed property

**Localization**:
- `/QuickLabelTimer/Localizable.xcstrings`
  - Add "ui.timer.endTimeFormat" (Korean: "%@ 종료 예정")
  - Add "ui.timer.completed" (Korean: "종료됨")
  - Add "ui.timer.deleteConfirmation" dialog strings

**Secondary**:
- `/QuickLabelTimer/QuickLabelTimer/Views/Components/TimerRow/CountdownMessageView.swift`
  - Ensure doesn't conflict with new bottom section
  - Consider hiding when status != .completed

### Testing Checklist
- [ ] Layout renders correctly on iPhone SE (smallest screen)
- [ ] Card shadow visible in light/dark mode
- [ ] Divider shows correctly between sections
- [ ] End time updates when timer runs
- [ ] End time format shows correct locale (Korean AM/PM)
- [ ] Delete button shows confirmation dialog
- [ ] Delete confirmation has correct strings
- [ ] Time doesn't overflow (test with 999:59:59)
- [ ] Long labels wrap correctly
- [ ] VoiceOver navigation order: top → middle → bottom

### Risk: LOW
Pure layout changes, no logic modifications.

---

## Phase 2: Running State Visual Feedback

### Goal
Add blue background inversion when timer is running, before changing button system.

### Changes

#### 1. Background Inversion
```swift
.background(timer.status == .running ? Color.blue : AppTheme.contentBackground)
```

#### 2. Text Color Adjustments
```swift
// All text components need isRunning conditional:
let isRunning = timer.status == .running

// Label
.foregroundColor(isRunning ? .white : labelColor)

// Time
.foregroundColor(isRunning ? .white : timeColor)

// End time text
.foregroundColor(isRunning ? .white.opacity(0.8) : .secondary)
```

#### 3. Divider Color
```swift
Divider()
    .background(isRunning ? Color.white : Color.secondary.opacity(0.3))
```

#### 4. Icon Colors
```swift
// Delete button (X)
.foregroundColor(isRunning ? .white.opacity(0.8) : .secondary)

// Alarm icon
.foregroundColor(isRunning ? .white.opacity(0.8) : indicatorInfo.color)
```

#### 5. Bookmark Icon (FavoriteToggleButton)
```swift
// Update FavoriteToggleButton to accept isRunning parameter
struct FavoriteToggleButton: View {
    let endAction: TimerEndAction
    let isRunning: Bool  // NEW
    let onToggle: () -> Void

    var body: some View {
        Image(systemName: endAction.isPreserve ? "bookmark.fill" : "bookmark")
            .foregroundColor(isRunning ? .white :
                           (endAction.isPreserve ? AppTheme.actionYellow : .secondary))
    }
}
```

#### 6. Button Colors (Keep Current Outline Style)
```swift
// Existing buttons need to adapt to running state
// Button outlines should be white when running
// This will be further refined in Phase 3
```

### Files to Modify

**Primary**:
- `/QuickLabelTimer/QuickLabelTimer/Views/Components/TimerRow/TimerRowView.swift`
  - Add `isRunning` computed property
  - Apply conditional colors to all text/icons
  - Update background with blue inversion

**Components**:
- `/QuickLabelTimer/QuickLabelTimer/Views/Components/TimerRowButton/FavoriteToggleButton.swift`
  - Add `isRunning: Bool` parameter
  - Adjust icon color based on running state

- `/QuickLabelTimer/QuickLabelTimer/Views/Components/TimerRow/AlarmModeIndicatorView.swift`
  - Add `isRunning: Bool` parameter (or pass adjusted color)
  - Adjust icon color for blue background

### Testing Checklist
- [ ] Blue background appears when running
- [ ] All text readable (white on blue)
- [ ] Smooth transition when pausing (blue → white)
- [ ] Bookmark icon visible in both states
- [ ] Alarm icon visible on blue background
- [ ] Delete button visible on blue background
- [ ] Divider visible on blue background
- [ ] Dark mode works correctly
- [ ] Accessibility contrast passes WCAG AA

### Risk: LOW
Pure styling changes, no logic modifications.

---

## Phase 3: Button System Redesign

### Goal
Replace 2-button state machine with simplified 1 main button + conditional reset.

### Changes

#### 1. State Machine Updates

**Remove `.stop` from TimerLeftButtonType**:
```swift
// TimerLeftButtonType.swift
enum TimerLeftButtonType {
    case none
    // case .stop  ← REMOVE
    case reset     ← ADD (or use existing type)
    case moveToFavorite
    case delete
    case edit
}
```

**Update makeButtonSet()**:
```swift
// TimerButtonMapping.swift
func makeButtonSet(for state: TimerInteractionState, endAction: TimerEndAction) -> TimerButtonSet {
    switch state {
    case .preset:
        return .init(left: .edit, right: .play)

    case .running:
        return .init(left: .none, right: .pause)  // Changed: no left button

    case .paused:
        return .init(left: .reset, right: .play)  // Changed: reset instead of stop

    case .stopped, .completed:
        return .init(left: endAction.isPreserve ? .moveToFavorite : .delete,
                     right: .restart)
    }
}
```

#### 2. Button Styling Changes

**New Filled Button Style** (for main play/pause button):
```swift
// Create FilledTimerButtonStyle.swift
struct FilledTimerButtonStyle: ButtonStyle {
    let color: Color
    let isRunning: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .foregroundColor(isRunning ? color : .white)
            .frame(width: 56, height: 56)
            .background(Circle().fill(isRunning ? Color.white : color))
            .shadow(radius: 4)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}
```

**Reset Button** (outline style, smaller):
```swift
// Use existing outline style, 44x44 instead of 56x56
Button(action: onReset) {
    Image(systemName: "arrow.clockwise")
        .font(.footnote)
        .foregroundColor(isRunning ? .white : .blue)
        .frame(width: 44, height: 44)
        .background(
            Circle()
                .strokeBorder(
                    isRunning ? Color.white.opacity(0.5) : Color.blue.opacity(0.3),
                    lineWidth: 1.5
                )
        )
}
```

#### 3. Button UI Mapping Updates

**TimerButtonUI.swift**:
```swift
// Remove .stop case
// Add .reset case
case .reset:
    return TimerButtonUI(
        systemImage: "arrow.clockwise",
        tint: .blue,
        role: nil,
        accessibilityLabel: "ui.timer.button.reset"
    )
```

#### 4. ViewModel Updates

**RunningTimersViewModel.swift**:
```swift
func handleLeft(for timer: TimerData) {
    let set = makeButtonSet(for: timer.interactionState, endAction: timer.endAction)
    switch set.left {
    case .none:
        break
    // case .stop:  ← REMOVE
    //     timerService.stopTimer(id: timer.id)
    case .reset:  ← ADD
        timerService.stopTimer(id: timer.id)  // Reset = stop (resets to full time)
    case .moveToFavorite:
        handleMoveToPreset(for: timer)
    case .delete:
        if let presetId = timer.presetId {
            presetRepository.hidePreset(withId: presetId)
        }
        timerService.removeTimer(id: timer.id)
    case .edit:
        assertionFailure("Left .edit should not appear for running timers")
        break
    }
}
```

**Note**: `stopTimer()` already resets to full time (line 276-281 in TimerService.swift), so it's perfect for reset functionality.

#### 5. Button View Updates

**TimerRightButtonView.swift**:
- Update to use filled style instead of outline
- Main button (play/pause) gets filled circle
- Larger size (56x56 vs 52x52)

**TimerLeftButtonView.swift**:
- Add reset button case
- Keep outline style for reset
- Smaller size (44x44)

#### 6. Accessibility Updates

**Accessibility+Helpers.swift**:
```swift
// Add
static let resetLabel = String(localized: "a11y.timer.button.reset")

// Remove or deprecate
// static let stopLabel = String(localized: "a11y.timer.button.stop")
```

### Files to Modify

**State Machine**:
- `/QuickLabelTimer/QuickLabelTimer/Models/Interaction/TimerLeftButtonType.swift`
  - Remove `.stop` case
  - Ensure `.reset` exists (or add if needed)

- `/QuickLabelTimer/QuickLabelTimer/Models/Interaction/TimerButtonMapping.swift`
  - Update `makeButtonSet()` logic
  - Remove .stop from .running and .paused states
  - Add .reset to .paused state

**Button UI**:
- `/QuickLabelTimer/QuickLabelTimer/Views/Components/TimerRowButton/TimerButtonUI.swift`
  - Remove .stop case
  - Add .reset case mapping

- `/QuickLabelTimer/QuickLabelTimer/Views/Style/TimerButtonStyle.swift`
  - Create `FilledTimerButtonStyle` (or add to existing file)
  - Keep `OutlineTimerButtonStyle` for reset button

- `/QuickLabelTimer/QuickLabelTimer/Views/Components/TimerRowButton/TimerRightButtonView.swift`
  - Update to use filled style
  - Increase size to 56x56

- `/QuickLabelTimer/QuickLabelTimer/Views/Components/TimerRowButton/TimerLeftButtonView.swift`
  - Add .reset case
  - Set reset button size to 44x44

**ViewModels**:
- `/QuickLabelTimer/QuickLabelTimer/ViewModels/RunningTimersViewModel.swift`
  - Update handleLeft() switch
  - Remove .stop case
  - Add .reset case (calls stopTimer)

**Service** (optional):
- `/QuickLabelTimer/QuickLabelTimer/Services/TimerService.swift`
  - `stopTimer()` already implements reset behavior (no changes needed)
  - Consider renaming to `resetTimer()` for clarity (optional)

**Accessibility**:
- `/QuickLabelTimer/QuickLabelTimer/Utils/Accessibility+Helpers.swift`
  - Add reset button label
  - Remove/deprecate stop button label

**Localization**:
- `/QuickLabelTimer/Localizable.xcstrings`
  - Add "ui.timer.button.reset"
  - Add "a11y.timer.button.reset"

### Testing Checklist
- [ ] No left button shows when running
- [ ] Reset button appears when paused
- [ ] Reset button disappears when resumed
- [ ] Play/Pause button toggles smoothly
- [ ] Reset button resets to full time
- [ ] Main button has filled circle style with shadow
- [ ] Reset button has outline style
- [ ] Button spacing correct (16pt between buttons)
- [ ] All state transitions work: preset→run→pause→reset→run
- [ ] Notifications reschedule after reset
- [ ] No crashes on state transitions
- [ ] Compiler catches all .stop references
- [ ] VoiceOver announces "Reset" button
- [ ] Accessibility labels correct for all buttons

### Risk: MEDIUM
Changes state machine and ViewModel logic. Requires comprehensive testing.

**Critical**: Test all timer state transitions thoroughly.

---

## Summary: Critical Files by Phase

### Phase 1: Layout Restructuring
```
MODIFY:
  QuickLabelTimer/QuickLabelTimer/Views/Components/TimerRow/TimerRowView.swift
  QuickLabelTimer/QuickLabelTimer/Models/TimerData.swift
  QuickLabelTimer/QuickLabelTimer/Views/Components/TimerRow/CountdownMessageView.swift
  QuickLabelTimer/Localizable.xcstrings
```

### Phase 2: Running State Feedback
```
MODIFY:
  QuickLabelTimer/QuickLabelTimer/Views/Components/TimerRow/TimerRowView.swift
  QuickLabelTimer/QuickLabelTimer/Views/Components/TimerRowButton/FavoriteToggleButton.swift
  QuickLabelTimer/QuickLabelTimer/Views/Components/TimerRow/AlarmModeIndicatorView.swift
```

### Phase 3: Button System Redesign
```
MODIFY:
  QuickLabelTimer/QuickLabelTimer/Models/Interaction/TimerLeftButtonType.swift
  QuickLabelTimer/QuickLabelTimer/Models/Interaction/TimerButtonMapping.swift
  QuickLabelTimer/QuickLabelTimer/Views/Components/TimerRowButton/TimerButtonUI.swift
  QuickLabelTimer/QuickLabelTimer/Views/Components/TimerRowButton/TimerLeftButtonView.swift
  QuickLabelTimer/QuickLabelTimer/Views/Components/TimerRowButton/TimerRightButtonView.swift
  QuickLabelTimer/QuickLabelTimer/ViewModels/RunningTimersViewModel.swift
  QuickLabelTimer/QuickLabelTimer/Views/Style/TimerButtonStyle.swift
  QuickLabelTimer/QuickLabelTimer/Utils/Accessibility+Helpers.swift
  QuickLabelTimer/Localizable.xcstrings

OPTIONAL:
  QuickLabelTimer/QuickLabelTimer/Services/TimerService.swift (rename stopTimer → resetTimer)
```

---

## Risk Matrix

| Phase | Risk Level | What Could Break | Mitigation |
|-------|-----------|------------------|------------|
| **Phase 1** | LOW | Layout breaks on small screens, end time calculation | Test on iPhone SE, guard against nil |
| **Phase 2** | LOW | Color contrast issues, dark mode | Test WCAG AA, test dark mode |
| **Phase 3** | MEDIUM | State machine bugs, notification issues | Comprehensive state transition testing |

---

## Success Criteria

### Phase 1
- ✅ New card layout renders correctly on all devices
- ✅ Delete button shows confirmation dialog
- ✅ End time displays and updates correctly
- ✅ All existing functionality preserved

### Phase 2
- ✅ Blue background appears when running
- ✅ All text readable on blue background
- ✅ Smooth transitions between states
- ✅ Dark mode works correctly

### Phase 3
- ✅ Stop button completely removed
- ✅ Reset button only shows when paused
- ✅ Main button toggles play/pause smoothly
- ✅ All timer state transitions work correctly
- ✅ Notifications reschedule properly

---

## Implementation Notes

### Important Considerations

1. **AlarmMode Property**: Design lab uses `timer.alarmMode.iconName` which doesn't exist. Must add computed property that wraps `AlarmNotificationPolicy.getMode()`.

2. **CountdownMessageView**: Currently shown at bottom of TimerRowView. Will conflict with new end time section. Options:
   - Hide when status != .completed
   - Integrate into bottom section conditionally
   - Move to overlay/separate location

3. **FavoritePresetRowView Impact**: Also uses TimerRowView, so will automatically inherit card styling. Confirm this is desired.

4. **Button Size Changes**:
   - Current: Both buttons 52 diameter
   - Phase 3: Main button 56, reset button 44

5. **Stop vs Reset**: `stopTimer()` already implements reset behavior (resets remainingSeconds to totalSeconds). No service changes needed, just rename button label.

6. **Delete Confirmation**: User chose "Always confirm", so even stopped/completed timers need confirmation dialog.

### Testing Strategy

**After Each Phase**:
1. Build and run on physical device
2. Test all timer states (preset, running, paused, stopped, completed)
3. Test light/dark mode
4. Test accessibility (VoiceOver)
5. Test on smallest device (iPhone SE)
6. Verify no regressions in existing functionality

**Regression Testing**:
- Timer creation and deletion
- Notification scheduling
- App backgrounding/foregrounding
- Timer completion flow
- Favorite toggle

---

## Estimated Effort

- **Phase 1**: 2-3 days (layout + data extensions + testing)
- **Phase 2**: 1 day (styling + testing)
- **Phase 3**: 2-3 days (state machine + button system + comprehensive testing)

**Total**: 5-7 days for complete redesign

---

**Next Steps**: Begin Phase 1 implementation after plan approval.
