# QuickLabelTimer - TabView to ScrollView 리팩토링 계획

## 개요

현재 TabView 기반의 2개 탭 구조를 단일 ScrollView로 통합하여 3개 섹션으로 재구성합니다.

**변경 전 (TabView):**
- 탭 1: 타이머 생성 + 실행 중인 타이머
- 탭 2: 북마크된 타이머

**변경 후 (ScrollView):**
- 섹션 1: 타이머 생성 (제목 없음)
- 섹션 2: 실행 중인 타이머 (제목 없음)
- 섹션 3: 북마크된 타이머 (제목: "북마크")

---

## 1. 와이어프레임 (ASCII 아트)

```
┌─────────────────────────────────────────────────┐
│ [Settings]            타이머            [Edit]   │ ← NavigationBar
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │   타이머 생성 (No Title)                   │ │ ← Section 1
│  │   ┌──────────────────────┐                │ │   (AddTimerView)
│  │   │ Label Input          │                │ │   ID: "addTimerSection"
│  │   │ Time Pickers         │                │ │   Fixed height (~250pt)
│  │   │ [Start Button]       │                │ │
│  │   └──────────────────────┘                │ │
│  └───────────────────────────────────────────┘ │
│                                                 │
│  ────────────────────────────────────────────   │ ← Divider
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │   실행 중인 타이머 (No Title)              │ │ ← Section 2
│  │   ┌──────────────────────┐                │ │   (RunningListView)
│  │   │ Timer 1              │                │ │   ID: "runningListSection"
│  │   ├──────────────────────┤                │ │   ANCHOR POINT for scroll
│  │   │ Timer 2              │                │ │   Dynamic height
│  │   └──────────────────────┘                │ │
│  └───────────────────────────────────────────┘ │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │   **북마크** (Title Visible)              │ │ ← Section 3
│  │   ┌──────────────────────┐                │ │   (FavoriteListView content)
│  │   │ Preset 1             │                │ │   ID: "favoriteListSection"
│  │   ├──────────────────────┤                │ │   Dynamic height
│  │   │ Preset 2             │                │ │   Editable in Edit mode
│  │   └──────────────────────┘                │ │
│  └───────────────────────────────────────────┘ │
│                                                 │
│  [Empty Space]                                 │
│                                                 │
└─────────────────────────────────────────────────┘
       ↕ ScrollView scrolls vertically
```

**스크롤 동작:**
- 사용자 수동 스크롤: 일반 동작
- 타이머 시작 시 (timerDidStart 이벤트): `runningListSection` 앵커로 자동 스크롤
- 애니메이션: `.easeInOut` (0.3초)

---

## 2. 파일 변경 계획

### 2.1 새로 만들 파일

**1. `/Views/UnifiedTimerView.swift` (NEW)**
- **역할**: MainTabView를 대체하는 새로운 루트 뷰
- **책임**:
  - ScrollView + ScrollViewReader로 3개 섹션 관리
  - timerDidStart 이벤트 수신하여 자동 스크롤
  - EditMode 상태 관리
  - NavigationStack 및 Toolbar 포함

**2. `/Views/Components/FavoriteListSectionView.swift` (NEW)**
- **역할**: FavoriteListView에서 추출한 콘텐츠 (NavigationStack 제외)
- **책임**:
  - 프리셋 리스트 표시
  - Edit 모드 지원
  - "북마크" 제목 표시
  - Alert 및 Sheet 관리

### 2.2 수정할 파일

**1. `/QuickLabelTimerApp.swift`**
- 변경: `MainTabView` → `UnifiedTimerView`
- 의존성 주입은 동일 유지

**2. `/Views/AddTimerView.swift`**
- 변경: TimerInputForm의 `sectionTitle` 파라미터를 `nil` 또는 빈 문자열로 전달

**3. `/Views/Components/Input/TimerInputForm.swift`**
- 변경: `sectionTitle` 파라미터를 옵셔널로 변경
- SectionTitle을 조건부로 표시

