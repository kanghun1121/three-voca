# 문제정의: Presentation 모델 계층 제거

- 이슈: #91 "모델링"
- 작업 ID: `091-refactor-3layer-model-redesign`
- 작성일: 2026-08-27

## 현상

현재 데이터는 3단계로 표현된다.

1. **DTO** — `Projects/Data/Sources/**/*ResponseDTO.swift`
2. **Domain Entity** — `Projects/Domain/Interface/Model/*.swift`
   (`WordDetail`, `Session`, `VocabularyLibrary`, `DailyActivity`, `AuthToken`)
3. **Presentation Model** — `Projects/Feature/**` 아래 12개 파일
   - PM 정의 7개: `HomePresentationModel`, `LevelCardPresentationModel`,
     `SessionRowPresentationModel`, `SessionDetailPresentationModel`,
     `VocabularyListPresentationModel`, `WordDetailPresentationModel`,
     `ChunkReaderPresentationModel`
   - Entity→PM 매핑 extension 4개: `VocabularyLibrary+PresentationModel.swift`,
     `Session+PresentationModel.swift`(Session/SessionDetail용, Vocabulary/VocabularyList용 2개),
     `WordDetail+PresentationModel.swift`
   - 이름만 다른 동일 역할 1개: `Projects/Feature/WordGame/Sources/Shared/GameWord.swift`
     (`Session.Word` → 평탄화 변환, PM과 동일 패턴)

## 문제

> DTO-Entity-Presentation 모델링이 너무 과하다. Entity로부터 적절히 데이터를 가공해서 쓰는데
> Presentation 모델이 너무 크다. Entity로부터 적절히 가공해서 ViewModel에서 그냥 써도 될 것
> 같다. 그런 이유에서 Presentation 모델은 지운다. (사용자 진술)

코드 조사 결과 이 판단은 다음 근거로 뒷받침된다.

**PM의 원래 존재 명분이 이미 대부분 무너져 있다.**

- UI 리소스(색·아이콘) 매핑이 PM에 없다. PM 파일 11개 중 `import DesignSystem`은 0개.
  매핑은 전부 View extension에 있다 —
  `Projects/Feature/Home/Sources/Home/Components/LevelCardHeader.swift:42-60`,
  `.../Components/SessionCell.swift:16-37`, `.../Components/CalendarDayIntensity.swift:8-22`.
- 실제 문자열 포맷팅도 PM에 없다. `SessionDetailPresentationModel.Record.firstCompletedDateText`는
  이름만 Text이고 값은 Entity의 `firstCompletedAt: String`을 그대로 통과시킨다
  (DTO 매핑 `Projects/Data/Sources/Session/SessionDetailResponseDTO+Mapping.swift:41-46`도
  포맷 없이 통과). 실제 조립은 View가 한다 —
  `.../Components/RecordCard.swift:33`(`"\(studyCount)회"`),
  `.../Components/SessionHeaderSection.swift:13-19`.
  과거 커밋 `ac3388d`("PresentationModel에서 UI 문구 분리")가 이 방향을 이미 확정했다.
- `Identifiable` 부여 목적도 대부분 중복이다. `Session.Word`, `SessionProgress`,
  `LevelSummary`는 이미 Domain에서 `Identifiable`이다.
- 여러 Entity를 조합하는 PM은 하나도 없다. 전부 1:1 변환이며, 유일한 조합 지점인
  `HomeViewModel`조차 `state`(PM)와 `activities`(Entity) 두 프로퍼티로 쪼개 들고 있어
  PM이 조합 역할을 하지 못한다 (`HomeViewModel.swift:12-13`).

**오히려 PM이 새 문제를 만들고 있다.**

- 계층 경계가 이미 샌다. `WordDetailPresentationModel.swift:17-18`이
  `chunks: [WordDetail.Example.Chunk]?`, `words: [...Word]?`로 Domain 타입을 그대로 품고
  `import DomainInterface`를 한다. `WordDetailViewModel.swift:46-49`는 PM에서 그 Domain
  값을 다시 꺼내 `ChunkReaderViewModel`에 넘긴다.
- 정보 손실 사본이다. `SessionDetailViewModel.swift:41-45`는 PM에 `audioUrl`이 없어서
  변환 후에도 원본 `session`을 따로 붙들고 있다. `VocabularyListViewModel.swift:36-40`도 동일.
- 타입 왕복 낭비다. `SessionRowPresentationModel.id: Int`는 `SessionProgress.id: String`을
  `Int(session.id) ?? 0`으로 뭉갠 뒤(`VocabularyLibrary+PresentationModel.swift:51`),
  `HomeViewModel.swift:114-116`에서 `String(id)`로 되돌린다. 파싱 실패 시 0으로 무너진다.
- 3중 중복이다. `Session.Word` → `WordPreview` / `WordRow` / `GameWord` 세 타입이
  `definitions.first?.meaning` 평탄화만 반복한다.
