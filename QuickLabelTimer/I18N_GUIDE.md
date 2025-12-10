# Internationalization (i18n) Guide

This document describes the localization patterns and best practices used in QuickLabelTimer.

## Overview

QuickLabelTimer supports multiple languages through Apple's String Catalog (`.xcstrings`) and Stringsdict (`.stringsdict`) systems. Currently supported languages:
- English (en) - source language
- Korean (ko)

## File Structure

```
QuickLabelTimer/
├── Localizable.xcstrings      # Main string catalog for all user-facing text
├── Localizable.stringsdict    # Pluralization rules for English
└── Utils/
    └── Accessibility+Helpers.swift  # Centralized accessibility string constants
```

## Localization Patterns

### 1. Static Text in Views

For simple, non-interpolated strings in SwiftUI views, use the localization key directly:

```swift
// ✅ Recommended
Text("ui.timer.title")
NavigationLink("ui.settings.defaultSound") { ... }

// ❌ Avoid
Text("Timer")  // Hardcoded string
```

**When to use**: Button labels, navigation titles, section headers, static labels

### 2. String Variables and Programmatic Access

For strings that need to be stored in variables or used programmatically:

```swift
// ✅ Recommended
let message = String(localized: "ui.alert.ok")
let title: LocalizedStringKey = "ui.settings.title"

// ❌ Avoid
let message = "OK"  // Hardcoded
```

**When to use**: ViewModel properties, computed values, conditional strings

### 3. String Interpolation and Formatting

For strings with dynamic values, use `String(format:)` with `String(localized:)`:

```swift
// ✅ Recommended
let message = String(format: String(localized: "%@, 남은 시간 %@"), label, time)
let counter = String(format: String(localized: "%lld / %lld"), current, max)

// ❌ Avoid
let message = "\(label), 남은 시간 \(time)"  // Won't be localized
let message = LocalizedStringKey("\(label), 남은 시간 \(time)")  // Hardcoded Korean
```

**Key points**:
- Always use positional arguments (`%1$@`, `%2$@`) when order might vary by language
- Return `String`, not `LocalizedStringKey`, for interpolated strings
- The localized format string should be in the String Catalog

**When to use**: Accessibility labels with dynamic content, formatted messages, counters

### 4. Pluralization

For strings that change based on quantity, use `.stringsdict` files:

```swift
// Swift code
let message = String(format: String(localized: "ui.countdown.deleteTimer"), seconds)

// Localizable.stringsdict
<key>ui.countdown.deleteTimer</key>
<dict>
    <key>NSStringLocalizedFormatKey</key>
    <string>%#@seconds@</string>
    <key>seconds</key>
    <dict>
        <key>NSStringFormatSpecTypeKey</key>
        <string>NSStringPluralRuleType</string>
        <key>NSStringFormatValueTypeKey</key>
        <string>lld</string>
        <key>one</key>
        <string>In %lld second, timer will be deleted</string>
        <key>other</key>
        <string>In %lld seconds, timer will be deleted</string>
    </dict>
</dict>
```

**Plural categories in English**:
- `one`: exactly 1 (e.g., "1 second")
- `other`: all other values including 0 (e.g., "0 seconds", "2 seconds")

**When to use**: Any string with a number where the noun/verb form changes (second/seconds, timer/timers, character/characters)

### 5. Accessibility Labels

Centralize accessibility strings in `Accessibility+Helpers.swift`:

```swift
// Define in A11yText enum
enum TimerRow {
    static func runningLabel(label: String, time: String) -> String {
        return String(format: String(localized: "%@, 남은 시간 %@"), label, time)
    }

    static let startLabel: LocalizedStringKey = "a11y.timerRow.startLabel"
}

// Use in views
.accessibilityLabel(A11yText.TimerRow.runningLabel(label: timer.label, time: timer.formattedTime))
.accessibilityLabel(A11yText.TimerRow.startLabel)
```

