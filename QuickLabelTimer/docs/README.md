# QuickLabelTimer Documentation

## Documentation Structure

This project uses a **two-tier documentation system** optimized for AI-assisted development:

### 📄 `/CLAUDE.md` - AI Collaboration Guide (396 lines)

**Purpose:** Fast, actionable reference consumed by Claude Code on EVERY request.

**Optimized for:**
- ✅ Token efficiency (minimal context usage)
- ✅ High signal-to-noise ratio
- ✅ Quick pattern lookup
- ✅ Critical rules and gotchas
- ✅ Common task recipes

**Contains:**
- Tech stack overview
- MVVM architecture diagram
- 🚨 Critical rules (NEVER break these)
- Core data models (essential properties only)
- State machine quick reference
- File structure map
- Common task checklists
- Key patterns (Combine, DI, error handling)
- Constants and configuration
- Quick debugging checklists

**Target Audience:** Claude Code AI, developers doing quick lookups

---

### 📚 `/docs/*` - Detailed Documentation

Deep-dive guides for human developers who need comprehensive understanding.

---

## Documentation Files

### [`ARCHITECTURE_DEEP_DIVE.md`](./ARCHITECTURE_DEEP_DIVE.md)

**For:** Understanding design decisions and system internals

**Contains:**
- MVVM architecture detailed explanation
- Why Service + Repository layers exist
- Complete data flow walkthrough
- Design decisions & trade-offs
  - UserDefaults vs CoreData
  - 1Hz tick loop vs Combine.Timer
  - Local notifications vs in-app audio
  - Repeating notification pattern (why 12?)
  - Soft delete rationale
  - Protocol-based dependencies
- Historical context (architecture evolution)
- Performance characteristics
- Testing strategy
- Future architecture considerations

**When to read:**
- Starting on the project (onboarding)
- Making architectural changes
- Understanding "why we built it this way"
- Planning major refactoring

---

### [`STATE_MACHINE_GUIDE.md`](./STATE_MACHINE_GUIDE.md)

**For:** Complete reference for TimerInteractionState system

**Contains:**
- The problem (why separate UI state from data state)
- The solution (3-layer system)
- Layer 1: TimerData.status (internal state)
  - State transition diagram
  - Valid transitions
- Layer 2: TimerInteractionState (UI state)
  - Conversion extensions
  - Why .preset exists only in UI
- Layer 3: Button mapping
  - Button types (Left/Right)
  - `makeButtonSet()` function (core logic)
  - Complete button combination table
- State transition functions
- EndAction logic (favorite toggle)
- Usage patterns in ViewModels and Views
- Testing the state machine
- Adding new states/buttons
- Visual state diagram

**When to read:**
- Working on button logic
- Adding new timer states
- Debugging UI button issues
- Understanding state machine pattern

---

### [`NOTIFICATION_SYSTEM.md`](./NOTIFICATION_SYSTEM.md)

**For:** Complete reference for notification scheduling and handling

**Contains:**
- Why local notifications (vs in-app audio)
- Notification ID strategy (`{timerId}_{index}`)
  - Why this format enables batch cancellation
- Repeating notification pattern
  - The problem (single notification can fail)
  - The solution (12 notifications over 36 seconds)
  - Visual escalation (⏰ → ⏰⏰ → ⏰⏰⏰)
- Alarm notification policy (3-layer translation)
  - AlarmMode (UI) → AlarmNotificationPolicy → UNNotificationSound
- NotificationUtils (utility functions)
- LocalNotificationDelegate
  - Foreground suppression strategy
  - User interaction handling
- Notification lifecycle example (complete trace)
- Notification count management (64-limit)
- Cleanup strategy
- Testing notifications
- Common issues & solutions

**When to read:**
- Working on notification features
- Debugging notification issues
- Understanding 64-notification limit
- Implementing alarm sounds/vibration

---

### [`DEVELOPMENT_GUIDE.md`](./DEVELOPMENT_GUIDE.md)

**For:** Extended examples, debugging walkthroughs, common scenarios

**Contains:**
- Development environment setup
- Common development scenarios
  - **Scenario 1:** Add new timer property (complete walkthrough)
  - **Scenario 2:** Add new button action (duplicate button example)
- Debugging walkthroughs
  - Debug: Timer not counting down
  - Debug: Notification not firing
  - Debug: Persistence not working
- Code review checklist
- Performance profiling
- Migration guide

**When to read:**
- Adding new features (follow templates)
- Debugging issues (systematic troubleshooting)
- Before submitting PR (checklist)
- Setting up dev environment

---

## How to Use This Documentation

### For AI-Assisted Development (Claude Code)

**Primary:** Read `/CLAUDE.md` - Always included in context

