# Localization Work Tracking

**목적:** 모든 하드코딩된 한국어 문자열을 키 기반 구조로 변환하고 영어 번역 추가

**생성일:** 2025-01-09
**상태:** 진행 중

---

## 📊 전체 요약

| 카테고리 | 하드코딩 개수 | 상태 |
|---------|------------|------|
| Settings 화면 | 20+ | ⏳ 대기 |
| Timer 입력/편집 | 8+ | ⏳ 대기 |
| Alert/Dialog | 12+ | ⏳ 대기 |
| Help 화면 | 15+ | ⏳ 대기 |
| ViewModel | 6 | ⏳ 대기 |
| **총계** | **60+** | - |

---

## 📝 상세 목록

### 1. Settings View (SettingsView.swift)

**파일:** `Views/Settings/SettingsView.swift`

| 라인 | 현재 (한국어) | 제안 키 | 영어 번역 | 비고 |
|-----|-------------|---------|---------|------|
| 36 | `"알림 설정"` | `ui.settings.notificationSection` | `"Notification Settings"` | Section header |
| 37 | `"기본 사운드"` | `ui.settings.defaultSound` | `"Default Sound"` | NavigationLink |
| 40 | `"기본 알림 방식"` | `ui.settings.defaultAlarmMode` | `"Default Alarm Mode"` | NavigationLink |
| 44 | `"다크 모드"` | `ui.settings.darkMode` | `"Dark Mode"` | Toggle |
| 48 | `"알림 권한"` | `ui.settings.permissionSection` | `"Notification Permission"` | Section header |
| 50 | `"현재 상태"` | `ui.settings.currentStatus` | `"Current Status"` | Label |
| 56 | `"설정에서 알림 허용하기"` | `ui.settings.enableNotifications` | `"Enable Notifications in Settings"` | Button |
| 63 | `"지원"` | `ui.settings.supportSection` | `"Support"` | Section header |
| 70 | `"소리가 안 들려요"` | `ui.settings.soundHelp` | `"Can't Hear Sound"` | NavigationLink |
| 80 | `"진동이 안 울려요"` | `ui.settings.vibrationHelp` | `"Vibration Not Working"` | NavigationLink |
| 84 | `"문의하기"` | `ui.settings.contact` | `"Contact Us"` | Link |
| 88 | `"개인정보 처리방침"` | `ui.settings.privacyPolicyKo` | `"Privacy Policy"` | Link (Korean) |
| 91 | `"Privacy Policy"` | `ui.settings.privacyPolicyEn` | `"Privacy Policy"` | Link (English) |
| 96 | `"설정"` | `ui.settings.title` | `"Settings"` | navigationTitle |
| 99 | `"Quick Label Timer"` | `ui.common.appName` | `"Quick Label Timer"` | App name |

---

### 2. Settings Sub-views

#### SoundPickerView.swift
| 라인 | 현재 | 제안 키 | 영어 번역 |
|-----|------|---------|---------|
| 43 | `"기본 사운드"` | `ui.settings.defaultSound` | `"Default Sound"` |

#### AlarmModePickerView.swift
| 라인 | 현재 | 제안 키 | 영어 번역 |
|-----|------|---------|---------|
| 51 | `"기본 알림 방식"` | `ui.settings.defaultAlarmMode` | `"Default Alarm Mode"` |

---

### 3. Help Views

#### SoundHelpView.swift
**파일:** `Views/Settings/Help/SoundHelpView.swift`

| 라인 | 현재 | 제안 키 | 영어 번역 |
|-----|------|---------|---------|
| 22 | `"기본 점검 항목"` | `ui.help.basicChecklist` | `"Basic Checklist"` |
| 27 | `"시스템 설정 확인"` | `ui.help.systemSettings` | `"Check System Settings"` |
| 30 | `"알림 설정 열기"` | `ui.help.openNotificationSettings` | `"Open Notification Settings"` |
| 40 | `"집중 모드 확인"` | `ui.help.focusModeCheck` | `"Check Focus Mode"` |
| 44 | `"Apple Watch 사용자"` | `ui.help.appleWatchUsers` | `"Apple Watch Users"` |
| 49 | `"알림 소리가 나지 않나요?"` | `ui.help.soundIssueTitle` | `"Not Hearing Notification Sound?"` |

**내용 문자열 (긴 텍스트):**
- 각 섹션의 설명 텍스트들도 별도 키로 변환 필요
- 예: `ui.help.soundMuteCheckText`, `ui.help.volumeCheckText` 등