**Key points**:
- Static labels use `LocalizedStringKey` type
- Dynamic labels use `String` return type with `String(format:)`
- All accessibility keys use `a11y.` prefix for organization

**When to use**: All VoiceOver labels, hints, and values

## Key Naming Conventions

Follow this hierarchical naming structure:

```
{category}.{screen/component}.{element}

Examples:
- ui.timer.title              # UI element in Timer screen
- ui.alert.cancel             # UI element in Alert
- ui.input.labelPlaceholder   # UI element in Input component
- a11y.timerRow.startLabel    # Accessibility label for TimerRow
- a11y.addTimer.createButton  # Accessibility label for AddTimer button
```

**Categories**:
- `ui.*` - User interface text (visible to all users)
- `a11y.*` - Accessibility labels (for VoiceOver/assistive tech)

**Benefits**:
- Easy to find related strings
- Prevents naming conflicts
- Groups by feature/screen for maintenance

## Testing Localization

Run localization tests to ensure all strings are properly translated:

```bash
# In Xcode
Product → Test (⌘U)

# Or via command line
xcodebuild test -scheme QuickLabelTimer -destination 'platform=iOS Simulator,name=iPhone 15'
```

Key test cases in `LocalizationTests.swift`:
- All keys have translations in both languages
- Plural forms are correct (1 second vs 2 seconds)
- String interpolation produces valid output
- Edge cases (zero, large numbers) are handled

## Common Mistakes to Avoid

### ❌ Hardcoding strings in code

```swift
// Wrong
Text("Timer")
let message = "In \(seconds) seconds, timer will be deleted"
```

### ❌ Using LocalizedStringKey for interpolated strings

```swift
// Wrong - Korean text hardcoded, won't adapt to user's language
static func runningLabel(label: String, time: String) -> LocalizedStringKey {
    return LocalizedStringKey("\(label), 남은 시간 \(time)")
}
```

### ❌ Not using positional arguments

```swift
// Wrong - word order might need to change in other languages
String(format: String(localized: "%@ remaining %@"), time, label)

// Correct - allows translators to reorder
String(format: String(localized: "%1$@ remaining %2$@"), time, label)
```

### ❌ Forgetting pluralization

```swift
// Wrong - always says "seconds" even for 1
let message = "In \(count) seconds"

// Correct - uses stringsdict plural rules
let message = String(format: String(localized: "ui.countdown.key"), count)
```

## Adding a New Language

1. **In Xcode**: Project Settings → Info → Localizations → Add Language
2. **Export for Localization**: Editor → Export for Localization
3. **Translate**: Send `.xcloc` file to translator
4. **Import**: Editor → Import Localizations
5. **Update Stringsdict**: Add plural rules for the new language if needed
6. **Test**: Switch device/simulator language and verify all strings

## Tools and Resources

- **Xcode String Catalog Editor**: Visual editor for `.xcstrings` files
- **NSLocalizedString**: Legacy API (we use `String(localized:)` instead)
- **Plural Rules**: [Unicode CLDR Plural Rules](http://cldr.unicode.org/index/cldr-spec/plural-rules)
- **Testing**: `LocalizationTests.swift` for automated verification

## Quick Reference

| Use Case | Pattern | Example |
|----------|---------|---------|
| Static UI text | `Text("key")` | `Text("ui.timer.title")` |
| String variable | `String(localized:)` | `String(localized: "ui.alert.ok")` |
| Formatted string | `String(format: String(localized:))` | `String(format: String(localized: "%@ %@"), a, b)` |
| Plural forms | Stringsdict + `String(format:)` | See Pluralization section |
| Accessibility | `A11yText` enum | `A11yText.TimerRow.startLabel` |

## Support

For questions or issues with localization:
1. Check this guide first
2. Review `LocalizationTests.swift` for examples
3. Consult Apple's [Localization Documentation](https://developer.apple.com/localization/)