**4. `/Views/RunningListView.swift`**
- 변경: TimerListContainerView의 `title` 파라미터를 `nil`로 설정

**5. `/Localizable.xcstrings`**
- 추가: `"ui.bookmark.title"` (en: "Bookmarks", ko: "북마크")
- 추가: 접근성 키 3개 (각 섹션별)

**6. `/Utils/Accessibility+Helpers.swift`**
- 추가: `A11yText.UnifiedView` enum 및 3개 섹션 레이블

### 2.3 아카이브할 파일 (테스트 후)

- `/Views/MainTabView.swift` → `.bak`
- `/Views/TimerView.swift` → `.bak`
- `/Views/FavoriteListView.swift` → `.bak`

### 2.4 변경 없는 파일

- 모든 ViewModel (AddTimerViewModel, RunningListViewModel, FavoriteListViewModel)
- 모든 Repository/Service 파일
- Container 뷰 (SectionContainerView, TimerListContainerView)
- Row 뷰 (RunningTimerRowView, FavoritePresetRowView)

---

## 3. 구현 상세 설계

### 3.1 ScrollView + ScrollViewReader 구조

```swift
struct UnifiedTimerView: View {
    @StateObject private var addTimerVM: AddTimerViewModel
    @StateObject private var runningListVM: RunningListViewModel
    @StateObject private var favoriteListVM: FavoriteListViewModel

    @State private var showSettings = false
    @Environment(\.editMode) private var editMode

    private let timerDidStart: AnyPublisher<Void, Never>

    private enum SectionID: String {
        case addTimer = "addTimerSection"
        case runningList = "runningListSection"
        case favoriteList = "favoriteListSection"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.pageBackground.ignoresSafeArea()

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 24) {
                            // Section 1: 타이머 생성
                            SectionContainerView {
                                AddTimerView(viewModel: addTimerVM)
                            }
                            .id(SectionID.addTimer.rawValue)

                            Divider()

                            // Section 2: 실행 중인 타이머
                            SectionContainerView {
                                RunningListView(viewModel: runningListVM)
                            }
                            .id(SectionID.runningList.rawValue)

                            // Section 3: 북마크
                            SectionContainerView {
                                FavoriteListSectionView(viewModel: favoriteListVM)
                            }
                            .id(SectionID.favoriteList.rawValue)

                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal)
                    }
                    .onReceive(timerDidStart.receive(on: RunLoop.main)) { _ in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(SectionID.runningList.rawValue, anchor: .top)
                        }
                    }
                }
            }
            .navigationTitle("ui.timer.title")
            .toolbar {
                MainToolbarContent(showSettings: $showSettings, showEditButton: true)
            }
        }
    }
}
```

### 3.2 섹션 ID 설계

```swift
private enum SectionID: String {
    case addTimer = "addTimerSection"
    case runningList = "runningListSection"
    case favoriteList = "favoriteListSection"
}

// 사용 예시
.id(SectionID.runningList.rawValue)
proxy.scrollTo(SectionID.runningList.rawValue, anchor: .top)
```

### 3.3 자동 스크롤 로직

**이벤트 소스**: `timerService.didStart` (PassthroughSubject<Void, Never>)

**흐름**:
1. 사용자가 Start 버튼 클릭 → AddTimerViewModel.startTimer() 호출
2. TimerService.addTimer() → `didStart.send()` 발행
3. UnifiedTimerView가 `onReceive(timerDidStart)` 수신
4. `proxy.scrollTo(SectionID.runningList.rawValue, anchor: .top)` 호출
5. 0.3초 easeInOut 애니메이션으로 스크롤

### 3.4 Edit 모드 관리

- UnifiedTimerView가 `@Environment(\.editMode)` 소유
- MainToolbarContent의 Edit 버튼이 editMode 토글
- FavoriteListSectionView만 editMode 감지하여 삭제 버튼 표시
- AddTimerView와 RunningListView는 editMode 무시

### 3.5 NavigationStack 통합

```
NavigationStack
└── ZStack
    ├── AppTheme.pageBackground
    └── ScrollViewReader
        └── ScrollView
            └── VStack (3 sections)
```

