# PLAN: HomeViewModel에서 캘린더 생성 로직 걷어내기

- 작업 ID: `094-feature-home-redesign`
- 기반 브랜치: dev
- Worktree: `.harness/worktrees/094-feature-home-redesign`
- 유형: refactor (동작 변경 없음)

---

## Context

홈 리디자인 구현 결과, `HomeViewModel`이 두 종류의 일을 같이 하고 있다.

1. **화면 상태와 액션** — 데이터 로드, 선택 날짜, 네비게이션 목적지
2. **캘린더 그리드 생성** — 월 오프셋 산술, 42칸 날짜 배열 조립, 주 단위 청킹, 점 개수 캡

2번은 입력이 정해지면 출력이 결정되는 순수 계산이고, 결과를 소비하는 곳도 한 군데뿐이다.
ViewModel이 이걸 들고 있을 이유가 있는지 실제 소비처를 추적해 확인했다.

| 상태 | 소비처 | 판정 |
|---|---|---|
| `calendarMonthOffset` 계열 (`calendarDisplayedDate`/`Year`/`Month`/`isCalendarAtCurrentMonth`/`calendarRows`/`calendarPreviousMonth`·`calendarNextMonth`·`calendarGoToToday`) | **`MonthlyCalendarCard` 단 하나** | 화면 로컬 내비게이션 상태 → View `@State`로 내린다 |
| `selectedDate`, `isSelectedDateToday`, `dayState` | `MonthlyCalendarCard`(선택 하이라이트) + `HomeContentView`(컨텍스트 행, 기록 목록) | 형제 뷰 공유 상태 → **VM에 남긴다** |
| `today`(현 `calendarToday`), `state`→`dayRecords` | 달력 점 + `dayState` 양쪽 | VM에 남긴다 (테스트 주입 지점) |

결론: ViewModel은 캘린더를 소유할 필요가 없다. 월 이동은 View가 갖고, 그리드 생성은
`FeatureHome` 내부 `Calendar` extension의 순수 함수로 옮긴다. 선택 날짜만 공유 상태로 VM에 남긴다.

기대 결과: `HomeViewModel`은 로드 / 선택 / 네비게이션만 남고, 캘린더 산술은 테스트 가능한
순수 함수가 된다. **화면 동작은 현재와 완전히 동일해야 한다.**

---

## 확정된 결정사항

- 월 이동 상한 가드(미래 달 차단)는 View에 흩뿌리지 않고 extension 순수 함수로 뽑는다.
  기존 `CalendarNavigationTests` 3개는 그 순수 함수 테스트로 재작성한다. (사용자 결정)
- 새 타입(구조체/프로토콜/전략)은 도입하지 않는다. 기존 타입의 extension과 시그니처 변경만 사용한다.
- extension 파일은 `Projects/Feature/Home/Sources/Home/` 안에 평평하게 두고 `Type+Purpose.swift`
  네이밍을 따른다 (레포 기존 관습: `WordDetail+DefinitionGrouping.swift`, `VocabularyLibrary+DayRecords.swift`).
  별도 `Extensions/` 폴더는 만들지 않는다 — 레포에 그런 폴더가 없다.
- `Project.swift`는 손대지 않는다. 소스 glob이 `Sources/**`라 새 파일은 자동 포함된다.

### 범위에서 제외한 것 (판단 근거)

- **`CalendarWeekRow.resolveCellKind` / `isTappable` 이동** — 제외. `CalendarDay` → `CalendarDayCellKind`
  매핑은 렌더링 분기 그 자체이고 이미 View 로컬 private 함수다. 파일만 하나 늘고 얻는 게 없다.
- **`RecordRow`의 행마다 `DateFormatter` 생성** — 제외. 실제 개선 여지는 있지만 캘린더 로직
  분리라는 이번 주제 밖이다. 별도 건으로 남긴다.

---

## 책임 분해

| # | 책임 | 위치 | 테스트 |
|---|---|---|---|
| R1 | 월 오프셋 이동 + 상한 가드 | `Calendar+HomeCalendarGrid.swift` (신규) | 테스트 필요 |
| R2 | 표시 월 산출 + 월 타이틀 문자열 | 동일 파일 | 테스트 필요 |
| R3 | 월간 날짜 그리드 조립 (`[[CalendarDay]]`) | 동일 파일 | 테스트 필요 |
| R4 | 선택 날짜 → 화면 상태 판정 | `HomeDayState.resolve` 시그니처 확장 | 테스트 불필요 (기존 로직 이동만) |
| R5 | 월 이동 상태 소유 + 달력 조립 | `MonthlyCalendarCard` (`@State`) | 테스트 불필요 (빌드 검증) |
| R6 | 로드 / 선택 날짜 / 네비게이션 | `HomeViewModel` (축소) | 기존 `HomeViewModelLoadTests` 유지 |

---

## 변경 내용

### 1. `Sources/Home/Calendar+HomeCalendarGrid.swift` (신규)

