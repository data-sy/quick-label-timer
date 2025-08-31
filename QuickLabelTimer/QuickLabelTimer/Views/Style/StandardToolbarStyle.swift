//
//  StandardToolbarStyle.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/9/25.
//
/// 앱의 표준 툴바 스타일을 정의하는 ViewModifier
///
/// - 사용 목적: NavigationBar 배경을 일관되게 적용

import SwiftUI

struct StandardToolbarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(
                AppTheme.pageBackground,
                for: .navigationBar
            )
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

extension View {
    func standardToolbarStyle() -> some View {
        self.modifier(StandardToolbarStyle())
    }
}