**When needed:** Reference detailed docs for:
- Architecture decisions → `ARCHITECTURE_DEEP_DIVE.md`
- State machine logic → `STATE_MACHINE_GUIDE.md`
- Notification handling → `NOTIFICATION_SYSTEM.md`
- Development patterns → `DEVELOPMENT_GUIDE.md`

### For Human Developers

#### New to Project?

1. **Start:** Read `/CLAUDE.md` (15 min) - Get high-level overview
2. **Deep dive:** Read `ARCHITECTURE_DEEP_DIVE.md` (30 min) - Understand design
3. **Hands-on:** Follow `DEVELOPMENT_GUIDE.md` setup steps

#### Working on Feature?

1. **Quick reference:** Check `/CLAUDE.md` for pattern
2. **Detailed guide:** Read relevant `/docs/*.md` section
3. **Template:** Use scenario walkthroughs in `DEVELOPMENT_GUIDE.md`

#### Debugging Issue?

1. **Quick fix:** Check debugging checklists in `/CLAUDE.md`
2. **Deep dive:** Use debugging walkthroughs in `DEVELOPMENT_GUIDE.md`
3. **System understanding:** Read relevant detailed doc

#### Code Review?

Use checklist in `DEVELOPMENT_GUIDE.md` → Code Review Checklist section

---

## Documentation Principles

### What Stays in `/CLAUDE.md`

✅ **High signal:**
- Architecture rules and constraints
- File location patterns
- Required patterns for common tasks
- Critical gotchas with immediate solutions
- Technology stack and key dependencies
- Quick reference code snippets (3-5 lines max)

### What Goes in `/docs/*.md`

📚 **Detailed explanations:**
- Historical context ("we used to use X, now Y")
- Detailed class-by-class walkthroughs
- Exhaustive code examples
- Theoretical pattern explanations
- "Why we chose this approach" narratives
- Complete data flow diagrams
- Migration guides
- Performance analysis
- Debugging walkthroughs

---

## Metrics

**CLAUDE.md:**
- Lines: 396 (target: 400-500)
- Token estimate: ~8,000 tokens
- Read time: 10 minutes
- AI context: Loaded on every request

**Detailed Docs:**
- ARCHITECTURE_DEEP_DIVE.md: ~600 lines
- STATE_MACHINE_GUIDE.md: ~650 lines
- NOTIFICATION_SYSTEM.md: ~550 lines
- DEVELOPMENT_GUIDE.md: ~800 lines
- Total: ~2,600 lines

**Reduction:** 2,500 lines → 396 lines in main AI context (84% reduction)

---

## Quick Navigation

**I want to...**

- **Understand the architecture** → Read `ARCHITECTURE_DEEP_DIVE.md`
- **Add a new feature** → Follow templates in `DEVELOPMENT_GUIDE.md`
- **Debug an issue** → Check `/CLAUDE.md` checklists, then `DEVELOPMENT_GUIDE.md` walkthroughs
- **Understand state machine** → Read `STATE_MACHINE_GUIDE.md`
- **Work with notifications** → Read `NOTIFICATION_SYSTEM.md`
- **Quick lookup (AI)** → `/CLAUDE.md` is always loaded
- **Code review** → Use checklist in `DEVELOPMENT_GUIDE.md`

---

## Contributing to Documentation

### When to Update `/CLAUDE.md`

- Adding critical new rule
- Changing core pattern
- Adding new common task recipe
- Updating file structure

**Keep it concise:** Max 500 lines

### When to Update `/docs/*.md`

- Detailed architecture changes
- New complex subsystem
- Extended examples
- Migration guides
- Performance optimizations

**Be comprehensive:** No line limit

### Documentation Style

**CLAUDE.md:**
- Bullet points and checklists
- Code fences (3-5 lines max)
- Symbols for quick scanning (✅❌⚠️🔧)
- Imperatives ("Do this", not "You can do this")

**Detailed docs:**
- Full explanations
- Extended code examples
- Diagrams and flowcharts
- Historical context
- Markdown headings (##, ###)

---

## Revision History

**Version 3.0** (2025-01-06)
- Refactored CLAUDE.md to 396 lines (was 2,500 lines)
- Extracted detailed content to 4 separate docs
- Optimized for AI token efficiency
- Added quick reference checklists

**Version 2.0** (2025-01-06)
- Enhanced CLAUDE.md for practical development guide
- Added Section 18: Common Development Tasks
- Added Section 19: Critical Rules & Common Pitfalls
- Added Quick Reference Summary

**Version 1.0** (2025-01-05)
- Initial CLAUDE.md created
- Comprehensive architecture documentation
- All content in single file

---

## License

Same as project license (see root LICENSE file).

---

**Questions?** Check the relevant detailed doc or search `/CLAUDE.md` for quick patterns.
