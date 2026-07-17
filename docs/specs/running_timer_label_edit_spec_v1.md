# Claude Code 프롬프트 플랜 v1: 실행 중 타이머 라벨 인라인 편집

이 문서는 **실행 중 타이머의 라벨을 인라인으로 수정할 수 있는 기능**을 Claude Code로 구현하기 위한 명세서입니다.

## 📋 작업 개요

### 목표
사용자가 RunningTimersView에서 실행 중인 타이머의 라벨을 직접 탭하여 수정할 수 있도록 구현합니다.

### 배경
- QuickLabelTimer iOS 앱 (Swift/SwiftUI, MVVM 아키텍처)
- RunningTimersView에서 `onLabelChange` 콜백이 이미 연결되어 있음
- UI 컴포넌트는 준비되었으나, 실제 업데이트 로직이 미구현 상태

### 아키텍처 설계
```
[UI Layer]
RunningTimersView
  → RunningTimersViewModel

[Service Layer]
RunningTimersViewModel
  → TimerService (메모리 관리)
  → PresetRepository (영구 저장)

[Data Flow]
1. 실행 중 라벨 변경: TimerService의 runningTimers 딕셔너리만 업데이트
2. 타이머 완료 시: preset 기반 + preserve 정책일 때만 PresetRepository에 반영
```

---

## 🎯 전체 실행 원칙

1. **각 Phase는 독립적으로 수행하며, 완료 후 개발자가 직접 검토 및 커밋합니다**
2. **각 단계마다 빌드 성공 및 테스트 가능한 상태를 유지합니다**
3. **기존 코드 스타일을 따르고, 과도한 검증 로직을 지양합니다**
4. **각 단계 완료 시 "Phase X - Step X-X complete. Ready for manual commit." 출력 후 중단합니다**

---

## Phase 1: 실행 중 라벨 변경 (메모리 업데이트)

### 목표
실행 중인 타이머의 라벨을 변경하면 메모리(TimerService.runningTimers)에만 반영되도록 구현합니다.
영구 저장은 하지 않으며, 타이머가 완료되기 전까지만 변경사항이 유지됩니다.

---

### Step 1-1: TimerService에 updateLabel 메서드 추가

```text
Proceed with Phase 1 – Step 1-1 only.

파일:
- Services/TimerService.swift

목표:
- TimerService에 라벨 업데이트 메서드 추가
- runningTimers 딕셔너리에서 해당 타이머를 찾아 label 속성만 변경

구현 요구사항:
```swift
/// 실행 중인 타이머의 라벨을 업데이트합니다 (메모리만)
/// - Parameters:
///   - timerId: 업데이트할 타이머 ID
///   - newLabel: 새로운 라벨 텍스트
func updateLabel(timerId: UUID, newLabel: String) {
    guard var timer = runningTimers[timerId] else { return }
    timer.label = newLabel
    runningTimers[timerId] = timer
    objectWillChange.send()
}
```

완료 조건:
- TimerService.swift에 updateLabel 메서드 추가됨
- 기존 코드는 수정하지 않음
- 빌드 성공

완료 후:
- "Phase 1 - Step 1-1 complete. Ready for manual commit." 출력
- 중단
```

**커밋 전 체크리스트:**
- [ ] 빌드 성공
- [ ] TimerService.updateLabel 메서드 시그니처 확인
- [ ] objectWillChange.send() 호출 확인

**권장 커밋 메시지:**
```
feat: add updateLabel method to TimerService

- Implement in-memory label update for running timers
- Update runningTimers dictionary and notify observers
- No persistence layer involved at this stage
```

---

### Step 1-2: RunningTimersViewModel에 updateLabel 메서드 추가

```text
Proceed with Phase 1 – Step 1-2 only.

파일:
- ViewModels/RunningTimersViewModel.swift

목표:
- ViewModel에서 UI 이벤트를 받아 TimerService로 전달하는 메서드 추가

구현 요구사항:
```swift
/// 실행 중인 타이머의 라벨을 업데이트합니다
/// - Parameters:
///   - timerId: 업데이트할 타이머 ID
///   - newLabel: 새로운 라벨 텍스트
func updateLabel(for timerId: UUID, newLabel: String) {
    timerService.updateLabel(timerId: timerId, newLabel: newLabel)
}
```

완료 조건:
- RunningTimersViewModel.swift에 updateLabel 메서드 추가됨
- TimerService의 updateLabel을 호출함
- 에러 처리는 guard 문으로 간단하게 처리 (서비스에서 이미 처리하므로)
- 빌드 성공

완료 후:
- "Phase 1 - Step 1-2 complete. Ready for manual commit." 출력
- 중단
```

