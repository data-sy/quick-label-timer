//
//  SectionContainerView.swift
//  LabelTimer
//
//  Created by 이소연 on 8/7/25.
//
/// 컨텐츠를 시각적으로 그룹화하는 재사용 가능한 컨테이너 뷰
/// - 사용 목적: 배경색, 코너 반경, 내부 여백을 일관되게 적용


import SwiftUI

struct SectionContainerView<Content: View>: View {
    // 이 뷰가 담을 컨텐츠를 @ViewBuilder를 통해 받음
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) { // 내부 요소들은 여백 없이 꽉 차게
            content
        }
        // iOS 시스템의 그룹화된 배경색을 사용 (라이트/다크 모드 자동 대응)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12) // 부드러운 코너 반경
    }
}
