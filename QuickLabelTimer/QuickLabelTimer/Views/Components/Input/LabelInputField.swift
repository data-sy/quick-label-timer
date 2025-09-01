//
//  LabelInputField.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 7/19/25.
//
/// 타이머 입력 섹션에서 사용하는 라벨 입력 필드
/// 
/// - 사용 목적: 사용자가 타이머의 목적이나 제목을 텍스트로 입력할 수 있도록 제공

import SwiftUI

struct LabelInputField: View {
    let warningThreshold: Int = 80
    
    @Binding var label: String
    @FocusState.Binding var isFocused: Bool
    @State private var showLimitToast = false
    @State private var prevCount = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            HStack {
                Text("라벨")
                    .font(.body)
                    .foregroundColor(.primary)
                
                Divider()
                    .frame(height: 20)
                    .overlay(Color.gray.opacity(0.4))
                
                TextField("라벨 입력 (비워두면 자동 생성)", text: $label)
                    .focused($isFocused)
                    .textInputAutocapitalization(.none)
                    .frame(maxWidth: .infinity)
                Spacer()
                
                // 카운터: 80 이상일 때부터 표시
                if label.count >= warningThreshold {
                    Text("\(label.count) / \(AppConfig.maxLabelLength)")
                        .font(.caption)
                        .foregroundColor(colorForCount(label.count))
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                        .animation(.easeInOut(duration: 0.2), value: label.count)
                        .layoutPriority(1)
                }
            }
            .padding(.vertical, 16)

            // 토스트
            if showLimitToast {
                ToastView(text: "최대 \(AppConfig.maxLabelLength)자까지 입력할 수 있어요")
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 8)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("타이머 라벨")
        .accessibilityValue(label.isEmpty ? "입력되지 않음" : label)
        .accessibilityHint("타이머의 라벨을 입력해 주세요. 비워두면 자동으로 라벨이 생성됩니다.")
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
        .onChange(of: label) { newValue in
            let count = newValue.count
            if count > AppConfig.maxLabelLength {
                
                label = String(newValue.prefix(AppConfig.maxLabelLength))

                // 초과 진입 시점에만 토스트 + 가벼운 햅틱
                if prevCount <= AppConfig.maxLabelLength {
                    showLimitToastBriefly()
                    lightHaptic()
                }
            }
            prevCount = label.count
        }
    }
    
    private func colorForCount(_ count: Int) -> Color {
        if count >= AppConfig.maxLabelLength { return .red }
        if count >= warningThreshold { return .orange }
        return .secondary
    }

    private func showLimitToastBriefly() {
        withAnimation { showLimitToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation { showLimitToast = false }
        }
    }

    private func lightHaptic() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
}

// 심플 토스트 뷰
struct ToastView: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.footnote)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
    }
}
