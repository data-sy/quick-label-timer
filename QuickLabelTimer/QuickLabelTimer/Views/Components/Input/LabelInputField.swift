//
//  LabelInputField.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 7/19/25.
//
/// 타이머 입력 섹션에서 사용하는 라벨 입력 필드
/// 
/// - 사용 목적: 사용자가 타이머의 목적이나 제목을 텍스트로 입력할 수 있도록 제공

import SwiftUI

struct LabelInputField: View {
    let maxLabelLength: Int
    
    @Binding var label: String
    @FocusState.Binding var isFocused: Bool

    var body: some View {
        HStack {
            Text("라벨")
                .font(.body)
                .foregroundColor(.primary)

            Divider()
                .frame(height: 20)
                .overlay(Color.gray.opacity(0.4))
            
            TextField("라벨 입력 (비워두면 자동 생성)", text: $label)
                .focused($isFocused)
                .textInputAutocapitalization(.none)
                .frame(maxWidth: .infinity)
            Spacer()
            
            Text("\(label.count) / \(maxLabelLength)")
                .font(.caption)
                .foregroundColor(label.count >= maxLabelLength ? .red : .secondary)
                .layoutPriority(1)

        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("타이머 라벨")
        .accessibilityValue(label.isEmpty ? "입력되지 않음" : label)
        .accessibilityHint("타이머의 라벨을 입력해 주세요. 비워두면 자동으로 라벨이 생성됩니다.")
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
        .onChange(of: label) { newValue in
            if newValue.count > maxLabelLength {
                label = String(newValue.prefix(maxLabelLength))
            }
        }
    }
}

