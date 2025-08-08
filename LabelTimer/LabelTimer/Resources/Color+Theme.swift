////
////  Color+Theme.swift
////  LabelTimer
////
////  Created by 이소연 on 7/24/25.
////
///// 앱 전역에서 사용하는 공통 색상 및 색상 생성 유틸리티를 정의한 파일
/////
///// - 사용 목적: 브랜드 색상(`brandColor`)을 비롯한 공통 컬러를 중앙에서 관리
//
//import SwiftUI
//
//extension Color {
//    static let brandColor = Color(hex: "#FF6F00")
//
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let r, g, b: UInt64
//        switch hex.count {
//        case 6: // RGB (24-bit)
//            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
//        default:
//            (r, g, b) = (255, 255, 255) // fallback: white
//        }
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: 1
//        )
//    }
//}