#### VibrationHelpView.swift
**파일:** `Views/Settings/Help/VibrationHelpView.swift`

| 라인 | 현재 | 제안 키 | 영어 번역 |
|-----|------|---------|---------|
| 21 | `"시스템 설정 확인"` | `ui.help.systemSettings` | `"Check System Settings"` |
| 31 | `"집중 모드 확인"` | `ui.help.focusModeCheck` | `"Check Focus Mode"` |
| 35 | `"Apple Watch 사용자"` | `ui.help.appleWatchUsers` | `"Apple Watch Users"` |
| 41 | `"진동 문제 해결"` | `ui.help.vibrationIssueTitle` | `"Troubleshoot Vibration"` |

---

### 4. Timer Views

#### EditPresetView.swift
| 라인 | 현재 | 제안 키 | 영어 번역 |
|-----|------|---------|---------|
| 66 | `"타이머 수정"` | `ui.editPreset.title` | `"Edit Timer"` |

#### TimerView.swift
| 라인 | 현재 | 제안 키 | 영어 번역 |
|-----|------|---------|---------|
| 37 | `"타이머 실행"` | `ui.timer.title` | `"Timer"` |

#### FavoriteListView.swift
| 라인 | 현재 | 제안 키 | 영어 번역 |
|-----|------|---------|---------|
| 60 | `"«« 실행 중"` | `ui.favorite.runningIndicator` | `"«« Running"` |
| 78 | `"즐겨찾기"` | `ui.favorite.title` | `"Favorites"` |

---

### 5. Input Components

#### LabelInputField.swift
| 라인 | 현재 | 제안 키 | 영어 번역 |
|-----|------|---------|---------|
| 24 | `"라벨"` | `ui.input.labelField` | `"Label"` |

#### TimePickerGroup.swift
| 라인 | 현재 | 제안 키 | 영어 번역 |
|-----|------|---------|---------|
| 26 | `"시간"` | `ui.input.hours` | `"Hours"` |
| 36 | `"분"` | `ui.input.minutes` | `"Minutes"` |
| 46 | `"초"` | `ui.input.seconds` | `"Seconds"` |

#### TimerInputForm.swift
| 라인 | 현재 | 제안 키 | 영어 번역 |
|-----|------|---------|---------|
| 33, 76 | `"+5분"` | `ui.input.add5Minutes` | `"+5 min"` |

---

### 6. Alert Messages (AppAlert.swift)

**파일:** `Views/Components/Common/AppAlert.swift`

| 라인 | 현재 | 제안 키 | 영어 번역 | 비고 |
|-----|------|---------|---------|------|
| 40 | `"실행 불가"` | `ui.alert.cannotRunTitle` | `"Cannot Run"` | Title |
| 41 | `"타이머는 최대 \(AppConfig.maxConcurrentTimers)개까지 실행할 수 있습니다."` | `ui.alert.maxTimersMessage` | `"You can run up to %lld timers."` | 동적 문자열 |
| 42 | `"확인"` | `ui.alert.ok` | `"OK"` | Button |
| 46 | `"저장 불가"` | `ui.alert.cannotSaveTitle` | `"Cannot Save"` | Title |
| 47 | `"즐겨찾기는 최대 20개까지 추가할 수 있습니다."` | `ui.alert.maxFavoritesMessage` | `"You can add up to 20 favorites."` | Message |
| 52 | `"삭제 불가"` | `ui.alert.cannotDeleteTitle` | `"Cannot Delete"` | Title |
| 53 | `"실행 중인 타이머는 삭제할 수 없습니다."` | `ui.alert.cannotDeleteRunningMessage` | `"Cannot delete a running timer."` | Message |
| 59 | `"이 타이머를 삭제하시겠습니까?"` | `ui.alert.deleteConfirmMessage` | `"Do you want to delete this timer?"` | Message |
| 60 | `"삭제"` | `ui.alert.delete` | `"Delete"` | Button |
| 61 | `"취소"` | `ui.alert.cancel` | `"Cancel"` | Button |

---

### 7. ViewModel Strings

#### SettingsViewModel.swift

**파일:** `ViewModels/SettingsViewModel.swift`

