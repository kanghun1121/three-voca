# PLAN: 홈 화면 전면 리디자인

- 작업 ID: `094-feature-home-redesign`
- 생성일: 2026-08-29
- 기반 브랜치: dev
- Worktree: `.harness/worktrees/094-feature-home-redesign`
- 문제정의: `.harness/problems/094-home-redesign.md`
- 상세 플랜: `.harness/plans/crispy-fluttering-token.md` (SOLID 리뷰 반영 사항 + 오버엔지니어링 체크 포함)

---

## 목표

홈 화면을 핸드오프(`home-handoff-v4.md`) + 목업 3장(State A/B/C) 기준으로 전면 리디자인한다.
캘린더를 선택 가능한 날짜 그리드로 바꾸고(히트맵 색칠 제거), 선택 날짜에 따라
CTA(오늘) / 기록 리스트(과거) / 빈 상태(기록 없음) 3가지로 분기한다.
기존 씨앗/새싹 레벨 아코디언은 디자인 그대로 완전히 독립된 화면+ViewModel
(`LevelLibraryView`/`LevelLibraryViewModel`)로 보존하고, CTA "학습하러 가기"가 그
화면으로 진입하는 유일한 경로가 된다.

---

## 사전 검토

- [x] 현재 Home 모듈 구조 파악 완료 (Explore agent)
- [x] DesignSystem 컬러/폰트/재사용 컴포넌트 파악 완료 (Explore agent)
- [x] Session/VocabularyLibrary 도메인 모델 파악 완료
- [x] 영향받는 모듈/파일 파악 완료
- [x] SOLID 리뷰 완료 — 5개 필수 변경 사항을 플랜에 반영
- [x] 오버엔지니어링 체크 완료 — `LevelLibraryViewModel` 분리 외 신규 추상화 없음

---

## 설계 결정

- 날짜별 세션 리스트: `GetHomeOverviewUseCase`의 `SessionProgress`를 클라이언트에서 날짜별로 그룹핑 (서버 변경 없음)
- `GetHeatmapDataUseCase`/`activities`는 `HomeViewModel`에서 제거 (개수 불일치 방지, 로직 단일 소스화)
- CTA "학습하러 가기" → 독립된 `LevelLibraryView` (자체 ViewModel, 자체 `getHomeOverviewUseCase` fetch — Home과 데이터 공유/캐시 안 함)
- `HomeViewModel`은 캘린더/선택날짜/CTA/오늘의 기록만 책임. 레벨 카탈로그 상태(`expandedLevelIDs`, `levelTapped`, 레벨 화면용 `sessionTapped`)는 `HomeViewModel`에 전혀 남기지 않고 `LevelLibraryViewModel`로 전량 이관 (SOLID SRP/ISP 반영)
- `HomeDayState`는 `resolve(records:isToday:isFuture:)` 순수 정적 함수로 판정하며, **오늘 여부를 최우선으로 체크**해 "오늘+기록 0개"가 빈 상태로 새지 않게 한다 (회귀 방지)
- 캘린더 점 개수 캡(최대 3개)은 `CalendarDayCellKind.maxDotCount` 한 곳에서만 관리. 리스트(RecordRow)는 캡 없이 전체 표시
- 테스트: 이번 작업은 테스트 작성 없음 — 빌드 검증 + 시뮬레이터 육안 확인으로만 검증

---

## 체크리스트

