# Claude Code 프롬프트 플랜 v8 (한국어)

이 문서는 **TimerRow Redesign** 작업을 Claude Code로 실행하기 위한 **최종 수정 버전(v8)**이다.

v8의 주요 변경 사항:
- **TimerActionButtons**: 컴포넌트 이름을 직관적인 `TimerActionButtons`로 확정
- **AppTheme 통합**: 하드코딩된 수치들을 `AppTheme`에 먼저 정의하고 사용
- **구현 예상 시나리오**: AI에게 문법적 강요보다는 의도(Intent)를 전달하는 방식으로 지시어 완화
- **Parallel Refactoring**: 기존 코드를 건드리지 않고 병렬로 개발 후 교체

---

## 전체 실행 원칙 (v8)

1.  **기존 TimerRowView는 절대 수정하지 않는다.** (안전 제일)
2.  **AppTheme의 디자인 토큰을 적극 활용한다.** (하드코딩 지양)
3.  **각 단계는 독립적으로 수행하며, 완료 후 개발자가 직접 검토 및 커밋한다.**
4.  **AI가 제시하는 코드는 "예상 시나리오"를 바탕으로 하되, 최적의 구현 방식을 따른다.**

---

## Phase 1: 디자인 시스템 및 뼈대 생성

### Step 1-1: AppTheme 확장

```text
`AppTheme.swift` 파일과 `timer-row-redesign-plan.md`를 컨텍스트로 읽으세요.

**Step 1-1 (AppTheme 확장)**만 수행하세요.

목표:
- 타이머 카드 UI에 필요한 디자인 상수들을 `AppTheme`에 정의합니다.
- 하드코딩된 숫자를 없애고 중앙에서 관리하도록 합니다.

구현 예상 시나리오:
`AppTheme` 내부에 `TimerCard` 열거형(혹은 구조체)을 추가하여 다음 수치들을 관리하도록 구성하세요:
- cornerRadius: 20
- padding: 16
- shadowRadius: 8, shadowY: 4
- timeTextSize: 48 (둥근 폰트)
- buttonSize: 56 (메인), 44 (서브)

완료 조건:
- `AppTheme.TimerCard`를 통해 수치에 접근 가능해야 함
- 기존 코드는 건드리지 않음

완료 후:
- "Step 1-1 complete. AppTheme updated. Ready for manual commit." 출력
- 중단

```

**체크리스트:**

* [ ] 빌드 성공
* [ ] `AppTheme.TimerCard` 정의 확인

---

### Step 1-2: NewTimerRow 뼈대 생성

```text
**Step 1-2 (NewTimerRow 파일 생성)**만 수행하세요.

목표:
- `Views/Components/TimerRow/NewTimerRow.swift` 파일 생성
- `AppTheme` 상수를 활용하여 3섹션(TOP/MIDDLE/BOTTOM) 카드 레이아웃 구성

구현 예상 시나리오:
```swift
struct NewTimerRow: View {
    let timer: TimerData
    // 온클로저 패턴
    let onToggleFavorite: () -> Void
    let onPlayPause: () -> Void
    let onReset: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // TOP: 북마크 + 라벨 + 삭제
            HStack { 
                /* 배치만 잡기 */ 
                Text("TOP") 
            }
            
            Divider()
            
            // MIDDLE: 시간 + 버튼들
            HStack { 
                Text(timer.formattedTime)
                    .font(.system(size: AppTheme.TimerCard.timeTextSize, ...)) // AppTheme 사용
                Spacer()
                Text("BUTTONS")
            }
            
            // BOTTOM: 정보
            HStack { Text("BOTTOM") }
        }
        .padding(AppTheme.TimerCard.padding)
        .background(AppTheme.contentBackground) // 또는 흰색
        .cornerRadius(AppTheme.TimerCard.cornerRadius)
        .shadow(...)
    }
}

```

완료 후:

* "Step 1-2 complete. Ready for manual commit." 출력
* 중단

```

**체크리스트:**
- [ ] NewTimerRow.swift 생성
- [ ] AppTheme 상수 적용 여부 확인
- [ ] 레이아웃 구조 확인

---

### Step 1-3: Preview 생성

