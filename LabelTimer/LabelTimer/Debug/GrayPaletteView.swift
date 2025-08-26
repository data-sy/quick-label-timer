//
//  GrayPaletteView.swift
//  LabelTimer
//
//  Created by 이소연 on 8/26/25.
//


import SwiftUI

/// 시스템 회색 계열 색상들을 시각적으로 보여주는 샘플 뷰
struct GrayPaletteView: View {
    var body: some View {
        List {
            Section(header: Text("Black").font(.headline)) {
                ColorRow(name: ".primary", color: .primary)
                ColorRow(name: ".primary.opacity(0.75)", color: .primary.opacity(0.75))

            }
            Section(header: Text("Custom Gray").font(.headline)) {
                ColorRow(name: "Color(white: 0.2)", color: Color(white: 0.2))
                ColorRow(name: "Color(white: 0.3)", color: Color(white: 0.3))
                ColorRow(name: "Color(white: 0.4)", color: Color(white: 0.4))
                ColorRow(name: "Color(white: 0.4)", color: Color(white: 0.4))


            }
            Section(header: Text("Semantic Gray").font(.headline)) {
                ColorRow(name: ".secondary", color: .secondary)
            }

            Section(header: Text("System Grays").font(.headline)) {
                ColorRow(name: "systemGray", color: Color(UIColor.systemGray))
                ColorRow(name: "systemGray2", color: Color(UIColor.systemGray2))
                ColorRow(name: "systemGray3", color: Color(UIColor.systemGray3))
                ColorRow(name: "systemGray4", color: Color(UIColor.systemGray4))
                ColorRow(name: "systemGray5", color: Color(UIColor.systemGray5))
                ColorRow(name: "systemGray6", color: Color(UIColor.systemGray6))
            }
        }
        .navigationTitle("Gray Palette")
    }
}

/// 색상 견본과 이름을 보여주는 행(Row) 뷰
fileprivate struct ColorRow: View {
    let name: String
    let color: Color

    var body: some View {
        HStack {
            Text(name)
                .font(Font.body.monospaced())
            Spacer()
            Rectangle()
                .fill(color)
                .frame(width: 120, height: 40)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(.vertical, 8)
    }
}


// MARK: - Xcode Preview

#if DEBUG
struct GrayPaletteView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 라이트 모드 미리보기
            NavigationView {
                GrayPaletteView()
            }
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")

            // 다크 모드 미리보기
            NavigationView {
                GrayPaletteView()
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
#endif
