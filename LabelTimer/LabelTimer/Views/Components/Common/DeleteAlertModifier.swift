//
//  DeleteAlertModifier.swift
//  LabelTimer
//
//  Created by 이소연 on 7/31/25.
//
/// 삭제 확인 알럿을 재사용할 수 있는 ViewModifier
///
/// - 사용 목적: 여러 뷰에서 일관된 삭제 확인 얼럿을 쉽게 적용할 수 있도록 공통 컴포넌트화

// TODO: 네이밍 리팩토링 (숨김/삭제 등 범용 얼럿에 맞게 이름 변경 예정)

import SwiftUI

struct DeleteAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let itemName: String
    let deleteLabel: String
    let onDelete: () -> Void

    func body(content: Content) -> some View {
        content
            .alert(
                "“\(itemName)” \(deleteLabel)를 삭제하시겠습니까?",
                isPresented: $isPresented,
                actions: {
                    Button("취소", role: .cancel) { }
                    Button("삭제", role: .destructive, action: onDelete)
                }
            )
    }
}

extension View {
    /// 삭제 확인 알럿을 쉽게 띄우는 헬퍼 메서드
    func deleteAlert(
        isPresented: Binding<Bool>,
        itemName: String,
        deleteLabel: String = "타이머",
        onDelete: @escaping () -> Void
    ) -> some View {
        self.modifier(DeleteAlertModifier(
            isPresented: isPresented,
            itemName: itemName,
            deleteLabel: deleteLabel,
            onDelete: onDelete
        ))
    }
}
