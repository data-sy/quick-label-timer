# TimerRow 리디자인 – 구현 계획

## 개요

기존의 단순 리스트 형태의 타이머 행을 **모던한 카드 기반 디자인**과 **새로운 인터랙션 패턴**으로 전면 리디자인한다. 구현은 리스크를 최소화하기 위해 **3단계 점진적 접근**을 따른다.

**디자인 기준 파일**: `/Debug/DesignLabTimerRow/TimerRowRedesign.swift`

## 단계별 전략

```
Phase 1: 레이아웃 재구성 (모던 카드)
    ↓
Phase 2: 실행 중 상태 시각적 피드백
    ↓
Phase 3: 버튼 시스템 리디자인
```

**주의**: 인라인 라벨 편집 기능은 이번 범위에서 제외하며, 별도 브랜치에서 처리한다.

---

## 정책 결정 사항 (확정)

1. ✅ **Stop 버튼 제거**: 완전히 제거. 사용자는 항상 Pause → Reset 흐름을 따른다.
2. ✅ **Reset 버튼 노출 조건**: `status == .paused` 일 때만 표시
3. ✅ **Delete 버튼(X)**: 항상 삭제 확인 다이얼로그 표시
4. ✅ **단계적 접근**: 총 3단계 (레이아웃 → 실행 상태 → 버튼)

---

## Phase 1: 레이아웃 재구성 (모던 카드)

### 목표

기존 기능은 그대로 유지한 채, **3섹션 카드 레이아웃**으로 구조를 변경한다.

### 변경 사항

#### 1. 카드 스타일
```swift
.padding(16)
.background(AppTheme.contentBackground)  // 실행 중 색상은 Phase 2에서 적용
.cornerRadius(20)
.shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
```

#### 2. 레이아웃 구조 (3 섹션)
```
VStack(alignment: .leading, spacing: 12) {
    // [상단] 북마크 + 라벨 + 삭제 버튼
    HStack {
        FavoriteToggleButton (44x44)
        Text(label) - .headline, 읽기 전용
        Spacer()
        Delete Button (X) - 44x44 터치 영역
    }

    // 구분선
    Divider()
        .background(Color.secondary.opacity(0.3))  // Phase 2에서 흰색
        .padding(.vertical, 4)

    // [중단] 시간 + 버튼 영역
    HStack {
        Text(formattedTime) - 48pt bold rounded (기존 44pt light에서 변경)
        Spacer()
        [기존 2버튼 시스템] - 그대로 유지
    }

    // [하단] 알람 아이콘 + 종료 예정 시간
    HStack(spacing: 4) {
        Image(systemName: alarmMode.iconName) - .caption
        Text(formattedEndTime) - .footnote
        Spacer()
    }
}
```

#### 3. 삭제 버튼 구현
```swift
Button(action: { showDeleteConfirmation = true }) {
    Image(systemName: "xmark")
        .font(.caption)
        .foregroundColor(.secondary)
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
}
.confirmationDialog("Delete timer?", isPresented: $showDeleteConfirmation) {
    Button("Delete", role: .destructive) { onDelete() }
    Button("Cancel", role: .cancel) { }
}
```

#### 4. 종료 예정 시간 표시
```swift
// TimerData extension에 추가
var formattedEndTime: String {
    if status == .completed {
        return String(localized: "ui.timer.completed")
    }
    let formatter = DateFormatter()
    formatter.dateFormat = "a h:mm"
    formatter.locale = Locale.current
    return String(format: String(localized: "ui.timer.endTimeFormat"),
                  formatter.string(from: endDate))
}

// 필요한 로컬라이즈 키:
// "ui.timer.endTimeFormat" = "%@ 종료 예정"
// "ui.timer.completed" = "종료됨"
```

#### 5. Alarm Mode 속성 추가
```swift
// TimerData extension에 추가
var alarmMode: AlarmMode {
    AlarmNotificationPolicy.getMode(
        soundOn: isSoundOn,
        vibrationOn: isVibrationOn
    )
}
```