- 단일 NavigationStack
- 제목: "ui.timer.title" ("타이머")
- Toolbar: Settings + Edit 버튼

### 3.6 각 섹션 높이 처리

| 섹션 | 높이 타입 | 크기 |
|------|----------|------|
| Section 1 (AddTimer) | 고정 | ~250pt |
| Section 2 (RunningList) | 동적 | 0-5 타이머: 100-500pt |
| Section 3 (Favorites) | 동적 | 0-20 프리셋: 100-1700pt |

**주의**: List inside ScrollView → 성능 이슈 가능성
- Phase 1: 현재 List 유지
- Phase 2 (필요시): LazyVStack으로 교체

---

## 4. 데이터 흐름 및 상태 관리

### 4.1 ViewModel 인스턴스 관리

- **생성 위치**: UnifiedTimerView.init()
- **라이프사이클**: @StateObject로 관리
- **패턴**: 기존 MainTabView와 동일

```swift
init(timerService: any TimerServiceProtocol, ...) {
    _addTimerVM = StateObject(wrappedValue: AddTimerViewModel(...))
    _runningListVM = StateObject(wrappedValue: RunningListViewModel(...))
    _favoriteListVM = StateObject(wrappedValue: FavoriteListViewModel(...))
}
```

### 4.2 Combine Publisher 구독

- ViewModel들이 Repository Publisher 구독 유지
- 변경 없음 (기존 코드 그대로 동작)

### 4.3 Edit 모드 상태 전파

```
MainToolbarContent (Edit 버튼)
    ↓
@Environment(\.editMode)
    ↓
FavoriteListSectionView
    ↓
TimerListContainerView (삭제 버튼 표시)
```

### 4.4 Alert 처리

각 섹션이 자체 Alert 관리:
- AddTimerView: `.appAlert(item: $addTimerVM.activeAlert)`
- RunningListView: `.appAlert(item: $runningListVM.activeAlert)`
- FavoriteListSectionView: `.appAlert(item: $favoriteListVM.activeAlert)`

---

## 5. 접근성 (Accessibility) 유지

### 5.1 섹션 레이블

```swift
// Accessibility+Helpers.swift
enum UnifiedView {
    static let addTimerSection: LocalizedStringKey = "a11y.unifiedView.addTimerSection"
    static let runningListSection: LocalizedStringKey = "a11y.unifiedView.runningListSection"
    static let favoriteListSection: LocalizedStringKey = "a11y.unifiedView.favoriteListSection"
}

// 사용
.accessibilityLabel(A11yText.UnifiedView.addTimerSection)
```

### 5.2 Divider 숨김

```swift
Divider()
    .accessibilityHidden(true)
```

### 5.3 기존 접근성 유지

- 타이머 행, 버튼 등의 접근성 레이블은 기존 코드 유지
- 추가 작업 불필요

---

## 6. 코드 예시

### 6.1 FavoriteListSectionView.swift

```swift
import SwiftUI

struct FavoriteListSectionView: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var viewModel: FavoriteListViewModel

    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }

    var body: some View {
        TimerListContainerView(
            title: String(localized: "ui.bookmark.title"),
            items: viewModel.visiblePresets,
            emptyMessage: A11yText.FavoriteList.emptyMessage,
            stateProvider: { _ in .preset },
            onDelete: viewModel.hidePreset(at:)
        ) { preset in
            // 기존 FavoritePresetRowView 로직
            ZStack {
                FavoritePresetRowView(
                    preset: preset,
                    onToggleFavorite: { viewModel.requestToHide(preset) },
                    onLeftTap: {
                        viewModel.handleLeft(for: preset)
                        editMode?.wrappedValue = .inactive
                    },
                    onRightTap: {
                        viewModel.handleRight(for: preset)
                        editMode?.wrappedValue = .inactive
                    }
                )

                // 실행 중 오버레이
                if viewModel.isPresetRunning(preset) {
                    // ... 기존 코드
                }
            }
        }
        .sheet(isPresented: $viewModel.isEditing) {
            // EditPresetView
        }
        .appAlert(item: $viewModel.activeAlert)
    }
}
```

