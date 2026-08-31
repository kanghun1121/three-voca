# PLAN: ChatBot SSE 스트리밍 배선 (ViewModel → UseCase → Repository → SSEClient)

- 작업 ID: `090-feature-chatbot` (기존 워크트리 재사용, 새 하위 작업)
- 문제정의: `.harness/problems/090-chatbot.md` — **빈 스켈레톤**(이슈 #90 본문 없음). 요구사항 근거는 사용자 지시이며, 아래 "가정" 절에 명시한다.
- 기반 브랜치: dev / Worktree: `.harness/worktrees/090-feature-chatbot`
- 전체 설계는 `.harness/plans/resilient-stargazing-hoare.md`에 있음(Plan Mode 산출물). 이 파일은 그 요약 + 진행 상황 기록용.

---

## Context

ChatBot 피처는 지금 양끝이 완성돼 있고 가운데가 끊겨 있다.

- **아래쪽(완성)**: `SSEClient`(Networking) → `ClaudeMessagesRequest`/`ClaudeSSEParser`(Data/Sources/Chat)까지 SSE 인프라 완비.
- **위쪽(완성)**: `MarkdownView(markdown:)` 마크다운 렌더링 서브시스템 완비.
- **가운데(없음)**: Data의 파서를 도메인으로 노출하는 Repository/UseCase가 없음. `ChatBotView`/`ChatBotViewModel`은 빈 껍데기. `FeatureChatBot`은 `.domainInterface`도 의존하지 않음.

목적: 텍스트필드 입력 → 버튼 탭 → SSE 응답이 청크 단위로 화면에 누적되는 것을 `FeatureChatBotExample`에서 실행해 확인한다.

부수 발견: `Networking` 구현 타겟이 어떤 실행 타겟에도 링크돼 있지 않아 `SSEClientKey`의 `liveValue`가 앱 바이너리에 안 들어감 — Example에 `.networking`을 처음으로 링크한다.

---

## 요구사항 (사용자 지시 기준)

1. `ChatBotView`에 텍스트필드 + 버튼 + 콘텐트뷰 배치.
2. 버튼 탭 시 텍스트필드 입력값으로 SSE 스트리밍 시작.
3. 스트리밍 텍스트를 누적해 콘텐트뷰에 그대로 렌더(`MarkdownView(markdown:)` 재사용).
4. ViewModel → UseCase → Repository → SSEClient 경로 실제 연결.
5. `FeatureChatBotExample`에 liveValue를 달아 실제 스트리밍 확인.

### 제약 / 엣지 케이스
- 공백만 있는 입력은 전송 안 함.
- 스트리밍 중 재전송 금지(버튼 비활성).
- 새 전송 시 이전 누적 텍스트 초기화.
- 스트림 에러는 크래시 대신 화면에 에러 문구.
- 뷰 사라지면 진행 중인 스트림 Task 취소.
- `CLAUDE_API_KEY` 미배선 시 401 — Example에 키 배선 필수.

### 가정 (문제정의 파일에 근거 없음)
- **A1**: 대화 히스토리 없음, 매 전송이 단발 요청(user 메시지 1건).
- **A2**: 도메인 스트림 원소는 `String`(텍스트 델타)만. `ClaudeMessageStreamResponse`는 Data 내부에 유지.
- **A3**: 모델 `claude-sonnet-5`, `max_tokens` 2048, Data 상수 한 곳.
- **A4**: 범위는 Example까지. `App` 타겟은 건드리지 않음(범위 밖 절 참고).

---

## 설계 요약

```
ChatBotViewModel (Feature)
  └ @Dependency(\.sendChatMessageUseCase)
      └ SendChatMessageUseCase (DomainInterface)
          └ liveValue (Domain/Sources/UseCase/+Live)
              └ @Dependency(\.chatRepository)
                  └ ChatRepository (DomainInterface)
                      └ liveValue (Data/Sources/Chat/+Live)
                          └ @Dependency(\.sseClient) → SSEClient (Networking)
                          └ ClaudeMessagesRequest + ClaudeSSEParser (기존 자산)
```

시그니처는 기존 `ObserveAuthStateUseCase` 선례를 따름: `@Sendable (String) -> AsyncThrowingStream<String, Error>` (비-async 클로저가 스트림 즉시 반환).

Tuist 변경: `Feature/ChatBot/Project.swift`의 implements 타겟에 `.domainInterface` 추가, example 타겟에 `.domainInterface/.domain/.data/.networking` + `CLAUDE_API_KEY` infoPlist + `../../App/Secrets.xcconfig` settings 추가.

자세한 SOLID 리뷰/설계 근거는 `.harness/plans/resilient-stargazing-hoare.md` 참고.

---

## 책임 분리 + 테스트 필요 여부

사용자 결정: 이번 작업은 **자동 테스트 없이 빌드 검증 + Example 실행으로 확인**. 모든 책임 `테스트 불필요`.

| 요구사항 | 책임 | 위치 | 테스트 |
|---|---|---|---|
| 스트리밍 포트 노출 | Repository 포트 | `Domain/Interface/Repository/ChatRepository.swift` | 불필요 |
| ViewModel 진입점 | UseCase 포트 | `Domain/Interface/UseCase/SendChatMessageUseCase.swift` | 불필요 |
| UseCase→Repository 위임 | UseCase liveValue | `Domain/Sources/UseCase/SendChatMessageUseCase+Live.swift` | 불필요 |
| SSE 프레임→텍스트 델타 | Repository liveValue | `Data/Sources/Chat/ChatRepository+Live.swift` | 불필요 |
| 입력·누적·에러·Task 수명 | ViewModel | `Feature/ChatBot/Sources/ChatBot/ChatBotViewModel.swift` | 불필요 |
| 텍스트필드/버튼/콘텐트뷰 | View | `…/ChatBotView.swift`, `…/ChatBotContentView.swift` | 불필요 |
| 모듈 링크·API 키 배선 | Tuist 매니페스트 | `Feature/ChatBot/Project.swift` | 불필요 |
| liveValue 주입 | Example | `Feature/ChatBot/Example/ChatBotExampleApp.swift` | 불필요 |

기존 `MarkdownBlockParserTests`/`MarkdownInlineParserTests`는 회귀 확인용으로 `tuist test AllTest` 함께 실행(신규 아님).

---

## 체크리스트

- [x] Plan Mode 설계 완료 (`.harness/plans/resilient-stargazing-hoare.md`)
- [x] `solid-review` 스킬 실행 (구현 착수 전) — 설계 변경 없이 진행 승인
- [x] `Domain/Interface/Repository/ChatRepository.swift` 작성
- [x] `Domain/Interface/UseCase/SendChatMessageUseCase.swift` 작성
- [x] `Domain/Sources/UseCase/SendChatMessageUseCase+Live.swift` 작성
- [x] `Data/Sources/Chat/ChatRepository+Live.swift` 작성
- [x] `Feature/ChatBot/Sources/ChatBot/ChatBotViewModel.swift` 구현
- [x] `Feature/ChatBot/Sources/ChatBot/ChatBotContentView.swift` 신규 작성
- [x] `Feature/ChatBot/Sources/ChatBot/ChatBotView.swift` 수정
- [x] `Feature/ChatBot/Project.swift` 수정 (implements/.domainInterface, example 의존성+infoPlist+xcconfig)
- [x] `Feature/ChatBot/Example/ChatBotExampleApp.swift` 수정 (챗봇 탭 + liveValue 주입)
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBot`/`FeatureChatBotExample`/`FiveVoca` 빌드 성공 (경고는 저장소 전역에 이미 존재하는 retroactive-conformance 패턴뿐, 신규 문제 아님 — 아래 발견사항 참고)
- [x] `tuist test AllTest --no-selective-testing` 회귀 없음 확인 — 전체 통과, `SSEFrameReaderTests` 7케이스(신규 1개 포함), `FeatureChatBotTests` 29케이스 포함
- [x] `FeatureChatBotExample` 시뮬레이터 실행 → 실 SSE 스트리밍 육안 확인 — 성공(아래 참고)
- [x] 변경 파일 요약 (테스트 검증 vs 코드 정독 추정 분리) — 최종 응답에 기재

---

## 실행 중 발견한 실제 버그 2건 (계획에 없던 추가 수정)

Example 실행으로 실 스트리밍을 확인하는 과정에서, 계획 단계에는 없었던 **진짜 버그 2개**를 발견해 함께 고쳤다. 둘 다 "일단 배선만 해두면 된다"가 아니라 "실제로 눌러서 확인해보자"는 이번 작업의 원래 목적이 아니었으면 못 잡았을 문제들이다.

### 발견 1 — Debug dylib 빌드가 참조 안 되는 모듈을 링크에서 제외

증상: 버튼을 눌러도 `CancellationError()`만 뜨고 아무 것도 출력되지 않음. `chatRepository.streamMessage`/`sseClient.stream` 내부 코드가 아예 실행되지 않는 것으로 추적됨.

원인: Xcode의 Debug dylib 빌드(`xxx.debug.dylib`)는 Tuist 매니페스트의 `dependencies`에 있어도, **소스 코드에서 심볼을 직접 참조하지 않는 모듈은 링크에서 제외**한다. `ChatRepository`/`SSEClientKey`의 `DependencyKey`(liveValue) 준수는 전부 `@Dependency` 프로퍼티 래퍼를 통한 **런타임 프로토콜 조회**로만 도달되고, 어떤 소스 파일도 `ChatRepository.liveValue`/`SSEClientKey.liveValue`를 이름으로 직접 참조하지 않았다. 그 결과 `Data`/`Networking` 모듈의 `liveValue` 확장이 실제 바이너리에 링크되지 않았고, swift-dependencies는 `(key as? any DependencyKey.Type)?.liveValue` 캐스팅이 실패하자 조용히 `testValue`(unimplemented placeholder, 즉시 `CancellationError`로 끝나는 Noop)로 폴백했다. `nm`으로 디버그 dylib을 직접 열어 `WordRepository`/`ChatRepository` 심볼이 전혀 없음을 확인해 검증함.

수정: `Feature/ChatBot/Example/ChatBotExampleApp.swift`의 `prepareDependencies`에서 `$0.chatRepository = .liveValue`, `$0.sseClient = SSEClientKey.liveValue`를 **명시적으로** 추가해 두 모듈을 강제로 링크시킴(기존 `$0.sendChatMessageUseCase = .liveValue`만으로는 Domain 모듈만 강제 링크되고 Data/Networking은 여전히 제외됨).

이 발견은 처음 계획에 적어둔 "`App` 타겟의 `Networking` 미링크" 범위 밖 항목과 **같은 계열의 문제**임을 시사한다 — Tuist 의존성 선언만으로는 부족하고, 컴포지션 루트(App이든 Example이든)의 소스 코드가 각 레이어의 `liveValue`를 최소 한 번은 명시적으로 참조해야 한다.

### 발견 2 — `URLSession.bytes(for:).lines`가 SSE 프레임 구분용 빈 줄을 넘겨주지 않음

증상: 발견 1을 고친 뒤 실제 200 응답과 SSE 데이터는 받아오지만, 매번 `NetworkError.decodingFailed`로 스트림이 끝남. 원인 추적을 위해 원시 라인을 출력해보니, 실제 Claude Messages API 응답을 `bytes.lines`로 순회했을 때 **빈 문자열 라인이 단 한 번도 나오지 않았다** — `event:`/`data:` 라인은 정확히 분리되는데, 그 사이의 빈 줄(SSE 프레임 구분자)만 사라진다. 그 결과 `SSEFrameReader`가 빈 줄에서만 dispatch하도록 되어 있어 EOF까지 전체 스트림(8개 이벤트)을 통째로 한 프레임에 누적했고, `flush()`가 8개의 JSON을 개행으로 이어붙인 문자열을 반환해 `JSONDecoder`가 깨졌다.

이 버그는 이전 세션의 `SSEFrameReaderTests` 6케이스로는 절대 잡을 수 없었다 — 그 테스트들은 전부 빈 줄을 `feed("")`로 **수동으로 직접 공급**했기 때문에, 테스트가 `URLSession.bytes(for:).lines`의 실제 런타임 동작을 검증한 적이 없었다.

수정: `Networking/Sources/SSE/SSEFrameReader.swift` — `event:` 라인이 도착했는데 이미 누적된 `data`가 있으면(빈 줄 구분자 없이 바로 다음 프레임이 시작된 것으로 판단) 이전 프레임을 먼저 dispatch하도록 `feed(_:)`를 수정. 기존 빈 줄 dispatch 경로는 그대로 유지해 6개 기존 테스트와 100% 호환. 회귀 테스트 1개(`test_빈줄_구분자_없이_event_라인이_곧바로_이어져도_이전_프레임이_dispatch된다`) 신규 추가.

---

## 범위 밖

- `App` 타겟의 `Networking`/`Data` 미링크(발견 1과 같은 계열의 기존 공백, SSE만의 문제 아님) — 별도 작업으로 남김.
- 대화 히스토리 / 메시지 목록 UI / 재시도 / 스트림 중단 버튼.
- 스트리밍 중 `MarkdownView` 재파싱 성능 최적화.

---

# 하위 작업 2: 스트리밍 텍스트 꼬리 페이드 인 효과

- 전체 설계/SOLID 리뷰: `.harness/plans/resilient-stargazing-hoare.md`
- 사용자 지시: 스트리밍 중인 블록의 꼬리를 서서히 나타나게, 매 SSE 청크 도착("틱")마다 경계 재계산.
- 테스트: 사용자 지시로 **전부 테스트 불필요** (빌드 검증 + Example 실 스트리밍 영상 확인으로 대체).

## 체크리스트

- [x] Plan Mode 설계 + `solid-review` 실행 (`MarkdownTailFader` SRP 분리, `MarkdownView` 파라미터명 `fadesTail`로 DIP 정리, 스타일러 순회 방식 유지 — 3건 모두 설계에 반영 완료)
- [x] `MarkdownTailOpacityAttribute.swift` 신규 작성
- [x] `MarkdownHighlightAttribute.swift`의 `MarkdownAttributeScope`에 `markdownTailOpacity` 등록
- [x] `MarkdownBlock+TailText.swift` 신규 작성 — `replacingTailText(_:)`
- [x] `MarkdownTailFader.swift` 신규 작성 — 문자 단위 불투명도 보간/스탬핑
- [x] `MarkdownInlineStyler`에 불투명도 소비 로직 추가 (전경색 + 배경색)
- [x] `MarkdownView`에 `fadesTail: Bool = false` 인자 추가
- [x] `ChatBotContentView`에서 `fadesTail: viewModel.isStreaming` 전달
- [x] **범위 수정 1(사용자 요청)**: 청크 단위 공개 → 단어 단위 공개로 변경. `ChatBotViewModel.didTapSend()`가
      청크를 `wordChunks(of:)`로 쪼개 단어(+뒤 공백)씩 `streamedText`에 붙임.
      최초 설계의 가정 A4("ViewModel은 건드리지 않는다")를 대체함 — 페이드 커브·꼬리 선정 로직은
      변경 없음, 오직 "언제 텍스트가 나타나는가"만 ViewModel에서 세분화.
- [x] **범위 수정 2(사용자 요청)**: 처음엔 단어 사이 인위적 지연 없이 `Task.yield()`만 사용했으나,
      실기기 확인 결과 "너무 빠르다"는 피드백을 받아 `wordRevealDelay: Duration`
      상수와 `try? await Task.sleep(for:)`로 교체 — 단어마다 실제 타이핑 속도의 지연을 둠.
      1차 80ms → 사용자가 "조금 더 천천히"를 요청해 **180ms로 재조정**(현재 값). 필요하면 이 상수만 바꾸면 됨.
- [x] 검증용 임시 `-autoSend` 훅(ChatBotContentView) 제거 — 사용자가 시뮬레이터에서 직접 확인하기로 함
- [x] `tuist generate` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample`/`FiveVoca` 둘 다 경고 0개로 빌드 성공 (테스트 검증)
- [x] `tuist test AllTest --no-selective-testing` 회귀 통과 확인 — 범위 수정 1·2 이전에 실행,
      이후 변경은 `ChatBotViewModel`/`ChatBotContentView`(둘 다 테스트 대상 아님)로 국한돼 재실행 불필요로 판단
- [ ] Example 실행 → 실 스트리밍 중 꼬리 그라데이션 + 단어 단위 타이핑 육안 확인 — **사용자가 직접 확인 예정**
      (세션에 UI 자동화 도구가 없어 이번엔 자동 검증을 시도했으나, 사용자 지시로 중단하고 검증용 임시 훅 제거함)
- [ ] 검증용 임시 코드 전량 제거 확인
- [ ] 변경 파일 및 검증 결과 요약 (테스트 검증 / 코드 확인 구분)

---

# 하위 작업 3: Figma 디자인 적용 (문법 분석 바텀시트)

- 전체 설계/SOLID 리뷰: `.harness/plans/jolly-puzzling-taco.md`
- 디자인 출처: Figma `node-id=51-55`("A · 빈 대화"), `node-id=74-128`("A · 빈 대화 — 입력 확장")
  — 같은 화면의 두 상태(빈 입력 / 입력 확장)로, 헤더+AnalysisCard+구분선+채팅 영역은 동일하고
  입력 필드의 높이만 다르다.
- 요약: 검증용 최소 UI(TextField+Button)를, 단어 상세 위에 뜨는 문법 분석 바텀시트로 재구성.
  헤더("문법 분석" + AnalysisCard) / 구분선 / 채팅 영역(기존 MarkdownView 재사용) / 구분선 /
  다중 행 입력 바(원형 전송 버튼)로 구성. WordDetailExampleRow의 NLTagger 하이라이트 로직을
  DesignSystem의 `SentenceHighlighter`로 추출해 AnalysisCard와 공용화(기존 TODO 해소).
- 사용자 결정: 이번 작업 범위는 **ChatBot 모듈 UI만** (WordDetail 진입점 배선은 범위 밖).
  테스트는 **전부 테스트 불필요** — 빌드 검증 + Example 앱 실행 육안 확인으로 대체.

## 체크리스트

- [x] `solid-review` 스킬 실행 (구현 착수 전) — 설계 변경 없음, `ChatBotInputBar.maxLines`만
      하드코딩 대신 파라미터화(기본값 5) 반영
- [x] `DesignSystem/Sources/SentenceHighlighter.swift` 신규 작성 (NLTagger 로직 이동 + 폰트 주입)
- [x] `WordDetailExampleRow.swift`에서 하이라이트 로직 6개 메서드 제거 → 공용 타입 호출로 교체
- [x] `ChatBotContext.swift` 신규 작성
- [x] `AnalysisCardView.swift` 신규 작성 (칩 + 하이라이트 예문)
- [x] `ChatBotInputBar.swift` 신규 작성 (가변 높이 필드 + 원형 전송 버튼)
- [x] `ChatBotContentView.swift` 재작성 (헤더 / 구분선 / 채팅 영역 / 입력 바)
- [x] `ChatBotView.swift` 수정 (NavigationStack 제거, context 주입, Preview 갱신)
- [x] `ChatBotViewModel.swift` 수정 (`init(context:)`)
- [x] `ChatBotExampleApp.swift` 수정 (시트 프레젠테이션 + 샘플 context)
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBot` / `FeatureChatBotExample` / `FiveVoca` 빌드 성공
      (테스트 결정과 무관하게 항상 수행) — 경고 0개(FiveVoca의 AccentColor 경고 1건은
      본 작업과 무관한 기존 이슈)
- [x] `tuist test AllTest --no-selective-testing` 회귀 없음 확인
      (`WordDetailExampleRow` 수정이 FeatureVocabulary에 영향을 주므로 필수) — 전체 통과
- [x] `swift-lint` 스킬로 신규/수정 파일 스타일 점검 — `ChatBotContext.init` 3-파라미터
      한 줄 작성 1건 발견 후 수정, 그 외 위반 없음(계산 프로퍼티 뷰 분리·중첩 컨테이너는
      `HomeLoadingView` 등 기존 코드베이스 선례와 일치해 위반으로 보지 않음)
- [x] Example 앱 시뮬레이터 실행 → 디자인 2개 상태(빈 입력 / 3행 확장) 육안 대조 —
      Claude가 임시 디버그 값(isPresented=true, input 프리필)으로 스크린샷 확인 후 즉시 원복.
      **사용자가 직접 재확인 예정**(사용자 요청으로 이후 자동화 검증 중단)
- [x] 검증용 임시 코드 원복 확인 — `isPresented = false`, `input = ""`로 원복 후 빌드 재확인 완료
- [x] 변경 파일 요약 (테스트 검증 vs 코드 정독 추정 분리)

### 범위 수정(사용자 요청): 바텀시트 → 네비게이션 push 전체 화면

Figma 목업은 바텀시트였지만(가정 A5), 사용자가 실제로는 **바텀시트가 아니라 네비게이션
push로 전체 화면을 채워야 한다**고 정정 — A5를 대체.

- [x] `ChatBotView.swift` 수정 — `NavigationBarBackButtonHidden(true)` +
      `ToolbarItem(.topBarLeading)` chevron.left "뒤로" 버튼 추가. 저장소 내 동일 push
      화면 선례(`ChunkReaderView`/`WordDetailView`)와 동일한 패턴 재사용, 새 컨벤션 만들지 않음.
- [x] `ChatBotExampleApp.swift` 수정 — `.sheet`+`presentationDetents` 제거,
      `NavigationStack` + `NavigationLink`로 push 데모로 교체 (`ChatBotSheetDemoView` →
      `ChatBotPushDemoView`)
- [x] `tuist generate` + **빌드 검증** — `FeatureChatBotExample`/`FiveVoca` 빌드 성공, 경고 0개
- [x] Example 앱 실행 → push 전체 화면 육안 확인 — **사용자가 직접 확인**

### 후속 디자인 수정 (사용자 요청, 소규모)

- [x] 헤더의 "문법 분석" 라벨 텍스트 제거 (AnalysisCard 안의 칩 라벨은 유지)
- [x] `ChatBotInputBar` 텍스트 세로 정렬 수정 (`.frame(minHeight: 30)`로 1행일 때 전송
      버튼과 같은 높이 안에서 중앙 정렬, 다중 행일 땐 자연스럽게 확장)
- [x] 빌드 검증 — `FeatureChatBotExample` 성공, 경고 0개

---

# 하위 작업 4: ChatBot 메시지 리스트(대화 히스토리) 도입

- 전체 설계/SOLID 리뷰: `.harness/plans/jolly-puzzling-taco.md` (이전 하위 작업 3의 계획을
  대체 — 하위 작업 3 자체는 이미 구현·검증 완료, 위 체크리스트에 기록됨)
- 디자인 출처: Figma `node-id=25-2`("A · AI 응답 대기")
- 요약: 단발 스트리밍 응답(`streamedText: String` 하나)을, 사용자 질문(우측 초록 말풍선)과
  AI 응답(좌측 흰 말풍선, 대기 중엔 스피너)이 쌓이는 대화 히스토리 리스트로 재구성.
  Figma 대비 사용자 정정 5가지: (1) 스피너는 시스템 `ProgressView`로 단순화, (2) 시드
  메시지 없이 항상 user→assistant 순서, (3) "AI 튜터" 라벨 제거, (4) AI 말풍선 가로 여백은
  기존 `.padding(16)` 재사용, (5) 전송 시 입력창 초기화.
- 사용자 결정: 테스트 **전부 불필요**, 자동 스크롤 **제외**(수동 스크롤만).

## 체크리스트

- [x] `solid-review` 스킬 실행 (구현 착수 전) — 설계 변경 없음
- [x] `ChatBotMessage.swift` 신규 작성
- [x] `ChatBotViewModel.swift` 수정 (`messages` 배열, `didTapSend()` 재작성, 입력 초기화)
- [x] `ChatBotMessageRow.swift` 신규 작성 (역할별 좌/우 라우팅)
- [x] `ChatBotUserBubbleView.swift` 신규 작성
- [x] `ChatBotAssistantBubbleView.swift` 신규 작성 (대기 상태 + 텍스트 상태)
- [x] `ChatBotContentView.swift`의 `chatArea` 재작성 (메시지 리스트 + 에러 라인)
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개
- [x] `swift-lint` 스킬로 신규/수정 파일 스타일 점검 — `ChatBotMessage(role:text:isGenerating:)`
      3-파라미터 호출 한 줄 작성 2건 발견 후 수정(`ChatBotViewModel.swift`,
      `ChatBotAssistantBubbleView.swift` Preview), 그 외 위반 없음
- [x] 변경 파일 요약 (테스트 검증 vs 코드 정독 추정 분리) — 시각 확인은 사용자가 직접 진행

---

# 하위 작업 5: 입력바 플로팅 글래스모피즘 전환 (+ 컨텐츠 가림 버그 수정)

- 전체 설계/SOLID 리뷰: `.harness/plans/jolly-puzzling-taco.md` (하위 작업 4의 계획을 대체)
- 사용자 재현: 다중 행 입력 시 마지막 채팅 메시지가 입력바에 가려짐(버그).
- 요약: 원인은 `VStack` 고정 행 구조 — `chatArea.safeAreaInset(edge: .bottom) { inputBar }`로
  전환해 스크롤 컨텐츠가 입력바 높이만큼 자동으로 하단 여백을 갖도록 구조적으로 수정.
  동시에 입력바 배경을 iOS 26+ `.glassEffect()`로, 그 미만은 기존 `bgSubtle` 폴백으로 분기
  (배포 타겟 18.0 유지, 사용자 결정).
- 사용자 결정: 테스트 **전부 불필요**. 배포 타겟 상향 **거부**(`if #available` 폴백 채택).

## 체크리스트

- [x] `solid-review` 스킬 실행 (구현 착수 전) — 설계 변경 없음
- [x] `ChatBotInputBar.swift` 수정 — `ChatBotInputBarBackground` modifier 추출,
      `if #available(iOS 26.0, *)` 분기(글래스/폴백)
- [x] `ChatBotContentView.swift` 수정 — `inputBar`를 `VStack` 행에서 제거,
      `chatArea.safeAreaInset(edge: .bottom) { inputBar }`로 이동, 채팅-입력바 사이
      `separator` 호출 제거
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개
      (iOS 26 시뮬레이터 기준 — `.glassEffect()` 분기 컴파일 확인)
- [x] `swift-lint` 스킬로 수정 파일 스타일 점검 — 위반 0건
- [x] 변경 파일 요약 (테스트 검증 vs 코드 정독 추정 분리) — 시각 확인은 사용자가 직접 진행

### 후속 수정 (사용자 요청): 챗봇 화면에서 탭바 숨김

- [x] `ChatBotView.swift`에 `.toolbar(.hidden, for: .tabBar)` 추가 — 저장소 선례
      (`Projects/Feature/Home/Sources/Home/HomeView.swift:35`의 `.toolbar(_:for: .tabBar)`
      패턴)를 따르되, 목적지 뷰(`ChatBotView`) 자신에 선언해 어느 탭에서 push되든
      자동으로 탭바가 숨겨지고 뒤로 가면 복원되게 함(호출부마다 조건부 상태를 따로 두지
      않아도 되는 더 견고한 위치)
- [x] `tuist generate` + **빌드 검증** — `FeatureChatBotExample`/`FiveVoca` 빌드 성공, 경고 0개

### 후속 수정 (사용자 요청): AnalysisCard를 고정 헤더가 아닌 스크롤 컨텐츠로 전환

- [x] `ChatBotContentView.swift` 수정 — `header`/`separator`(헤더-채팅 구분선) computed
      property 제거, `AnalysisCardView`를 `chatArea`의 `LazyVStack` 첫 항목으로 이동.
      더 이상 고정 헤더가 아니라 메시지와 함께 스크롤되어 화면 밖으로 사라짐. 입력바
      플로팅(`safeAreaInset`)은 변경 없음.
- [x] `tuist generate` + **빌드 검증** — `FeatureChatBotExample`/`FiveVoca` 빌드 성공, 경고 0개

### 후속 수정 (사용자 요청): ChatGPT 스타일 "전송 시 위로 스크롤 + 빈 공간" 도입

사용자 지시로 하위 작업 4의 "자동 스크롤 제외" 결정을 대체 — 새 요구사항이 이전 결정보다
우선한다.

- [x] `ChatBotContentView.swift` 수정 — `chatArea`를 `GeometryReader` + `ScrollViewReader`로
      감싸고, 각 메시지 행에 `.id(message.id)` 부여. 전송으로 `messages.count`가 바뀌면
      마지막 유저 메시지로 `anchor: .top` 스크롤(`withAnimation`). 마지막 메시지가
      assistant일 땐 `.frame(minHeight: geometry.size.height, alignment: .top)`을 줘서
      응답이 짧아도 뷰포트 높이만큼 빈 공간이 남게 함(ChatGPT와 동일한 시각 효과)
- [x] `tuist generate` + **빌드 검증** — `FeatureChatBotExample`/`FiveVoca` 빌드 성공, 경고 0개
- [x] `swift-lint` 스킬로 수정 파일 스타일 점검 — 위반 0건

### 후속 버그 수정 (사용자 요청): 컨텐츠가 네비게이션 바 아래로 파고듦

원인: `GeometryReader`는 안전 영역(safe area)을 무시하고 자신에게 주어진 프레임을 그대로
차지한다 — 방금 추가한 스크롤-투-탑 기능으로 메시지가 화면 맨 위까지 스크롤되면서 그
동작이 처음으로 드러남(이전엔 사용자가 그렇게까지 위로 스크롤할 일이 없었음).

- [x] `ChatBotContentView.swift` 수정 — `GeometryReader`를 제거하고 iOS 18
      `.onGeometryChange(for:of:action:)`로 교체(`@State private var chatAreaHeight`에
      측정값 저장). 이 API는 레이아웃에 영향을 주지 않고 크기만 관찰해 안전 영역을
      정상적으로 존중한다.
- [x] `tuist generate` + **빌드 검증** — `FeatureChatBotExample`/`FiveVoca` 빌드 성공, 경고 0개

---

# 하위 작업 6: iOS 26 Liquid Glass 네비게이션 바 — 컨텐츠 가림 버그 수정

- 전체 설계/웹 리서치: `.harness/plans/jolly-puzzling-taco.md`
- 사용자 재현: "네비게이션 영역 때문에 챗봇 컨텐츠가 위로 스크롤하면 짤린다" — iOS 26에서
  상단 영역이 제거됐다고 알고 있는데도 여전히 발생한다는 가설.
- 실제 원인(웹 리서치로 확인, 가설과 다름): iOS 26에서 `NavigationStack`은 자동으로
  Liquid Glass + 스크롤 엣지 이펙트를 갖는데, `ChatBotView.swift`의 커스텀
  `.toolbarBackground(...)` 2줄(하위 작업 3에서 `WordDetailView`/`ChunkReaderView` 선례를
  따라 추가)이 그 네이티브 동작을 강제로 덮어써 스크롤 엣지 이펙트가 깨지고, 그 결과
  컨텐츠가 네비게이션 바 영역에 가려 짤림. 하위 작업 5의 "전송 시 위로 스크롤" 기능이
  사용자를 그 위치까지 스크롤하게 만들면서 처음 드러남.
- 사용자 결정: 테스트 **전부 불필요**. `WordDetailView`/`ChunkReaderView`의 동일 패턴은
  범위 밖(발견 사항으로만 남김, 다른 기능 모듈이라 임의로 고치지 않음).

## 체크리스트

- [x] `solid-review` 스킬 실행 (구현 착수 전) — 설계 변경 없음
- [x] `ChatBotView.swift` 수정 — `ChatBotNavigationBarBackground` modifier 추출,
      `if #available(iOS 26.0, *)` 분기(iOS 26+는 커스텀 배경 생략, 미만은 기존 유지)
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개
      (iOS 26 시뮬레이터 기준 — 신규 분기 컴파일 확인)
- [x] `swift-lint` 스킬로 수정 파일 스타일 점검 — 위반 0건
- [x] 변경 파일 요약 (테스트 검증 vs 코드 정독 추정 분리) — 시각 확인은 사용자가 직접 진행

### 후속 수정 (사용자 요청): iOS 26 글래스 입력바에 배경과 구분되는 색조 추가

기본 `.regular` 글래스는 투명도만 있고 색조가 없어, 흰색 챗봇 배경과 거의 구분이 안 됐다.

- [x] `ChatBotInputBar.swift` 수정 — `ChatBotInputBarBackground`의 iOS 26+ 분기를
      `.glassEffect(.regular.tint(DesignSystemAsset.bgSubtle.swiftUIColor), in: .rect(cornerRadius: 22))`로
      변경. 폴백(iOS 18~25)과 같은 `bgSubtle` 토큰을 재사용해 두 경로의 룩을 일관되게 함.
- [x] `tuist generate` + **빌드 검증** — `FeatureChatBotExample`/`FiveVoca` 빌드 성공, 경고 0개

### 하위 작업 7: 챗봇 메시지가 네비게이션 영역을 침범하는 버그 수정

하위 작업 6에서 iOS 26+ 커스텀 `toolbarBackground`를 제거해 "컨텐츠가 바에 가려 짤림"을
고쳤는데, 반대로 네비게이션 바가 완전 투명해지면서 전송 후 자동 스크롤(`scrollTo(anchor:
.top)`)이 유저 메시지를 상태바/뒤로가기 버튼 영역까지 밀어 올리는 부작용이 생겼다 —
사용자가 스크린샷으로 확인. `scrollEdgeEffectStyle(.hard, for: .top)`(iOS 26+)로 상단
스크롤 엣지를 하드 컷오프시켜, 컨텐츠가 그 영역에 그려지지 않게 했다.

- [x] `solid-review` 스킬 실행 (구현 착수 전) — 설계 변경 없음
- [x] `ChatBotContentView.swift` 수정 — `ChatBotScrollEdgeEffect` modifier 추가,
      `chatArea`의 `ScrollView`에 적용(iOS 26+ `.hard` 상단 엣지, 미만은 무변경)
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개
      (iOS 26 시뮬레이터 기준 — 신규 API 컴파일 확인)
- [x] `swift-lint` 스킬로 수정 파일 스타일 점검 — 위반 0건
- [x] 변경 파일 요약 (테스트 검증 vs 코드 정독 추정 분리) — `.hard`가 요구사항 2(보낸
      메시지가 바 아래에 온전히 보임)까지 함께 해결한다는 것은 가정(A1, 문서 근거)이며
      시뮬레이터로 확인한 사실이 아님 — 시각 확인은 사용자가 직접 진행

#### 하위 작업 7 재수정: `.hard`가 효과 없어 상단 여백 상수 방식으로 교체

사용자 재테스트 결과 `scrollEdgeEffectStyle(.hard, ...)`는 효과가 없었다(오히려 더
블러처럼 보임) — `scrollEdgeEffectStyle`은 컨텐츠가 그 좌표에 위치하는 것 자체를 막지
못하고 페이드 방식만 바꾼다는 게 재조사로 드러남(A1 폐기). 대신 `chatArea`의 `LazyVStack`
맨 앞에 iOS 26+ 전용 상단 여백(44pt, 상수)을 예약해 `scrollTo(anchor: .top)`가 메시지를
네비게이션 바 영역까지 올릴 수 없게 만들었다 — 이 구간은 배경색뿐이라 유리 재질 아래로
비쳐도 눈에 띄지 않는다. `ChatBotScrollEdgeEffect`(`.hard`)는 해가 되지 않아 유지.

- [x] `solid-review` 스킬 재실행 — `ViewModifier` 대신 계산 프로퍼티로 처리(과설계 방지)
- [x] `ChatBotContentView.swift` 수정 — `.padding(16)`을 수평/상단/하단으로 분리,
      `chatTopPadding` 계산 프로퍼티 추가(iOS 26+: 44, 미만: 0)
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개
- [x] `swift-lint` 스킬로 수정 파일 스타일 점검 — 위반 0건
- [x] 변경 파일 요약 — 44pt는 상수/추정값(A1 신규)이며 시뮬레이터로 확인한 사실이 아님,
      부족하면 값 조정 필요 — 시각 확인은 사용자가 직접 진행

### 하위 작업 8: 챗봇 네비게이션/탭바 전면 기본화 (커스텀 전부 제거)

하위 작업 6·7에서 iOS 26 Liquid Glass 네비게이션 바를 커스터마이즈하며 세 번 연속 다른
증상의 버그가 났다(가림 → 침범 → 미해결). 사용자가 방향을 바꿔 커스텀을 전부 걷어내고
시스템 기본 네비게이션/탭바로 되돌리기로 결정 — `ChatBot` 모듈 전체를 grep으로 재검토해
네비게이션 관련 커스터마이즈가 `ChatBotView.swift`/`ChatBotContentView.swift` 외에 더
없음을 확인했다.

- [x] `solid-review` 스킬 실행 — 순수 삭제 작업, 설계 변경 없음
- [x] `ChatBotView.swift` 수정 — `navigationBarBackButtonHidden`, 커스텀 뒤로가기
      `ToolbarItem`, `ChatBotNavigationBarBackground`(modifier+구조체), `.toolbar(.hidden,
      for: .tabBar)`, 미사용 `@Environment(\.dismiss)`, 미사용 `DesignSystem` import 삭제
- [x] `ChatBotContentView.swift` 수정 — `chatTopPadding` 계산 프로퍼티와 적용 삭제
      (`.padding(16)`로 원복), `ChatBotScrollEdgeEffect`(modifier+구조체) 삭제
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개
- [x] `swift-lint` 스킬로 수정 파일 스타일 점검 — 위반 0건
- [x] 변경 파일 요약 — 기본 네비게이션에서 `scrollTo(anchor: .top)`가 문제없는지는 가정
      (A1)이며 시뮬레이터로 확인한 사실이 아님 — 시각 확인은 사용자가 직접 진행

### 하위 작업 9: SSE 스트리밍 취소

전송 버튼을 스트리밍 중엔 취소 버튼으로 바꾸고, 탭하면 기존에 이미 배선돼 있던
`Task.cancel()` → `onTermination` → `URLSession` 취소 체인을 실제로 발동시킨다. 취소를
에러로 오인하지 않고, 누적된 텍스트를 보존하며, 빈 자리표시 메시지를 정리하도록
`ChatBotViewModel`의 종료 처리를 고쳤다. Figma `node-id=25-50` 확인 결과 취소 버튼은
전송 버튼과 동일한 30×30 `study300` 원형에 흰 정지 아이콘만 다름.

과설계 방지 차원에서 초안에 있던 "취소 시 남은 단어 플러시" 로직, `isCancellation` 헬퍼,
전용 `ChatBotSendButton` 타입/파일을 계획 단계에서 제거했다(자세한 근거는
`.harness/plans/jolly-puzzling-taco.md`의 "비판적 재검토" 절 참고).

- [x] `solid-review` 스킬 실행 — 설계 변경 필요 없음, 계획대로 진행
- [x] `ChatBotViewModel.swift` 수정 — `didTapCancel()` 추가, `try?`→`try`(취소 시 즉시
      멈추도록), 취소/에러 구분(`!Task.isCancelled`), 빈 자리표시 제거를 종료 공통 경로로
      이동, `streamTask`를 `private(set)`으로 테스트에 노출
- [x] `ChatBotInputBar.swift` 수정 — `ChatBotSendButtonState` enum 추가, `canSend`→`state`,
      `onCancel` 추가, 인라인 Button→`sendButton`/`buttonIcon`, 프리뷰 갱신(+취소 상태 프리뷰)
- [x] `ChatBotContentView.swift` 수정 — `inputBar`에서 ViewModel 상태→버튼 상태 변환 +
      `onCancel` 연결
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개
- [x] `ChatBotTests.swift`에 테스트 3건 작성(스트리밍 중 취소/첫 응답 전 취소/실제 실패)
- [x] **테스트 실행** — `FeatureChatBotTests` 32건 전체 통과(신규 3건 포함)
- [x] `swift-lint` 스킬로 수정 파일 점검 — doc comment 위치 오류 1건(구현 중 실수) 발견 즉시
      수정, 파라미터 줄바꿈 P2 1건 정리
- [x] 변경 파일 요약 — 취소 체인이 실제로 즉시 멈추는지(180ms 타이핑 지연 내)는 테스트로
      검증(48ms에 통과). 버튼 UI가 실제 기기에서 기대대로 바뀌는지는 시뮬레이터 시각
      확인이 필요하며 사용자가 직접 진행

### 하위 작업 10: 챗봇 탭바 다시 숨기기

하위 작업 8에서 사용자 요청으로 탭바를 보이게 바꿨으나, 사용자가 다시 숨겨달라고 요청 —
네비게이션 바/뒤로가기 버튼 기본화(하위 작업 8 요구사항 1·2)는 그대로 유지, 탭바 가시성만
되돌린다.

- [x] `ChatBotView.swift`에 `.toolbar(.hidden, for: .tabBar)` 추가
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample`(경고 9건, 전부 Data 레이어의 기존
      `DependencyKey` 적합성 경고로 이 변경과 무관) / `FiveVoca`(경고 0개) 빌드 성공
- [x] `swift-lint` 스킬로 수정 파일 점검 — 위반 0건
- [x] 변경 파일 요약 — 실제 탭바가 안 보이는지는 사용자가 직접 확인 필요
