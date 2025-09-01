//
//  SpeakerBadgeIcon.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 8/31/25.
//

import SwiftUI

struct SpeakerBadgeIcon: View {
    var body: some View {
        Image(systemName: "speaker.wave.2.fill")
            .font(.system(size: 20))
            .symbolRenderingMode(.hierarchical)
            .overlay(
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.yellow)
                    .background(.white, in: Circle())
                    .offset(x: 6, y: -6),
                alignment: .topTrailing
            )
    }
}

struct VibrationBadgeIcon: View {
    var body: some View {
        Image(systemName: "iphone.radiowaves.left.and.right")
            .font(.system(size: 20))
            .symbolRenderingMode(.hierarchical)
            .overlay(
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.yellow)
                    .background(.white, in: Circle())
                    .offset(x: 6, y: -6),
                alignment: .topTrailing
            )
    }
}