### 6.2 TimerInputForm 수정

```swift
// Before
var sectionTitle: String

// After
var sectionTitle: String?

// Body
var body: some View {
    VStack {
        if let sectionTitle, !sectionTitle.isEmpty {
            SectionTitle(text: sectionTitle)
        }
        // ... rest of form
    }
}
```

---

## 7. 위험 요소 및 주의사항

### 7.1 List inside ScrollView 성능

**문제**: SwiftUI에서 비권장 패턴
**영향**: 스크롤 충돌, 성능 저하 가능성

**해결방안**:
1. Phase 1: List 유지 (20개 프리셋까지는 문제없을 것으로 예상)
2. Phase 2 (필요시): LazyVStack으로 교체
3. 테스트 중 성능 모니터링

```swift
// Phase 2 대안 (필요시)
LazyVStack(spacing: 0) {
    ForEach(items) { item in
        row(for: item)
    }
}
```

### 7.2 Edit 모드 상태 관리

**문제**: Edit 모드 활성 상태로 Favorites에서 스크롤 이동

**해결방안**:
- Option A (권장): Edit 버튼이 Toolbar에 항상 보이므로 허용
- Option B: 스크롤 위치 추적하여 자동 해제 (복잡도 증가)

**결정**: Option A 채택

### 7.3 빈 RunningList로 스크롤

**문제**: 타이머 시작 시 RunningList가 비어있음

**해결방안**:
- Option A (권장): 항상 RunningList로 스크롤 (일관성)
- Option B: 조건부 스크롤 (복잡도 증가)

**결정**: Option A 채택 - 사용자가 새 타이머를 즉시 확인 가능

### 7.4 키보드 처리

**현재**: `.ignoresSafeArea(.keyboard, edges: .bottom)`

**확인 필요**:
- Label 입력 시 키보드가 입력 필드를 가리지 않는지
- 키보드 표시 시 자동 스크롤 동작

**테스트**: Phase 3에서 집중 테스트

### 7.5 애니메이션 충돌

**잠재적 문제**:
- ScrollView scrollTo 애니메이션
- Edit 모드 토글 애니메이션
- 섹션 콘텐츠 애니메이션

**해결방안**: 일관된 `.easeInOut` 타이밍 사용, 테스트 중 확인

---

## 8. 단계별 구현 체크리스트

### [설계 확인 단계]

**구조 설계**
- [ ] 3개 섹션 수직 레이아웃 확인
- [ ] 섹션 제목: AddTimer (없음), RunningList (없음), Favorites ("북마크")
- [ ] Toolbar 버튼: Settings (우측), Edit (좌측, 항상 표시)
- [ ] 자동 스크롤: 타이머 시작 시 RunningList로 이동
- [ ] Edit 모드 범위: Favorites 섹션만 적용

**데이터 흐름**
- [ ] ViewModel 인스턴스: UnifiedTimerView.init()에서 생성 (MainTabView 패턴 동일)
- [ ] timerDidStart Publisher: TimerService → UnifiedTimerView
- [ ] EditMode 전파: Toolbar → FavoriteListSectionView
- [ ] Alert 처리: 각 섹션별 개별 관리

**UI/UX**
- [ ] 스크롤 앵커: RunningList 섹션 `.top`
- [ ] 애니메이션: `.easeInOut(duration: 0.3)`
- [ ] 섹션 간격: 24pt
- [ ] 하단 여백: 40pt 최소
- [ ] Phase 1 List vs LazyVStack: List 사용 (성능 모니터링)
- [ ] Edit 모드 스크롤 이동 시: 활성 상태 유지
- [ ] 빈 RunningList 스크롤: 항상 스크롤

**로컬라이제이션**
- [ ] 새 키 추가: `"ui.bookmark.title"` = "북마크" (ko), "Bookmarks" (en)
- [ ] 접근성 키 3개: 각 섹션별 레이블
- [ ] 기존 키 유효성: "ui.timer.title" 등

