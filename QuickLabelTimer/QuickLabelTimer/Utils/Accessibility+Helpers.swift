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
    static let emptyInput: LocalizedStringKey = "입력되지 않음"
    static let notSet: LocalizedStringKey = "설정되지 않음"
    
    // 타이머 생성 (AddTimerView)
    enum AddTimer {
        static let labelInputLabel: LocalizedStringKey = "타이머 라벨"
        static let labelInputHint: LocalizedStringKey = "타이머의 이름을 입력해 주세요. 비워두면 자동으로 이름이 생성됩니다."
        
        static let timePickerLabel: LocalizedStringKey = "타이머 시간 설정"
        static let timePickerHint: LocalizedStringKey = "타이머의 시간을 시간, 분, 초 단위로 설정합니다."
        
        static let createButtonLabel: LocalizedStringKey = "타이머 생성"
        static let createButtonHint: LocalizedStringKey = "입력한 라벨과 시간으로 새로운 타이머를 생성합니다."
        
        static let timeChipHint: LocalizedStringKey = "타이머 설정 시간에 5분을 추가합니다."
    }
    
    // 실행 중인 타이머 (RunningTimerView)
    enum RunningTimer {
        // %1$@ = 라벨, %2$@ = 남은 시간
        static func cellLabel(label: String, remainingTime: String) -> LocalizedStringKey {
            return LocalizedStringKey("\(label) 타이머, 남은 시간 \(remainingTime)")
        }
        static let cellHint: LocalizedStringKey = "선택하여 타이머의 세부 정보를 확인하거나 수정합니다."
        
        static let pauseButtonLabel: LocalizedStringKey = "일시정지"
        static let resumeButtonLabel: LocalizedStringKey = "재개"
        static let stopButtonLabel: LocalizedStringKey = "정지"
    }
}
