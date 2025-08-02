//
//  MainHeaderView.swift
//  LabelTimer
//
//  Created by 이소연 on 8/1/25.
//
/// 홈 화면 상단에 앱 타이틀과 설정 버튼을 표시하는 헤더 뷰
///
/// - 사용 목적: 앱 이름을 강조하고, 설정 화면 진입 버튼을 제공

import SwiftUI

struct MainHeaderView: View {
    var onTapSettings: () -> Void

    var body: some View {
        HStack {
            Spacer()

            Text("Quick Label Timer")
                .font(.title2.bold())
                .foregroundColor(.brandColor)
                .frame(maxWidth: .infinity, alignment: .center)

            Button(action: onTapSettings) {
                Image(systemName: "gearshape")
                    .imageScale(.large)
                    .padding(.horizontal)
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
}

#Preview {
    MainHeaderView {
        print("⚙️ 설정 버튼 탭됨")
    }
}