---

### [구현 단계]

**Step 1: 로컬라이제이션 설정**
- [ ] Localizable.xcstrings에 `"ui.bookmark.title"` 추가
- [ ] Accessibility 키 3개 추가:
  - `"a11y.unifiedView.addTimerSection"` (en: "Create Timer Section", ko: "타이머 생성 섹션")
  - `"a11y.unifiedView.runningListSection"` (en: "Running Timers Section", ko: "실행 중인 타이머 섹션")
  - `"a11y.unifiedView.favoriteListSection"` (en: "Bookmarks Section", ko: "북마크 섹션")
- [ ] Accessibility+Helpers.swift에 `A11yText.UnifiedView` enum 추가
- [ ] 빌드 성공 확인

**Step 2: TimerInputForm 수정**
- [ ] `sectionTitle` 파라미터를 옵셔널로 변경: `var sectionTitle: String?`
- [ ] SectionTitle을 조건부로 표시: `if let sectionTitle, !sectionTitle.isEmpty { ... }`
- [ ] Preview 확인
- [ ] 빌드 성공 확인

**Step 3: AddTimerView 수정**
- [ ] TimerInputForm 호출 시 `sectionTitle: nil` 전달
- [ ] 빌드 성공 확인
- [ ] 시각적 확인: 제목 미표시

**Step 4: RunningListView 수정**
- [ ] TimerListContainerView의 `title` 파라미터를 `nil`로 설정
- [ ] 빌드 성공 확인

**Step 5: FavoriteListSectionView 생성**
- [ ] 새 파일 생성: Views/Components/FavoriteListSectionView.swift
- [ ] FavoriteListView에서 콘텐츠 추출 (NavigationStack 제외)
- [ ] 제목을 `"ui.bookmark.title"` 사용
- [ ] 실행 중 표시기, Edit Sheet, Alert 포함
- [ ] `.appAlert(item: $viewModel.activeAlert)` 추가
- [ ] `.sheet(isPresented: $viewModel.isEditing)` 추가
- [ ] 빌드 성공 확인

**Step 6: UnifiedTimerView 생성**
- [ ] 새 파일 생성: Views/UnifiedTimerView.swift
- [ ] MainTabView의 init 구조 복사 (ViewModel 생성)
- [ ] SectionID enum 구현
- [ ] NavigationStack + ScrollViewReader + ScrollView 구조 구현
- [ ] Section 1 추가: AddTimerView (ID + 접근성)
- [ ] Divider 추가
- [ ] Section 2 추가: RunningListView (ID + 접근성)
- [ ] Section 3 추가: FavoriteListSectionView (ID + 접근성)
- [ ] `.onReceive(timerDidStart)` + scrollTo 로직 추가
- [ ] Toolbar (MainToolbarContent, showEditButton: true) 추가
- [ ] Settings Sheet 추가
- [ ] 빌드 성공 확인

**Step 7: QuickLabelTimerApp 수정**
- [ ] Root view를 `MainTabView` → `UnifiedTimerView`로 변경
- [ ] environmentObject 주입 유지
- [ ] 빌드 성공 확인

**Step 8: 초기 테스트**
- [ ] 시뮬레이터에서 앱 실행
- [ ] 크래시 없이 실행 확인
- [ ] 3개 섹션이 스크롤뷰에 표시되는지 확인
- [ ] 수동 스크롤 동작 확인
- [ ] 콘솔 경고/에러 확인

**커밋 포인트 1**: "feat: implement UnifiedTimerView with 3-section ScrollView layout"

**Step 9: 레거시 파일 아카이브**
- [ ] MainTabView.swift → MainTabView.swift.bak
- [ ] TimerView.swift → TimerView.swift.bak
- [ ] FavoriteListView.swift → FavoriteListView.swift.bak
- [ ] 아카이브 사유 주석 추가
- [ ] 빌드 성공 확인 (참조 제거 확인)

**커밋 포인트 2**: "refactor: archive legacy TabView files"

---

### [테스트 단계]

**기능 동작 확인**

