# PLAN: 스트리밍 텍스트 꼬리 페이드 인 효과

- 작업 ID: `090-feature-chatbot` (기존 워크트리 재사용)
- 문제정의: `.harness/problems/090-chatbot.md` (빈 스켈레톤 — 요구사항 출처는 사용자 지시)

---

## Context

ChatBot의 SSE 스트리밍 배선은 이미 끝났고, 지금은 `MarkdownView`가 `streamedText`를 받아
청크가 도착할 때마다 통째로 다시 그린다. 그래서 새 글자가 "툭툭" 나타난다 — 대부분의 LLM
챗봇이 주는, 텍스트가 부드럽게 번져 나오는 인상이 없다.

목표는 사용자가 제시한 아래 동작을 그대로 구현하는 것이다:

> 스트리밍 중인 블록의 마지막 텍스트에 "서서히 나타나는" 효과를 준다.
> 가장 최근에 공개된 몇 글자일수록 더 옅게 그리고, 그 경계는 매 틱마다 다시 계산된다.
> 프레임을 연속으로 보면 오른쪽 끝에서 옅은 그라데이션이 계속 새로 그려지며 앞으로
> 밀려나는 것처럼 보여, 텍스트가 부드럽게 번져 나오는 것 같은 인상을 만든다.

여기서 "틱"은 **SSE 청크 도착 시점**이다(사용자 확인). 별도 타이머나 공개 버퍼를 두지 않고,
`streamedText` 갱신 → `MarkdownView` 재생성이라는 지금의 흐름을 그대로 틱으로 쓴다.
따라서 **ViewModel은 건드리지 않는다.**

---

## 1. 문제 재정의

스트리밍 중일 때, 렌더된 마크다운의 **맨 끝 몇 글자**를 위치에 따라 점점 옅게 그려,
매 청크마다 그 옅은 구간이 새로 계산되며 앞으로 밀려나는 것처럼 보이게 한다.

---

## 2. 기능 요구사항

- **판정**: 파싱된 블록 배열에서 "문서의 꼬리 텍스트"(마지막 블록의 마지막 `AttributedString`)를 고른다.
- **계산**: 그 텍스트의 뒤 N글자에 대해, 앞에서 뒤로 갈수록 낮아지는 불투명도를 문자 단위로 산출한다.
- **표시**: 산출한 불투명도를 의미 속성으로 심고, 스타일러가 실제 `Color.opacity(_:)`로 적용한다.
- **전환**: `fadesTail`이 false면 페이드를 아예 계산하지 않아 텍스트가 완전 불투명해진다.
- **재계산**: 청크가 도착해 `streamedText`가 바뀔 때마다 위 과정 전체가 다시 돈다(추가 코드 없이 SwiftUI 재생성으로 성립).

---

## 3. 제약과 무효 상태

| 상황 | 처리 |
|---|---|
| 빈 문자열 / 블록 0개 | 페이드 없이 그대로 반환 |
| 꼬리 텍스트가 N글자보다 짧음 | 있는 글자 수만큼만 페이드 (구간 축소) |
| 마지막 블록이 `.table` / `.structure` / `.divider` | 페이드 없음. `.structure`는 원문 `String`이라 속성을 심을 대상이 없다 — 정상 폴백이지 예외가 아니다 |
| 마지막 블록이 리스트/콜아웃 | 마지막 항목(콜아웃은 마지막 본문 줄, 본문 없으면 제목)에만 페이드 |
| 페이드 구간이 코드/하이라이트 배경과 겹침 | 배경색에도 같은 불투명도를 곱해 글자만 뜨는 현상을 막는다 |
| 스트리밍 종료 | 페이드 미적용 상태로 한 번 더 그려져 자연스럽게 완전 불투명이 된다 |
| 에러 표시 중 | 기존 분기상 `MarkdownView` 자체가 렌더되지 않음 — 영향 없음 |

---

## 4. 변경 포인트 (앞으로 바뀔 여지가 있는 규칙)

