//
//  LocalizationTests.swift
//  QuickLabelTimerTests
//
//  Created by Claude Code on 12/10/25.
//
/// i18n(국제화) 기능을 검증하는 테스트 스위트
///
/// - 사용 목적:
///   1. 모든 로컬라이제이션 키가 올바르게 번역되는지 확인
///   2. 복수형 규칙이 정확히 작동하는지 검증
///   3. 동적 문자열 보간이 올바르게 현지화되는지 테스트

import Testing
import Foundation
@testable import QuickLabelTimer

struct LocalizationTests {

    // MARK: - Static String Tests

    @Test("All UI keys have English translations")
    func testUIKeysHaveEnglishTranslations() async throws {
        let testKeys = [
            "ui.timer.title",
            "ui.settings.title",
            "ui.favorite.title",
            "ui.alert.ok",
            "ui.alert.cancel"
        ]

        for key in testKeys {
            let localized = String(localized: String.LocalizationValue(key))
            #expect(localized != key, "Key '\(key)' should be translated")
            #expect(!localized.isEmpty, "Translation for '\(key)' should not be empty")
        }
    }

    @Test("All accessibility keys have English translations")
    func testAccessibilityKeysHaveEnglishTranslations() async throws {
        let testKeys = [
            "a11y.addTimer.createButton",
            "a11y.timerRow.startLabel",
            "a11y.timerRow.pauseLabel",
            "a11y.mainToolbar.settingsButton"
        ]

        for key in testKeys {
            let localized = String(localized: String.LocalizationValue(key))
            #expect(localized != key, "Key '\(key)' should be translated")
            #expect(!localized.isEmpty, "Translation for '\(key)' should not be empty")
        }
    }

    // MARK: - Pluralization Tests

    @Test("Countdown messages use correct plural forms")
    func testCountdownMessagePluralForms() async throws {
        // Test singular (1 second)
        let singular = String(format: String(localized: "ui.countdown.deleteTimer"), 1)
        #expect(singular.contains("second"), "Singular form should use 'second' not 'seconds'")
        #expect(!singular.contains("seconds,"), "Singular form should not use 'seconds'")

        // Test plural (2 seconds)
        let plural = String(format: String(localized: "ui.countdown.deleteTimer"), 2)
        #expect(plural.contains("seconds"), "Plural form should use 'seconds'")
    }

    @Test("Alert messages use correct plural forms")
    func testAlertMessagePluralForms() async throws {
        // Test singular (1 timer)
        let singular = String(format: String(localized: "ui.alert.maxTimersMessage"), 1)
        #expect(singular.contains("timer"), "Singular form should use 'timer'")

        // Test plural (5 timers)
        let plural = String(format: String(localized: "ui.alert.maxTimersMessage"), 5)
        #expect(plural.contains("timers"), "Plural form should use 'timers'")
    }

    @Test("Character limit message uses correct plural forms")
    func testCharacterLimitPluralForms() async throws {
        // Test singular (1 character)
        let singular = String(format: String(localized: "ui.input.maxLabelToast"), 1)
        #expect(singular.contains("character"), "Singular form should use 'character'")

        // Test plural (100 characters)
        let plural = String(format: String(localized: "ui.input.maxLabelToast"), 100)
        #expect(plural.contains("characters"), "Plural form should use 'characters'")
    }

    // MARK: - Dynamic String Interpolation Tests

    @Test("Timer row accessibility labels are properly localized")
    func testTimerRowAccessibilityLabels() async throws {
        let label = "Meeting Timer"
        let time = "05:00"

        // Test running label
        let runningLabel = A11yText.TimerRow.runningLabel(label: label, time: time)
        #expect(runningLabel.contains(label), "Should contain timer label")
        #expect(runningLabel.contains(time), "Should contain time")
        #expect(runningLabel.contains("remaining"), "English should contain 'remaining'")

        // Test paused label
        let pausedLabel = A11yText.TimerRow.pausedLabel(label: label, time: time)
        #expect(pausedLabel.contains(label), "Should contain timer label")
        #expect(pausedLabel.contains(time), "Should contain time")
        #expect(pausedLabel.contains("paused"), "English should contain 'paused'")

        // Test completed label
        let completedLabel = A11yText.TimerRow.completedLabel(label: label)
        #expect(completedLabel.contains(label), "Should contain timer label")
        #expect(completedLabel.contains("completed"), "English should contain 'completed'")
    }

    @Test("Counter display is properly localized")
    func testCounterDisplay() async throws {
        let current: Int64 = 85
        let max: Int64 = 100

        let formatted = String(format: String(localized: "%lld / %lld"), current, max)
        #expect(formatted.contains("85"), "Should contain current count")
        #expect(formatted.contains("100"), "Should contain max count")
        #expect(formatted.contains("/"), "Should contain separator")
    }

    // MARK: - Edge Cases

    @Test("Zero values are handled correctly in pluralization")
    func testZeroValuePluralization() async throws {
        // In English, 0 typically uses plural form
        let zero = String(format: String(localized: "ui.countdown.deleteTimer"), 0)
        #expect(zero.contains("seconds"), "Zero should use plural form in English")
    }

    @Test("Large numbers are formatted correctly")
    func testLargeNumberFormatting() async throws {
        let large = String(format: String(localized: "ui.countdown.deleteTimer"), 999)
        #expect(large.contains("999"), "Should display large numbers correctly")
        #expect(large.contains("seconds"), "Large numbers should use plural form")
    }
}