- 계층 적용이 일관되지도 않다. `DailyActivity`는 PM이 아예 없어 View가 Entity를 직접
  순회하고(`Components/MonthlyCalendarCard.swift:9-19`), `AuthToken`은 Feature 소비처가
  0건이다.

## 목표

Entity → PresentationModel 변환 계층을 제거하고, ViewModel이 Entity를 직접 가공해
보유하도록 한다. **DTO → Entity 변환은 그대로 유지한다** — 이번 작업은 Entity 이후
단계만 대상으로 한다.

## 범위

- **포함 (12개 파일과 그 소비처)**
  - PM 정의 7개, 매핑 extension 4개, `GameWord.swift` 1개
  - 소비처: ViewModel 5개(`HomeViewModel`, `SessionDetailViewModel`,
    `VocabularyListViewModel`, `WordDetailViewModel`, `ChunkReaderViewModel`)와
    WordGame 계열 ViewModel(`WordGameViewModel`, `MultipleChoiceViewModel`,
    `RecognitionViewModel`, `SpellingViewModel`), View 약 20개
- **제외**
  - DTO ↔ Entity 매핑 (`*ResponseDTO+Mapping.swift`)
  - Repository/UseCase 시그니처
  - DesignSystem 매핑을 담당하는 View extension (`LevelStatus`/`SessionCellStatus`의
    색·아이콘 분기) — 이미 올바른 위치에 있으므로 손대지 않는다

## 보존해야 할 동작

PM 제거 후에도 아래 5가지는 사라지면 안 된다. **이전할 위치(ViewModel computed property인지
Entity extension인지)는 이 문서에서 정하지 않는다** — harness-plan에서 결정한다.

1. 품사별 정의 그룹핑 — `WordDetail+PresentationModel.swift:25-48`
2. 품사 한글 라벨 (2개의 서로 다른 매핑 테이블) —
   `WordDetail+PresentationModel.swift:51-64`(enum 기반, `.noun`→"명사")과
   `ChunkReaderPresentationModel.swift:44-57`(문자열 코드 기반, `"n"`→"명사").
   입력 타입이 달라 갈라져 있으며 통합 여부도 harness-plan에서 판단한다.
3. `LevelStatus` 파생 규칙 — `VocabularyLibrary+PresentationModel.swift:15-22`
4. `SessionCellStatus`의 "완료되지 않은 첫 세션 = current" 순번 의존 규칙 —
   `VocabularyLibrary+PresentationModel.swift:38-55`. `map` 내부 가변 상태
   (`currentAssigned`)를 쓰므로 단순 computed property로 표현하기 가장 까다로운 로직이다.
5. `ChunkReader`의 index 기반 `id` 부여 — Domain `Chunk`/`Word`에 id가 없어 필요
   (`ChunkReaderPresentationModel.swift:24-38`)

## 제약

- 3-Layer MicroFeature 모듈 구조(Domain/Data/Feature 모듈 분리)는 유지한다.
- `ViewModel은 Repository가 아닌 UseCase만 @Dependency로 주입받는다` 규칙을 유지한다
  (`docs/ARCHITECTURE.md:36-37`).
- Domain Entity에 UI 관심사(색·아이콘·문구)를 넣지 않는다.
- **리팩터링 전 특성화 테스트로 안전망을 먼저 확보한다.** 현재 PM 타입을 직접 참조하는
  테스트는 0건이며(`grep "PresentationModel" Projects/Feature/*/Tests/`), 단
  `pm.wordCount`(`VocabularyListViewModelTests.swift:35-42`),
  `pm.definitionGroups.count`(`WordDetailViewModelTests.swift:18-25`) 등 필드 어서션은
  존재해 PM 제거 시 재설계가 필요하다.
- `docs/ARCHITECTURE.md:59-100`의 3-Layer 데이터 모델 절이 아직 옛 이름 `ViewState`를
  쓰고 있어 코드와 불일치한다. 이번 작업에서 함께 갱신한다.

## 완료 조건 (1단계 — PM 제거)

- 위 12개 PM/매핑 파일이 삭제되고, ViewModel이 Entity를 직접 가공해 View에 넘긴다.
- 보존 대상 5가지 동작이 모두 유지된다(테스트로 확인).
- AllTest 스킴이 통과한다.
- `docs/ARCHITECTURE.md`가 현재 구조(DTO → Entity → ViewModel 가공)를 정확히 설명한다.

**1단계 완료됨 (2026-08-27).** AllTest 71개 테스트 통과, `FiveVoca` 앱 스킴 빌드 성공.

---

## 2단계 — Domain Entity 자체 정리 (PartOfSpeech 중복 제거)

1단계 완료 후 사용자가 "현재 모델이 난잡하다"고 지적했고, 확인 결과 Domain Entity 레벨에서
**품사(PartOfSpeech) 표현이 세 갈래로 흩어져 있다.**

### 현상 (근거)