- **페이드 길이 N과 최저 불투명도** — 튜닝 대상. `MarkdownTailFader`의 상수 두 개로 모은다.
- **불투명도 커브** — 지금은 선형. ease-out 등으로 바꿀 여지가 있어 계산을 한 함수에 가둔다.
- **꼬리 텍스트 선정 규칙** — 블록 종류가 늘어나면 확장 지점은 fader의 `switch` 한 곳뿐.

---

## 5. 책임 분리

| 요구사항 | 책임 | 모듈/타입 |
|---|---|---|
| 불투명도를 담는 의미 속성 정의 | 커스텀 AttributedString 속성 | `MarkdownTailOpacityAttribute` (신규) |
| 블록에서 꼬리 텍스트를 찾아 교체 | 블록 형태 지식 | `MarkdownBlock+TailText` (신규 확장) |
| 문자별 불투명도 계산 및 스탬핑 | 페이드 정책 | `MarkdownTailFader` (신규) |
| 의미 속성 → 실제 색 적용 | 스타일링 | `MarkdownInlineStyler` (수정) |
| 페이드 on/off | 렌더 진입점 | `MarkdownView` (수정) |
| 스트리밍 상태 → 페이드 여부 매핑 | 화면 조립 | `ChatBotContentView` (수정) |

이 저장소의 기존 경계 — **"파서/모델은 의미, 스타일러는 디자인"** — 를 그대로 지킨다.
fader는 `Color`를 만들지 않고 `Double`만 심는다. 이미 `==하이라이트==`가 쓰고 있는
`MarkdownHighlightAttribute` 패턴과 동일한 방식이다.

---

## 6. SOLID 리뷰

solid-review 결과 **구현 전 반영할 변경 3건**이 나왔고, 아래 설계는 이미 반영된 상태다.

- **SRP (변경 1 반영)**: 초안에서는 `MarkdownTailFader`가 "블록 종류별 꼬리 선정"과 "불투명도 커브"를
  함께 가져 변경 이유가 둘이었다. 전자를 `MarkdownBlock+TailText`의 `replacingTailText(_:)`로 분리한다 —
  블록 종류가 늘 때는 모델 확장만, 커브를 바꿀 때는 fader만 연다.
- **OCP**: 리프 뷰 8개(`MarkdownParagraphView` 등)는 **한 줄도 수정하지 않는다** — 이미 전부
  `MarkdownInlineStyler.styled(...)`를 거치기 때문에 속성 소비 지점이 한 군데다.
  `==하이라이트==`가 같은 경로로 확장된 선례가 있다.
- **LSP / ISP**: 새 프로토콜이 없어 해당 없음.
- **DIP (변경 2 반영)**: `MarkdownView(markdown:isStreaming:)`은 렌더러가 알 필요 없는 호출자 사정
  (스트리밍)을 인터페이스로 끌어들인다. 파라미터를 **`fadesTail`**로 바꿔, 스트리밍→페이드 매핑을
  화면 조립 지점(`ChatBotContentView`)에 남긴다.
- **오버엔지니어링 점검 — 만들지 않을 것**:
  - `TailFading` 프로토콜 / 커브 전략 타입 (구현체 하나뿐)
  - `@Environment` 주입 (`MarkdownView`가 이미 유일한 진입점이라 불필요)
  - `.mask(LinearGradient)` 방식 (여러 줄로 접히면 **모든 줄의 오른쪽**이 옅어져 요구사항과 다름 — 채택하지 않는다)
- **변경 3 (구현 시 주의)**: 스타일러는 순회 대상을 `text.runs`로 유지하고 쓰기만 `result[range]`에 한다.
  문자 단위 불투명도로 run이 쪼개지므로, 순회 중인 컬렉션을 바꾸지 않는 기존 형태를 반드시 지킨다.

---

## 7. 테스트 범위

사용자 지시("테스트는 굳이 작성하지 않아도 된다")에 따라 **5절의 모든 책임을 `테스트 불필요`로 표시**한다.
새 테스트 케이스를 제안하지 않는다.

단, 이는 검증 면제가 아니다 — 빌드 검증은 필수이고, 기존 `AllTest` 회귀도 함께 돌린다
(`MarkdownInlineStyler`를 수정하므로 파서 테스트가 깨지지 않는지 확인한다).