| 라인 | 현재 | 제안 키 | 영어 번역 | 비고 |
|-----|------|---------|---------|------|
| 31 | `"허용됨"` | `ui.settings.statusAuthorized` | `"Authorized"` | 알림 권한 상태 |
| 32 | `"거부됨"` | `ui.settings.statusDenied` | `"Denied"` | 알림 권한 상태 |
| 33 | `"미요청"` | `ui.settings.statusNotDetermined` | `"Not Requested"` | 알림 권한 상태 |
| 34 | `"임시 허용"` | `ui.settings.statusProvisional` | `"Provisional"` | 알림 권한 상태 |
| 35 | `"일시적 세션"` | `ui.settings.statusEphemeral` | `"Ephemeral"` | 알림 권한 상태 |
| 36 | `"알 수 없음"` | `ui.settings.statusUnknown` | `"Unknown"` | 알림 권한 상태 |

---

## 🎯 작업 우선순위

### Phase 1: 독립적인 화면 (추천 순서)
1. **Settings View** (SettingsView.swift + sub-views)
   - 가장 많은 하드코딩 (20+ 문자열)
   - 독립적이라 다른 화면에 영향 없음
   - 완료 시 즉시 효과 확인 가능

2. **Help Views** (SoundHelpView, VibrationHelpView)
   - Settings의 일부
   - 긴 설명 텍스트 많음
   - 독립적

### Phase 2: 공통 컴포넌트
3. **Alert Messages** (AppAlert.swift)
   - 앱 전체에서 사용
   - 동적 문자열 포함

4. **Input Components** (LabelInputField, TimePickerGroup, TimerInputForm)
   - Timer와 Preset 화면에서 공유

### Phase 3: 메인 화면
5. **Timer Views** (TimerView, EditPresetView)
   - 상대적으로 적은 하드코딩

6. **Favorite View** (FavoriteListView)
   - 마지막

### Phase 4: ViewModel
7. **SettingsViewModel**
   - 알림 권한 상태 문자열

---

## 📌 특별히 주의할 사항

### 1. 동적 문자열 (String Interpolation)

**A11yText.swift에 이미 구현된 패턴 따르기:**
```swift
// 현재 (AppAlert.swift:41)
"타이머는 최대 \(AppConfig.maxConcurrentTimers)개까지 실행할 수 있습니다."

// 변경 후
LocalizedStringKey("타이머는 최대 \(AppConfig.maxConcurrentTimers)개까지 실행할 수 있습니다.")

// Localizable.xcstrings
{
  "타이머는 최대 %lld개까지 실행할 수 있습니다.": {
    "en": "You can run up to %lld timers.",
    "ko": "타이머는 최대 %lld개까지 실행할 수 있습니다."
  }
}
```

### 2. 긴 텍스트 (Help 화면)

**Markdown 형식 유지:**
```swift
// 현재
Text(.init("**설정 > 알림 > 퀵라벨타이머**로 이동해..."))

// 변경 후
Text(.init("ui.help.notificationPathText"))

// Localizable.xcstrings
{
  "ui.help.notificationPathText": {
    "en": "Go to **Settings > Notifications > QuickLabelTimer**...",
    "ko": "**설정 > 알림 > 퀵라벨타이머**로 이동해..."
  }
}
```

### 3. 언어별 분기 제거

**현재 (SettingsView.swift:87-92):**
```swift
if languageCode == "ko" {
    Link("개인정보 처리방침", destination: privacyPolicyURL)
} else {
    Link("Privacy Policy", destination: privacyPolicyURL_en)
}
```

**변경 후:**
```swift
Link("ui.settings.privacyPolicy", destination: privacyPolicyURL)

// 시스템이 자동으로 언어에 맞는 문자열 선택
```

---

## ✅ 완료된 작업

### Accessibility Strings
- ✅ 모든 a11y.* 키로 변환 완료
- ✅ 한국어/영어 번역 완료
- ✅ `A11yText` enum으로 구조화 완료

---

## 🔄 진행 중

**현재:** 전수 조사 완료, 문서화 완료

**다음:** Commit 2 - Settings View 리팩토링 시작

---

## 📁 키 네이밍 규칙

### 확정된 규칙:
```
ui.{screen}.{element}        - UI 텍스트
a11y.{context}.{element}     - 접근성 (이미 완료)
```

### 예시:
- `ui.settings.title` - 설정 화면 제목
- `ui.settings.notificationSection` - 설정 화면의 알림 설정 섹션
- `ui.alert.ok` - Alert의 확인 버튼
- `ui.input.labelField` - 입력 폼의 라벨 필드
- `ui.common.appName` - 앱 이름 (여러 곳에서 사용)

---

**마지막 업데이트:** 2025-01-09
