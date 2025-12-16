//
//  TimerSectionView.swift
//  QuickLabelTimer
//
//  Created by Claude on 12/15/25.
//
/// 타이머 섹션 뷰 (VStack 기반)
///
/// - 사용 목적: TimerListContainerView의 VStack 기반 대체 구현
/// - 중첩 스크롤 문제 방지를 위해 List 대신 LazyVStack 사용

import SwiftUI

struct TimerSectionView<Item: Identifiable, RowContent: View>: View {
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
                    .padding([.horizontal, .top])
                    .padding(.bottom, 8)
            }

            if items.isEmpty {
                Text(emptyMessage)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, minHeight: 100, alignment: .center)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        row(for: item, at: index)
                    }
                }
            }
        }
    }

    /// Vstack에 표시될 개별 행을 생성하고 공통 스타일(배경, 색상 등)을 적용하는 헬퍼 뷰
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
                .padding(.horizontal, 12)
            }

            rowContent(item)
        }
        .background(backgroundColor(for: stateProvider(item)))
        .cornerRadius(12)
        .padding(.vertical, 4)
        .padding(.horizontal, 16)
        .animation(.default, value: isEditing)
    }

    private func backgroundColor(for state: TimerInteractionState) -> Color {
        switch state {
        case .paused, .stopped, .completed:
            return Color(.systemGray5)
        default:
            return AppTheme.contentBackground
        }
    }
}
