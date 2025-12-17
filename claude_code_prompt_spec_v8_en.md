# Claude Code Prompt Spec v8 (English)

This document is the **final revised version (v8)** for executing the **TimerRow Redesign** using Claude Code.

Key changes in v8:
- **TimerActionButtons**: The component name is finalized as the intuitive `TimerActionButtons`
- **AppTheme integration**: Hardcoded values are first defined in `AppTheme` and then reused
- **Expected implementation scenarios**: Instructions are relaxed to convey intent rather than enforce strict syntax on the AI
- **Parallel Refactoring**: Development proceeds in parallel without touching existing code, followed by replacement

---

## Global Execution Principles (v8)

1. **Never modify the existing TimerRowView.** (Safety first)
2. **Actively leverage design tokens defined in AppTheme.** (Avoid hardcoding)
3. **Each step must be executed independently, and after completion the developer manually reviews and commits.**
4. **Code suggested by the AI should be based on the described "expected scenarios" while choosing the optimal implementation approach.**

---

## Phase 1: Design System and Skeleton Creation

### Step 1-1: AppTheme Extension

```text
Read the `AppTheme.swift` file and `timer-row-redesign-plan.md` as context.

Perform **Step 1-1 (AppTheme Extension)** only.

Goal:
- Define the design constants required for the timer card UI in `AppTheme`.
- Remove hardcoded numeric values and manage them centrally.

Expected implementation scenario:
Inside `AppTheme`, add a `TimerCard` enum (or struct) to manage the following values:
- cornerRadius: 20
- padding: 16
- shadowRadius: 8, shadowY: 4
- timeTextSize: 48 (rounded font)
- buttonSize: 56 (primary), 44 (secondary)

Completion conditions:
- Values must be accessible via `AppTheme.TimerCard`
- Existing code must not be modified

After completion:
- Output "Step 1-1 complete. AppTheme updated. Ready for manual commit."
- Stop
```

**Checklist:**

- [ ] Build succeeds
- [ ] `AppTheme.TimerCard` definition confirmed

---

### Step 1-2: Create NewTimerRow Skeleton

```text
Perform **Step 1-2 (Create NewTimerRow file)** only.

Goal:
- Create `Views/Components/TimerRow/NewTimerRow.swift`
- Build a 3-section (TOP / MIDDLE / BOTTOM) card layout using `AppTheme` constants

Expected implementation scenario:
```swift
struct NewTimerRow: View {
    let timer: TimerData
    // Closure pattern
    let onToggleFavorite: () -> Void
    let onPlayPause: () -> Void
    let onReset: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // TOP: Favorite + Label + Delete
            HStack {
                /* Layout only */
                Text("TOP")
            }
            
            Divider()
            
            // MIDDLE: Time + Buttons
            HStack {
                Text(timer.formattedTime)
                    .font(.system(size: AppTheme.TimerCard.timeTextSize, ...)) // Use AppTheme
                Spacer()
                Text("BUTTONS")
            }
            
            // BOTTOM: Info
            HStack { Text("BOTTOM") }
        }
        .padding(AppTheme.TimerCard.padding)
        .background(AppTheme.contentBackground) // Or white
        .cornerRadius(AppTheme.TimerCard.cornerRadius)
        .shadow(...)
    }
}
```

After completion:
- Output "Step 1-2 complete. Ready for manual commit."
- Stop
```

**Checklist:**
- [ ] NewTimerRow.swift created
- [ ] AppTheme constants applied
- [ ] Layout structure verified

---

### Step 1-3: Add Preview

```text
Perform **Step 1-3 (NewTimerRow Preview)** only.

Goal:
- Add a Preview at the bottom of `NewTimerRow.swift`
- Verify that `AppTheme` colors render correctly in both light and dark modes

Expected implementation scenario:
- Create two dummy TimerData instances (running, paused)
- Place rows on top of `AppTheme.pageBackground` to verify real look and feel

After completion:
- Output "Step 1-3 complete. Ready for manual commit."
- Stop
```

---

## Phase 2: Functional Block Assembly

### Step 2-1: Place Existing Components

