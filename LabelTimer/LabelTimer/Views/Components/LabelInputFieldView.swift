import SwiftUI

//
//  LabelInputFieldView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/11/25.
//
/// 텍스트 레이블을 입력받는 컴포넌트
///
/// - 사용 목적: 타이머에 붙일 사용자 정의 레이블 입력 UI 제공
///

struct LabelInputFieldView: View {
    @Binding var label: String
    @FocusState var isLabelFocused: Bool

    var body: some View {
        HStack {
            Text("레이블")
                .foregroundColor(.gray)

            TextField("입력", text: $label)
                .focused($isLabelFocused)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isLabelFocused = true
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