- [ ] **자동 스크롤 동작**:
  - [ ] AddTimer에서 Start 버튼 클릭 → RunningList로 스크롤 확인
  - [ ] 애니메이션 부드러움 확인 (.easeInOut)
  - [ ] 스크롤 속도 적절성 확인 (~0.3초)
  - [ ] RunningList 비어있을 때도 스크롤 동작 확인
  - [ ] RunningList 가득 찼을 때 (5개) 스크롤 동작 확인

- [ ] **타이머 생성**:
  - [ ] 모든 필드 입력하여 타이머 생성
  - [ ] 최소 필드만 입력하여 타이머 생성
  - [ ] RunningList에 타이머 표시 확인
  - [ ] 자동 스크롤 즉시 실행 확인

- [ ] **실행 중인 타이머**:
  - [ ] 여러 타이머 생성 (1-5개)
  - [ ] RunningList 섹션에 모두 표시 확인
  - [ ] 카운트다운 업데이트 확인
  - [ ] Pause/Resume 버튼 동작 확인
  - [ ] Stop 버튼 동작 확인
  - [ ] 타이머 삭제 확인

- [ ] **북마크 섹션**:
  - [ ] "북마크" 제목 표시 확인
  - [ ] 실행 중인 타이머에서 프리셋 생성 (end action: preserve)
  - [ ] 북마크 섹션에 프리셋 표시 확인
  - [ ] 프리셋 Start 버튼 → 타이머 시작 확인
  - [ ] 실행 중 표시기 오버레이 확인

- [ ] **Edit 모드**:
  - [ ] Toolbar Edit 버튼 클릭
  - [ ] Favorites 섹션에만 삭제 버튼 표시 확인
  - [ ] AddTimer 섹션 영향 없음 확인
  - [ ] RunningList 섹션 영향 없음 확인
  - [ ] 스와이프 삭제 동작 확인
  - [ ] Done 버튼 → Edit 모드 종료 확인
  - [ ] 프리셋 Edit 버튼 → EditPresetView Sheet 표시 확인
  - [ ] 변경 저장 → Sheet 닫힘 및 Edit 모드 종료 확인

- [ ] **Settings**:
  - [ ] Toolbar Settings 버튼 클릭
  - [ ] SettingsView Sheet 표시 확인
  - [ ] 설정 변경 (예: 다크 모드)
  - [ ] Sheet 닫기 → 설정 적용 확인
  - [ ] UnifiedTimerView 재빌드 확인 (`.id(colorScheme)`)

**UI/레이아웃 확인**

- [ ] **섹션 간격**:
  - [ ] AddTimer - Divider 간격: 24pt
  - [ ] Divider 표시 확인
  - [ ] RunningList - Favorites 간격: 24pt
  - [ ] 하단 여백 40pt 확인

- [ ] **섹션 배경**:
  - [ ] 모든 섹션 둥근 모서리 (12pt radius)
  - [ ] 배경색: AppTheme.contentBackground
  - [ ] 페이지 배경: AppTheme.pageBackground

- [ ] **스크롤**:
  - [ ] 최상단으로 스크롤 - AddTimer 완전히 보임
  - [ ] 중간 스크롤 - 전환 부드러움
  - [ ] 최하단으로 스크롤 - Favorites 완전히 보임
  - [ ] 스크롤 관성 자연스러움
  - [ ] 상단/하단 바운스 동작

- [ ] **동적 높이**:
  - [ ] RunningList 비어있을 때 - 최소 공간 (~100pt)
  - [ ] RunningList 1개 타이머 - 적절한 높이
  - [ ] RunningList 5개 타이머 - 모두 표시
  - [ ] Favorites 비어있을 때 - 최소 공간
  - [ ] Favorites 많은 프리셋 (10+) - 스크롤 가능

**엣지 케이스**

- [ ] **빈 상태**:
  - [ ] 모든 섹션 비어있음 - 빈 메시지 표시
  - [ ] AddTimer만 콘텐츠 있음 - 레이아웃 정상
  - [ ] RunningList만 콘텐츠 있음 - 레이아웃 정상
  - [ ] Favorites만 콘텐츠 있음 - 레이아웃 정상

