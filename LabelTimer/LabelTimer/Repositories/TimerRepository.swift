//
//  TimerRepository.swift
//  LabelTimer
//
//  Created by 이소연 on 8/14/25.
//
/// 실행 중인 타이머 데이터의 소유 및 관리를 담당
///
/// - 사용목적:
///   - 타이머 데이터의 단일 진실 공급원(SSOT) 역할 수행
///   - 데이터 추가, 조회, 수정, 삭제(CRUD)를 위한 일관된 인터페이스 제공

import Foundation
import Combine

// MARK: - Protocol Definition
@MainActor
protocol TimerRepositoryProtocol {
    var timersPublisher: Published<[TimerData]>.Publisher { get }
    
    func getAllTimers() -> [TimerData]
    func getTimer(byId id: UUID) -> TimerData?
    func addTimer(_ timer: TimerData)
    func updateTimer(_ timer: TimerData)
    @discardableResult
    func removeTimer(byId id: UUID) -> TimerData?
}
@MainActor
// MARK: - TimerRepository Class
final class TimerRepository: ObservableObject, TimerRepositoryProtocol {
    @Published var timers: [TimerData] = []
    var timersPublisher: Published<[TimerData]>.Publisher { $timers }
    
    private let timersStorageKey = "running_timers"
    
    init() {
        loadTimers()
    }

    /// 모든 타이머 객체를 배열로 반환
    func getAllTimers() -> [TimerData] {
        return timers
    }

    /// ID로 특정 타이머 객체를 찾아 반환
    func getTimer(byId id: UUID) -> TimerData? {
        timers.first { $0.id == id }
    }

    /// 새로운 타이머를 배열에 추가
    func addTimer(_ timer: TimerData) {
        timers.append(timer)
        saveTimers()
    }

    /// 기존 타이머의 정보를 수정
    func updateTimer(_ updatedTimer: TimerData) {
        guard let index = timers.firstIndex(where: { $0.id == updatedTimer.id }) else { return }
        timers[index] = updatedTimer
        saveTimers()
    }

    /// ID로 특정 타이머를 배열에서 삭제하고, 삭제된 객체를 반환
    @discardableResult
    func removeTimer(byId id: UUID) -> TimerData? {
        guard let index = timers.firstIndex(where: { $0.id == id }) else { return nil }
        let removed = timers.remove(at: index)
        saveTimers()
        return removed
    }
    
    // MARK: - Private Persistence Helpers
        
    // 타이머 목록을 UserDefaults에 저장하는 함수
    private func saveTimers() {
        if let data = try? JSONEncoder().encode(timers) {
            UserDefaults.standard.set(data, forKey: timersStorageKey)
        }
    }
    
    // UserDefaults에서 타이머 목록을 불러오는 함수
    private func loadTimers() {
        if let data = UserDefaults.standard.data(forKey: timersStorageKey),
           let decoded = try? JSONDecoder().decode([TimerData].self, from: data) {
            self.timers = decoded
        }
    }
}
