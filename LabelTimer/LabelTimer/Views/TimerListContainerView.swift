//
//  TimerListContainerView.swift
//  LabelTimer
//
//  Created by 이소연 on 8/7/25.
//
/// 타이머 계열 공통 리스트 컨테이너 뷰
///
/// - 사용 목적: 프리셋, 실행중 등 다양한 타이머 목록을 동일한 구조로 표시할 때 재사용
///

import SwiftUI

struct TimerListContainerView<Item: Identifiable, RowContent: View>: View {
    let title: String
    let items: [Item]
    let emptyMessage: String
    let namespace: Namespace.ID
    let rowContent: (Item, Namespace.ID) -> RowContent

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle(text: title)
            if items.isEmpty {
                Text(emptyMessage)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                List(items) { item in
                    rowContent(item, namespace)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
}
