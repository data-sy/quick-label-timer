//
//  Accessibility+Helpers.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 9/6/25.
//
/// 접근성(Accessibility) 관련 ViewModifier, Extension, 문자열 상수 등을 관리
///
/// 사용 목적: 반복적으로 사용되는 접근성 코드를 한 곳에서 관리하여 재사용성을 높이고 유지보수를 용이하게 함

import SwiftUI

// MARK: - Accessibility View Modifiers

/// 입력 필드(TextField, Picker 등)를 위한 ViewModifier
struct A11yInputModifier: ViewModifier {
    let label: LocalizedStringKey
    let value: String
    let emptyValueText: LocalizedStringKey
    let hint: LocalizedStringKey
    let combineChildren: Bool

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: combineChildren ? .combine : .ignore)
            .accessibilityLabel(label)
            .accessibilityValue(value.isEmpty ? emptyValueText : LocalizedStringKey(value))
            .accessibilityHint(hint)
    }
}

/// 일반적인 뷰(Button, Text 등)를 위한 ViewModifier
struct A11yGeneralModifier: ViewModifier {
    let label: LocalizedStringKey
    let hint: LocalizedStringKey?
    let traits: AccessibilityTraits
    let combineChildren: Bool
    
    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: combineChildren ? .combine : .ignore)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }
}

// MARK: - View Extension for Accessibility

extension View {
    /// 접근성: 입력 필드(TextField, Picker 등)에 공통적으로 사용되는 Modifier
    /// - Parameters:
    ///   - label: VoiceOver가 읽어줄 UI 요소의 이름 (예: "타이머 이름")
    ///   - value: 현재 입력되거나 선택된 값 (예: "회의록 작성")
    ///   - emptyValueText: 값이 비어있을 때 읽어줄 문구 (기본값: "입력되지 않음")
    ///   - hint: UI 요소의 역할이나 사용법에 대한 추가 안내 (예: "타이머의 라벨을 입력해 주세요.")
    ///   - combineChildren: 자식 뷰들의 접근성 요소를 합칠지 여부 (기본값: true)
    func a11yInput(
        label: LocalizedStringKey,
        value: String,
        emptyValueText: LocalizedStringKey = A11yText.emptyInput,
        hint: LocalizedStringKey,
        combineChildren: Bool = true
    ) -> some View {
        self.modifier(A11yInputModifier(label: label,
                                        value: value,
                                        emptyValueText: emptyValueText,
                                        hint: hint,
                                        combineChildren: combineChildren))
    }
    
    /// 접근성: 버튼, 텍스트 등 일반적인 뷰에 사용되는 Modifier
    /// - Parameters:
    ///   - label: VoiceOver가 읽어줄 UI 요소의 이름 또는 텍스트 (예: "타이머 시작")
    ///   - hint: UI 요소의 역할이나 사용법에 대한 추가 안내 (선택 사항)
    ///   - traits: 버튼, 헤더 등 UI 요소의 속성 (기본값: 없음)
    ///   - combineChildren: 자식 뷰들의 접근성 요소를 합칠지 여부 (기본값: true)
    func a11y(
        label: LocalizedStringKey,
        hint: LocalizedStringKey? = nil,
        traits: AccessibilityTraits = [],
        combineChildren: Bool = true
    ) -> some View {
        self.modifier(A11yGeneralModifier(label: label,
                                          hint: hint,
                                          traits: traits,
                                          combineChildren: combineChildren))
    }
}


// MARK: - Centralized Accessibility Strings

enum A11yText {
    // 공통
    static let emptyInput: LocalizedStringKey = "a11y.common.emptyInput"
    static let notSet: LocalizedStringKey = "a11y.common.notSet"
    
    // 메인 툴바
    enum MainToolbar {
        static let listEditButtonLabel: LocalizedStringKey = "a11y.mainToolbar.listEditButton"
        static let doneButtonLabel: LocalizedStringKey = "a11y.mainToolbar.doneButton"
        static let settingsButtonLabel: LocalizedStringKey = "a11y.mainToolbar.settingsButton"
    }
    