- [ ] **최대 콘텐츠**:
  - [ ] 5개 타이머 + 20개 프리셋 - 모두 접근 가능
  - [ ] 스크롤 성능 저하 없음
  - [ ] 시각적 결함 없음

- [ ] **빠른 상호작용**:
  - [ ] 연속 3개 타이머 빠르게 시작 - 자동 스크롤 대기열 정상
  - [ ] Edit 모드 빠르게 토글 - 상태 손상 없음
  - [ ] 여러 프리셋 빠르게 생성/삭제 - UI 업데이트 정상

- [ ] **키보드 처리**:
  - [ ] AddTimer에서 Label 입력 포커스 - 키보드 표시
  - [ ] 필요 시 AddTimer 섹션 스크롤 확인
  - [ ] 키보드가 입력 필드를 가리지 않음
  - [ ] 키보드 닫기 - 스크롤 위치 적절히 복원

- [ ] **Alert**:
  - [ ] RunningList에서 Alert 트리거 (예: 삭제 확인)
  - [ ] Favorites에서 Alert 트리거 (예: 프리셋 숨김)
  - [ ] 한 번에 하나의 Alert만 표시
  - [ ] Alert 정상 종료

- [ ] **앱 라이프사이클**:
  - [ ] 타이머 실행 중 앱 백그라운드 → 복귀 - 상태 정상
  - [ ] 앱 종료 → 재시작 - 타이머/프리셋 유지
  - [ ] Scene Phase 변경 - Reconciliation 동작

**접근성 테스트**

- [ ] **VoiceOver**:
  - [ ] VoiceOver 활성화
  - [ ] 모든 섹션 스와이프 - 섹션 레이블 정상 읽기
  - [ ] 섹션 순서: AddTimer → RunningList → Favorites
  - [ ] AddTimer 섹션 탭 - "타이머 생성 섹션" 안내
  - [ ] RunningList 섹션 탭 - "실행 중인 타이머 섹션" 안내
  - [ ] Favorites 섹션 탭 - "북마크 섹션" 안내

- [ ] **개별 요소**:
  - [ ] 타이머 행 정확한 레이블 (기존 A11yText)
  - [ ] 버튼 정확한 레이블 (pause, play, stop 등)
  - [ ] Edit 버튼 상태 안내 (Edit/Done)
  - [ ] Settings 버튼 레이블

- [ ] **Edit 모드 + VoiceOver**:
  - [ ] Edit 모드 진입 - VoiceOver 변경 안내
  - [ ] 삭제 버튼 접근 가능
  - [ ] Edit 모드 종료 - VoiceOver 변경 안내

**성능 테스트**

- [ ] **스크롤 성능**:
  - [ ] Xcode Instruments로 스크롤 중 FPS 측정
  - [ ] 60 fps 유지 (또는 근접)
  - [ ] 자동 스크롤 중 프레임 드롭 확인

- [ ] **메모리**:
  - [ ] 최대 콘텐츠 (5 타이머 + 20 프리셋) 메모리 사용량
  - [ ] Instruments로 메모리 누수 확인

**로컬라이제이션 테스트**

- [ ] **영어 (en)**:
  - [ ] 기기 언어를 영어로 변경
  - [ ] Favorites 섹션에 "Bookmarks" 제목 확인
  - [ ] 모든 문자열 정상 표시

- [ ] **한국어 (ko)**:
  - [ ] 기기 언어를 한국어로 변경
  - [ ] Favorites 섹션에 "북마크" 제목 확인
  - [ ] 모든 문자열 정상 표시

- [ ] **텍스트 잘림**:
  - [ ] 긴 타이머 레이블 - 오버플로우 없음
  - [ ] 양쪽 언어 테스트

**기기 테스트**

- [ ] **iPhone SE (작은 화면)**:
  - [ ] 모든 섹션 적절히 표시
  - [ ] 스크롤 부드럽게 동작
  - [ ] 자동 스크롤 위치 정상