- `WordDetail.Definition.PartOfSpeech`(`Projects/Domain/Interface/Model/WordDetail.swift:5-15`)와
  `Session.Word.Definition.PartOfSpeech`(`Projects/Domain/Interface/Model/Session.swift:4-14`)가
  **완전히 동일한 9개 case**(noun/verb/adjective/adverb/preposition/conjunction/interjection/
  pronoun/unknown)를 가진 `String` raw-value enum으로 **각자 따로 정의**돼 있다. 공유 타입이 아니다.
- 두 DTO 매핑(`WordDetailResponseDTO+Mapping.swift:20-22`,
  `SessionDetailResponseDTO+Mapping.swift:32-33`)이 각각 `PartOfSpeech(rawValue: "noun") ?? .unknown`
  처럼 **같은 raw value 컨벤션**(전체 단어: `"noun"`, `"verb"`, …)으로 디코딩한다 — 백엔드가 이
  필드에 대해서는 두 API에서 같은 표기를 쓴다는 뜻.
- `WordDetail.Example.Word.pos`(`Projects/Domain/Interface/Model/WordDetail.swift:27-30`)는 같은
  "품사" 개념인데 enum이 아니라 **원본 `String`을 그대로 통과**시킨다
  (`WordDetailResponseDTO+Mapping.swift:33` — `pos: $0.pos`). 이 필드의 백엔드 표기는 위 두
  DTO와 **다른 컨벤션**(축약 코드: `"n"`, `"v"`, `"adj"`, …)이다 — 확인 근거:
  `Projects/Feature/Analysis/Sources/ChunkReader/String+KoreanPOSLabel.swift`의 매핑 테이블.
- 이 축약 코드 매핑 테이블에는 `"det": "한정사"`가 있는데, 대응하는 enum case가 없다
  (`PartOfSpeech`에 `.determiner`가 없음) — 통합 시 이 케이스가 `.unknown`으로 뭉개지면 라벨이
  "한정사" → "기타"로 바뀌는 회귀가 된다.
- 두 "unknown" 폴백의 의미도 서로 다르다: enum 경로는 인식 못한 값을 전부 `.unknown`(라벨 "기타")
  으로 뭉개고, String 경로(`ChunkReader`)는 인식 못한 코드를 **원문 그대로** 보여준다
  (`labels[lowercased()] ?? self`).

### 목표

`WordDetail.Definition.PartOfSpeech`와 `Session.Word.Definition.PartOfSpeech`를 `DomainInterface`
최상위의 **단일 공유 `PartOfSpeech` enum**으로 통합한다.

### 범위

- **포함**
  - `Projects/Domain/Interface/Model/PartOfSpeech.swift` 신규 — 공유 enum
    (기존 9 case + `.determiner` 추가)
  - `WordDetail.Definition`, `Session.Word.Definition`이 이 공유 타입을 참조하도록 수정
    (중첩 enum 삭제)
  - 두 DTO 매핑(`WordDetailResponseDTO+Mapping.swift`, `SessionDetailResponseDTO+Mapping.swift`)이
    공유 타입으로 디코딩하도록 수정 — **이번엔 DTO→Entity 매핑도 대상에 포함한다**
    (1단계의 "DTO ↔ Entity 매핑은 제외" 제약을 이 서브스코프에 한해 해제)
  - Feature 쪽 한글 라벨 extension(`PartOfSpeech+KoreanLabel.swift`)이 공유 타입을 확장하도록 수정
- **명시적으로 제외 (하지 않음)**
  - `WordDetail.Example.Word.pos: String`은 **그대로 둔다.** 축약 코드 컨벤션이 다르고,
    "인식 못한 코드는 원문 그대로 표시"라는 현재 폴백 동작이 enum 통합 시 "기타"로 뭉개지는
    행동 변화(회귀)를 만들기 때문이다. 이 필드까지 통합하는 건 별도 판단이 필요한 결정이라
    이번 서브스코프에서는 진행하지 않는다 — `ChunkReader`의 `String.koreanPartOfSpeechLabel`
    확장은 그대로 유지한다.

### 보존해야 할 동작

- `WordDetailDefinitionGroupingTests`, `WordDetailExampleSortingTests`,
  `PartOfSpeech+KoreanLabel`을 쓰는 기존 라벨(명사/동사/…/기타) 결과가 그대로 유지되어야 한다.
- `SessionDetailResponseDTO`/`WordDetailResponseDTO` 양쪽 다 새 공유 enum으로 정상 디코딩되어야
  한다.

### 완료 조건 (2단계)

- `WordDetail.Definition.PartOfSpeech`, `Session.Word.Definition.PartOfSpeech` 중첩 enum이
  사라지고 공유 `PartOfSpeech` 하나만 남는다.
- `WordDetail.Example.Word.pos`는 `String`으로 그대로 남는다(의도적 유지, 회귀 아님).
- AllTest 스킴이 통과한다.
