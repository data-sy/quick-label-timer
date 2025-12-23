//
//  EditableTimerLabel.swift
//  QuickLabelTimer
//
//  Created for TimerRow Redesign - Inline Editing
//
/// 탭하여 편집 가능한 타이머 라벨
///
/// - 사용 목적: 타이머 라벨을 탭하여 즉시 편집 가능하게 함

import SwiftUI

struct EditableTimerLabel: View {
    let label: String
    let status: TimerStatus
    let onLabelChange: (String) -> Void
    @Binding var isEditing: Bool

    @State private var editedLabel: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        let colors = RowTheme.colors(for: status)
        
        Group {
            if isEditing {
                TextField("", text: $editedLabel)
                    .font(.headline)
                    .foregroundColor(colors.cardForeground)
                    .focused($isFocused)
                    .onSubmit {
                        commitEdit()
                    }
                    .onAppear {
                        editedLabel = label
                        isFocused = true
                    }
                    .padding(RowTheme.editingBackgroundPadding)
                    .background(
                        RoundedRectangle(cornerRadius: RowTheme.editingCornerRadius)
                            .fill(RowTheme.editingBackgroundOverlay)
                            .overlay(
                                RoundedRectangle(cornerRadius: RowTheme.editingCornerRadius)
                                    .strokeBorder(RowTheme.editingBorderColor, lineWidth: RowTheme.editingBorderWidth)
                            )
                    )
            } else {
                HStack(spacing: 0) {
                    Text(label)
                        .font(.headline)
                        .foregroundColor(colors.cardForeground)
                        .lineLimit(nil)
//                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                                        
                    Image(systemName: "pencil")
                        .font(.system(size: RowTheme.editIconSize))
                        .foregroundColor(colors.cardForeground)
                        .opacity(RowTheme.editIconOpacity)
                }
                // 텍스트 필드와 높이를 맞추기 위해 패딩이나 프레임 조정 가능 (여기선 최소 높이 보장)
                .frame(minHeight: RowTheme.minimumTapHeight)
                .contentShape(Rectangle()) // 빈 공간(Spacer)도 탭 인식되도록 설정
                .onTapGesture {
                    startEditing()
                }
            }
        }
        .onChange(of: isFocused) { newValue in
            if !newValue && isEditing {
                // Lost focus - commit changes
                commitEdit()
            }
        }
        .onChange(of: isEditing) { newValue in
            if !newValue && isFocused {
                // Parent forced edit to end (e.g., play button tapped) - commit changes
                commitEdit()
            }
        }
        // 3. 영역 확장: 부모 뷰(HStack) 내에서 가로로 꽉 차게 설정
        .frame(maxWidth: .infinity)
    }

    private func startEditing() {
        editedLabel = label
        isEditing = true
    }

    private func commitEdit() {
        let trimmed = editedLabel.trimmingCharacters(in: .whitespacesAndNewlines)

        // Only save if non-empty and changed
        if !trimmed.isEmpty && trimmed != label {
            onLabelChange(trimmed)
        }

        isEditing = false
        isFocused = false
    }
}
