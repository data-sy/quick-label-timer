import SwiftUI

//
//  LabelDisplayView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/11/25.
//
/// 레이블을 보여주는 공통 컴포넌트
///
/// - 역할: 레이블 텍스트를 강조하여 표시하거나, 비어 있을 경우 동일한 레이아웃을 확보
///

struct LabelDisplayView: View {
    let label: String

    var body: some View {
        if !label.isEmpty {
            Text(label)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 8)
        } else {
            Text(" ")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 8)
                .hidden() // 레이블 없을 시 공간 확보
        }
    }
}