```text
Perform **Step 2-1 (Place existing components)** only.

Goal:
- Place `FavoriteToggleButton` and a delete button in the TOP section
- Reuse existing components

Expected implementation scenario:
- TOP section:
  - FavoriteToggleButton (reuse existing)
  - Timer Label (Text)
  - Spacer
  - X button (delete) → ensure 44x44 touch area

After completion:
- Output "Step 2-1 complete. Ready for manual commit."
- Stop
```

---

### Step 2-2: Create TimerActionButtons

```text
Perform **Step 2-2 (Create TimerActionButtons)** only.

Goal:
- Create `Views/Components/TimerRowButton/TimerActionButtons.swift`
- Introduce a simple view to replace the existing complex button logic

Expected implementation scenario:
- Props: `status: TimerStatus`, `onPlayPause: () -> Void`, `onReset: () -> Void`
- Play/Pause button: circular button using `AppTheme.TimerCard.buttonSize` (56)
- Reset button: shown on the left only when paused (size 44)

After completion:
- Output "Step 2-2 complete. Ready for manual commit."
- Stop
```

---

### Step 2-3: Connect TimerActionButtons

```text
Perform **Step 2-3 (Connect TimerActionButtons)** only.

Goal:
- Place `TimerActionButtons` in the MIDDLE section of `NewTimerRow`
- Verify that buttons change based on timer state

Expected implementation scenario:
- Place TimerActionButtons on the right side of the MIDDLE section
- Pass down closures (`onPlayPause`, `onReset`) from the parent

After completion:
- Output "Step 2-3 complete. Ready for manual commit."
- Stop
```

---

## Phase 3: Isolated Testing (Verification)

### Step 3-1: Create TestView

```text
Perform **Step 3-1 (Create NewTimerRowTestView)** only.

Goal:
- Create `Debug/NewTimerRowTestView.swift`
- Build a sandbox environment to test state changes without a real ViewModel

Expected implementation scenario:
- Manage `TimerData` using a @State variable
- Tapping Play toggles status between running and paused
- Reset button resets time
- Verify favorite toggle behavior

After completion:
- Output "Step 3-1 complete. Ready for manual commit."
- Stop
```

**Checklist:**

- [ ] TestView builds and runs
- [ ] UI reflects state changes on button tap

---

## Phase 4: Production Deployment (Migration)

### Step 4-1: Migrate FavoriteTimersView

```text
Perform **Step 4-1 (FavoriteTimersView migration)** only.

Goal:
- Replace existing `TimerRowView` with `NewTimerRow` in `FavoriteTimersView.swift`

Expected implementation scenario:
- Before: `TimerRowView(timer: timer, ...)`
- After: `NewTimerRow(timer: timer, ...)`
- Mapping notes:
  - onPlayPause → viewModel.handleRight(for: timer) (usually Play)
  - onDelete → viewModel.handleLeft(for: timer)

After completion:
- Output "Step 4-1 complete. Ready for manual commit."
- Stop
```

---

### Step 4-2: Migrate RunningTimersView

```text
Perform **Step 4-2 (RunningTimersView migration)** only.

Goal:
- Replace `TimerRowView` in `RunningTimersView.swift`
- This is the most complex part, so pay close attention to button-action mapping

Expected implementation scenario:
- onPlayPause → viewModel.handleRight (Play/Pause toggle)
- onReset → viewModel.handleLeft (Reset when paused)
- onDelete → viewModel.handleLeft (Delete when completed)
- *Note: Do not modify ViewModel logic; call appropriate closures from the view*

After completion:
- Output "Step 4-2 complete. Ready for manual commit."
- Stop
```

---

## Phase 5: Cleanup

### Step 5-1: Remove Legacy Code

```text
Perform **Step 5-1 (Legacy code removal)** only.

Goal:
- Remove unused `TimerRowView.swift` and related button files

Expected implementation scenario:
- Delete `TimerRowView.swift`
- Delete `TimerLeftButtonView`, `TimerRightButtonView`, `TimerButtonMapping`, etc.
- Verify no build errors after deletion (fix references if still used elsewhere)

After completion:
- Output "Step 5-1 complete. Legacy code removed. Ready for manual commit."
- Stop
```

