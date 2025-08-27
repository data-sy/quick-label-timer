//
//  FavoriteListView.swift
//  LabelTimer
//
//  Created by 이소연 on 7/14/25.
//
/// 저장된 프리셋 타이머 목록을 보여주는 뷰
///
/// - 사용 목적: 사용자 또는 앱이 제공한 프리셋 타이머를 리스트 형태로 표시하고, 실행 버튼을 통해 타이머를 시작할 수 있도록 함

import SwiftUI

struct FavoriteListView: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var viewModel: FavoriteListViewModel
    @State private var showSettings = false
    
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.pageBackground
                    .ignoresSafeArea()
                
                TimerListContainerView(
                    title: nil,
                    items: viewModel.visiblePresets,
                    emptyMessage: "저장된 즐겨찾기가 없습니다.",
                    stateProvider: { _ in
                        return .preset
                    },
                    onDelete: viewModel.hidePreset(at:)
                ) { preset in
                    ZStack {
                        FavoritePresetRowView(
                            preset: preset,
                            onToggleFavorite: {
                                viewModel.requestToHide(preset)
                            },
                            onLeftTap: {
                                viewModel.handleLeft(for: preset)
                                editMode?.wrappedValue = .inactive
                            },
                            onRightTap: {
                                viewModel.handleRight(for: preset)
                                editMode?.wrappedValue = .inactive
                            }
                        )
                        // 실행 중인 프리셋
                        if viewModel.isPresetRunning(preset) {
                            Color.black.opacity(0.4)
                                .cornerRadius(12)
                                .padding(4)
                            HStack(spacing: 8) {
                                Text("«« 실행 중")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Image(systemName: "figure.run")
                                    .font(.title)
                                    .scaleEffect(x: -1, y: 1)
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .disabled(viewModel.isPresetRunning(preset))
                }
                .padding(.horizontal)
                .navigationTitle("즐겨찾기")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    MainToolbarContent(showSettings: $showSettings, showEditButton: true)
                }
                .confirmationAlert(
                    isPresented: $viewModel.isShowingHideAlert,
                    itemName: viewModel.presetToHide?.label ?? "",
                    titleMessage: "이 타이머를 삭제하시겠습니까?",
                    actionButtonLabel: "삭제",
                    onConfirm: viewModel.confirmHide
                )
                .sheet(isPresented: $viewModel.isEditing, onDismiss: viewModel.stopEditing) {
                    if let preset = viewModel.editingPreset {
                        let editViewModel = EditPresetViewModel(
                            preset: preset,
                            presetRepository: viewModel.presetRepository,
                            timerService: viewModel.timerService
                        )
                        EditPresetView(viewModel: editViewModel)
                        .presentationDetents([.medium])
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
                .standardToolbarStyle()
            }
        }
    }
}

// MARK: - Preview

import Combine

private let runningPresetID = UUID()

// 프리뷰를 위한 가짜(Mock) Repository와 Service
class MockPresetRepository: PresetRepositoryProtocol {
    @Published var userPresets: [TimerPreset] = [
        // "회의 준비" 프리셋에 고정 ID 부여
        TimerPreset(id: runningPresetID, label: "회의 준비", hours:12 , minutes: 15, seconds: 58, isHiddenInList: false),
        TimerPreset(label: "스트레칭", hours: 0, minutes: 1, seconds: 30, isHiddenInList: false),
        TimerPreset(label: "업무 집중", hours: 0, minutes: 25, seconds: 0, isHiddenInList: false)
    ]
    var userPresetsPublisher: AnyPublisher<[TimerPreset], Never> { $userPresets.eraseToAnyPublisher() }
    
    // 사용되지 않는 함수들은 비워두기
    func getPreset(byId id: UUID) -> TimerPreset? { nil }
    func addPreset(from timer: TimerData) {}
    func showPreset(withId id: UUID) {}
    func hidePreset(withId id: UUID) {}
    var allPresets: [TimerPreset] { userPresets }
    func updatePreset(_ preset: TimerPreset, label: String, hours: Int, minutes: Int, seconds: Int, isSoundOn: Bool, isVibrationOn: Bool) {}
    func updateLastUsed(for presetId: UUID) {}
}

class MockTimerRepository: TimerRepositoryProtocol {
    @Published var timers: [TimerData] = [
        // 실행 중인 타이머
        TimerData(label: "회의 준비", hours: 0, minutes: 5, seconds: 0, createdAt: Date(), endDate: Date(), remainingSeconds: 300, status: .running, presetId: runningPresetID)
    ]
    var timersPublisher: Published<[TimerData]>.Publisher { $timers }
    
    // 사용되지 않는 함수들은 비워둠
    func getAllTimers() -> [TimerData] { timers }
    func getTimer(byId id: UUID) -> TimerData? { nil }
    func addTimer(_ timer: TimerData) {}
    func updateTimer(_ timer: TimerData) {}
    func removeTimer(byId id: UUID) -> TimerData? { nil }
}

class MockTimerService: TimerServiceProtocol {
    var didStart = PassthroughSubject<Void, Never>()
    func getTimer(byId id: UUID) -> TimerData? { nil }
    func addTimer(label: String, hours: Int, minutes: Int, seconds: Int, isSoundOn: Bool, isVibrationOn: Bool, presetId: UUID?, isFavorite: Bool) {}
    func runTimer(from preset: TimerPreset) {}
    func removeTimer(id: UUID) -> TimerData? { nil }
    func convertTimerToPreset(timerId: UUID) {}
    func pauseTimer(id: UUID) {}
    func resumeTimer(id: UUID) {}
    func stopTimer(id: UUID) {}
    func restartTimer(id: UUID) {}
    func toggleFavorite(for id: UUID) {}
    func setFavorite(for id: UUID, to value: Bool) {}
    func userDidConfirmCompletion(for timerId: UUID) {}
    func userDidRequestDelete(for timerId: UUID) {}
    func updateScenePhase(_ phase: ScenePhase) {}
    func scheduleNotification(for timer: TimerData) {}
    func scheduleRepeatingNotifications(baseId: String, title: String, body: String, sound: UNNotificationSound?, endDate: Date, repeatingInterval: TimeInterval) {}
    func stopTimerNotifications(for baseId: String) {}
}


// 프리뷰 본체
struct FavoriteListView_Previews: PreviewProvider {
    static var previews: some View {
        // 가짜 객체들 생성
        let mockPresetRepo = MockPresetRepository()
        let mockTimerRepo = MockTimerRepository()
        
        // 가짜 ViewModel 만들고 가짜 객체들 주입
        let viewModel = FavoriteListViewModel(
            presetRepository: mockPresetRepo,
            timerService: MockTimerService(),
            timerRepository: mockTimerRepo
        )
        
        // 진짜 FavoriteListView에 가짜 ViewModel을 넣어서 프리뷰를 띄움
        FavoriteListView(viewModel: viewModel)
    }
}
