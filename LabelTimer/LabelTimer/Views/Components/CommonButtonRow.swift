import SwiftUI

//
//  CommonButtonRow.swift
//  LabelTimer
//
//  Created by 이소연 on 7/11/25.
//
/// 하단 버튼 두 개를 나란히 배치하는 공통 뷰
///
/// - 사용 목적: 타이머 입력, 알람, 실행 화면의 액션 버튼을 통일된 스타일로 구성

struct CommonButtonRow: View {
    let leftTitle: String
    let leftIcon: String? // Optional system image
    let leftAction: () -> Void
    let leftColor: Color
    let leftWidthRatio: CGFloat

    let rightTitle: String
    let rightAction: () -> Void
    let rightColor: Color
    let isRightDisabled: Bool

    var body: some View {
        HStack(spacing: 16) {
            Button(action: leftAction) {
                if let icon = leftIcon {
                    Label(leftTitle, systemImage: icon)
                        .frame(maxWidth: .infinity)
                } else {
                    Text(leftTitle)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(width: UIScreen.main.bounds.width * leftWidthRatio)
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(leftColor)
            .cornerRadius(10)

            Button(rightTitle, action: rightAction)
                .frame(maxWidth: .infinity)
                .padding()
                .background(rightColor)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isRightDisabled)
                .opacity(isRightDisabled ? 0.5 : 1.0)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}
