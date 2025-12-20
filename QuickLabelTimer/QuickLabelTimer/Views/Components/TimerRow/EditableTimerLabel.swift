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

    @State private var isEditing = false
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
            } else {
                Text(label)
                    .font(.headline)
                    .foregroundColor(colors.cardForeground)
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

#Preview("EditableTimerLabel - All States") {
    VStack(spacing: 20) {
        // Stopped (준비)
        EditableTimerLabel(
            label: "Ready to Start",
            status: .stopped,
            onLabelChange: { print("Changed to: \($0)") }
        )
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        
        // Paused (일시정지)
        EditableTimerLabel(
            label: "Paused Timer",
            status: .paused,
            onLabelChange: { print("Changed to: \($0)") }
        )
        .padding()
        .background(Color.blue.opacity(0.15))
        .cornerRadius(12)

        // Running (실행 중)
        EditableTimerLabel(
            label: "Running Timer",
            status: .running,
            onLabelChange: { print("Changed to: \($0)") }
        )
        .padding()
        .background(Color.blue)
        .cornerRadius(12)
        
        // Completed (완료)
        EditableTimerLabel(
            label: "Completed Timer",
            status: .completed,
            onLabelChange: { print("Changed to: \($0)") }
        )
        .padding()
        .background(Color.green)
        .cornerRadius(12)
    }
    .padding()
}