**커밋 전 체크리스트:**
- [ ] 빌드 성공
- [ ] RunningTimersViewModel.updateLabel 메서드 추가 확인
- [ ] timerService.updateLabel 호출 확인

**테스트 방법:**
1. 앱 실행
2. 타이머 시작
3. RunningTimersView에서 라벨 탭하여 편집
4. 새 라벨 입력 후 엔터
5. 라벨이 즉시 변경되는지 확인
6. 앱 재시작하면 원래 라벨로 돌아가는지 확인 (영구 저장 안 됨을 검증)

**권장 커밋 메시지:**
```
feat: wire up label update from ViewModel to Service

- Add updateLabel method in RunningTimersViewModel
- Connect UI callback to TimerService layer
- Enable in-memory label editing for running timers
```

---

## Phase 2: 타이머 완료 시 프리셋 업데이트 (영구 저장)

### 목표
타이머가 완료될 때, 특정 조건에서 변경된 라벨을 프리셋에 영구 저장합니다.

**저장 조건:**
- preset 기반 타이머 (`presetId != nil`)
- AND 보존 정책 (`endAction == .preserve`)

**저장 안 하는 경우:**
- 즉석 타이머 (presetId가 nil)
- 폐기 정책 (endAction == .discard)

---

### Step 2-1: PresetRepository에 updatePresetLabel 메서드 추가

```text
Proceed with Phase 2 – Step 2-1 only.

파일:
- Repositories/PresetRepository.swift

목표:
- PresetRepository에 라벨 업데이트 메서드 추가
- Firebase에 변경사항 영구 저장

구현 요구사항:
```swift
/// 프리셋의 라벨을 업데이트하고 Firebase에 저장합니다
/// - Parameters:
///   - presetId: 업데이트할 프리셋 ID
///   - newLabel: 새로운 라벨 텍스트
func updatePresetLabel(presetId: UUID, newLabel: String) {
    guard let index = presets.firstIndex(where: { $0.id == presetId }) else { return }
    presets[index].label = newLabel
    objectWillChange.send()
    
    // Firebase 저장
    savePreset(presets[index])
}
```

완료 조건:
- PresetRepository.swift에 updatePresetLabel 메서드 추가됨
- presets 배열 업데이트 후 objectWillChange.send() 호출
- 기존 savePreset 메서드 활용하여 Firebase 저장
- 빌드 성공

완료 후:
- "Phase 2 - Step 2-1 complete. Ready for manual commit." 출력
- 중단
```

**커밋 전 체크리스트:**
- [ ] 빌드 성공
- [ ] PresetRepository.updatePresetLabel 메서드 추가 확인
- [ ] Firebase 저장 로직 포함 확인
- [ ] objectWillChange.send() 호출 확인

**권장 커밋 메시지:**
```
feat: add updatePresetLabel method to PresetRepository

- Implement persistent label update for presets
- Update local presets array and sync to Firebase
- Notify observers of changes
```

---

### Step 2-2: RunningTimersViewModel.handle 메서드에 라벨 업데이트 로직 추가

```text
Proceed with Phase 2 – Step 2-2 only.

파일:
- ViewModels/RunningTimersViewModel.swift

목표:
- 타이머 완료 핸들러에서 preset 기반 + preserve 정책일 때 라벨 업데이트 처리

구현 요구사항:
기존 handle(timerId:) 메서드의 switch 문에서 `.some(let presetId), .preserve` 케이스를 다음과 같이 수정:

```swift
case (.some(let presetId), .preserve):
    // 변경된 라벨이 있으면 프리셋에 반영
    presetRepository.updatePresetLabel(presetId: presetId, newLabel: latestTimer.label)
    timerService.removeTimer(id: timerId)
