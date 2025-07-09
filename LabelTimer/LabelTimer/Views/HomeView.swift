import SwiftUI

//
//  HomeView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/9/25.
//
/// 타이머 생성을 시작하는 메인 화면
///
/// - 사용 목적: "+ 새 타이머" 버튼을 통해 입력 화면으로 이동
/// - ViewModel: 없음


struct HomeView: View {
    @State private var showModal = false
    
    var body: some View {
        VStack {
            Button("+ 새 타이머") {
                showModal = true
            }
        }
        .sheet(isPresented: $showModal) {
            TimerInputView()
        }
    }
}


#Preview {
    HomeView()
}
