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
                    title: Text("ui.alert.cannotRunTitle"),
                    message: Text(String(format: String(localized: "ui.alert.maxTimersMessage"), AppConfig.maxConcurrentTimers)),
                    dismissButton: .default(Text("ui.alert.ok"))
                )
            case .presetSaveLimit:
                return Alert(
                    title: Text("ui.alert.cannotSaveTitle"),
                    message: Text("ui.alert.maxFavoritesMessage"),
                    dismissButton: .default(Text("ui.alert.ok"))
                )
            case .cannotDeleteRunningPreset:
                return Alert(
                    title: Text("ui.alert.cannotDeleteTitle"),
                    message: Text("ui.alert.cannotDeleteRunningMessage"),
                    dismissButton: .default(Text("ui.alert.ok"))
                )
            case .confirmDeletion(let itemName, let onConfirm):
                return Alert(
                    title: Text("\"\(itemName)\""),
                    message: Text("ui.alert.deleteConfirmMessage"),
                    primaryButton: .destructive(Text("ui.alert.delete"), action: onConfirm),
                    secondaryButton: .cancel(Text("ui.alert.cancel"))
                )
            }
        }
    }
}
