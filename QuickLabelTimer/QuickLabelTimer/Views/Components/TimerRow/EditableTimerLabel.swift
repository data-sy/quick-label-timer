//
//  EditableTimerLabel.swift
//  QuickLabelTimer
//
//  Created for TimerRow Redesign - Inline Editing
//

import SwiftUI

/// Editable timer label that switches to TextField on tap
///
/// - 사용 목적: 타이머 레이블을 탭하여 즉시 편집 가능하게 함
struct EditableTimerLabel: View {
    let label: String
    let isRunning: Bool
    let onLabelChange: (String) -> Void

    @State private var isEditing = false
    @State private var editedLabel: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        Group {
            if isEditing {
                TextField("", text: $editedLabel)
                    .font(.headline)
                    .foregroundColor(isRunning ? .white : .primary)
                    .focused($isFocused)
                    .onSubmit {
                        commitEdit()
                    }
                    .onAppear {
                        editedLabel = label
                        isFocused = true
                    }
            } else {
                Text(label)
                    .font(.headline)
                    .foregroundColor(isRunning ? .white : .primary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
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

#Preview("EditableTimerLabel") {
    VStack(spacing: 20) {
        EditableTimerLabel(
            label: "Tap to Edit",
            isRunning: false,
            onLabelChange: { newLabel in
                print("Label changed to: \(newLabel)")
            }
        )
        .padding()
        .background(Color.gray.opacity(0.1))

        EditableTimerLabel(
            label: "Running Timer Label",
            isRunning: true,
            onLabelChange: { newLabel in
                print("Label changed to: \(newLabel)")
            }
        )
        .padding()
        .background(Color.blue)
        .cornerRadius(12)
    }
    .padding()
}
