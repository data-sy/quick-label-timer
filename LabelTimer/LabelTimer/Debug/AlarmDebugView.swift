//
//  AlarmDebugView.swift
//  LabelTimer
//
//  Created by 이소연 on 8/20/25.
//
/// 알림 기능 테스트 시나리오를 실행하고 검증하기 위한 UI
/// - 사용 목적: AlarmDebugManager의 각 테스트 함수를 직접 실행하고 결과를 확인

#if DEBUG

import SwiftUI

struct AlarmDebugView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("알림 시스템 종합 검증 🧪")
                    .font(.title)
                    .padding(.bottom, 20)

                // MARK: - 0. 유틸리티 기능
                VStack(spacing: 10) {
                    Text("Utilities").font(.headline)
                    HStack {
                        Button("권한 요청") { AlarmDebugManager.requestAuth() }
                        Button("전체 클리어") { AlarmDebugManager.clearAllTestNotifications() }
                    }
                    HStack {
                        Button("설정 덤프") { Task { await AlarmDebugManager.dumpSettings() } }
                        Button("Pending 덤프") { Task { await AlarmDebugManager.dumpPending() } }
                        Button("Delivered 덤프") { Task { await AlarmDebugManager.dumpDelivered() } }
                    }
                }
                .buttonStyle(.bordered)

                Divider().padding(.vertical)
                
                // MARK: - 0. (연속 알림이 아닌) 소리 기본 동작 검증
                VStack(spacing: 15) {
                    Text("Part 0: 1회 소리 기본 동작 검증 (햅틱: 켜짐)").font(.title2).bold()
                    
                    Text("가설 0-1: 30초 커스텀 사운드로 로컬 알림을 1회 사용했을 때, 무음 모드일 때 진동으로 변환되어 울리는가")
                    Button("테스트 0-1: 커스텀 사운드 ") { AlarmDebugManager.testCustomSoundOne() }
                    
                    Text("가설 0-2: 30초 무음 사운드로 로컬 알림을 1회 사용했을 때, 무음 모드일 때 진동으로 변환되어 울리는가")
                    Button("테스트 0-2: 무음 사운드 ") { AlarmDebugManager.testSilentSoundOne() }

                }
                .buttonStyle(.bordered)
                
                // MARK: - 1. 소리 기본 동작 검증
                VStack(spacing: 15) {
                    Text("Part 1: 소리 기본 동작 검증 (햅틱: 항상 재생 상태)").font(.title2).bold()
                    
                    Text("가설 1-1: 커스텀 사운드. 소리모드: 소리ㅇ 진동ㅇ. 무음모드: 소리x 진동 ㅇ")
                    Button("테스트 1-1: 커스텀 사운드 ") { AlarmDebugManager.testCustomSound() }

                    Text("가설 1-2: 시스템 기본 사운드. 연속 알림 간격이 2초일 때 소리 텀 적당한가")
                    Button("테스트 1-2: 시스템 사운드 ") { AlarmDebugManager.testSystemSound() }
                    
                    Text("가설 1-3: 무음 사운드. 소리모드: 소리x 진동ㅇ. 무음모드: 소리x 진동ㅇ")
                    Button("테스트 1-3: 무음 사운드 ") { AlarmDebugManager.testSilentSound() }

                    Text("가설 1-4: sound = nil. 소리모드: 소리x 진동x. 무음모드: 소리x 진동x")
                    Button("테스트 1-4: 사운드 없음") {
                        AlarmDebugManager.testNilSound() }
                }
                .buttonStyle(.bordered)

                Divider().padding(.vertical)

                // MARK: - 2. 배너 기본 동작 검증
                VStack(spacing: 15) {
                    Text("Part 2: 배너 기본 동작 검증").font(.title2).bold()
                    
                    Text("~~가설 2-1: 제목/본문 없이 소리만 있는 알림은 배너 없이 소리만 재생됨~~")
                    Button("~~테스트 2-1: 소리만~~") {
                        AlarmDebugManager.testSoundOnly() }
                    Text("결과: Suspended 상태에서 미실행. iOS 정책상 미지원으로 판단")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 5)
                    Text("가설 2-2: 제목 X(빈문자열) 본문 ㅇ 소리 X")
                    Button("테스트 2-2: 본문만") {
                        AlarmDebugManager.testBodyOnly() }
                    Text("결과: Title은 프로젝트 이름으로 뜸")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 5)
                    Text("가설 2-3: 제목 ㅇ 본문 X(빈문자열) 소리 X")
                    Button("테스트 2-3: 제목만") {
                        AlarmDebugManager.testTitleOnly() }
                    
                    Text("~~가설 2-4: 동일 ID로 알림 10개 연속 전송 시 배너 1개만 남음~~")
                    Button("~~테스트 2-4: 동일 ID 연속 알림~~") {
                        AlarmDebugManager.testSameIdentifierNotifications()}
                    Text("결과: id가 같으면 새 알림으로 대체되어 가장 마지막 알림만 울림")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 5)
                    Text("가설 2-5: 고유 ID + 동일 threadID 연속 전송 시 순차 실행 및 그룹핑")
                    Button("테스트 2-5: threadID 그룹핑 알림") {
                        AlarmDebugManager.testThreadIdentifierGrouping()
                    }
                    
                }
                .buttonStyle(.bordered)

                Divider().padding(.vertical)

                // MARK: - 3. 연속 알림 성능 및 UX 검증
                VStack(spacing: 15) {
                    Text("Part 3: 연속 알림 성능/UX 검증").font(.title2).bold()

                    Text("~~가설 3-1: 1초 간격 적당한가~~")
                    Button("~~테스트 3-1: 1초 간격~~") { AlarmDebugManager.testBarrage(interval: 1) }
                    Text("결과: 너무 빨라")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 5)

                    Text("가설 3-1': 1.5초 간격 적당한가")
                    Button("테스트 3-1': 1.5초 간격") { AlarmDebugManager.testBarrage(interval: 1.5) }
                    
                    Text("가설 3-2: 2초 간격 적당한가")
                    Button("테스트 3-2: 2초 간격") { AlarmDebugManager.testBarrage(interval: 2) }

                    Text("가설 3-3: 예약된 연속 알림 즉시 취소 (포그라운드 didReceive에서 사용 예정)")
                    Button("테스트 3-3: 연속 알림 즉시 취소") { AlarmDebugManager.testCancel() }

                    Text("~~가설 3-4: '대표 배너'로 스팸 느낌을 줄일 수 있는가~~")
                    Button("~~테스트 3-4: 대표 배너 1개 + 소리 9회~~") {
                    }
                    Text("결과: 가설 2-1 실패로 3-4 철회")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 5)

                }
                .buttonStyle(.bordered)
                
                Divider().padding(.vertical)

                // MARK: - 4. 최종 정책 동적 생성 검증
                VStack(spacing: 15) {
                    Text("Part 4: 최종 정책 동적 생성 검증").font(.title2).bold()
                    
                    Button("A: 소리O, 진동O") { AlarmDebugManager.testPolicy(soundOn: true, vibrationOn: true) }
                    Text("~~B: 소리O, 진동X 는 iOS 정책상 불가~~")
                        .padding(.leading, 5)
                    Button("C: 소리X, 진동O") { AlarmDebugManager.testPolicy(soundOn: false, vibrationOn: true) }
                    Button("D: 소리X, 진동X") { AlarmDebugManager.testPolicy(soundOn: false, vibrationOn: false) }
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 40)
            }
            .padding()
        }
        .navigationTitle("알람 디버그")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#endif