---

## 8. 가정 (문제정의 파일에 근거가 없어 명시)

- **A1** 페이드 기본값은 **뒤 12글자, 최저 불투명도 0.12, 선형 커브**로 시작한다. 실기기 확인 후 조정 가능한 상수로 둔다.
- **A2** 페이드 대상은 **문서 전체의 마지막 텍스트 하나**다. 마지막 블록 안의 여러 항목에 걸쳐 번지지 않는다.
- **A3** `MarkdownView(markdown:)` 기존 호출부(Example 2곳)는 그대로 둔다 — 새 인자에 기본값 `false`를 준다.
- **A4** 애니메이션 modifier를 붙이지 않는다. 움직임은 청크 도착 빈도 자체에서 나온다(사용자가 고른 틱 기준).

---

## 9. 구현 상세

### 신규 `Sources/Markdown/Model/MarkdownTailOpacityAttribute.swift`

```swift
enum MarkdownTailOpacityAttribute: AttributedStringKey {
    typealias Value = Double
    static let name = "markdownTailOpacity"
}
```

`MarkdownHighlightAttribute.swift`의 `AttributeScopes.MarkdownAttributeScope`에
`let markdownTailOpacity: MarkdownTailOpacityAttribute` 한 줄을 추가한다
(스코프 정의가 그 파일에 있으므로 — "한 파일 한 타입" 규칙상 속성 타입 자체는 새 파일).

### 신규 `Sources/Markdown/Model/MarkdownBlock+TailText.swift`

블록의 "마지막 텍스트"가 어디인지는 블록 형태의 문제이므로 모델 쪽에 둔다.

```swift
extension MarkdownBlock {
    /// 이 블록의 마지막 AttributedString에만 변환을 적용한 새 블록.
    /// 텍스트를 담지 않는 블록(.table / .structure / .divider)은 그대로 반환한다.
    func replacingTailText(_ transform: (AttributedString) -> AttributedString) -> MarkdownBlock
}
```

`switch`로 케이스별 꼬리를 고른다 — 문단/헤딩은 자기 자신, 리스트·결과 리스트는 마지막 항목,
예문 인용은 한글 줄(없으면 영문 줄), 콜아웃은 마지막 본문 줄(본문이 비면 제목).
`.structure`는 원문 `String`이라 심을 대상이 없어 제외된다.

### 신규 `Sources/Markdown/Model/MarkdownTailFader.swift`

fader는 **커브 정책만** 소유한다.

```swift
enum MarkdownTailFader {
    private static let length = 12
    private static let minOpacity = 0.12

    /// 마지막 블록의 꼬리 텍스트에만 문자 단위 불투명도를 심은 새 블록 배열을 만든다.
    static func fadingTail(of blocks: [MarkdownBlock]) -> [MarkdownBlock]

    /// 뒤 length글자에 1.0 → minOpacity 선형 보간값을 문자 단위로 스탬프한다.
    private static func faded(_ text: AttributedString) -> AttributedString
}
```

- `fadingTail`: `blocks.last`를 `replacingTailText(faded)`로 바꿔 끼운다. 블록 종류를 여기서 알지 않는다.
- `faded`: `text.characters` 기준 뒤에서부터 한 글자씩 범위를 잡아
  `result[range].markdownTailOpacity = 1.0 - (1.0 - minOpacity) * progress` 를 심는다.
  속성만 바꾸므로 인덱스는 무효화되지 않지만, 구현 시 `result.characters`에서 인덱스를 다시 구해 안전하게 간다.

### 수정 `Sources/Markdown/View/MarkdownInlineStyler.swift`

run 루프 끝, `result[range].font = font` 직전에:

```swift
if let opacity = run.markdownTailOpacity {
    color = color.opacity(opacity)
    if let background = result[range].backgroundColor {
        result[range].backgroundColor = background.opacity(opacity)
    }
}
```

