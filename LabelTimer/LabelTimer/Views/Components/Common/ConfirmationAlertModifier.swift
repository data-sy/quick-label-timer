//
//  ConfirmationAlertModifier.swift
//  LabelTimer
//
//  Created by 이소연 on 7/31/25.
//
/// 확인이 필요한 액션(삭제, 숨김 등)에 대한 얼럿을 재사용할 수 있는 ViewModifier
///
/// - 사용 목적: 여러 뷰에서 일관된 확인 얼럿을 쉽게 적용할 수 있도록 공통 컴포넌트화

import SwiftUI

struct ConfirmationAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let itemName: String
    let titleMessage: String
    let actionButtonLabel: String
    let onConfirm: () -> Void

    func body(content: Content) -> some View {
        content
            .alert(
                "“\(itemName)”",
                isPresented: $isPresented,
                actions: {
                    Button("취소", role: .cancel) { }
                    Button(actionButtonLabel, role: .destructive, action: onConfirm)
                },
                message: {
                    Text(titleMessage)
                }
            )
    }
}

extension View {
    /// 확인이 필요한 액션에 대한 얼럿을 쉽게 띄우는 헬퍼 메서드
    func confirmationAlert(
        isPresented: Binding<Bool>,
        itemName: String,
        titleMessage: String,
        actionButtonLabel: String = "삭제",
        onConfirm: @escaping () -> Void
    ) -> some View {
        self.modifier(ConfirmationAlertModifier(
            isPresented: isPresented,
            itemName: itemName,
            titleMessage: titleMessage,
            actionButtonLabel: actionButtonLabel,
            onConfirm: onConfirm
        ))
    }
}