```text
**Step 1-3 (NewTimerRow Preview)**만 수행하세요.

목표:
- `NewTimerRow.swift` 하단에 Preview 추가
- 라이트/다크 모드에서 `AppTheme` 색상이 잘 적용되는지 확인

구현 예상 시나리오:
- 더미 TimerData 2개(실행 중, 일시정지)를 생성하여 배치
- 배경색으로 `AppTheme.pageBackground`를 깔고 그 위에 Row 배치하여 실제 룩앤필 확인

완료 후:
- "Step 1-3 complete. Ready for manual commit." 출력
- 중단

```

---

## Phase 2: 기능 블록 조립

### Step 2-1: 기존 컴포넌트 배치

```text
**Step 2-1 (기존 컴포넌트 배치)**만 수행하세요.

목표:
- TOP 섹션에 `FavoriteToggleButton`과 삭제 버튼 배치
- 이미 존재하는 컴포넌트들을 재사용

구현 예상 시나리오:
- TOP 섹션:
  - FavoriteToggleButton (기존 것 활용)
  - Timer Label (Text)
  - Spacer
  - X 버튼 (삭제) -> 44x44 터치 영역 확보

완료 후:
- "Step 2-1 complete. Ready for manual commit." 출력
- 중단

```

---

### Step 2-2: TimerActionButtons 생성

```text
**Step 2-2 (TimerActionButtons 생성)**만 수행하세요.

목표:
- `Views/Components/TimerRowButton/TimerActionButtons.swift` 생성
- 기존의 복잡한 버튼 로직을 대체할 단순한 뷰

구현 예상 시나리오:
- Props: `status: TimerStatus`, `onPlayPause: () -> Void`, `onReset: () -> Void`
- Play/Pause 버튼: `AppTheme.TimerCard.buttonSize` (56) 크기의 원형 버튼
- Reset 버튼: 일시정지(paused) 상태일 때만 왼쪽에 표시 (크기 44)

완료 후:
- "Step 2-2 complete. Ready for manual commit." 출력
- 중단

```

---

### Step 2-3: TimerActionButtons 연결

```text
**Step 2-3 (TimerActionButtons 연결)**만 수행하세요.

목표:
- `NewTimerRow`의 MIDDLE 섹션에 `TimerActionButtons` 배치
- 타이머 상태에 따라 버튼이 바뀌는지 확인

구현 예상 시나리오:
- NewTimerRow의 MIDDLE 섹션 우측에 TimerActionButtons 배치
- 상위에서 받은 클로저(onPlayPause, onReset) 전달

완료 후:
- "Step 2-3 complete. Ready for manual commit." 출력
- 중단

```

---

## Phase 3: 독립 테스트 (검증)

### Step 3-1: TestView 생성

```text
**Step 3-1 (NewTimerRowTestView 생성)**만 수행하세요.

목표:
- `Debug/NewTimerRowTestView.swift` 생성
- 실제 뷰모델 없이 상태 변화를 테스트할 수 있는 샌드박스 환경 구축

구현 예상 시나리오:
- @State 변수로 `TimerData` 관리
- Play 버튼 누르면 status가 running <-> paused 토글되도록 간단한 로직 구현
- Reset 버튼 누르면 시간 초기화
- 북마크 토글 동작 확인

완료 후:
- "Step 3-1 complete. Ready for manual commit." 출력
- 중단

```

**체크리스트:**

* [ ] TestView 빌드 및 실행
* [ ] 버튼 클릭 시 상태 변화 확인 (UI 반영)

---

## Phase 4: 실전 배치 (교체)

### Step 4-1: FavoriteTimersView 교체

```text
**Step 4-1 (FavoriteTimersView 마이그레이션)**만 수행하세요.

목표:
- `FavoriteTimersView.swift`에서 기존 `TimerRowView`를 `NewTimerRow`로 교체

구현 예상 시나리오:
- 기존: `TimerRowView(timer: timer, ...)`
- 변경: `NewTimerRow(timer: timer, ...)`
- 매핑 주의:
  - onPlayPause -> viewModel.handleRight(for: timer) (보통 Play 역할)
  - onDelete -> viewModel.handleLeft(for: timer)

완료 후:
- "Step 4-1 complete. Ready for manual commit." 출력
- 중단

```

### Step 4-2: RunningTimersView 교체

```text
**Step 4-2 (RunningTimersView 마이그레이션)**만 수행하세요.

목표:
- `RunningTimersView.swift` 교체
- 여기가 가장 복잡하므로 버튼 동작 매핑에 주의

구현 예상 시나리오:
- onPlayPause -> viewModel.handleRight (Play/Pause 토글)
- onReset -> viewModel.handleLeft (일시정지 시 Reset)
- onDelete -> viewModel.handleLeft (완료 시 Delete)
- *참고: ViewModel의 로직을 수정하지 않고 뷰에서 적절한 클로저를 호출*

완료 후:
- "Step 4-2 complete. Ready for manual commit." 출력
- 중단

```

