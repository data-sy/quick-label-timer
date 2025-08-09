//
//  MainToolbarContent.swift
//  LabelTimer
//
//  Created by 이소연 on 8/9/25.

/// 메인 화면들(타이머, 즐겨찾기)에서 공통으로 사용하는 툴바
///
/// - 사용 목적: 툴바 버튼의 UI 및 동작을 한 곳에서 관리

import SwiftUI

struct MainToolbarContent: ToolbarContent {
    // 현재 뷰의 편집 모드를 읽어옴
    @Environment(\.editMode) private var editMode
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }
    
    // 설정 화면(시트)을 띄우기 위해 부모 뷰와 연결된 바인딩 변수
    @Binding var showSettings: Bool
    
    var body: some ToolbarContent {
        // "삭제/완료" 버튼 (왼쪽)
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                withAnimation {
                    editMode?.wrappedValue = isEditing ? .inactive : .active
                }
            } label: {
                Text(isEditing ? "완료" : "삭제")
            }
        }
        
        // "설정" 버튼 (오른쪽)
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gearshape")
            }
        }
    }
}
