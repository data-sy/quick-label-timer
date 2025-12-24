//
//  TimerListSection.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/24/25.
//
/// 타이머 리스트를 섹션 단위로 표시하는 컨테이너 뷰
///
/// - 사용 목적: 섹션 타이틀과 타이머 리스트를 하나의 카드 형태로 그룹화

import SwiftUI

struct TimerListSection<Item: Identifiable, RowContent: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.editMode) private var editMode
    
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }

    let title: String?
    let items: [Item]
    let emptyMessage: LocalizedStringKey
    let stateProvider: (Item) -> TimerInteractionState
    let onDelete: ((IndexSet) -> Void)?
    let rowContent: (Item) -> RowContent

    init(
        title: String?,
        items: [Item],
        emptyMessage: LocalizedStringKey,
        stateProvider: @escaping (Item) -> TimerInteractionState,
        onDelete: ((IndexSet) -> Void)? = nil,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent
    ) {
        self.title = title
        self.items = items
        self.emptyMessage = emptyMessage
        self.stateProvider = stateProvider
        self.onDelete = onDelete
        self.rowContent = rowContent
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            if let title {
                SectionTitle(text: title)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
            }

            if items.isEmpty {
                Text(emptyMessage)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, minHeight: 100, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 8) { // 행 사이 간격
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        row(for: item, at: index)
                    }
                }
            }
        }
    }

    /// 개별 행을 생성하고 편집 모드일 때 delete 버튼을 표시
    @ViewBuilder
    private func row(for item: Item, at index: Int) -> some View {
        HStack(spacing: 0) {
            if isEditing, onDelete != nil {
                Button(role: .destructive) {
                    onDelete?(IndexSet(integer: index))
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .imageScale(.large)
                }
            }

            rowContent(item)
        }
        .animation(.default, value: isEditing)
    }
}