기존 `Calendar+MonthlyCalendar.swift`의 `monthlyCalendarPeriod(for:)`를 **그대로 재사용**한다
(수정하지 않는다). 새 파일은 그 위에 얹는 그리드 생성 계층이다.

```swift
extension Calendar {
    /// 현재 달(offset 0)을 상한으로 월 오프셋을 이동시킨다.
    func homeMonthOffset(_ offset: Int, movedBy delta: Int) -> Int

    /// 오늘 기준 offset만큼 이동한 표시 월의 대표 날짜
    func homeDisplayedMonth(today: Date, offset: Int) -> Date

    /// "2026년 8월" 형태의 헤더 타이틀
    func homeMonthTitle(for date: Date) -> String

    /// 표시 월의 캘린더 그리드를 주 단위로 조립한다.
    /// `HomeViewModel.calendarRows` + `calendarDays(for:)`의 본문을 그대로 옮긴 것.
    func homeCalendarRows(
        displayedMonth: Date,
        today: Date,
        selectedDate: Date,
        recordsByDate: [Date: [DayRecord]]
    ) -> [[CalendarDay]]
}
```

`homeCalendarRows`는 현재 `HomeViewModel.calendarDays(for:)`의 로직(현재 월 판정, `isToday`,
`isFuture`, `isSelected`, `min(recordCount, CalendarDayCellKind.maxDotCount)`)과 `calendarRows`의
`stride` 청킹을 합친 것이다. 계산 규칙은 한 줄도 바꾸지 않는다.

### 2. `Sources/Home/HomeViewModel.swift` (축소)

제거: `calendarMonthOffset`, `calendarDisplayedDate`, `calendarYear`, `calendarMonth`,
`isCalendarAtCurrentMonth`, `calendarRows`, `calendarDays(for:)`, `calendarPreviousMonth()`,
`calendarNextMonth()`, `calendarGoToToday()`

변경:
- `calendarToday` → `today`로 개명. 더 이상 캘린더 소유 상태가 아니라 "오늘/과거/미래 판정 기준"이다.
  `init(destination:today:)`로 파라미터명도 함께 변경.
- `dayRecordsByDate`를 computed → `private(set)` 저장 프로퍼티로 변경하고 `load()` 성공 시
  `state`와 함께 갱신한다. 지금은 접근할 때마다 전체 세션을 다시 그룹핑하는데, 그리드 생성이
  extension으로 나가면 이 값이 인자로 매 렌더 전달되므로 재계산이 그대로 노출된다.
- `selectToday()`는 `selectedDate = today`만 한다 (월 오프셋을 더 이상 건드리지 않는다).

남는 것: `state`, `isLoading`, `errorMessage`, `selectedDate`, `today`, `dayRecordsByDate`,
`dayState`, `isSelectedDateToday`, `destination`, `load()`, `dateTapped(_:)`, `selectToday()`,
`ctaTapped()`, `sessionTapped(id:)`

### 3. `Sources/Home/HomeDayState.swift`

`resolve`가 날짜 비교와 레코드 조회까지 맡아 VM에서 `startOfDay` 산술을 없앤다.

```swift
static func resolve(
    selectedDate: Date,
    today: Date,
    recordsByDate: [Date: [DayRecord]],
    calendar: Calendar
) -> HomeDayState
```

**우선순위는 반드시 유지한다**: `isToday`를 최우선으로 판정해 오늘 기록이 0개여도 `.today`를
반환해야 한다(핸드오프 §5, CTA 노출). 기존 파일의 해당 주석도 함께 옮긴다.

### 4. `Sources/Home/Components/MonthlyCalendarCard.swift`

- `@State private var monthOffset = 0` 추가 — 월 이동 상태의 새 소유자
- `displayedMonth` / `title` / `rows`를 `Calendar.current`의 새 extension으로 계산
- 이전/다음/오늘 액션을 로컬 메서드로 구현 (`monthOffset = cal.homeMonthOffset(monthOffset, movedBy:)`,
  `monthOffset = 0`)
- **기존 스와이프 제스처(`simultaneousGesture` + 축 우세 판정)는 그대로 유지**하고 호출 대상만
  로컬 메서드로 바꾼다
- `.onChange(of: viewModel.selectedDate)` 추가: 선택 날짜가 오늘이면 `monthOffset = 0`.
  `EmptyDayView`의 "오늘 학습으로 이동"(`viewModel.selectToday`)이 과거 달을 보던 중에도 달력을
  현재 달로 되돌리던 기존 동작을 단방향(달력이 선택 날짜를 따라감)으로 대체한다.

### 5. `Sources/Home/Components/CalendarHeaderRow.swift`

`year: Int, month: Int` → `title: String`으로 교체. View에서 `cal.component(.year/.month, ...)`
호출이 사라진다. 나머지(`.frame(minHeight: 44)` 정렬 고정, `CalendarNavButtons` 배선)는 그대로.

