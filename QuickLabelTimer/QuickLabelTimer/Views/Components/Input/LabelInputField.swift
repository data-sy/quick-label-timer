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
    @Binding var label: String
    @FocusState.Binding var isFocused: Bool

    var body: some View {
        HStack {
            Text("레이블")
                .font(.body)
                .foregroundColor(.primary)

            Divider()
                .frame(height: 20)
                .overlay(Color.gray.opacity(0.4))
            
            TextField("레이블을 입력하세요", text: $label)
                .focused($isFocused)
                .frame(maxWidth: .infinity)

        }
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
    }
}

