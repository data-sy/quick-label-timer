//
//  SectionTitle.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 7/23/25.
//
/// 화면 상단 섹션 타이틀을 표시하는 컴포넌트
///
/// - 사용 목적: 타이머 생성, 실행 중인 타이머, 타이머 목록 등 여러 화면에서 일관된 타이틀 UI를 제공

import SwiftUI

struct SectionTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.title2)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}
