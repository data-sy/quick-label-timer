////
////  DesignSection.swift
////  QuickLabelTimer
////
////  Created by 이소연 on 12/16/25.
////
//
//import SwiftUI
//
//// MARK: - Design Section Helper
//struct DesignSection<Content: View>: View {
//    let title: String
//    let description: String?
//    let content: Content
//    
//    init(
//        title: String,
//        description: String? = nil,
//        @ViewBuilder content: () -> Content
//    ) {
//        self.title = title
//        self.description = description
//        self.content = content()
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(title)
//                .font(.title3)
//                .bold()
//                .foregroundColor(.blue)
//            
//            if let description {
//                Text(description)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                    .padding(.bottom, 4)
//            }
//            
//            content
//        }
//    }
//}
//
