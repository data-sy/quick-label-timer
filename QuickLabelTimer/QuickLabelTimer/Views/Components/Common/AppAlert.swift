//
//  AppAlert.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/28/25.
//
/// 앱 전역에서 사용되는 얼럿(Alert)의 종류를 정의하고 이를 표시하기 위한 ViewModifier
///
/// - 사용 목적: 여러 ViewModel과 View에 흩어져 있는 얼럿 로직을 한 곳에서 중앙 관리

import SwiftUI

enum AppAlert: Identifiable {
    case timerRunLimit
    case presetSaveLimit
    case cannotDeleteRunningPreset
    case confirmDeletion(itemName: String, onConfirm: () -> Void)

    var id: String {
        switch self {
        case .timerRunLimit:
            return "timerRunLimit"
        case .presetSaveLimit:
            return "presetSaveLimit"
        case .cannotDeleteRunningPreset:
            return "cannotDeleteRunningPreset"
        case .confirmDeletion(let itemName, _):
            return "confirmDeletion_\(itemName)"
        }
    }
}

// 어떤 View에서든 .appAlert(...)를 호출할 수 있도록 하는 View extension
extension View {
    func appAlert(item: Binding<AppAlert?>) -> some View {
        self.alert(item: item) { alertType in
            switch alertType {
            case .timerRunLimit:
                return Alert(
                    title: Text("실행 불가"),
                    message: Text("타이머는 최대 10개까지 실행할 수 있습니다."),
                    dismissButton: .default(Text("확인"))
                )
            case .presetSaveLimit:
                return Alert(
                    title: Text("저장 불가"),
                    message: Text("즐겨찾기는 최대 20개까지 추가할 수 있습니다."),
                    dismissButton: .default(Text("확인"))
                )
            case .cannotDeleteRunningPreset:
                return Alert(
                    title: Text("삭제 불가"),
                    message: Text("실행 중인 타이머는 삭제할 수 없습니다."),
                    dismissButton: .default(Text("확인"))
                )
            case .confirmDeletion(let itemName, let onConfirm):
                return Alert(
                    title: Text("“\(itemName)”"),
                    message: Text("이 타이머를 삭제하시겠습니까?"),
                    primaryButton: .destructive(Text("삭제"), action: onConfirm),
                    secondaryButton: .cancel(Text("취소"))
                )
            }
        }
    }
}