---

## Phase 5: 청소 (Cleanup)

### Step 5-1: 구버전 코드 제거

```text
**Step 5-1 (Legacy Code 삭제)**만 수행하세요.

목표:
- 더 이상 사용하지 않는 `TimerRowView.swift` 및 관련 버튼 파일들 삭제

구현 예상 시나리오:
- `TimerRowView.swift` 삭제
- `TimerLeftButtonView`, `TimerRightButtonView`, `TimerButtonMapping` 등 삭제
- 삭제 후 빌드 에러가 없는지 확인 (만약 다른 곳에서 쓰고 있다면 수정 필요)

완료 후:
- "Step 5-1 complete. Legacy code removed. Ready for manual commit." 출력
- 중단

```

---

## Phase 6 이후: 고도화 (Improvement)

## Phase 6: 종료시간 표시

### Step 6-1: TimeFormatter 유틸리티 추가

```text
**Step 6-1 (TimeFormatter 추가)**만 구현하세요.

범위:
- `Utils/TimeUtils.swift`에 TimeFormatter 추가
- formatRemaining, formatEndTime 메서드 구현

구현 상세:
TimeUtils.swift 파일 끝에 추가:

```swift
// MARK: - Time Formatting

/// 시간 포맷팅 유틸리티
enum TimeFormatter {
    /// 남은 초를 "HH:MM:SS" 또는 "MM:SS"로 변환
    /// - Parameter seconds: 변환할 초
    /// - Returns: 포맷된 시간 문자열
    static func formatRemaining(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%01d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
    
    /// Date를 로케일 인식 시간 문자열로 변환 (예: "오전 10:30")
    /// - Parameters:
    ///   - date: 변환할 날짜
    ///   - locale: 사용할 로케일 (기본값: 현재 로케일)
    /// - Returns: 포맷된 시간 문자열
    static func formatEndTime(_ date: Date, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.locale = locale
        return formatter.string(from: date)
    }
}
```

완료 후:
- "Step 6-1 complete. Ready for manual commit." 출력
- 다음 지시를 기다리며 중단
```

**커밋 전 테스트 체크리스트:**
- [ ] 빌드 성공
- [ ] `TimeFormatter.formatRemaining(180)` → "03:00"
- [ ] `TimeFormatter.formatEndTime(Date())` → "오전/오후 시:분" 형식
- [ ] 한국어 로케일에서 정상 작동

**권장 커밋 메시지:**
```
feat: add TimeFormatter utility for time formatting

- Add formatRemaining for converting seconds to HH:MM:SS
- Add formatEndTime for locale-aware date formatting
- Support both Korean and English locales
- Prepare for formattedEndTime implementation
```

---

### Step 6-2: TimerData에 formattedEndTime 추가

```text
**Step 6-2 (formattedEndTime 추가)**만 구현하세요.

범위:
- TimerData extension에 formattedEndTime computed property 추가
- Localizable.xcstrings에 필요한 키 추가

구현 상세:

Models/TimerData.swift에 추가:
```swift
extension TimerData {
    /// 종료 예정 시간을 로케일에 맞게 포맷
    var formattedEndTime: String {
        if status == .completed {
            return String(localized: "ui.timer.completed")
        }
        let timeString = TimeFormatter.formatEndTime(endDate)
        return String(format: String(localized: "ui.timer.endTimeFormat"), timeString)
    }
}
```

Localizable.xcstrings에 추가:
```json
"ui.timer.endTimeFormat": {
  "extractionState": "manual",
  "localizations": {
    "en": { "stringUnit": { "value": "Ends at %@" } },
    "ko": { "stringUnit": { "value": "%@ 종료 예정" } }
  }
},
"ui.timer.completed": {
  "extractionState": "manual",
  "localizations": {
    "en": { "stringUnit": { "value": "Completed" } },
    "ko": { "stringUnit": { "value": "종료됨" } }
  }
}
```

완료 후:
- "Step 6-2 complete. Ready for manual commit." 출력
- 다음 지시를 기다리며 중단
```

**커밋 전 테스트 체크리스트:**
- [ ] 빌드 성공
- [ ] `timer.formattedEndTime` 컴파일 정상
- [ ] 실행 중 타이머: "오전 10:30 종료 예정" 형식
- [ ] 완료된 타이머: "종료됨"
- [ ] 영어 로케일: "Ends at 10:30 AM"
- [ ] 한국어 로케일: "오전 10:30 종료 예정"

**권장 커밋 메시지:**
```
feat: add formattedEndTime to TimerData

- Add formattedEndTime computed property
- Use TimeFormatter.formatEndTime for locale-aware formatting
- Add ui.timer.endTimeFormat localization key
- Add ui.timer.completed localization key
- Support both Korean and English
```

---

### Step 6-3: NewTimerRow에 종료시간 표시

```text
**Step 6-3 (종료시간 UI 추가)**만 구현하세요.

범위:
- NewTimerRow의 BOTTOM 섹션에 알람 아이콘 + 종료시간 표시

구현 상세:
NewTimerRow.swift의 BOTTOM 섹션 업데이트:

```swift
// BOTTOM: 알람 + 종료시간
HStack(spacing: 4) {
    // 알람 모드 아이콘
    let alarmMode = AlarmNotificationPolicy.getMode(
        soundOn: timer.isSoundOn,
        vibrationOn: timer.isVibrationOn
    )
    Image(systemName: alarmMode.iconName)
        .font(.caption)
        .foregroundColor(.secondary)
    
    // 종료 시간
    Text(timer.formattedEndTime)
        .font(.footnote)
        .foregroundColor(.secondary)
    
    Spacer()
}
```

완료 후:
- "Step 6-3 complete. Ready for manual commit." 출력
- 다음 지시를 기다리며 중단
```

**커밋 전 테스트 체크리스트:**
- [ ] 빌드 성공
- [ ] BOTTOM 섹션에 알람 아이콘 표시
- [ ] 종료 예정 시간 표시
- [ ] 완료된 타이머: "종료됨" 표시
- [ ] 알람 모드에 따라 아이콘 변경 (소리/진동/무음)
- [ ] 시간 형식이 로케일에 맞게 표시

**권장 커밋 메시지:**
```
feat: add end time display to NewTimerRow bottom section

- Show alarm mode icon
- Display formatted end time using formattedEndTime
- Show "종료됨" for completed timers
- Apply proper styling (caption icon, footnote text)
```

---

## Phase 7: 삭제 확인 다이얼로그

### Step 7-1: 삭제 확인 다이얼로그 추가

```text
**Step 7-1 (삭제 확인 추가)**만 구현하세요.

범위:
- NewTimerRow에 삭제 확인 다이얼로그 추가
- @State로 다이얼로그 표시 관리

구현 상세:
NewTimerRow.swift 업데이트:

```swift
struct NewTimerRow: View {
    let timer: TimerData
    let onToggleFavorite: () -> Void
    let onPlayPause: () -> Void
    let onReset: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteConfirmation = false  // 추가
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // TOP 섹션
            HStack(alignment: .center, spacing: 8) {
                FavoriteToggleButton(...)
                
                Text(timer.label)...
                
                Spacer()
                
                // 삭제 버튼 (확인 다이얼로그 연결)
                Button(action: { showDeleteConfirmation = true }) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
            }
            
