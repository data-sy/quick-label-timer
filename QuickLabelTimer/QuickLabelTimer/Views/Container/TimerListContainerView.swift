//
//  TimerListContainerView.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/7/25.
//
/// 타이머 계열 공통 리스트 컨테이너 뷰
///
/// - 사용 목적: 프리셋, 실행중 등 다양한 타이머 목록을 동일한 구조로 표시할 때 재사용

import SwiftUI

struct TimerListContainerView<Item: Identifiable, RowContent: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.editMode) private var editMode
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }
    
    let title: String?
    let items: [Item]
    let emptyMessage: String
    let stateProvider: (Item) -> TimerInteractionState
    let onDelete: ((IndexSet) -> Void)?
    let rowContent: (Item) -> RowContent
    
    init(
        title: String?,
        items: [Item],
        emptyMessage: String,
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
                List {
                    ForEach(items) { item in
                        row(for: item)
                            .listRowSeparator(.visible)
                    }
                    .onDelete(perform: onDelete) // Edit모드에서 사용하므로 삭제X
                    .deleteDisabled(!isEditing)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
    
    /// 리스트에 표시될 개별 행을 생성하고 공통 스타일(배경, 색상 등)을 적용하는 헬퍼 뷰
    @ViewBuilder
    private func row(for item: Item) -> some View {
        rowContent(item)
            .listRowInsets(EdgeInsets()) // List 내부의 앞 여백 없애기
            .listRowBackground(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor(for: stateProvider(item)))
                    .padding(.vertical, 4)
                    .offset(x: isEditing ? 40 : 0)
                    .animation(.default, value: isEditing)
            )
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