### 6. `Tests/HomeTests.swift` (재작성)

`CalendarNavigationTests`(VM 대상 3개)를 제거하고 extension 순수 함수 테스트로 대체한다.
`CalendarDay`와 extension 모두 internal이라 `@testable import FeatureHome`으로 접근 가능하다.

- R1: `homeMonthOffset(0, movedBy: 1) == 0` — 현재 달에서 미래 달 이동 차단 (회귀 방지 핵심)
- R1: `homeMonthOffset(0, movedBy: -1) == -1`, `homeMonthOffset(-1, movedBy: 1) == 0` — 왕복
- R2: `today = 2026-06-01`, `offset = -1` → `homeMonthTitle == "2026년 5월"`
  (기존 `calendarYear == 2026 && calendarMonth == 5` 검증을 대체)
- R3: 모든 행이 7칸이고 행 수가 5 이상 — 그리드 형태 불변식
- R3: `recordsByDate`에 4건을 넣은 날의 `dotCount == CalendarDayCellKind.maxDotCount` — 점 캡
- R3: 선택 날짜 셀만 `isSelected == true`

`HomeViewModelLoadTests`, `LevelSummaryStatusTests`, `SessionProgressCellStatusTests`는 손대지 않는다.

---

## 구현 순서

1. `.harness/exec-plans/active/094-feature-home-redesign/PLAN.md`에 아래 체크리스트 반영
2. `Calendar+HomeCalendarGrid.swift` 작성 (VM 로직을 그대로 이식)
3. `HomeDayState.resolve` 시그니처 확장
4. `HomeViewModel` 축소 (`today` 개명, `dayRecordsByDate` 저장 프로퍼티화 포함)
5. `MonthlyCalendarCard` + `CalendarHeaderRow` 배선 변경
6. `HomeTests.swift` 재작성
7. `tuist generate` (신규 파일 반영)
8. 빌드/테스트 검증

---

## 체크리스트

- [ ] exec-plan PLAN.md에 체크리스트 반영
- [ ] R1: `homeMonthOffset(_:movedBy:)` 작성
- [ ] R2: `homeDisplayedMonth(today:offset:)` / `homeMonthTitle(for:)` 작성
- [ ] R3: `homeCalendarRows(displayedMonth:today:selectedDate:recordsByDate:)` 작성
- [ ] R4: `HomeDayState.resolve` 시그니처 확장 (오늘 우선 판정 유지)
- [ ] R6: `HomeViewModel`에서 캘린더 프로퍼티/메서드 10종 제거
- [ ] R6: `calendarToday` → `today` 개명
- [ ] R6: `dayRecordsByDate` 저장 프로퍼티화 + `load()`에서 갱신
- [ ] R5: `MonthlyCalendarCard` `@State monthOffset` + 액션 + `.onChange` 배선
- [ ] R5: 스와이프 제스처가 로컬 메서드를 호출하도록 유지
- [ ] R5: `CalendarHeaderRow`를 `title: String`으로 변경
- [ ] R1~R3 테스트 6종 작성 (`HomeTests.swift` 재작성)
- [ ] `tuist generate` 실행
- [ ] **빌드 성공 확인** (`FiveVoca`, `FeatureHomeExample` — 경고 0)
- [ ] `FeatureHome` 테스트 전체 통과

---

## 검증

1. `tuist generate` 후 `FiveVoca` 스킴 빌드 — 경고 0
2. `FeatureHomeExample` 스킴 빌드 — 경고 0
3. `FeatureHome` 테스트 실행 — 재작성한 그리드 테스트 6종 + 기존 로드/레벨 테스트 전부 통과
4. `FeatureHomeExample`을 시뮬레이터에서 실행하고 스크린샷으로 회귀 확인:
   - 오늘 날짜가 선택된 초기 상태 (CTA + 오늘 기록)
   - 월 타이틀의 세로 위치가 이전/현재 달에서 동일 (직전 작업에서 고친 정렬 유지)
   - 점 개수 ≤ 3, 기록 목록 개수와 일치
5. 인터랙션(날짜 탭, 이전/다음 달, 스와이프, "오늘 학습으로 이동")은 이 환경에 UI 자동화
   도구가 없어 직접 재현이 불가하다. 코드 검증 후 사용자 확인이 필요한 항목으로 보고한다.

---

## 가정

- A1. 화면 동작은 변경하지 않는다. 리팩터링 전후 렌더 결과가 동일해야 한다.
- A2. "오늘 학습으로 이동" 시 달력이 현재 달로 돌아가는 동작은 유지 대상이다
  (`.onChange` 방식으로 재구현).
- A3. `HomeViewModel(calendarToday:)`의 개명은 외부 모듈에 영향이 없다. 호출처는
  `HomeTests.swift` 한 곳뿐임을 확인했다 (`Projects/App`, Example 앱은 기본 이니셜라이저 사용).