            // ... 나머지 섹션들
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .confirmationDialog(
            "타이머를 삭제하시겠습니까?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("삭제", role: .destructive) {
                onDelete()
            }
            Button("취소", role: .cancel) { }
        }
    }
}
```

완료 후:
- "Step 7-1 complete. Ready for manual commit." 출력
- 다음 지시를 기다리며 중단
```

**커밋 전 테스트 체크리스트:**
- [ ] 빌드 성공
- [ ] 삭제 버튼(X) 클릭 시 다이얼로그 표시
- [ ] "삭제" 버튼 클릭 시 onDelete 호출
- [ ] "취소" 버튼 클릭 시 다이얼로그 닫힘
- [ ] 다이얼로그 외부 탭으로 닫힘
- [ ] 다이얼로그 문구 정확함

**권장 커밋 메시지:**
```
feat: add delete confirmation dialog to NewTimerRow

- Add confirmationDialog for delete action
- Show confirmation for all timer states (always confirm)
- Provide "삭제" (destructive) and "취소" (cancel) options
- Ensure proper state management with @State
```

---

## Phase 8: Running State 색반전

### Step 8-1: 색반전 스타일 추가

```text
**Step 8-1 (Running State 색반전)**만 구현하세요.

범위:
- NewTimerRow에 isRunning 조건부 스타일 적용
- 파란 배경 + 흰색 텍스트

구현 상세:
NewTimerRow.swift 업데이트:

```swift
struct NewTimerRow: View {
    // ... 기존 프로퍼티들
    
