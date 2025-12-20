////
////  CardStyleRow.swift
////  QuickLabelTimer
////
////  Created by 이소연 on 12/16/25.
////
//
//import SwiftUI
//
//// MARK: - 3. Modern Card Style
//struct CardStyleRow: View {
//    let timer: TimerData
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack {
//                Label(timer.label, systemImage: "timer")
//                    .font(.headline)
//                    .foregroundColor(.primary)
//                Spacer()
//                FavoriteToggleButton(endAction: timer.endAction, onToggle: {})
//            }
//            
//            Divider().padding(.vertical, 4)
//            
//            HStack(alignment: .center) {
//                Text(timer.formattedTime)
//                    .font(.system(size: 48, weight: .bold, design: .rounded))
//                    .foregroundColor(timer.status == .completed ? .red : .primary)
//                    .minimumScaleFactor(0.5)
//                
//                Spacer()
//                
//                // 카드형은 버튼을 원형으로 강조
//                Button(action: {}) {
//                    Image(systemName: timer.status == .running ? "pause.fill" : "play.fill")
//                        .font(.title2)
//                        .foregroundColor(.white)
//                        .frame(width: 56, height: 56)
//                        .background(Circle().fill(Color.blue))
//                        .shadow(radius: 4)
//                }
//            }
//            
//            HStack {
//                Text(timer.status == .completed ? "타이머 종료" : "오전 10:30 종료 예정")
//                    .font(.footnote)
//                    .foregroundColor(.secondary)
//                Spacer()
//            }
//        }
//        .padding()
//        .background(AppTheme.contentBackground)
//        .cornerRadius(20)
//        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
//    }
//}