---

## Phase 6+: Improvements

## Phase 6: End Time Display

### Step 6-1: Add TimeFormatter Utility

```text
Perform **Step 6-1 (Add TimeFormatter)** only.

Scope:
- Add TimeFormatter to `Utils/TimeUtils.swift`
- Implement `formatRemaining` and `formatEndTime` methods

Implementation details:
Add the following to the bottom of TimeUtils.swift:

```swift
// MARK: - Time Formatting

/// Time formatting utility
enum TimeFormatter {
    /// Converts remaining seconds to "HH:MM:SS" or "MM:SS"
    static func formatRemaining(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%01d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
    
    /// Converts Date to a locale-aware time string (e.g. "10:30 AM")
    static func formatEndTime(_ date: Date, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.locale = locale
        return formatter.string(from: date)
    }
}
```

After completion:
- Output "Step 6-1 complete. Ready for manual commit."
- Stop
```

**Pre-commit checklist:**
- [ ] Build succeeds
- [ ] `TimeFormatter.formatRemaining(180)` → "03:00"
- [ ] `TimeFormatter.formatEndTime(Date())` → locale-aware time
- [ ] Works correctly in Korean locale

**Recommended commit message:**
```
feat: add TimeFormatter utility for time formatting

- Add formatRemaining for converting seconds to HH:MM:SS
- Add formatEndTime for locale-aware date formatting
- Support both Korean and English locales
- Prepare for formattedEndTime implementation
```

---

### Step 6-2: Add formattedEndTime to TimerData

```text
Perform **Step 6-2 (Add formattedEndTime)** only.

Scope:
- Add a computed property `formattedEndTime` to TimerData
- Add required localization keys to Localizable.xcstrings

Implementation details:
Add to Models/TimerData.swift:
```swift
extension TimerData {
    /// Formats the scheduled end time according to locale
    var formattedEndTime: String {
        if status == .completed {
            return String(localized: "ui.timer.completed")
        }
        let timeString = TimeFormatter.formatEndTime(endDate)
        return String(format: String(localized: "ui.timer.endTimeFormat"), timeString)
    }
}
```

Add to Localizable.xcstrings:
```json
"ui.timer.endTimeFormat": {
  "extractionState": "manual",
  "localizations": {
    "en": { "stringUnit": { "value": "Ends at %@" } },
    "ko": { "stringUnit": { "value": "%@ 종료 예정" } }
  }
},
"ui.timer.completed": {
  "extractionState": "manual",
  "localizations": {
    "en": { "stringUnit": { "value": "Completed" } },
    "ko": { "stringUnit": { "value": "종료됨" } }
  }
}
```

After completion:
- Output "Step 6-2 complete. Ready for manual commit."
- Stop
```

**Pre-commit checklist:**
- [ ] Build succeeds
- [ ] `timer.formattedEndTime` compiles
- [ ] Running timer shows "Ends at 10:30 AM"
- [ ] Completed timer shows "Completed"
- [ ] Korean locale shows "%@ 종료 예정"

**Recommended commit message:**
```
feat: add formattedEndTime to TimerData

- Add formattedEndTime computed property
- Use TimeFormatter.formatEndTime for locale-aware formatting
- Add ui.timer.endTimeFormat localization key
- Add ui.timer.completed localization key
- Support both Korean and English
```

---

### Step 6-3: Display End Time in NewTimerRow

```text
Perform **Step 6-3 (Add end time UI)** only.

Scope:
- Display alarm icon and end time in the BOTTOM section of NewTimerRow

Implementation details:
Update the BOTTOM section in NewTimerRow.swift:

```swift
// BOTTOM: Alarm + End Time
HStack(spacing: 4) {
    let alarmMode = AlarmNotificationPolicy.getMode(
        soundOn: timer.isSoundOn,
        vibrationOn: timer.isVibrationOn
    )
    Image(systemName: alarmMode.iconName)
        .font(.caption)
        .foregroundColor(.secondary)
    
    Text(timer.formattedEndTime)
        .font(.footnote)
        .foregroundColor(.secondary)
    
    Spacer()
}
```

After completion:
- Output "Step 6-3 complete. Ready for manual commit."
- Stop
```

**Pre-commit checklist:**
- [ ] Build succeeds
- [ ] Alarm icon is visible in the BOTTOM section
- [ ] End time text is displayed
- [ ] Completed timer shows "Completed"
- [ ] Alarm icon changes based on mode (sound/vibration/silent)
- [ ] Time format is locale-aware

**Recommended commit message:**
```
feat: add end time display to NewTimerRow bottom section

- Show alarm mode icon
- Display formatted end time using formattedEndTime
- Show "Completed" for completed timers
- Apply proper styling (caption icon, footnote text)
```

---

## Phase 7: Delete Confirmation Dialog

### Step 7-1: Add Delete Confirmation

```text
Perform **Step 7-1 (Add delete confirmation)** only.

Scope:
- Add a delete confirmation dialog to NewTimerRow
- Manage dialog visibility with @State

Implementation details:
Update NewTimerRow.swift:

```swift
struct NewTimerRow: View {
    let timer: TimerData
    let onToggleFavorite: () -> Void
    let onPlayPause: () -> Void
    let onReset: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                FavoriteToggleButton(...)
                Text(timer.label)...
                Spacer()
                Button(action: { showDeleteConfirmation = true }) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
            }
        }
        .confirmationDialog(
            "Delete this timer?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}
```

After completion:
- Output "Step 7-1 complete. Ready for manual commit."
- Stop
```

**Pre-commit checklist:**
- [ ] Build succeeds
- [ ] Confirmation dialog appears when tapping delete
- [ ] Delete button triggers onDelete
- [ ] Cancel button dismisses dialog
- [ ] Dialog dismisses when tapping outside
- [ ] Dialog text is correct

**Recommended commit message:**
```
feat: add delete confirmation dialog to NewTimerRow

- Add confirmationDialog for delete action
- Show confirmation for all timer states
- Provide destructive and cancel options
- Manage dialog state with @State
```

---

## Phase 8: Running State Color Inversion

### Step 8-1: Add Color Inversion Styles

```text
Perform **Step 8-1 (Running state color inversion)** only.

Scope:
- Apply conditional styles based on isRunning
- Blue background with white text when running

Implementation details:
Update NewTimerRow.swift accordingly

After completion:
- Output "Step 8-1 complete. Ready for manual commit."
- Stop
```

**Pre-commit checklist:**
- [ ] Build succeeds
- [ ] Running state shows blue background with white text
- [ ] Paused state shows white background with dark text
- [ ] Transitions are smooth
- [ ] Readability is preserved in all states

---

### Step 8-2: Update FavoriteToggleButton

```text
Perform **Step 8-2 (Add isRunning support to FavoriteToggleButton)** only.

Scope:
- Add isRunning parameter with default value

After completion:
- Output "Step 8-2 complete. Ready for manual commit."
- Stop
```

---

### Step 8-3: Update UnifiedTimerButton

```text
Perform **Step 8-3 (UnifiedTimerButton color inversion)** only.

Scope:
- Add isRunning parameter
- Invert button colors when running

After completion:
- Output "Step 8-3 complete. Ready for manual commit."
- Stop
```

---

## Phase 9: Inline Label Editing

### Step 9-1: Create EditableTimerLabel

```text
Perform **Step 9-1 (Create EditableTimerLabel)** only.

Scope:
- Create `EditableTimerLabel.swift`
- Switch to editable TextField on tap

After completion:
- Output "Step 9-1 complete. Ready for manual commit."
- Stop
```

---

### Step 9-2: Integrate Inline Editing

```text
Perform **Step 9-2 (Integrate inline editing)** only.

Scope:
- Add onLabelChange closure to NewTimerRow
- Replace Text with EditableTimerLabel

After completion:
- Output "Step 9-2 complete. Ready for manual commit."
- Stop
```

---

## Final Execution Summary (v8)

This specification defines a **production-grade, experiment-friendly refactoring strategy** that prioritizes safety, clarity, and incremental validation when collaborating with AI tools.