    private var isRunning: Bool {
        timer.status == .running
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // TOP 섹션
            HStack(alignment: .center, spacing: 8) {
                FavoriteToggleButton(
                    endAction: timer.endAction,
                    isRunning: isRunning,  // 추가
                    onToggle: onToggleFavorite
                )
                
                Text(timer.label)
                    .font(.headline)
                    .foregroundColor(isRunning ? .white : .primary)  // 변경
                    // ...
                
                Spacer()
                
                Button(action: { showDeleteConfirmation = true }) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(isRunning ? .white.opacity(0.8) : .secondary)  // 변경
                        // ...
                }
            }
            
            Divider()
                .background(isRunning ? Color.white : Color.secondary.opacity(0.3))  // 변경
                .padding(.vertical, 4)
            
            // MIDDLE 섹션
            HStack(alignment: .center, spacing: 16) {
                Text(timer.formattedTime)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(isRunning ? .white : .primary)  // 변경
                    // ...
                
                Spacer()
                
                UnifiedTimerButton(...)  // Phase 8-2에서 업데이트
            }
            
            // BOTTOM 섹션
            HStack(spacing: 4) {
                Image(systemName: alarmMode.iconName)
                    .font(.caption)
                    .foregroundColor(isRunning ? .white.opacity(0.8) : .secondary)  // 변경
                
                Text(timer.formattedEndTime)
                    .font(.footnote)
                    .foregroundColor(isRunning ? .white.opacity(0.8) : .secondary)  // 변경
                
                Spacer()
            }
        }
        .padding(16)
        .background(isRunning ? Color.blue : Color.white)  // 변경
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .confirmationDialog(...)
    }
}
```

완료 후:
- "Step 8-1 complete. Ready for manual commit." 출력
- 다음 지시를 기다리며 중단
```

**커밋 전 테스트 체크리스트:**
- [ ] 빌드 성공
- [ ] 실행 중: 파란 배경 + 흰색 텍스트
- [ ] 일시정지: 흰 배경 + 검은 텍스트
- [ ] Play/Pause 시 부드러운 전환
- [ ] 모든 텍스트 읽기 쉬움 (대비 확인)
- [ ] 다크 모드에서도 정상 작동

**권장 커밋 메시지:**
```
feat: add running state visual feedback to NewTimerRow

- Apply blue background when timer is running
- Invert all text/icons to white for contrast
- Update divider color to white
- Ensure smooth color transitions
- Maintain readability in both states
```

---

### Step 8-2: FavoriteToggleButton 업데이트

```text
**Step 8-2 (FavoriteToggleButton isRunning 지원)**만 구현하세요.

범위:
- FavoriteToggleButton에 isRunning 파라미터 추가 (기본값 제공)

구현 상세:
Views/Components/TimerRowButton/FavoriteToggleButton.swift 업데이트:

```swift
struct FavoriteToggleButton: View {
    let endAction: TimerEndAction
    let isRunning: Bool = false  // 기본값 추가
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            Image(systemName: endAction.isPreserve ? "bookmark.fill" : "bookmark")
                .font(.title3)
                .foregroundColor(
                    isRunning ? .white :
                    (endAction.isPreserve ? AppTheme.actionYellow : .secondary)
                )
        }
    }
}
```

완료 후:
- "Step 8-2 complete. Ready for manual commit." 출력
- 다음 지시를 기다리며 중단
```

**커밋 전 테스트 체크리스트:**
- [ ] 빌드 성공
- [ ] 북마크 아이콘이 실행 중에 흰색
- [ ] 북마크 아이콘이 정지 시 노란색/회색
- [ ] 기존 사용처(기본값)에서도 정상 작동

**권장 커밋 메시지:**
```
feat: add running state support to FavoriteToggleButton

- Add isRunning parameter with default value false
- Show white icon when running, original color otherwise
- Maintain backward compatibility with default parameter
```

---

### Step 8-3: UnifiedTimerButton 색반전 지원

