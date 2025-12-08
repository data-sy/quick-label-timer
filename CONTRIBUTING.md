# Contributing to QuickLabelTimer

This document provides guidelines for contributing to QuickLabelTimer. Following these conventions ensures consistency and maintainability across the codebase.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Style](#code-style)
- [Branching Strategy](#branching-strategy)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)
- [Localization](#localization)
- [Accessibility](#accessibility)

## Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 16.0+ SDK
- Git
- CocoaPods (if using Firebase)

### Initial Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/quick-label-timer.git
   cd quick-label-timer
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/data-sy/quick-label-timer.git
   ```
4. Install dependencies:
   ```bash
   pod install  # If using CocoaPods
   ```
5. Open `QuickLabelTimer.xcworkspace`

### Keeping Your Fork Updated

```bash
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

## Development Workflow

### Before Making Changes

1. Create a new branch from `main`:
   ```bash
   git checkout main
   git pull upstream main
   git checkout -b feature/your-feature-name
   ```

2. Review relevant documentation:
   - `QuickLabelTimer/CLAUDE.md`: Quick reference
   - `QuickLabelTimer/docs/ARCHITECTURE_DEEP_DIVE.md`: Design patterns
   - `QuickLabelTimer/docs/STATE_MACHINE_GUIDE.md`: State management
   - `QuickLabelTimer/docs/DEVELOPMENT_GUIDE.md`: Extended examples

### During Development

1. **Read before modifying**: Always read existing files before making changes
2. **Follow architecture patterns**: Use protocol-based dependency injection
3. **Test incrementally**: Run the app frequently during development
4. **Check accessibility**: Test with VoiceOver and Dynamic Type
5. **Verify localization**: Ensure new strings are added to `Localizable.xcstrings`

### Critical Rules

These rules are non-negotiable and prevent common bugs:

1. **Never modify `TimerData`/`TimerPreset` directly in Views/ViewModels**
   - Always route through `TimerService` methods

2. **Never create new service/repository instances**
   - Use dependency injection via `init()` parameters

3. **Never access repositories from background threads**
   - Always use `@MainActor` for timer-related operations

4. **Never exceed 64 notification limit**
   - Cancel notifications before removing timers

5. **Never use `try!` for persistence**
   - Use `do/catch` with fallback to empty arrays

See `QuickLabelTimer/CLAUDE.md` for detailed examples.

## Code Style

### Swift Conventions

- **Naming**: Use descriptive names following Swift API Design Guidelines
  - Types: `PascalCase`
  - Functions/Variables: `camelCase`
  - Constants: `camelCase` (not `UPPER_CASE`)

- **Formatting**:
  - Indent with 4 spaces (not tabs)
  - Max line length: 120 characters
  - One blank line between methods

- **Access Control**:
  - Explicit access modifiers (`private`, `internal`, `public`)
  - Prefer `private` for implementation details

- **Type Inference**:
  - Use type inference where obvious
  - Explicit types for public interfaces

### Architecture Patterns

#### Dependency Injection

```swift
// ✅ Correct: Protocol-based injection
class MyViewModel: ObservableObject {
    private let timerService: any TimerServiceProtocol

    init(timerService: any TimerServiceProtocol) {
        self.timerService = timerService
    }
}

// ❌ Wrong: Direct instantiation
class MyViewModel: ObservableObject {
    private let timerService = TimerService()
}
```

#### Combine Subscriptions

```swift
// ✅ Correct: Use assign(to:) to avoid retain cycles
timerRepository.timersPublisher
    .map { $0.sorted(by: { $0.createdAt > $1.createdAt }) }
    .assign(to: &$sortedTimers)

// ❌ Wrong: Strong reference in sink
timerRepository.timersPublisher
    .sink { self.timers = $0 }
```

#### Error Handling

```swift
// ✅ Correct: Graceful fallback
do {
    timers = try JSONDecoder().decode([TimerData].self, from: data)
} catch {
    Logger.persistence.error("Decode failed: \(error)")
    timers = []
}

// ❌ Wrong: Force unwrapping
timers = try! JSONDecoder().decode([TimerData].self, from: data)
```

### Logging

Use structured logging with OSLog:

```swift
import OSLog

// Use appropriate log levels
Logger.timer.debug("Tick loop iteration: \(count)")      // Verbose
Logger.timer.info("Timer started: \(label)")             // Important events
Logger.timer.notice("State transition: \(state)")        // Significant changes
Logger.persistence.error("Save failed: \(error)")        // Errors
Logger.notification.fault("Exceeded limit: \(count)")    // Critical issues
```

Available loggers: `.timer`, `.persistence`, `.notification`, `.ui`

## Branching Strategy

### Branch Naming

Use descriptive prefixes:

- `feature/`: New features (`feature/preset-export`)
- `fix/`: Bug fixes (`fix/notification-scheduling`)
- `refactor/`: Code refactoring (`refactor/state-machine`)
- `docs/`: Documentation updates (`docs/architecture-guide`)
- `test/`: Test additions (`test/timer-service`)
- `chore/`: Maintenance tasks (`chore/update-dependencies`)

### Branch Lifecycle

1. Create from `main`
2. Keep branches focused (one feature/fix per branch)
3. Rebase regularly to stay current with `main`
4. Delete after merging

## Commit Guidelines

### Commit Message Format

Follow Conventional Commits style:

```
<type>: <description>

[optional body]

[optional footer]
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code restructuring without behavior change
- `docs`: Documentation changes
- `test`: Test additions or modifications
- `chore`: Maintenance tasks (dependencies, config)
- `perf`: Performance improvements
- `style`: Code formatting (not visual style)

### Examples

```bash
# Good commits
feat: add timer export functionality
fix: prevent notification count exceeding iOS limit
refactor: extract button mapping to separate file
docs: update state machine guide with new transitions
test: add coverage for timer completion handler

# Bad commits
update stuff
fixed bug
WIP
changes
```

### Guidelines

- Use imperative mood ("add feature" not "added feature")
- First line max 72 characters
- Capitalize first letter
- No period at end of first line
- Body explains what and why (not how)

## Pull Request Process

### Before Submitting

1. **Self-review**:
   - [ ] Code follows style guidelines
   - [ ] No console warnings or errors
   - [ ] Accessibility labels added for new UI
   - [ ] New strings added to `Localizable.xcstrings` (both en and ko)
   - [ ] No direct data model mutations
   - [ ] Proper error handling (no force unwraps)

2. **Test checklist**:
   - [ ] Tested with multiple timers (5 concurrent)
   - [ ] Tested app backgrounding/foregrounding
   - [ ] Verified notification scheduling (<64 total)
   - [ ] Tested with VoiceOver enabled
   - [ ] Tested with Dynamic Type (largest size)
   - [ ] Tested in both English and Korean

3. **Documentation**:
   - Update relevant docs if architecture changes
   - Add comments for non-obvious logic
   - Update `CHANGELOG.md` under `[Unreleased]`

### PR Description Template

```markdown
## Summary
Brief description of changes

## Changes
- List specific modifications
- Use bullet points

## Testing
- Describe test scenarios
- Include edge cases tested

## Screenshots (if UI changes)
[Add before/after screenshots]

## Checklist
- [ ] Follows code style guidelines
- [ ] Updated documentation
- [ ] Added/updated tests
- [ ] Tested accessibility
- [ ] Tested localization
- [ ] Updated CHANGELOG.md
```

### Review Process

1. Automated checks must pass
2. At least one maintainer review required
3. Address feedback in new commits (don't force push)
4. Once approved, maintainer will merge

### Merge Strategy

- Squash and merge for feature branches
- Meaningful commit message in squashed commit
- Delete branch after merge

## Testing

### Running Tests

```bash
# In Xcode
Product → Test (⌘U)

# Or select specific test target
```

### Writing Tests

Use Swift Testing framework (iOS 18+):

```swift
import Testing
@testable import QuickLabelTimer

@Suite("Timer Service Tests")
struct TimerServiceTests {
    @Test("Should create timer with valid parameters")
    func createTimer() async throws {
        // Test implementation
    }
}
```

### Test Coverage Priorities

1. **State machine transitions**: All state changes
2. **Service layer**: Business logic
3. **Repository layer**: Persistence operations
4. **Pure functions**: Button mapping, calculations

### Testing Patterns

- Use protocol mocks for dependencies
- Test ViewModels in isolation
- Verify Combine publisher emissions
- Test error handling paths

## Localization

### Adding New Strings

1. Add to `Localizable.xcstrings`:
   ```json
   "ui.feature.element": {
     "en": "English text",
     "ko": "한국어 텍스트"
   }
   ```

2. Follow naming conventions:
   - UI text: `"ui.{screen}.{element}"`
   - Accessibility: `"a11y.{context}.{element}"`

3. Keep strings concise and context-aware
4. Avoid hardcoded strings in code

### Translation Guidelines

- Maintain consistent terminology
- Consider cultural context
- Test in both languages
- Verify text doesn't truncate at normal sizes

## Accessibility

### Requirements

All UI changes must support:

1. **VoiceOver**:
   - Semantic labels for all interactive elements
   - Logical navigation order
   - State changes announced

2. **Dynamic Type**:
   - Text scales properly
   - No truncation at largest sizes
   - Layout adapts to content

3. **High Contrast**:
   - Sufficient color contrast ratios
   - Don't rely solely on color for information

### Implementation

```swift
// Accessibility labels
.accessibilityLabel(Text("a11y.timer.startButton"))
.accessibilityHint(Text("a11y.timer.startHint"))

// Dynamic Type
Text("Label")
    .font(.body)  // Use system fonts

// VoiceOver grouping
.accessibilityElement(children: .combine)
```

### Testing

- Enable VoiceOver: Settings → Accessibility → VoiceOver
- Test Dynamic Type: Settings → Accessibility → Display & Text Size
- Verify with Accessibility Inspector (Xcode)

---

## Questions or Issues?

- Check existing documentation in `QuickLabelTimer/docs/`
- Search existing issues/PRs
- Open a new issue for bugs or feature requests
- Tag maintainers for urgent questions

Thank you for contributing to QuickLabelTimer!