- [ ] **iPhone 15 Pro Max (큰 화면)**:
  - [ ] 레이아웃이 공간 잘 활용
  - [ ] 어색한 빈 공간 없음
  - [ ] 스크롤 동작 적절

**다크 모드 테스트**

- [ ] **라이트 모드**:
  - [ ] 모든 색상 정상
  - [ ] 텍스트 가독성
  - [ ] 섹션 시각적 구분

- [ ] **다크 모드**:
  - [ ] Settings에서 다크 모드 토글
  - [ ] UnifiedTimerView 재빌드 (`.id(colorScheme)`)
  - [ ] 모든 색상 정상
  - [ ] 텍스트 가독성
  - [ ] 섹션 시각적 구분

- [ ] **자동 모드**:
  - [ ] 시스템 외관 변경 - 앱 업데이트

**리그레션 테스트**

- [ ] **기존 기능 유지**:
  - [ ] 타이머 틱 루프 (1Hz 업데이트)
  - [ ] 알림 정상 발생
  - [ ] 타이머 완료 카운트다운 (10초)
  - [ ] 프리셋 생성/편집
  - [ ] 설정 저장
  - [ ] 모든 알람 모드 (소리, 진동, 무음)

**최종 검증**

- [ ] Unit 테스트 실행 (존재 시)
- [ ] 콘솔 에러/경고 없음
- [ ] SwiftUI 레이아웃 경고 없음
- [ ] Xcode 접근성 경고 없음
- [ ] 빌드 경고 0개
- [ ] 앱 크기 큰 증가 없음

**커밋 포인트 3**: "test: validate UnifiedTimerView functionality and UX"

**문서화**
- [ ] CLAUDE.md 업데이트:
  - [ ] MainTabView → UnifiedTimerView 참조 변경
  - [ ] ScrollView 패턴 문서화
  - [ ] 자동 스크롤 동작 설명
  - [ ] 파일 구조 섹션 업데이트
- [ ] /docs/ 폴더 관련 문서 업데이트
- [ ] UnifiedTimerView에 주요 결정 사항 주석 추가

**커밋 포인트 4**: "docs: update architecture guide for ScrollView refactoring"

---

## 구현 우선순위 요약

1. **Critical Path** (반드시 순서대로):
   - Localization 설정 → TimerInputForm → AddTimerView → RunningListView
   - FavoriteListSectionView → UnifiedTimerView → QuickLabelTimerApp
   - 초기 테스트 → 레거시 파일 아카이브

2. **Testing Focus**:
   - 자동 스크롤 동작 (가장 중요)
   - Edit 모드 동작
   - 키보드 처리
   - 성능 (List inside ScrollView)

3. **Post-Launch** (Phase 2, 필요시):
   - List → LazyVStack 교체 (성능 개선)
   - Edit 모드 스크롤 위치 추적 (UX 개선)

---

## 핵심 파일 요약

**구현에 필수적인 파일:**

1. `/Views/UnifiedTimerView.swift` (NEW) - 핵심 루트 뷰
2. `/Views/Components/FavoriteListSectionView.swift` (NEW) - Favorites 섹션 추출
3. `/QuickLabelTimerApp.swift` (MODIFY) - 루트 뷰 변경
4. `/Views/Components/Input/TimerInputForm.swift` (MODIFY) - 옵셔널 제목 지원
5. `/Localizable.xcstrings` (MODIFY) - 새 키 추가

---

## 구현 완료 기준

다음 조건이 모두 충족되면 구현 완료:
- [ ] 모든 기능 테스트 통과
- [ ] UI/UX 테스트 통과
- [ ] 접근성 테스트 통과
- [ ] 성능 기준 충족 (60 fps)
- [ ] 다국어 지원 확인
- [ ] 문서 업데이트 완료
- [ ] 빌드 경고 0개
- [ ] 리그레션 없음

---

**계획 버전**: 1.0
**작성일**: 2025-12-14
**예상 구현 시간**: 4-6시간 (테스트 포함)