```text
**Step 8-3 (UnifiedTimerButton 색반전)**만 구현하세요.

범위:
- UnifiedTimerButton에 isRunning 파라미터 추가
- 버튼 색상 반전 (running일 때)

구현 상세:
Views/Components/TimerRowButton/UnifiedTimerButton.swift 업데이트:

```swift
struct UnifiedTimerButton: View {
    let status: TimerStatus
    let isRunning: Bool  // 추가
    let onPlayPause: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // 리셋 버튼
            if status == .paused {
                Button(action: onReset) {
                    Image(systemName: "arrow.clockwise")
                        .font(.footnote)
                        .foregroundColor(isRunning ? .white : .blue)  // 변경
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .strokeBorder(
                                    isRunning ? Color.white.opacity(0.5) : Color.blue.opacity(0.3),
                                    lineWidth: 1.5
                                )
                        )
                }
            }
            
            // Play/Pause 메인 버튼
            Button(action: onPlayPause) {
                Image(systemName: status == .running ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .foregroundColor(isRunning ? .blue : .white)  // 변경
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(isRunning ? Color.white : Color.blue))  // 변경
                    .shadow(radius: 4)
            }
        }
    }
}
```

NewTimerRow.swift에서 호출 시:
```swift
UnifiedTimerButton(
    status: timer.status,
    isRunning: isRunning,  // 추가
    onPlayPause: onPlayPause,
    onReset: onReset
)
```

완료 후:
- "Step 8-3 complete. Ready for manual commit." 출력
- 다음 지시를 기다리며 중단
```

**커밋 전 테스트 체크리스트:**
- [ ] 빌드 성공
- [ ] 실행 중: 흰 원형 + 파란 아이콘
- [ ] 정지 중: 파란 원형 + 흰 아이콘
- [ ] 리셋 버튼도 색반전 적용
- [ ] 버튼 전환이 부드러움

**권장 커밋 메시지:**
```
feat: add running state color inversion to UnifiedTimerButton

- Add isRunning parameter to UnifiedTimerButton
- Invert main button colors when running (white bg, blue icon)
- Invert reset button colors when running
- Wire up isRunning from NewTimerRow
```

---

## Phase 9: 인라인 라벨 편집

### Step 9-1: EditableTimerLabel 컴포넌트 생성

```text
**Step 9-1 (EditableTimerLabel 생성)**만 구현하세요.

범위:
- 새 파일 생성: `Views/Components/TimerRow/EditableTimerLabel.swift`
- 탭하면 편집 가능한 TextField로 전환

구현 상세:
```swift
import SwiftUI

struct EditableTimerLabel: View {
    let text: String
    let isRunning: Bool
    let onSubmit: (String) -> Void
    
    @State private var isEditing = false
    @State private var editText = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        Group {
            if isEditing {
                TextField("타이머 이름", text: $editText, axis: .vertical)
                    .font(.headline)
                    .foregroundColor(isRunning ? .blue : .primary)
                    .lineLimit(nil)
                    .focused($isFocused)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isRunning ? Color.white : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isRunning ? Color.clear : Color.secondary.opacity(0.3), lineWidth: 1.5)
                    )
                    .onSubmit { commitEdit() }
                    .onAppear {
                        editText = text
                        isFocused = true
                    }
            } else {
                HStack(spacing: 6) {
                    Text(text)
                        .font(.headline)
                        .foregroundColor(isRunning ? .white : .primary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(isRunning ? .white.opacity(0.8) : .secondary)
                }
                .onTapGesture { startEditing() }
            }
        }
    }
    
    private func startEditing() {
        isEditing = true
    }
    
    private func commitEdit() {
        let trimmed = editText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            onSubmit(trimmed)
        }
        isEditing = false
    }
}
```

완료 후:
- "Step 9-1 complete. Ready for manual commit." 출력
- 다음 지시를 기다리며 중단
```

**커밋 전 테스트 체크리스트:**
- [ ] 빌드 성공
- [ ] EditableTimerLabel.swift 생성됨
- [ ] TextField 포커스 관리 정상
- [ ] 엔터 키로 편집 완료
- [ ] 빈 문자열 제출 방지

**권장 커밋 메시지:**
```
feat: create EditableTimerLabel component

- Add inline label editing with TextField
- Show pencil icon hint when not editing
- Support running state color inversion
- Handle focus management with @FocusState
- Validate non-empty input on submit
```

---

### Step 9-2: NewTimerRow에 EditableTimerLabel 통합