    // 타이머 생성 (AddTimerView)
    enum AddTimer {
        static let labelInputLabel: LocalizedStringKey = "a11y.addTimer.labelInputLabel"
        static let labelInputHint: LocalizedStringKey = "a11y.addTimer.labelInputHint"
        
        static let timePickerLabel: LocalizedStringKey = "a11y.addTimer.timePickerLabel"
        static let timePickerHint: LocalizedStringKey = "a11y.addTimer.timePickerHint"
        
        static let createButtonLabel: LocalizedStringKey = "a11y.addTimer.createButton"
        static let createButtonHint: LocalizedStringKey = "a11y.addTimer.createButtonHint"
        
        static let timeChipHint: LocalizedStringKey = "a11y.addTimer.timeChipHint"
    }
    
    // Timer Row (TimerRowView) & Buttons
    enum TimerRow {
        // 동적 문자열은 원래대로 유지 (자동 추출 안 됨)
        static func runningLabel(label: String, time: String) -> LocalizedStringKey {
            return LocalizedStringKey("\(label), 남은 시간 \(time)")
        }

        static func pausedLabel(label: String, time: String) -> LocalizedStringKey {
            return LocalizedStringKey("\(label), 일시정지됨, 남은 시간 \(time)")
        }

        static func completedLabel(label: String) -> LocalizedStringKey {
            return LocalizedStringKey("\(label), 완료됨")
        }
        
        static func presetLabel(label: String, time: String) -> LocalizedStringKey {
            return LocalizedStringKey("\(label), 설정 시간 \(time)")
        }

        static let favoriteLabel: LocalizedStringKey = "a11y.timerRow.favoriteLabel"
        static let favoriteOnHint: LocalizedStringKey = "a11y.timerRow.favoriteOnHint"
        static let favoriteOffHint: LocalizedStringKey = "a11y.timerRow.favoriteOffHint"
        static let moveToFavoriteLabel: LocalizedStringKey = "a11y.timerRow.moveToFavorite"

        static let pauseLabel: LocalizedStringKey = "a11y.timerRow.pauseLabel"
        static let playLabel: LocalizedStringKey = "a11y.timerRow.playLabel"
        static let stopLabel: LocalizedStringKey = "a11y.timerRow.stopLabel"
        static let startLabel: LocalizedStringKey = "a11y.timerRow.startLabel"
        static let restartLabel: LocalizedStringKey = "a11y.timerRow.restartLabel"
        static let deleteLabel: LocalizedStringKey = "a11y.timerRow.deleteLabel"
        static let editLabel: LocalizedStringKey = "a11y.timerRow.editLabel"
    }
    
    // 즐겨찾기 목록 (FavoriteListView)
    enum FavoriteList {
        static let emptyMessage: LocalizedStringKey = "a11y.favoriteList.emptyMessage"
        static let runningStatus: LocalizedStringKey = "a11y.favoriteList.runningStatus"
    }
    
    // 실행중인 타이머 목록 (RunningListView)
    enum RunningList {
     static let emptyMessage: LocalizedStringKey = "a11y.runningList.emptyMessage"
    }

    // 메인 탭 (MainTabView)
    enum MainTabs {
        static let timerTab: LocalizedStringKey = "a11y.mainTabs.timerTab"
        static let favoritesTab: LocalizedStringKey = "a11y.mainTabs.favoritesTab"
    }
    
    // 프리셋 편집 (EditPresetView)
    enum EditPreset {
        static let saveButton: LocalizedStringKey = "a11y.editPreset.saveButton"
        static let cancelButton: LocalizedStringKey = "a11y.editPreset.cancelButton"
        static let deleteButton: LocalizedStringKey = "a11y.editPreset.deleteButton"
    }
    
    // 설정 (SettingsView)
    enum Settings {
        static let opensExternalLinkHint: LocalizedStringKey = "a11y.settings.opensExternalLinkHint"
        static let opensExternalLinkHint_EN: LocalizedStringKey = "a11y.settings.opensExternalLinkHint_EN"
        static let opensSystemSettingsHint: LocalizedStringKey = "a11y.settings.opensSystemSettingsHint"
    }
}
