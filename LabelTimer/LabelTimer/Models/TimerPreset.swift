//
//  TimerPreset.swift
//  LabelTimer
//
//  Created by 이소연 on 7/12/25.
//
/// 타이머 실행을 위한 프리셋 모델
///
/// - 사용 목적: 자주 사용하는 시간과 라벨을 저장해두고 빠르게 실행할 수 있도록 함.

import Foundation

struct TimerPreset: Identifiable, Codable, Hashable {
    let id: UUID
    
    let label: String
    let hours: Int
    let minutes: Int
    let seconds: Int
    let isSoundOn: Bool
    let isVibrationOn: Bool
    let createdAt: Date
    
    var lastUsedAt: Date
    var isHiddenInList: Bool = false
    var totalSeconds: Int {
        hours * 3600 + minutes * 60 + seconds
    }
    
    /// id 없이 생성할 때(새 프리셋 생성)
    init(
        id: UUID = UUID(),
        label: String,
        hours: Int,
        minutes: Int,
        seconds: Int,
        isSoundOn: Bool = true,
        isVibrationOn: Bool = true,
        createdAt: Date = Date(),
        lastUsedAt: Date? = nil,
        isHiddenInList: Bool = false
    ) {
        let now = createdAt
        self.id = id
        self.label = label
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
        self.isSoundOn = isSoundOn
        self.isVibrationOn = isVibrationOn
        self.createdAt = now
        self.lastUsedAt = lastUsedAt ?? createdAt
        self.isHiddenInList = isHiddenInList
    }
    
    /// id 포함 생성자 (복사/업데이트/디코딩 등)
    // Codable을 통해 UserDefaults에서 데이터를 디코딩(불러오기)할 때 사용되는 초기화 함수
       init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           
           id = try container.decode(UUID.self, forKey: .id)
           createdAt = try container.decode(Date.self, forKey: .createdAt)
           label = try container.decode(String.self, forKey: .label)
           hours = try container.decode(Int.self, forKey: .hours)
           minutes = try container.decode(Int.self, forKey: .minutes)
           seconds = try container.decode(Int.self, forKey: .seconds)
           isSoundOn = try container.decode(Bool.self, forKey: .isSoundOn)
           isVibrationOn = try container.decode(Bool.self, forKey: .isVibrationOn)
           isHiddenInList = try container.decode(Bool.self, forKey: .isHiddenInList)
                      
           // lastUsedAt 디코딩 (데이터 마이그레이션 처리)
           let decodedLastUsedAt = try container.decodeIfPresent(Date.self, forKey: .lastUsedAt)
           // 가져온 값이 nil이면(옛날 데이터), createdAt 값을 대신 사용
           lastUsedAt = decodedLastUsedAt ?? createdAt
       }
}