문자마다 불투명도가 달라지면 run이 글자 단위로 쪼개지지만, 스타일러는 이미 run 단위 순회라
추가 분기 없이 그대로 동작한다. `inlinePresentationIntent`(굵게/코드 등)는 쪼개진 run에도 그대로 상속된다.
순회는 `text.runs`, 쓰기는 `result[range]`라는 기존 형태를 유지한다(SOLID 리뷰 변경 3).

### 수정 `Sources/Markdown/View/MarkdownView.swift`

```swift
public init(markdown: String, fadesTail: Bool = false) {
    let parsed = MarkdownBlockParser.parse(markdown)
    blocks = fadesTail ? MarkdownTailFader.fadingTail(of: parsed) : parsed
}
```

### 수정 `Sources/ChatBot/ChatBotContentView.swift`

```swift
MarkdownView(markdown: viewModel.streamedText, fadesTail: viewModel.isStreaming)
```

`ChatBotViewModel` / UseCase / Repository / SSEClient는 **변경 없음**.

---

## 10. 체크리스트

구현 착수 시 아래를 `.harness/exec-plans/active/090-feature-chatbot/PLAN.md`에 옮겨 적고
진행하면서 체크한다.

- [ ] PLAN.md에 이 체크리스트 반영 (기존 SSE 배선 기록은 보존하고 새 절로 추가)
- [ ] `MarkdownTailOpacityAttribute.swift` 신규 작성
- [ ] `MarkdownHighlightAttribute.swift`의 `MarkdownAttributeScope`에 새 속성 등록
- [ ] `MarkdownBlock+TailText.swift` 신규 작성 — `replacingTailText(_:)` 블록별 `switch`
- [ ] `MarkdownTailFader.swift` 신규 작성 — 문자 단위 불투명도 보간 및 스탬핑
- [ ] `MarkdownInlineStyler`에 불투명도 소비 로직 추가 (전경색 + 배경색)
- [ ] `MarkdownView`에 `fadesTail` 인자 추가 (기본값 `false`)
- [ ] `ChatBotContentView`에서 `fadesTail: viewModel.isStreaming` 전달
- [ ] `tuist generate` 성공 확인
- [ ] **빌드 성공 확인** (`FeatureChatBotExample`, `FiveVoca`)
- [ ] `tuist test AllTest --no-selective-testing` 회귀 통과 확인
- [ ] Example 실행 → 실제 스트리밍 중 꼬리 그라데이션 육안 확인
- [ ] 검증용 임시 코드 전량 제거 확인
- [ ] 변경 파일 및 검증 결과 요약 (테스트 검증 / 코드 확인 구분)

---

## 11. 검증 방법

1. `tuist generate` 후 `build_sim`으로 `FeatureChatBotExample`, `FiveVoca` 두 스킴 빌드.
2. `tuist test AllTest --no-selective-testing` — 스타일러 수정이 기존 마크다운 테스트를 깨지 않는지 확인.
3. Example 앱을 시뮬레이터에서 실행해 실제 SSE 응답을 받으며 꼬리 페이드를 확인한다.
   - 이 세션에는 탭/입력 UI 자동화 도구가 없으므로, 직전 태스크와 동일하게
     **Example 전용 임시 `-autoSend` 런치 인자 훅**을 넣어 전송을 트리거하고, 확인 후 즉시 되돌린다.
   - 단발 스크린샷으로는 "밀려나는" 느낌을 판단할 수 없으므로 `record_sim_video`로 영상을 남겨
     그라데이션이 프레임마다 새로 그려지는지 본다.
4. 스트리밍이 끝난 뒤 텍스트가 완전 불투명으로 정착하는지 마지막 프레임에서 확인한다.

---

## 12. 범위 밖

- 타이머 기반 일정 속도 공개 버퍼(사용자가 SSE 틱 기준을 선택 — 이후 부드러움이 부족하면 별도 태스크)
- 스트리밍 중 마크다운 전체 재파싱 최적화 (기존 이슈, 그대로 둠)
- 대화 히스토리 / 메시지 목록 UI
- 커서(캐럿) 깜빡임, 타이핑 사운드 등 다른 스트리밍 연출
- App 타겟의 Networking/Data 미링크 (직전 태스크에서 이미 범위 밖으로 기록)