#### 6. CountdownMessageView 처리
- 완료 상태가 아닐 때는 숨김
- 또는 하단 섹션에 조건부로 통합

### 수정 파일 목록

**주요 파일**:
- `/QuickLabelTimer/QuickLabelTimer/Views/Components/TimerRow/TimerRowView.swift`
  - 전체 레이아웃 재구성
  - 삭제 버튼 + 확인 다이얼로그 추가
  - 시간 폰트 48pt bold rounded 적용
  - 섹션 간 Divider 추가
  - 알람 표시를 하단으로 이동
  - 종료 예정 시간 표시 추가

**확장**:
- `/QuickLabelTimer/QuickLabelTimer/Models/TimerData.swift`
  - `alarmMode` 계산 속성 추가
  - `formattedEndTime` 계산 속성 추가

**로컬라이제이션**:
- `/QuickLabelTimer/Localizable.xcstrings`
  - "ui.timer.endTimeFormat" 추가
  - "ui.timer.completed" 추가
  - 삭제 확인 다이얼로그 문자열 추가

**보조**:
- `/QuickLabelTimer/QuickLabelTimer/Views/Components/TimerRow/CountdownMessageView.swift`
  - 새로운 하단 섹션과 충돌하지 않도록 조정
  - `status != .completed` 시 숨김 고려

### 테스트 체크리스트
- [ ] iPhone SE(최소 화면)에서 레이아웃 정상 표시
- [ ] 라이트/다크 모드에서 카드 그림자 확인
- [ ] Divider 정상 표시
- [ ] 타이머 실행 시 종료 시간 업데이트
- [ ] 종료 시간 포맷 로케일 정상 (오전/오후)
- [ ] 삭제 버튼 확인 다이얼로그 표시
- [ ] 삭제 다이얼로그 문구 정상
- [ ] 시간 오버플로우 없음 (999:59:59 테스트)
- [ ] 긴 라벨 줄바꿈 정상
- [ ] VoiceOver 탐색 순서: 상단 → 중단 → 하단

### 리스크: LOW

레이아웃 변경만 포함, 로직 변경 없음

---

## Phase 2: 실행 중 상태 시각적 피드백

### 목표

버튼 시스템을 바꾸기 전에, **실행 중일 때 파란 배경 반전 효과**를 추가한다.

### 변경 사항

#### 1. 배경 반전
```swift
.background(timer.status == .running ? Color.blue : AppTheme.contentBackground)
```

#### 2. 텍스트 색상 조정
```swift
let isRunning = timer.status == .running

.foregroundColor(isRunning ? .white : labelColor)
```

#### 3. Divider 색상
```swift
Divider()
    .background(isRunning ? Color.white : Color.secondary.opacity(0.3))
```

#### 4. 아이콘 색상
```swift
.foregroundColor(isRunning ? .white.opacity(0.8) : .secondary)
```

#### 5. 북마크 아이콘 처리
```swift
struct FavoriteToggleButton: View {
    let endAction: TimerEndAction
    let isRunning: Bool
    let onToggle: () -> Void

    var body: some View {
        Image(systemName: endAction.isPreserve ? "bookmark.fill" : "bookmark")
            .foregroundColor(isRunning ? .white :
                           (endAction.isPreserve ? AppTheme.actionYellow : .secondary))
    }
}
```

### 리스크: LOW

스타일링 변경만 포함

---

## Phase 3: 버튼 시스템 리디자인

### 목표

기존 2버튼 상태 머신을 제거하고, **메인 버튼 1개 + 조건부 Reset 버튼** 구조로 단순화한다.

(이하 내용은 원문 구조를 그대로 유지하며 한글 번역됨)

---

## 다음 단계

- 본 계획 승인 후 **Phase 1 구현 시작**

