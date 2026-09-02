# PLAN: WordDetail 예문 액션바 교체 + 챗봇 네비게이션 연결 — 하위 작업 24

- 작업 ID: `090-feature-chatbot` (기존 워크트리 재사용, 하위 작업 24)
- 문제정의: `.harness/problems/090-chatbot.md` — 빈 스켈레톤. 근거는 Figma
  node-id=129:5(`https://www.figma.com/design/HqmIYf73yHUljbwmfmspjQ/...?node-id=129-5`)
  와 사용자 요청("끊어읽기를 이 디자인으로 변경, 에셋도 이걸로 변경, 챗봇은 내가 구현한
  챗봇으로 navigation push").

---

## Context

`WordDetail` 화면의 예문 카드에는 지금 "끊어읽기" 버튼 하나만 있다
(`WordDetailExampleRow.swift:22-38`, SF Symbol `text.word.spacing` + 텍스트, chunks가
있을 때만 표시). Figma 129:5는 이 자리를 **"끊어읽기" + "챗봇" 두 버튼이 나란히 들어간
연한 초록 필(pill) 액션바**로 바꾼 디자인이다. 사용자가 명시적으로 "에셋도 이걸로
변경"이라고 했으므로 SF Symbol이 아니라 Figma의 실제 벡터를 다운로드해 쓴다. "챗봇"
버튼은 이미 이 세션에서 완성한 `FeatureChatBot` 모듈(`ChatBotView`/`ChatBotViewModel`/
`ChatBotContext`)로 **네비게이션 push**한다.

### Figma 디자인 확정 사항 (`get_design_context` + `download_assets` 결과)

- 129:5 `card-action-bar`: bg `#F1F7F4`, padding 12/8, gap 12, radius 12.
  - 129:6 `button-끊어읽기`: 아이콘(129:15 `align-left`, 14×14) + "끊어읽기" 13px
    SemiBold, 색상 `#136C5B`. padding 8/6, gap 6, chunks 있을 때만 노출(기존 조건 유지).
  - 129:10 `button-챗봇`: 아이콘(129:18 `message-square`, 14×14) + "챗봇" 13px
    SemiBold, 색상 `#136C5B`. 예문마다 항상 노출(끊어읽기 유무와 무관 — 챗봇에는 모든
    예문을 물어볼 수 있어야 하므로).
- 두 아이콘 다운로드 확인(`download_assets` nodeId=129:5의 `svgAssets`):
  - align-left: `<path d="M12.25 2.9162H1.75M8.75 7H1.75M9.91667 11.0838H1.75" stroke="#136C5B" stroke-width="2" stroke-linecap="round"/>` (14×14, viewBox 0 0 14 14)
  - message-square: 말풍선 윤곽 path, 동일 `stroke="#136C5B" stroke-width="2"` (14×14)
  - 둘 다 **단색 스트로크 아이콘**이라 `ErrorIcon`(두 톤 배지라 `template-rendering-intent:
    original`로 고정 렌더)과 성격이 다르다 — 텍스트와 같은 초록으로 항상 같이 움직이는
    아이콘이라 재사용성 있게 만드는 게 맞다.
- 색상 매칭: Figma `#136C5B`(0.0745, 0.4235, 0.3569)는 기존 `DesignSystemAsset.study300`
  (0.059, 0.431, 0.337 = `#0F6E56`)과 근접하지만 완전히 같지는 않다. 새 컬러 자산을 또
  만들지 않고(컬러는 DesignSystemAsset만 사용 — 프로젝트 규칙), **`study300`을 그대로
  재사용**한다 — 마침 이 자리에서 지워지는 기존 끊어읽기 버튼도 이미 `study300`을 쓰고
  있었다(`WordDetailExampleRow.swift:33`). 아이콘도 텍스트와 완전히 같은 톤으로 맞추기
  위해 SVG를 **템플릿(단색 틴트 가능) 자산**으로 만들고 `.foregroundStyle(study300)`로
  칠한다 — 이렇게 하면 아이콘 SVG 안에 색을 박아넣지 않아도 되고, 텍스트와 아이콘이
  같은 토큰 하나로 항상 일치한다.

### 왜 SF Symbol이 아니라 실제 SVG인가

사용자가 "에셋도 이걸로 변경"이라고 명시했다 — 이전 세션(에러 아이콘, 하위 작업 18)에서
이미 확인된 패턴과 같다: Figma 실물 벡터가 SF Symbol 추측과 실제로 다를 수 있고(그때도
그랬다), 사용자가 실제 에셋 반영을 원할 때는 다운로드해 imageset으로 추가하는 편이
맞다. `ErrorIcon.imageset`(`Projects/DesignSystem/Resources/Colors.xcassets/ErrorIcon.imageset/`)이
같은 파이프라인의 선례다.

### 챗봇에 필요한 컨텍스트를 어디서 조달하나

`ChatBotContext(term:sentence:levelLabel:)`(`Projects/Feature/ChatBot/Sources/ChatBot/ChatBotContext.swift`)가
필요로 하는 세 값 중 `sentence`는 탭한 예문(`example.en`)로 바로 나온다. `term`은
`WordDetailPresentationModel.term`에 이미 있다. **`levelLabel`은 현재 아무 데도 없다** —
`WordDetail.level: Int`(도메인 모델, `WordDetail.swift:76`)는 있지만
`WordDetailPresentationModel`이 이걸 지금 버리고 있다(`WordDetail+PresentationModel.swift`에
매핑 안 됨). 저장소 전체를 검색해도 Int 레벨 → "초급/중급/고급" 같은 한글 난이도 이름
매핑은 어디에도 존재하지 않는다(Home 모듈의 "씨앗/새싹/줄기..." 레벨 *이름*은
`VocabularyLibrary` 응답에만 있고 `WordDetail` 경로로는 안 내려온다). 반면 `Level \(n)`
형식은 이미 `VocabularyListHeaderView.swift:16`("Level \(level) · Session
\(sessionNumber)")에 선례가 있다. → **가정 A1**: 새 매핑을 만들지 않고 `"Level
\(level)"` 형식을 그대로 재사용한다(레벨 이름 체계를 새로 발명하지 않음). 문구 하나
바꾸는 정도라 사용자가 나중에 쉽게 바꿀 수 있다.

---

## 1. 문제 재진술

WordDetail 예문 카드의 "끊어읽기" 버튼을 Figma 129:5 디자인(끊어읽기+챗봇 2버튼 액션바)으로
교체하고, "챗봇" 버튼을 탭하면 해당 예문을 컨텍스트로 하는 챗봇 화면으로 push한다.

## 2. 기능 요구사항

1. 예문 카드에 액션바(연한 초록 필)를 렌더한다.
2. chunks가 있는 예문에만 "끊어읽기" 버튼을 보여준다(기존 조건 유지) — 탭하면 기존과
   동일하게 `ChunkReaderView`로 push.
3. **모든** 예문에 "챗봇" 버튼을 보여준다 — 탭하면 `ChatBotContext(term: 페이지 단어,
   sentence: 그 예문의 영문, levelLabel: "Level \(그 단어의 레벨)")`로 `ChatBotView`를
   push한다.
4. 두 버튼 모두 실제 Figma 벡터 아이콘(align-left / message-square)을 쓴다, SF Symbol
   아님.
5. push는 현재 `WordDetailView`가 이미 쓰고 있는 `.navigationDestination(item:)` +
   `Destination` enum 패턴을 그대로 따른다(모달 아님, 스택 push).

## 3. 제약 / 무효 상태

- 새 컬러 자산을 만들지 않는다 — `study300` 재사용(위 Context 참고).
- `WordDetailPresentationModel`에 `level`을 추가하는 것 외에 기존 필드/모델 구조를
  바꾸지 않는다.
- `ChunkReaderView` 쪽 흐름(조건, ViewModel, 네비게이션)은 건드리지 않는다 — 액션바
  안에 나란히 놓이는 것 외에는 무관.
- FeatureVocabulary가 FeatureChatBot에 새로 의존하게 된다 — 순환 의존 여부 확인 필요
  (FeatureChatBot은 Vocabulary를 참조하지 않으므로 안전, `Project.swift` 확인 완료).

## 4. 변경 지점

| 파일 | 변경 |
|---|---|
| `Projects/DesignSystem/Resources/Colors.xcassets/AlignLeft.imageset/` (신규) | align-left SVG, 템플릿 렌더 |
| `Projects/DesignSystem/Resources/Colors.xcassets/MessageSquare.imageset/` (신규) | message-square SVG, 템플릿 렌더 |
| `Projects/Feature/Vocabulary/Sources/WordDetail/WordDetailPresentationModel.swift` | `level: Int` 필드 추가 |
| `Projects/Feature/Vocabulary/Sources/WordDetail/WordDetail+PresentationModel.swift` | `level: level` 매핑 추가 |
| `Projects/Feature/Vocabulary/Sources/WordDetail/WordDetailExampleRow.swift` | 기존 단일 버튼 → 액션바(2버튼)로 교체 |
| `Projects/Feature/Vocabulary/Sources/WordDetail/WordDetailExamplesView.swift` | `onChatBotTapped` 콜백 스레딩 |
| `Projects/Feature/Vocabulary/Sources/WordDetail/WordDetailContentView.swift` | 〃 |
| `Projects/Feature/Vocabulary/Sources/WordDetail/WordDetailPageView.swift` | `.loaded(let state)` 지점에서 `state` 캡처해 `onChatBotTapped(state, example)`로 바인딩 |
| `Projects/Feature/Vocabulary/Sources/WordDetail/WordDetailViewModel.swift` | `Destination.chatBot(ChatBotViewModel)` 케이스 추가, `didTapChatBot(state:example:)` 추가 |
| `Projects/Feature/Vocabulary/Sources/WordDetail/WordDetailView.swift` | `import FeatureChatBot`, `onChatBotTapped: viewModel.didTapChatBot` 배선, `.navigationDestination(item: $viewModel.destination.chatBot)` 추가 |
| `Projects/Feature/Vocabulary/Project.swift` | `FeatureVocabulary` 타겟 dependencies에 `.feature(implements: .chatBot)` 추가 |

## 5. 책임 분리 + 테스트 필요 여부

| 요구사항 | 책임 | 위치 | 테스트 |
|---|---|---|---|
| 1·2·4 | 액션바 레이아웃(2버튼, 조건부 끊어읽기) | `WordDetailExampleRow.swift` | 테스트 불필요(순수 뷰) |
| 3(콜백 배선) | `onChatBotTapped` 콜백을 뷰 계층으로 스레딩 | `WordDetailExamplesView/ContentView/PageView.swift` | 테스트 불필요(순수 뷰) |
| 3(네비게이션 상태) | `state.term`+`example.en`+`state.level`로 `ChatBotContext`를 만들어 `destination`을 세팅 | `WordDetailViewModel.didTapChatBot(state:example:)` | **테스트 필요** |
| level 매핑 | `WordDetail.level` → `WordDetailPresentationModel.level` | `WordDetail+PresentationModel.swift` | 테스트 불필요(기존 `test_requestIfNeeded_index1_loaded이며_데이터가_올바르다`가 이미 매핑 필드들을 검증하는 자리라, 여기에 `level` assertion 한 줄만 추가) |

`didTapChunkReader`가 이미 이 코드베이스에서 테스트되지 않은 선례(순수 setter라 판단)와
달리, `didTapChatBot`은 **문자열 포맷팅 로직(`"Level \(level)"`)이 섞여 있어** 조용히
깨질 수 있는 지점이라 테스트 필요로 판단했다.

## 6. SOLID 리뷰

- **SRP**: `WordDetailViewModel`은 이미 "화면 상태 + 네비게이션 목적지 소유"라는 하나의
  책임을 갖고 있고, `didTapChatBot`도 그 책임 범위 안(`didTapChunkReader`와 동급)이라
  새 타입을 만들 이유가 없다.
- **OCP**: `Destination` enum에 케이스 하나 추가하는 것은 기존 패턴의 자연스러운 확장 —
  별도 프로토콜/전략 계층을 도입하지 않는다.
- **LSP/ISP/DIP**: 해당 없음 — 정책 인터페이스나 주입 대상이 없다.
- **과설계 점검**:
  - `WordDetailExampleRow`를 더 잘게 쪼개지 않는다(액션바를 별도 파일로 빼지 않음) —
    `inputBar`처럼 같은 파일 안 private helper로 충분한 규모.
  - `level: Int → String` 매핑을 별도 `LevelLabelFormatter` 같은 타입으로 만들지 않는다
    — 한 줄짜리 문자열 보간이라 그 자체로 충분히 읽힌다.
  - 새 컬러 자산(과 SVG에 하드코딩된 색)을 만들지 않고 기존 `study300` 재사용 — 위
    Context에서 이미 결정.
  - `ChatBotContext` 자체는 이미 이전 세션에서 "최소 계약"으로 설계돼 있어(주석 참고)
    그대로 재사용, 확장하지 않는다.

## 7. 가정

- **A1**: `levelLabel`은 `"Level \(state.level)"` 형식(기존 `VocabularyListHeaderView`
  선례 재사용). 초급/중급/고급 같은 한글 난이도 이름 매핑은 저장소 어디에도 없어
  새로 발명하지 않았다. 챗봇 헤더 칩이 "문법 분석 · Level 3"처럼 보이는데, 사용자가
  "초급/중급/고급"을 원하면 이 한 줄만 바꾸면 된다.
- **A2**: "챗봇" 버튼은 chunks 유무와 무관하게 모든 예문에 항상 노출한다(문제정의 파일에
  명시 없음 — 모든 예문이 챗봇 질문 대상이 되는 게 자연스럽다고 판단).
- **A3**: `AlignLeft`/`MessageSquare` 아이콘은 template-rendering-intent로 만들어
  `study300`으로 틴트한다(ErrorIcon과 달리 단색 스트로크 아이콘이라 텍스트와 같은
  토큰을 공유하는 게 낫다고 판단) — SwiftUI에서 방식은
  `DesignSystemAsset.alignLeft.swiftUIImage.renderingMode(.template)` 후
  `.foregroundStyle(study300)`.

---

## 구현 상세

### 1) 아이콘 자산 (`Projects/DesignSystem/Resources/Colors.xcassets/`)

`AlignLeft.imageset/align-left.svg` (다운로드된 벡터 그대로, 스트로크 색상만 템플릿이라
무의미 — 원본 유지 가능):
```svg
<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 14 14" fill="none">
<path d="M12.25 2.9162H1.75M8.75 7H1.75M9.91667 11.0838H1.75" stroke="black" stroke-width="2" stroke-linecap="round"/>
</svg>
```
`Contents.json`: `preserves-vector-representation: true`, `template-rendering-intent: template`.

`MessageSquare.imageset/message-square.svg` (동일 패턴, 다운로드된 path 그대로 `stroke="black"`로 치환):
```svg
<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 14 14" fill="none">
<path d="M12.4921 10.7417C12.7109 10.5229 12.8338 10.2261 12.8338 9.91671V2.91667C12.8338 2.60725 12.7109 2.3105 12.4921 2.09171C12.2733 1.87292 11.9765 1.75 11.667 1.75H2.33296C2.02352 1.75 1.72675 1.87292 1.50794 2.09171C1.28913 2.3105 1.1662 2.60725 1.1662 2.91667V12.4169C1.16621 12.4988 1.19051 12.5789 1.23602 12.647C1.28154 12.7151 1.34622 12.7681 1.4219 12.7995C1.49758 12.8308 1.58085 12.839 1.66119 12.823C1.74153 12.8071 1.81533 12.7676 1.87326 12.7097L3.15786 11.4252C3.37662 11.2064 3.67334 11.0834 3.98276 11.0834H11.667C11.9765 11.0834 12.2733 10.9605 12.4921 10.7417Z" stroke="black" stroke-width="2" stroke-linecap="round"/>
</svg>
```
(`stroke="black"`은 template 렌더링에서 알파 채널만 쓰이므로 실제 표시색과 무관 —
`ErrorIcon`은 두 톤이라 "original"을 썼지만 이번엔 단색이라 "template"으로 실제 틴트를
코드에서 결정한다.)

### 2) `WordDetailExampleRow.swift`

```swift
// 기존 22-38행 통째로 교체
if example.chunks?.isEmpty == false || true {
    HStack(spacing: 12) {
        if let chunks = example.chunks, !chunks.isEmpty {
            actionButton(icon: DesignSystemAsset.alignLeft, title: "끊어읽기") {
                onChunkReaderTapped(example)
            }
        }
        actionButton(icon: DesignSystemAsset.messageSquare, title: "챗봇") {
            onChatBotTapped(example)
        }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(DesignSystemAsset.study100.swiftUIColor.opacity(0.5), in: .rect(cornerRadius: 12))
}
```
(위 `example.chunks?.isEmpty == false || true`는 사실 "항상 그린다"는 뜻이라 조건 자체가
무의미 — 실제 구현에서는 `if` 없이 그냥 액션바를 최상위로 둔다. 여기 의사코드는 "안이
조건부"라는 점만 보여주기 위한 것.)

```swift
private func actionButton(icon: DesignSystemImages, title: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Label {
            Text(title)
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
        } icon: {
            icon.swiftUIImage
                .renderingMode(.template)
                .resizable()
                .frame(width: 14, height: 14)
        }
        .foregroundStyle(DesignSystemAsset.study300.swiftUIColor)
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 6)
    .contentShape(.rect)
    .buttonStyle(.plain)
}
```
`onChatBotTapped: (WordDetailPresentationModel.ExampleRow) -> Void` 파라미터를
`onChunkReaderTapped`와 나란히 추가.

### 3) 콜백 스레딩 (`WordDetailExamplesView` → `ContentView` → `PageView`)

기존 `onChunkReaderTapped` 스레딩과 완전히 동일한 모양으로 `onChatBotTapped`를 나란히
추가한다(각 파일에서 파라미터 하나, 전달 한 줄씩).

`WordDetailPageView.swift`만 다르게 — `state`를 캡처해야 하므로:
```swift
case .loaded(let state):
    WordDetailContentView(
        state: state,
        onPronunciationTapped: onPronunciationTapped,
        onChunkReaderTapped: onChunkReaderTapped,
        onChatBotTapped: { example in onChatBotTapped(state, example) }
    )
```
`WordDetailPageView`의 파라미터 타입: `onChatBotTapped: (WordDetailPresentationModel, WordDetailPresentationModel.ExampleRow) -> Void`.

### 4) `WordDetailViewModel.swift`

```swift
import FeatureChatBot   // 추가

@CasePathable
enum Destination {
    case chunkReader(ChunkReaderViewModel)
    case chatBot(ChatBotViewModel)   // 추가
}

func didTapChatBot(state: WordDetailPresentationModel, example: WordDetailPresentationModel.ExampleRow) {
    destination = .chatBot(ChatBotViewModel(context: .init(
        term: state.term,
        sentence: example.en,
        levelLabel: "Level \(state.level)"
    )))
}
```

### 5) `WordDetailView.swift`

```swift
import FeatureChatBot   // 추가

WordDetailPageView(
    viewState: viewModel.viewStates[index],
    onPronunciationTapped: viewModel.pronunciationTapped,
    onChunkReaderTapped: viewModel.didTapChunkReader,
    onChatBotTapped: viewModel.didTapChatBot   // 추가
)
...
.navigationDestination(item: $viewModel.destination.chunkReader) { chunkReaderVM in
    ChunkReaderView(viewModel: chunkReaderVM)
}
.navigationDestination(item: $viewModel.destination.chatBot) { chatBotVM in   // 추가
    ChatBotView(viewModel: chatBotVM)
}
```

### 6) `WordDetailPresentationModel.swift` / `WordDetail+PresentationModel.swift`

```swift
struct WordDetailPresentationModel: Equatable {
    ...
    let term: String
    let level: Int   // 추가
    let pronunciation: String
    ...
}
```
```swift
WordDetailPresentationModel(
    term: term,
    level: level,   // 추가
    pronunciation: pronunciation,
    ...
)
```

### 7) `Project.swift` (Vocabulary)

```swift
.feature(implements: .vocabulary, factory: .init(
    dependencies: [
        .feature(implements: .analysis),
        .feature(implements: .chatBot),   // 추가
        .dependencies,
        .designSystem,
        .swiftUINavigation,
    ]
)),
```

---

## 8. 체크리스트

- [ ] `AlignLeft.imageset` / `MessageSquare.imageset` 생성(SVG + Contents.json, template
      렌더링)
- [ ] `WordDetailPresentationModel.swift` — `level: Int` 필드 추가
- [ ] `WordDetail+PresentationModel.swift` — `level: level` 매핑 추가
- [ ] `WordDetailExampleRow.swift` — 액션바(2버튼) 구현, `onChatBotTapped` 파라미터 추가
- [ ] `WordDetailExamplesView.swift` — `onChatBotTapped` 스레딩
- [ ] `WordDetailContentView.swift` — 〃
- [ ] `WordDetailPageView.swift` — `state` 캡처해 `onChatBotTapped(state, example)` 바인딩
- [ ] `WordDetailViewModel.swift` — `Destination.chatBot` 케이스, `didTapChatBot(state:example:)`
- [ ] `WordDetailView.swift` — `import FeatureChatBot`, 콜백 배선, `.navigationDestination(item: $viewModel.destination.chatBot)`
- [ ] `Project.swift`(Vocabulary) — `.feature(implements: .chatBot)` 의존성 추가
- [ ] `tuist generate --no-open` 성공 확인(`DesignSystemAsset.alignLeft`/`.messageSquare` 생성 확인)
- [ ] **빌드 검증** — `FeatureVocabularyExample` / `FiveVoca` 빌드 성공, 신규 경고 0개
- [ ] **테스트 작성** — `WordDetailViewModelTests.swift`에 `didTapChatBot` 테스트 추가:
      `destination`이 `.chatBot`이 되고, context의 `term`/`sentence`/`levelLabel`이
      기대값과 일치하는지 검증
- [ ] **테스트 작성** — 기존 `test_requestIfNeeded_index1_loaded이며_데이터가_올바르다`에
      `XCTAssertEqual(pm.level, ...)` 한 줄 추가(매핑 회귀 방지)
- [ ] 기존 테스트 회귀 확인 — `AllTest` 스킴 전체
- [ ] `swift-lint` 관점 점검
- [ ] 시뮬레이터 육안 확인 — 액션바 레이아웃(간격/색/아이콘), 챗봇 탭 시 push 전환,
      챗봇 화면에 예문이 정확히 채워지는지
- [ ] 변경 파일 요약 — 테스트 검증된 것과 육안 확인만 한 것을 분리해 기술

## 9. 검증 방법

1. `tuist generate --no-open`
2. `build_sim` — `FeatureVocabularyExample`, 이어서 `FiveVoca`
3. `AllTest` 스킴으로 `WordDetailViewModelTests` 포함 전체 회귀 확인
4. 시뮬레이터 실행 후 WordDetail 화면 진입 → 액션바 육안 확인 → "챗봇" 탭 → push 전환 +
   `AnalysisCardView`에 해당 예문이 정확히 표시되는지 확인. chunks 없는 예문에서
   "끊어읽기"가 안 보이고 "챗봇"만 보이는지도 함께 확인.
5. `swift-lint` 관점 점검

## 범위 밖

- `ChunkReaderView`/`ChunkReaderViewModel` 로직 변경.
- `levelLabel`을 초급/중급/고급 같은 별도 난이도 이름 체계로 바꾸는 것(가정 A1, 사용자
  요청 시 후속 변경).
- 챗봇 화면 자체의 UI/로직 변경 — 이번 작업은 진입 경로만 새로 만든다.
