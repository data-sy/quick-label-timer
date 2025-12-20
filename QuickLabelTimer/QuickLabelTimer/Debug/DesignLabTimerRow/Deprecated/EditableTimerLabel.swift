////
////  EditableTimerLabel.swift
////  QuickLabelTimer
////
////  Created by 이소연 on 12/16/25.
////
//
//import SwiftUI
//
////struct EditableTimerLabel: View {
//    let timer: TimerData
//    let onLabelChange: (String) -> Void
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
//                    .foregroundColor(.primary)
//                    .lineLimit(nil)
//                    .focused($isFocused)
//                    .onSubmit { commitEdit() }
//                    .onAppear {
//                        editText = timer.label
//                        isFocused = true
//                    }
//            } else {
//                Text(timer.label)
//                    .font(.headline)
//                    .foregroundColor(.primary)
//                    .lineLimit(nil)
//                    .fixedSize(horizontal: false, vertical: true)
//                    .onTapGesture { startEditing() }
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
