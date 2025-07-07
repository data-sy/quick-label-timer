//
//  ContentView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/6/25.
//
/// 타이머 생성을 시작하는 메인 화면
///
/// - 사용 목적: "새 타이머" 버튼을 통해 입력 화면으로 이동
/// - ViewModel: 없음

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    HomeView()
}

