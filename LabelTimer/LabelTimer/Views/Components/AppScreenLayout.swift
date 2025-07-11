import SwiftUI

//
//  AppScreenLayout.swift
//  LabelTimer
//
//  Created by 이소연 on 7/11/25.
//
/// 앱 화면의 공통 레이아웃
///
/// - 상단 60% 영역에 주요 콘텐츠 표시 (하단 정렬)
/// - 하단 40% 영역에 버튼 등 액션 표시 (상단 정렬)
/// - 콘텐츠 간 여백은 내부에서 패딩으로 조정

struct AppScreenLayout<Content: View, Bottom: View>: View {
    let content: () -> Content
    let bottom: () -> Bottom

    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder bottom: @escaping () -> Bottom
    ) {
        self.content = content
        self.bottom = bottom
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 상단 콘텐츠 (60%) - 하단 정렬
                VStack {
                    Spacer()
                    content()
                }
                .padding(.horizontal)
                .frame(height: geometry.size.height * 0.6)
                .frame(maxWidth: .infinity)

                // 하단 콘텐츠 (40%) - 상단 정렬
                VStack {
                    bottom()
                        .padding(.top, 32)
                    Spacer()
                }
                .padding(.horizontal)
                .frame(height: geometry.size.height * 0.4)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
