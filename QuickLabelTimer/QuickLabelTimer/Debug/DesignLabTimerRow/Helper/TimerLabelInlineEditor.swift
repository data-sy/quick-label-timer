////
////  TimerLabelInlineEditor.swift
////  QuickLabelTimer
////
////  Created by 이소연 on 12/16/25.
////
//
//
////
////  TimerLabelInlineEditor.swift
////  QuickLabelTimer
////
////  Created by 이소연 on 12/16/25.
////
//
//import SwiftUI
//
//struct TimerLabelInlineEditor: View {
//    let timer: TimerData
//    let onLabelChange: (String) -> Void
//    let isRunning: Bool
//    
//    @State private var isEditing = false
//    @State private var editText = ""
//    @FocusState private var isFocused: Bool
//    
//    var body: some View {
//        Group {
//            if isEditing {
//                TextField("timer-label-placeholder", text: $editText, axis: .vertical)
//                    .font(.headline)
//                    .foregroundColor(isRunning ? .blue : .primary)
//                    .lineLimit(nil)
//                    .focused($isFocused)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
//                    .background(
//                        RoundedRectangle(cornerRadius: 6)
//                            .fill(isRunning ? Color.white : Color.clear)
//                    )
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 6)
//                            .stroke(isRunning ? Color.clear : Color.secondary.opacity(0.3), lineWidth: 1.5)
//                    )
//                    .onSubmit { commitEdit() }
//                    .onAppear {
//                        editText = timer.label
//                        isFocused = true
//                    }
//            } else {
//                HStack(spacing: 6) {
//                    Text(timer.label)
//                        .font(.headline)
//                        .foregroundColor(isRunning ? .white : .primary)
//                        .lineLimit(nil)
//                        .fixedSize(horizontal: false, vertical: true)
//                    
//                    Image(systemName: "pencil")
//                        .font(.caption)
//                        .foregroundColor(isRunning ? .white.opacity(0.8) : .secondary)
//                }
//                .onTapGesture { startEditing() }
//            }
//        }
//    }
//    
//    private func startEditing() {
//        isEditing = true
//    }
//    
//    private func commitEdit() {
//        let trimmed = editText.trimmingCharacters(in: .whitespacesAndNewlines)
//        if !trimmed.isEmpty {
//            onLabelChange(trimmed)
//        }
//        isEditing = false
//    }
//}
