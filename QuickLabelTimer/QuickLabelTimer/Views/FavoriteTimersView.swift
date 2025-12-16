//
//  FavoriteTimersView.swift
//  QuickLabelTimer
//
//  Created by 이소연 on 12/16/25.
//
/// 즐겨찾기(북마크)된 타이머 목록을 표시하는 뷰
///
/// - 사용 목적: 저장된 타이머를 리스트로 보여주고, 실행/편집/삭제 기능을 제공

import SwiftUI

struct FavoriteTimersView: View {
    @ObservedObject var viewModel: FavoriteTimersViewModel
    @Binding var editMode: EditMode
    
    var body: some View {
        // MARK: [이동됨] TimerSectionView 호출
        // MainView에 있던 즐겨찾기 리스트 생성 로직이 그대로 여기로 왔습니다.
        TimerSectionView(
            title: String(localized: "ui.favorite.title"),
            items: viewModel.visiblePresets,
            emptyMessage: A11yText.FavoriteTimers.emptyMessage,
            stateProvider: { _ in .preset },
            onDelete: viewModel.hidePreset(at:)
        ) { preset in
            
            // MARK: [이동됨] 개별 Row 및 오버레이
            ZStack {
                FavoritePresetRowView(
                    preset: preset,
                    onToggleFavorite: { viewModel.requestToHide(preset) },
                    onLeftTap: {
                        viewModel.handleLeft(for: preset)
                        editMode = .inactive
                    },
                    onRightTap: {
                        viewModel.handleRight(for: preset)
                        editMode = .inactive
                    }
                )
                
                // 실행 중일 때 가림막(Overlay) 처리
                if viewModel.isPresetRunning(preset) {
                    runningOverlay
                }
            }
            .disabled(viewModel.isPresetRunning(preset))
            .deleteDisabled(viewModel.isPresetRunning(preset))
            .accessibilityValue(
                viewModel.isPresetRunning(preset) ? A11yText.FavoriteTimers.runningStatus : ""
            )
        }
        // MARK: [이동됨] 편집 시트 로직
        // 메인 뷰의 .sheet 모디파이어 하나가 여기로 옮겨져, 메인 뷰 코드가 깔끔해졌습니다.
        .sheet(isPresented: $viewModel.isEditing, onDismiss: viewModel.stopEditing) {
            if let preset = viewModel.editingPreset {
                EditPresetView(viewModel: EditPresetViewModel(
                    preset: preset,
                    presetRepository: viewModel.presetRepository,
                    timerService: viewModel.timerService
                ))
                .presentationDetents([.medium])
            }
        }
    }
    
    // MARK: [추출됨] 오버레이 뷰
    // 본문 가독성을 위해 별도 프로퍼티로 뺐습니다.
    private var runningOverlay: some View {
        Color.black.opacity(0.4)
            .cornerRadius(12)
            .padding(4)
            .overlay {
                 HStack(spacing: 8) {
                    Text("ui.favorite.runningIndicator")
                        .font(.title).fontWeight(.bold)
                    Image(systemName: "figure.run")
                        .font(.title).scaleEffect(x: -1, y: 1)
                }
                .foregroundColor(.white)
            }
            .accessibilityHidden(true)
    }
}