**R7 — 토큰**
- [ ] `Line.colorset` (#70737C @ 0.16) 추가
- [ ] `HomeTypography.swift` — 핸드오프 9종 타이포 정의
- [ ] `Project.swift` Example 타겟에 `UIAppFonts` 9종 추가

**R6 — 레벨 라이브러리 완전 분리**
- [ ] 레벨 관련 12개 View/파생로직 파일을 `Sources/LevelLibrary/`로 이동
- [ ] `LevelLibraryViewModel.swift` 신규 — 독립 `@Dependency(\.getHomeOverviewUseCase)`, `state`/`isLoading`/`errorMessage`/`expandedLevelIDs`/`destination`/`load()`/`levelTapped(id:)`/`sessionTapped(id:)`
- [ ] `LevelLibraryView.swift` 신규 — 자체 `navigationDestination(item:)` 선언
- [ ] `HomeViewModel`에서 `expandedLevelIDs`/`levelTapped` 완전 삭제 (grep으로 잔존 여부 확인)
- [ ] 기존 테스트 2종(`LevelSummaryStatusTests`, `SessionProgressCellStatusTests`) import 경로 정정

**R1 — 데이터 파생**
- [ ] `DayRecord.swift` 작성
- [ ] `VocabularyLibrary+DayRecords.swift` — 날짜별 그룹핑

**R2/R3 — ViewModel + 순수 판정 함수**
- [ ] `HomeDayState.swift` — `resolve(records:isToday:isFuture:)` 정적 팩토리, `today` 우선순위 최상단 고정
- [ ] `HomeViewModel`에 `selectedDate` + `dateTapped/goToToday/ctaTapped` 추가
- [ ] `HomeViewModel.dayState`는 `HomeDayState.resolve(...)` 위임 한 줄로 구현
- [ ] `Destination.levelLibrary` 추가
- [ ] `getHeatmapDataUseCase` / `activities` 제거
- [ ] `HomeViewModelLoadTests` 수정 (heatmap 스텁 제거, `expandedLevelIDs` 관련 assertion 제거)

**R4 — 캘린더**
- [ ] `CalendarDayCellKind` 재정의 (색칠 제거, `dotCount`, `static let maxDotCount = 3`)
- [ ] `CalendarDayCell` — 46pt 셀 / 30pt 원 / 4pt 점
- [ ] `MonthlyCalendarCard` 카드 껍데기 제거
- [ ] 월 헤더 26pt + 32×32 원형 네비 버튼
- [ ] 요일 헤더 11pt/600, tracking 0.04em

**R5 — State 컨텐츠**
- [ ] `HomeTopBar.swift`
- [ ] `SelectedDateContextRow.swift`
- [ ] `StudyCTACard.swift` (그라디언트 + 글로우 3 + 글래스 버튼)
- [ ] `RecordRow.swift`
- [ ] `EmptyDayView.swift` (과거/미래 문구 분기 + pill 버튼)

**조립 및 정리**
- [ ] `HomeContentView` 전면 재구성 — `HomeDayState` 3케이스 `default:` 없이 명시 분기
- [ ] `HomeView`에 `.levelLibrary` navigationDestination 연결
- [ ] 죽은 파일 4개 삭제 (`HomeGreetingHeader`, `CalendarDayIntensity`, `CalendarLegendRow`, `LevelInfo`)

**검증**
- [ ] 빌드 성공 확인 (`FiveVoca` + `FeatureHomeExample`, 경고 0)
- [ ] 시뮬레이터에서 State A/B/C 육안 검증 (오늘 기록 0개 + CTA 유지 케이스 포함)
- [ ] `LevelLibraryView` 진입 + 세션 push 동작 확인
- [ ] 기존 Home 테스트 4종 통과 확인
- [ ] 커밋

---

## 참고: 이슈 본문 부재로 인한 가정 (A1~A8)

핸드오프/목업에 명시되지 않아 추론한 사항은 `.harness/plans/crispy-fluttering-token.md`의
"가정" 섹션에 A1~A8로 기록됨. A2는 SOLID 반영 후 "홈 자체 세션 push"와
"LevelLibrary 자체 세션 push"가 서로 독립임을 명시하도록 갱신됨. 구현 전 재확인 필요.

---

## 추가 리팩터링: HomeViewModel 캘린더 로직 걷어내기

상세 플랜: `.harness/plans/crispy-fluttering-token.md` (최신본, 이 섹션과 함께 갱신됨)

월 이동 상태의 소비처가 `MonthlyCalendarCard` 단 하나임을 추적으로 확인 → ViewModel이
캘린더를 소유할 필요 없음. 그리드 생성은 순수 함수로 extension 이동, 월 이동은 View
`@State`로 이동. 동작 변경 없음(순수 리팩터링).

- [x] `Calendar+HomeCalendarGrid.swift` 신규 — `homeMonthOffset`/`homeDisplayedMonth`/`homeMonthTitle`/`homeCalendarRows`
- [x] `HomeDayState.resolve` 시그니처 확장 (`selectedDate`/`today`/`recordsByDate`/`calendar`), 오늘 우선 판정 유지
- [x] `HomeViewModel`에서 캘린더 프로퍼티/메서드 10종 제거, `calendarToday` → `today` 개명
- [x] `dayRecordsByDate` computed → 저장 프로퍼티화, `load()`에서 갱신
- [x] `MonthlyCalendarCard`에 `@State monthOffset` 추가, 액션 로컬화, 스와이프 제스처는 유지하되 로컬 메서드 호출로 변경
- [x] `.onChange(of: viewModel.selectedDate)`로 "오늘 학습으로 이동" 시 달력이 오늘로 복귀하는 기존 동작 재구현
- [x] `CalendarHeaderRow`를 `year/month: Int` → `title: String`으로 변경
- [x] `HomeTests.swift`의 `CalendarNavigationTests`(VM 대상 3개)를 extension 순수 함수 테스트 6종(`CalendarGridTests`)으로 재작성
- [x] `tuist generate`
- [x] 빌드 성공 확인 (`FiveVoca` + `FeatureHomeExample`, 경고 0)
- [x] `FeatureHome` 테스트 전체 통과 (17개 전부 통과)