```

완료 조건:
- case (.some(let presetId), .preserve) 케이스에 updatePresetLabel 호출 추가됨
- 기존 timerService.removeTimer 호출은 그대로 유지
- 다른 케이스들은 수정하지 않음
- 빌드 성공

완료 후:
- "Phase 2 - Step 2-2 complete. Ready for manual commit." 출력
- 중단
```

**커밋 전 체크리스트:**
- [ ] 빌드 성공
- [ ] handle 메서드의 해당 케이스 수정 확인
- [ ] 다른 케이스들은 변경되지 않았는지 확인

**테스트 시나리오:**
1. 저장된 프리셋에서 타이머 시작
2. 실행 중 라벨 수정 (예: "운동" → "요가")
3. 타이머 완료까지 대기
4. 완료 알림에서 "보존" 선택
5. 앱 재시작
6. 해당 프리셋의 라벨이 "요가"로 영구 변경되었는지 확인

**테스트 시나리오 (변경 안 되는 경우):**
1. 저장된 프리셋에서 타이머 시작
2. 실행 중 라벨 수정
3. 타이머 완료 후 "폐기" 선택
4. 앱 재시작
5. 원래 프리셋 라벨이 유지되는지 확인

**권장 커밋 메시지:**
```
feat: persist label changes to presets on completion

- Update preset label when timer completes with preserve policy
- Only apply to preset-based timers with endAction == .preserve
- Maintain existing behavior for other completion scenarios
```

---

## 🎉 Phase 3 완료 기준

### 전체 기능 검증 체크리스트

**Phase 1 (메모리 업데이트):**
- [ ] 실행 중 타이머 라벨을 탭하여 편집 가능
- [ ] 새 라벨 입력 후 엔터 키로 확정
- [ ] UI에 즉시 반영됨
- [ ] 앱 종료 후 재시작하면 원래 라벨로 복구 (영구 저장 안 됨)

**Phase 2 (영구 저장):**
- [ ] preset 기반 타이머에서 라벨 변경 후 완료
- [ ] "보존" 선택 시 프리셋에 라벨 변경사항 반영됨
- [ ] 앱 재시작 후에도 변경된 라벨 유지
- [ ] "폐기" 선택 시 프리셋 라벨은 원래대로 유지
- [ ] 즉석 타이머에서 라벨 변경 후 완료 시 영향 없음

**빌드 및 성능:**
- [ ] 모든 단계에서 빌드 성공
- [ ] 메모리 누수 없음
- [ ] UI 반응 즉시성 확인
- [ ] Firebase 동기화 정상 작동

---

## 📝 다음 작업 (별도 진행)

저장된 타이머(FavoriteTimersView)에서도 동일한 인라인 편집 기능을 추가하려면:

**Phase 3: 저장된 타이머 라벨 편집 (별도 작업)**
- FavoriteTimersView에서 onLabelChange 콜백 연결
- FavoriteTimersViewModel.updateLabel 구현
- PresetRepository.updatePresetLabel 재사용

---

## 📚 참고 정보

### 프로젝트 구조
```
QuickLabelTimer/
├── Services/
│   └── TimerService.swift          # Phase 1-1
├── Repositories/
│   └── PresetRepository.swift      # Phase 2-1
├── ViewModels/
│   └── RunningTimersViewModel.swift # Phase 1-2, 2-2
└── Views/
    └── RunningTimersView.swift     # 이미 onLabelChange 연결됨
```

### 데이터 모델
```swift
struct TimerData {
    var id: UUID
    var label: String          // 수정 대상
    var duration: Int
    var status: TimerStatus
    var presetId: UUID?        // Phase 2에서 사용
    var endAction: EndAction   // Phase 2에서 사용
    // ...
}

enum EndAction {
    case preserve  // 보존 (영구 저장)
    case discard   // 폐기 (임시)
}
```

### 코드 스타일 가이드
- DocString 작성: 3-슬래시 형식 (`///`)
- 간결한 구현: guard 문으로 early return
- SwiftUI 관찰: objectWillChange.send() 사용
- 명명 규칙: updateLabel (동사 + 명사)

---

**이 문서는 실행 중 타이머 라벨 인라인 편집 기능을 안전하고 체계적으로 구현하기 위한 단계별 명세서입니다.**