```text
**Step 9-2 (인라인 편집 통합)**만 구현하세요.

범위:
- NewTimerRow에 onLabelChange 클로저 추가
- Text → EditableTimerLabel 교체

구현 상세:
NewTimerRow.swift 업데이트:

```swift
struct NewTimerRow: View {
    let timer: TimerData
    let onToggleFavorite: () -> Void
    let onPlayPause: () -> Void
    let onReset: () -> Void
    let onDelete: () -> Void
    let onLabelChange: (String) -> Void  // 추가
    
    // ... 나머지
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // TOP 섹션
            HStack(alignment: .center, spacing: 8) {
                FavoriteToggleButton(...)
                
                // Text 대신 EditableTimerLabel
                EditableTimerLabel(
                    text: timer.label,
                    isRunning: isRunning,
                    onSubmit: onLabelChange
                )
                
                Spacer()
                
                Button(...)  // 삭제 버튼
            }
            
            // ... 나머지 섹션들
        }
        // ...
    }
}
```

호출하는 곳(FavoriteTimersView, RunningTimersView)에서:
```swift
NewTimerRow(
    timer: timer,
    onToggleFavorite: { ... },
    onPlayPause: { ... },
    onReset: { ... },
    onDelete: { ... },
    onLabelChange: { newLabel in
        viewModel.updateLabel(for: timer, newLabel: newLabel)
    }
)
```

완료 후:
- "Step 9-2 complete. Ready for manual commit." 출력
- 다음 지시를 기다리며 중단
```

**커밋 전 테스트 체크리스트:**
- [ ] 빌드 성공
- [ ] 라벨 탭 시 편집 모드 진입
- [ ] TextField에 포커스 자동 설정
- [ ] 엔터로 편집 완료
- [ ] ViewModel에서 라벨 업데이트 처리
- [ ] 실행 중 타이머에서도 편집 가능
- [ ] 편집 중 배경/텍스트 색상 정상

**권장 커밋 메시지:**
```
feat: integrate inline label editing into NewTimerRow

- Replace static Text with EditableTimerLabel
- Add onLabelChange closure parameter
- Wire up label updates to ViewModel
- Support editing in all timer states (running/paused/preset)
- Complete Phase 9: All planned features implemented
```

---

## 최종 실행 요약 (v7)

### 커밋 시퀀스 (총 19단계)
```
Phase 1 (2 commits):
  1-1: NewTimerRow 뼈대
  1-2: Preview 추가

Phase 2 (3 commits):
  2-1: 기존 컴포넌트 배치
  2-2: UnifiedTimerButton 생성
  2-3: UnifiedTimerButton 연결

Phase 3 (2 commits):
  3-1: NewTimerRowTestView
  3-2: 함수 리팩토링 (선택)

Phase 4 (2 commits):
  4-1: FavoriteTimersView 교체
  4-2: RunningTimersView 교체

Phase 5 (2 commits):
  5-1: 구버전 주석 처리
  5-2: 구버전 삭제

Phase 6 (3 commits):
  6-1: TimeFormatter 추가
  6-2: formattedEndTime 추가
  6-3: 종료시간 UI

Phase 7 (1 commit):
  7-1: 삭제 확인 다이얼로그

Phase 8 (3 commits):
  8-1: NewTimerRow 색반전
  8-2: FavoriteToggleButton 업데이트
  8-3: UnifiedTimerButton 색반전

Phase 9 (2 commits):
  9-1: EditableTimerLabel 생성
  9-2: 인라인 편집 통합
```

### v7의 핵심 개선사항
- ✅ **Parallel 전략**: 기존 코드 안전하게 유지
- ✅ **동작 우선**: Phase 1-5는 기본 동작만
- ✅ **시각 나중**: Phase 6-9는 개선 기능
- ✅ **함수 리팩토링**: 발견 시 즉시 개선
- ✅ **독립 테스트**: TestView로 격리 검증
- ✅ **온클로저 패턴**: 베이스 뷰는 로직 없음
- ✅ **수동 커밋**: 각 단계 검토 후 직접 커밋

### 위험도 평가
- Phase 1-3: **위험 없음** (격리된 개발)
- Phase 4: **낮음** (순차 교체)
- Phase 5: **낮음** (주석 → 삭제)
- Phase 6-9: **매우 낮음** (추가 기능)

---

**이 문서는 실전 iOS 개발자의 안전하고 체계적인 리팩토링 전략을 반영한 production-grade 협업 명세서입니다.**
