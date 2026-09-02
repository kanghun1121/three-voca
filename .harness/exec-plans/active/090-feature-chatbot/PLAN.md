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

### 하위 작업 11: (취소) 취소 후 빈 공간 버그 — 플랜 작성 중 사용자가 방향 전환 요청

사용자가 하위 작업 12(아래) 요청으로 넘어가면서 이 플랜은 실행 없이 폐기됨. `.harness/plans/jolly-puzzling-taco.md`도 사용자 요청으로 비웠음. 별도 기록 없음.

### 하위 작업 12: content_block_delta 단위로 즉시 스트리밍 (합성 타이핑 효과 제거)

기존에는 SSE 델타를 받을 때마다 단어 단위로 재분할해 고정 지연(80ms/단어)으로 타이핑
효과를 합성했다. Domain/Data/Networking 계층은 이미 `content_block_delta` 프레임 하나당
텍스트 하나를 그대로 넘겨주고 있음을 코드로 재확인했고(`ClaudeSSEParser.swift`,
`ChatRepository+Live.swift`), 배칭은 오직 `ChatBotViewModel`의 단어 재분할+지연 루프에서
발생하고 있었다. 이 루프를 제거하고 델타 도착 즉시 반영하도록 바꿨다.

- [x] `solid-review` 스킬 실행 — 설계 변경 필요 없음, 계획대로 진행
- [x] `ChatBotViewModel.swift` 수정 — 단어 재분할+`Task.sleep` 이중 루프를 단일
      `for try await chunk in ...` + 즉시 반영 + `try Task.checkCancellation()`으로 교체,
      `wordRevealDelay`/`wordChunks(of:)` 삭제
- [x] `ChatBotTests.swift`의 `waitUntil` doc comment 갱신(180ms 타이핑 연출 언급 제거)
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개
- [x] **테스트 실행** — `FeatureChatBotTests` 32건 전체 통과(하위 작업 9 취소 테스트 3건
      포함, 회귀 없음)
- [x] `swift-lint` 스킬로 수정 파일 점검 — 위반 0건
- [x] 변경 파일 요약 — 델타 도착 즉시 반영이 실제로 "더 자연스러운" 애니메이션으로
      느껴지는지는 사용자가 실제 API 응답으로 직접 확인 필요

### 하위 작업 12 정정: 80ms 의도적 지연 복원

사용자가 "의도적 지연은 80ms으로 그대로 놔둔다"고 정정 — 배칭(단어 재분할) 자체가 아니라
지연을 없앤 것이 문제였다. `AskUserQuestion`으로 "델타당 80ms" vs "원래대로(단어별 80ms)"
확인 결과 **원래 방식(단어 재분할 + 단어마다 80ms)으로 완전 복귀**를 선택 — 하위 작업 12에서
제거했던 `wordRevealDelay`/`wordChunks(of:)`와 이중 for문을 그대로 되살렸다.

- [x] `ChatBotViewModel.swift` — `wordRevealDelay`(80ms)와 `wordChunks(of:)` 복원, 단일
      `for try await chunk` + `checkCancellation()`을 원래의 이중 for문(단어 재분할 +
      `Task.sleep`)으로 되돌림
- [x] `ChatBotTests.swift`의 `waitUntil` doc comment도 "80ms 타이핑 연출" 언급으로 되돌림
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample`(경고 9건, 기존 Data 레이어 무관 경고) /
      `FiveVoca`(경고 0개) 빌드 성공
- [x] **테스트 실행** — `FeatureChatBotTests` 32건 전체 통과(회귀 없음)

### 하위 작업 13: 챗봇 상단 콘텐츠를 네비게이션 인셋에 맞춤

화면 진입/맨 위 스크롤 시 `AnalysisCardView` 상단이 투명 Liquid Glass 네비게이션 바 뒤로
비쳐 보이는 문제 — `AskUserQuestion`으로 "침범/블러 없이 바 아래에서 시작" 확인.
`scrollEdgeEffectStyle`(하위 작업 7)로는 콘텐츠 배치 자체를 막을 수 없다는 게 이미
검증돼 있어, 콘텐츠 쪽 인셋 계산이 아니라 `WordDetailView`/`ChunkReaderView`가 이미 쓰는
불투명 `toolbarBackground` 패턴을 재사용 — 하위 작업 8의 "네비게이션 배경 커스텀 금지"
결정에 대한 사용자의 명시적 정정으로 처리(뒤로가기 버튼/탭바 관련 결정은 그대로 유지).

- [x] `solid-review` 스킬 실행 — 설계 변경 필요 없음, 검증된 패턴 재사용
- [x] `ChatBotView.swift` 수정 — `toolbarBackground(색상, for: .navigationBar)` +
      `toolbarBackground(.visible, for: .navigationBar)` 2줄 추가, `import DesignSystem` 복원
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample`(경고 12건, 전부 Networking/Data 레이어의
      기존 `DependencyKey` 적합성 경고로 무관) / `FiveVoca`(경고 0개) 빌드 성공
- [x] `swift-lint` 스킬로 수정 파일 점검 — 위반 0건
- [x] 변경 파일 요약 — AnalysisCard가 실제로 바 아래에서 깔끔하게 시작하는지는 사용자가
      직접 확인 필요(시뮬레이터 UI 자동화 도구 없음)

### 하위 작업 13 되돌림: 사용자 요청으로 변경 제거

사용자가 방금 변경을 제거해달라고 요청 — `ChatBotView.swift`를 하위 작업 13 이전 상태로
되돌렸다(`toolbarBackground` 2줄, `import DesignSystem` 제거). 네비게이션 바는 다시
완전 기본(하위 작업 8 상태)으로 복귀.

- [x] `ChatBotView.swift` 되돌림
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개

### 하위 작업 14: 스크롤 끝에서도 마지막 유저 메시지가 네비게이션 영역을 침범하지 않게

ChatGPT 참고 스크린샷 + `AskUserQuestion` 확인("네비게이션 바 투명/불투명은 고려 대상
아님, 스크롤이 끝났을 때 마지막 유저 메시지가 네비게이션 영역에 위치하는 것 자체가
문제") — 하위 작업 4/5부터 있던 "마지막 assistant 메시지에 `minHeight: chatAreaHeight`
예약" 메커니즘 자체는 맞는 설계였지만, `chatAreaHeight` 측정값이 상단 안전 영역(iOS 26
스크롤 엣지 이펙트로 시스템이 자동으로 안 챙겨줌)을 반영하지 않아 정확히 그 부족분만큼
침범했다. 하단 입력바와 동일한 `.safeAreaInset(edge: .top)` 패턴으로 상단도 명시적으로
예약해 근본 수정.

- [x] `solid-review` 스킬 실행 — `ChatTopSafeAreaReservation` 별도 ViewModifier는 과설계로
      판단(하위 작업 7의 `chatTopPadding`과 동일 기준) → 계산 프로퍼티 `topReservedHeight`로
      단순화한 뒤 구현
- [x] `ChatBotContentView.swift` 수정 — `ambientTopInset` state + 측정용 `onGeometryChange`
      추가, `navigationBarHeight`(44pt) 상수 추가, `topReservedHeight` 계산 프로퍼티(iOS
      26+: 측정값+44, 미만: 0), `chatArea`에 `.safeAreaInset(edge: .top)` 적용, doc comment 갱신
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개
- [x] `swift-lint` 스킬로 수정 파일 점검 — 위반 0건
- [x] 변경 파일 요약 — A1(측정값+44pt 조합이 정확한 예약량인지)은 검증되지 않은 가정,
      시뮬레이터 UI 자동화 도구 없어 확인 못함 — 사용자가 직접 확인 후 상수 조정 가능

### 하위 작업 14 되돌림: 사용자 요청으로 변경 제거

사용자가 방금 작업을 제거해달라고 요청 — `ChatBotContentView.swift`를 하위 작업 14
이전 상태로 되돌렸다(`ambientTopInset`/`navigationBarHeight`/`topReservedHeight`,
상단 `.safeAreaInset` 전부 제거). 상단 안전 영역 예약 없이 하위 작업 8 이전과 동일한
`chatArea` 상태로 복귀.

- [x] `ChatBotContentView.swift` 되돌림
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개

### 하위 작업 15: 스크롤/전송 시 키보드 자동 내리기

사용자 요청: "스크롤을 해서 화면을 올리거나, 채팅을 보냈을 때 자동으로 키보드를
내려가도록 해줘." `AskUserQuestion`으로 스크롤 시 내림 방식 확인 —
`.interactively`(손가락 따라 내려감) 선택.

원인: (1) 입력바가 `chatArea`의 `.safeAreaInset(edge: .bottom)`에 얹혀 있어 ScrollView
콘텐츠 밖 → 기본값(`.automatic`)으로는 스크롤해도 키보드가 안 내려감. (2)
`ChatBotInputBar`의 `TextField`에 포커스 제어 수단이 없어 전송해도 키보드가 안 내려감.

- [x] `solid-review` — 별도 정책 타입/모디파이어 없이 각 시점(스크롤/전송)에서 한 줄씩
      처리(과설계 방지). 포커스는 `TextField`를 소유한 `ChatBotInputBar`가 책임짐(SRP).
- [x] `ChatBotInputBar.swift` 수정 — `@FocusState private var isInputFocused` 추가,
      `TextField`에 `.focused($isInputFocused)`, `sendButton`이 `didTapSend()` 헬퍼
      호출(포커스 해제 후 `onSend()`) — 취소(`onCancel`)는 그대로 둬 스트리밍 중에도
      다음 질문을 이어 입력할 수 있게 유지
- [x] `ChatBotContentView.swift` 수정 — `chatArea`의 `ScrollView`에
      `.scrollDismissesKeyboard(.interactively)` 추가
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개
      (`FiveVoca` 빌드에 경고 9개가 뜨지만 전부 `Data/Sources/*+Live.swift`의 기존
      `DependencyKey` retroactive-conformance 경고 — 이번 변경과 무관한 사전 존재 경고)
- [x] 기존 테스트 회귀 확인 — `AllTest` 스킴, `FeatureChatBotTests` 3개 포함 32개 전부 통과
- [x] `swift-lint` 스킬로 수정 파일 2개 점검 — 위반 0건
- [x] 변경 파일 요약 — A1(`.interactively`가 safeAreaInset 밖 필드에서도 인터랙티브하게
      동작하는지)은 코드 검토 기반 가정, 시뮬레이터 UI 자동화 도구 없어 실제 제스처
      확인 못함 — 사용자가 직접 확인 필요

### 하위 작업 15 되돌림: 스크롤 시 키보드 내림 제거 (사용자 요청)

사용자 요청: "스크롤로 키보드가 내려가는 경우는 제거해라." `ChatBotContentView.swift`의
`.scrollDismissesKeyboard(.interactively)` 한 줄만 제거 — 전송 시 키보드 내림
(`ChatBotInputBar.swift`의 `@FocusState`/`didTapSend()`)은 그대로 유지.

- [x] `ChatBotContentView.swift` — `.scrollDismissesKeyboard(.interactively)` 제거
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개

### 하위 작업 16: 화면 아무 곳이나 탭하면 키보드 내리기

사용자 요청: "화면을 한번 터치했을 때 키보드가 내려가도록 해줘." 스크롤 제스처로
내리는 방식(하위 작업 15)은 이미 사용자가 제거 요청 — 이번엔 탭 한 번으로 내리는
방식.

포커스를 `ChatBotInputBar`가 계속 혼자 갖고 있으면 "화면 아무 곳" 탭(즉,
`ChatBotContentView`의 `chatArea` 배경)에서 그 포커스를 내릴 방법이 없어, 포커스
소유권을 상위(`ChatBotContentView`)로 옮기고 `ChatBotInputBar`에는
`FocusState<Bool>.Binding`을 파라미터로 내려보내는 구조로 바꿨다(SRP 재조정 — 이제
"누가 포커스를 내리는가"가 두 곳(배경 탭, 전송 버튼)이라 포커스는 두 곳을 모두 아는
공통 상위가 가져야 함).

- [x] `ChatBotInputBar.swift` 수정 — 로컬 `@FocusState` 제거, `isFocused:
      FocusState<Bool>.Binding` 파라미터로 대체, `didTapSend()`가
      `isFocused.wrappedValue = false` 사용. 프리뷰 3개는 `FocusState`를 프로퍼티
      래퍼로만 선언 가능해 `ChatBotInputBarPreview` 래퍼 뷰를 새로 만들어 대응
- [x] `ChatBotContentView.swift` 수정 — `@FocusState private var isInputFocused: Bool`
      추가, `chatArea`에 `.contentShape(Rectangle())` + `.onTapGesture { isInputFocused
      = false }` 추가(배경 탭 시 키보드 내림 — 메시지/버튼 등 컨트롤 위 탭은 그 컨트롤이
      먼저 소비해 영향 없음), `inputBar`에 `isFocused: $isInputFocused` 전달
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개
      (`FiveVoca` 경고 9개는 여전히 `Data/Sources/*+Live.swift`의 기존
      `DependencyKey` retroactive-conformance 경고 — 이번 변경과 무관)
- [x] 기존 테스트 회귀 확인 — `AllTest` 스킴, `FeatureChatBotTests` 3개 포함 32개 전부 통과
- [x] 변경 파일(`ChatBotInputBar.swift`, `ChatBotContentView.swift`) 컨벤션 점검 —
      네이밍/import/파라미터 줄바꿈/주석 스타일 모두 기존 패턴 준수, 위반 없음
- [x] 변경 파일 요약 — 시뮬레이터 UI 자동화 도구가 없어 실제 탭 제스처로 확인 못함,
      코드 검토(contentShape + onTapGesture는 SwiftUI 표준 배경-탭-감지 패턴) 기반
      가정 — 사용자가 직접 확인 필요

### 하위 작업 17: 챗봇 컨텐츠뷰 구분선 제거

사용자 요청: "챗봇 컨텐츠뷰에 구분선이 있는데 이건 제거해라." 코드 검토로 확인한
원인 — AI 응답 마크다운에 수평선(`---`)이 포함되면 `MarkdownBlockParser`가
`.divider` 블록으로 파싱하고, `MarkdownBlockView`가 이를
`MarkdownDividerView`(1pt 높이 `Rectangle` + 상하 8pt 패딩)로 렌더링해 챗봇 말풍선
안에 가로선이 그려졌다.

- [x] `MarkdownBlockView.swift` 수정 — `.divider` 블록은 `EmptyView()`를 반환하도록
      변경. `body`에서도 `.divider`일 때는 블록 공통 상하 15pt 패딩(`content
      .padding(.vertical, 15)`)까지 건너뛰어, 선뿐 아니라 그 자리의 빈 여백도 남지
      않게 함
- [x] `MarkdownDividerView.swift` 삭제 — 참조하는 곳이 `MarkdownBlockView.swift`
      하나뿐이라 대체 후 남은 죽은 코드
- [x] 파서(`MarkdownBlockParser`)는 그대로 유지 — `.divider` 블록 자체(모델/파싱)는
      건드리지 않고 화면 렌더링만 제거. `test_수평선이_파싱된다`는 파서를 검증하는
      테스트라 영향 없음
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개
      (`FiveVoca` 경고 9개는 여전히 `Data/Sources/*+Live.swift`의 기존
      `DependencyKey` retroactive-conformance 경고 — 이번 변경과 무관)
- [x] 기존 테스트 회귀 확인 — `AllTest` 스킴, `FeatureChatBotTests` 3개 +
      `MarkdownBlockParserTests`(`test_수평선이_파싱된다` 포함) 전부 통과, 총 32개
- [x] 변경 파일 요약 — 실제 AI 응답에 수평선이 포함된 케이스는 API 키 없이 재현하지
      못해 코드 검토로만 확인. 시뮬레이터 UI 자동화(tap/typeText)가 이 세션에서
      비활성화돼 있어 실제 채팅 화면에서 시각 확인은 못함 — 사용자가 직접 확인 필요

### 하위 작업 18: 답변 실패 시 에러 카드 + 다시 시도

사용자 요청 + Figma 디자인(node-id=54:9, "bubble" 컴포넌트). 기존엔 스트리밍 실패 시
빨간 `Text` 한 줄만 뜨고 재시도 수단이 없었다 — Figma대로 아이콘+문구+재시도 버튼
카드로 교체하고, 실제 재시도 동작을 새로 연결했다. Plan Mode에서 1차 초안을
"오버엔지니어링 체크" 요청으로 재검토해, `lastFailedMessage` 별도 저장 프로퍼티와
새 테스트 인프라(호출 카운터)를 걷어내고 기존 `messages` 배열 조회 +
`withDependencies` 중첩 오버라이드로 대체했다(자세한 내용은
`.harness/plans/jolly-puzzling-taco.md` §0 참고).

- [x] `solid-review` 관점 재검증(§0/§6, Plan Mode에서 수행)
- [x] Figma `imgErrorIcon` SVG(node 54:2, 정리된 벡터 에셋) 다운로드 →
      `Projects/DesignSystem/Resources/Colors.xcassets/ErrorIcon.imageset/` 등록
      (`preserves-vector-representation: true`, `template-rendering-intent: original`)
      — 다운로드해보니 빨간 원+흰 느낌표가 아니라 옅은 빨강(12% 오퍼시티) 원 배경 +
      진한 빨강 느낌표였다. SF Symbol로 대체했다면 시각적으로 틀렸을 것 — 실제
      에셋을 받기로 한 사용자 선택이 맞았음을 확인.
- [x] `ChatBotErrorView.swift` 신규 작성 — 아이콘(24×24) + 문구(`fg.opacity(0.75)`)
      + "↻ 다시 시도" 버튼(Figma 원본이 아이콘+텍스트가 아니라 텍스트 노드 하나라
      그대로 유니코드 글리프 포함 텍스트로 구현)
- [x] `ChatBotViewModel.swift` — `didTapSend()`에서 스트리밍 처리를 `private func
      send(_:)`로 추출, `didTapRetry()` 추가(`messages.last(where: { $0.role ==
      .user })`로 재시도 대상 조회, 별도 상태 없음), 에러 문구를
      "답변을 가져오지 못했어요"로 변경
- [x] `ChatBotContentView.swift` — 에러 렌더링 지점을 `ChatBotErrorView` +
      `onRetry: { viewModel.didTapRetry() }`로 교체
- [x] `tuist generate --no-open` — `DesignSystemAsset.errorIcon` 생성 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개
      (`FiveVoca` 경고 9개는 여전히 `Data/Sources/*+Live.swift`의 기존
      `DependencyKey` retroactive-conformance 경고 — 이번 변경과 무관)
- [x] `ChatBotTests.swift`에 재시도 테스트 1개 추가 — 재시도 시점에만
      `withDependencies`로 스텁을 성공 스트림으로 바꿔치기해 "실제로 다시
      호출됐는지"를 결과 텍스트로 증명. 최초 작성 시 `waitUntil`이 다단어 텍스트의
      첫 단어 도착만 보고 취소해 실패 — 전체 텍스트 일치로 대기 조건을 고쳐 통과.
      `AllTest` 스킴, 기존 3개 포함 총 33개 회귀 없이 통과
- [x] `swift-lint` 관점 점검 — 수정/신규 파일 모두 기존 네이밍/import/주석 컨벤션
      준수, 위반 없음
- [x] 변경 파일 요약 — 실제 네트워크 실패를 유도한 시각 확인은 사용자가 직접

### 하위 작업 19: 다시 시도 버튼 + SVG 제거 (사용자 요청)

사용자가 "다시 시도 버튼은 제거해라. SVG도"라고 요청 — 하위 작업 18에서 만든
`ChatBotErrorView`(아이콘+문구+버튼)를 걷어내고, 에러 표시를 다시 순수 텍스트
한 줄로 되돌렸다. 버튼이 사라지면 `didTapRetry()`를 호출할 방법이 없으므로 죽은
코드로 남기지 않고 같이 제거 — `send(_:)` 분리도 호출부가 `didTapSend()` 하나만
남아 의미가 없어져 원래의 단일 `didTapSend()`로 합쳤다(불필요한 분리 유지 X).

- [x] `ChatBotErrorView.swift` 삭제
- [x] `Projects/DesignSystem/Resources/Colors.xcassets/ErrorIcon.imageset/` 삭제
- [x] `ChatBotContentView.swift` — 에러 렌더링을 `ChatBotErrorView` 호출에서 순수
      `Text(errorMessage)`(`fg.opacity(0.75)`, 14pt medium)로 되돌림
- [x] `ChatBotViewModel.swift` — `didTapRetry()` 제거, `send(_:)`를 다시
      `didTapSend()`에 합침(단일 호출부라 분리 유지할 이유 없음), 스테일해진
      `didTapCancel()` 주석의 "send" 참조를 "didTapSend"로 정정
- [x] `ChatBotTests.swift` — 재시도 테스트 1개 제거
- [x] `tuist generate --no-open` — `DesignSystemAsset.errorIcon` 접근자가 더는
      생성되지 않음을 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개
      (`FiveVoca` 9개는 여전히 기존 무관 `DependencyKey` 경고)
- [x] 기존 테스트 회귀 확인 — `AllTest` 스킴, `FeatureChatBotTests` 3개(재시도
      테스트 제거 후) 포함 총 32개 통과
- [x] lint 관점 점검 — 잔여 파일에 삭제된 타입/메서드 참조 없음, 컨벤션 위반 없음

### 하위 작업 20: 실패 메시지를 AI 챗봇 메시지로 통합 + SVG 아이콘 복원

사용자 요청: "'답변을 가져오지 못했어요'도 하나의 AI 챗봇 메세지로 처리되어야
한다. 다시 메세지를 보내면 사라지게 된다. 그리고 ! SVG는 살려서 다시 추가해라."
하위 작업 18/19에서 별도 `errorMessage: String?` 상태 + 독립 렌더링으로 처리하던
실패 표시를, `messages` 배열 안의 실제 `ChatBotMessage`(role: .assistant)로
바꿨다 — 스크롤 위치 고정/뷰포트 예약 등 기존 어시스턴트 메시지 처리 로직을 그대로
공유한다. 다만 정상 응답과 달리 다음 전송 시작과 함께 히스토리에서 제거된다.

- [x] `ChatBotMessage.swift` — `isError: Bool = false` 필드 추가(`isGenerating`과
      동시에 true가 될 수 없음을 문서화)
- [x] `Projects/DesignSystem/Resources/Colors.xcassets/ErrorIcon.imageset/` 재생성
      (하위 작업 19에서 삭제한 것과 동일한 SVG — 옅은 빨강 원 + 진한 빨강 느낌표)
- [x] `ChatBotAssistantBubbleView.swift` — `isError` 분기 추가(아이콘 24×24 +
      `fg.opacity(0.75)` 텍스트, 말풍선 배경/그림자 없음), 프리뷰 1개 추가
- [x] `ChatBotViewModel.swift` — `errorMessage` 프로퍼티 완전히 제거. `didTapSend()`
      시작 시 `messages.removeAll(where: { $0.isError })`로 이전 실패 메시지를
      먼저 걷어낸 뒤 새 턴을 시작. 실패 시 빈 assistant 자리표시를 지우는 대신 그
      자리표시의 `text`/`isError`를 직접 채워 넣어 "하나의 AI 메시지"가 되게 함
- [x] `ChatBotContentView.swift` — 별도 에러 렌더링 블록 제거(이제 `messages`
      ForEach 하나로 전부 처리됨)
- [x] `ChatBotTests.swift` — `errorMessage` 참조 3곳을 `messages.last?.isError`
      기반 검증으로 교체, "다음 전송 시 사라진다" 요구사항을 검증하는 어서션을
      기존 실패 테스트에 추가(재작성: `test_실패하면_AI_메시지로_표시되고_다음_전송_시_히스토리에서_사라진다`)
- [x] `tuist generate --no-open` — `DesignSystemAsset.errorIcon` 재생성 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개
      (`FiveVoca` 9개는 여전히 기존 무관 `DependencyKey` 경고)
- [x] 기존 테스트 회귀 확인 — `AllTest` 스킴, `FeatureChatBotTests` 3개 포함 총
      32개 통과
- [x] lint 관점 점검 — 신규/수정 파일 컨벤션 위반 없음

### 하위 작업 21: 스크롤 최하단 이동 버튼 + 입력바 위 페이드아웃

사용자가 ChatGPT 스크린샷 첨부 + 요청: (1) 스크롤이 최하단이 아닐 때 최하단으로
이동하는 원형 버튼, (2) 입력 플레이스홀더 아래가 서서히 페이드아웃되는 효과.
`AskUserQuestion`으로 "입력바를 오버레이+실제 블러로 바꾸는 구조" vs "기존 구조
유지 + 장식 그라디언트"를 물었으나 사용자가 차이를 몰라도 된다며 "서서히
페이드아웃되면 된다"고 확인 — 리스크가 작은 후자(장식 그라디언트, 기존
`.safeAreaInset` 구조 유지)로 결정.

- [x] `ChatBotContentView.swift` — `isScrolledToBottom` 상태 추가,
      `onScrollGeometryChange(for: Bool.self)`로 스크롤 최하단 여부 추적(iOS 18+
      API, 버전 분기 불요 — 배포 타겟 18.0 확인됨), LazyVStack 끝에
      `bottomAnchorID` 앵커 추가, 하단 페이드 `LinearGradient` 오버레이
      (`allowsHitTesting(false)`로 배경 탭 제스처 방해 안 함), 조건부
      `scrollToBottomButton(proxy:)` 오버레이(흰 배경 + 테두리 + 그림자, 입력바
      iOS18 폴백/어시스턴트 말풍선과 같은 톤 재사용) 추가
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개
- [x] 기존 테스트 회귀 확인 — `AllTest` 스킴, `FeatureChatBotTests` 3개 포함 총
      32개 통과(순수 View 변경이라 새 테스트는 계획대로 불필요)
- [x] lint 관점 점검 — 위반 0건
- [x] 변경 파일 요약 — 허용 오차 상수(40pt) 2개는 실기기 확인 후 조정 여지를
      남긴 가정, 시뮬레이터 UI 자동화 도구 없어 실제 제스처/시각 확인은 사용자가
      직접 필요

### 하위 작업 22: 페이드 그라디언트 제거 + 최하단 버튼 등장 임계값 상향

사용자 요청: "블러처리 작업은 우선 제거해라. 그리고 스크롤 최하단 내려가는
버튼은 어느정도 스크롤이 위에 있을 때 떠야한다." — 하위 작업 21의 페이드
그라디언트를 완전히 제거하고, 버튼이 너무 민감하게(40pt만 스크롤해도) 뜨던 것을
한 화면 높이에 가까운 300pt로 올려 "확실히 위로 스크롤했을 때만" 뜨게 했다.

- [x] `ChatBotContentView.swift` — `bottomFadeHeight` 상수 + 하단 `LinearGradient`
      오버레이 블록 전체 삭제, `bottomThreshold`를 40 → 300으로 상향(주석도 갱신)
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 경고 0개
      (`FeatureChatBotExample` 9개는 여전히 기존 무관 `DependencyKey` 경고)
- [x] 기존 테스트 회귀 확인 — `AllTest` 스킴, `FeatureChatBotTests` 3개 포함 총
      32개 통과
- [x] 변경 파일 요약 — 300pt가 "어느 정도"에 정확히 맞는지는 사용자가 실기기에서
      확인 후 조정 가능(상수 하나)

### 하위 작업 23: 입력바 하단 스크롤 엣지 페이드 (iOS 26 네이티브)

사용자 요청: ChatGPT 스크린샷의 "입력 플레이스홀더 아래가 서서히 페이드아웃 +
약간의 블러" 효과 — "네비게이션 부분 뷰가 블러처리되는 것과 비슷한 효과"라는
사용자 설명대로, 이게 SwiftUI가 자체 지원하는지 먼저 확인 후 플랜 작성하라는
지시. 조사 결과 iOS 26의 `ScrollEdgeEffectStyle`/`.safeAreaBar`가 정확히 이
메커니즘이고 iOS 18~25엔 대응 API가 없음을 확인, 사용자가 "iOS 26 네이티브만
(권장)"을 선택(iOS 18 폴백용 수동 그라디언트/블러는 만들지 않음).

- [x] `ChatBotContentView.swift` — `private struct ChatBotBottomBar<Bar: View>:
      ViewModifier` 추가(iOS 26+: `.safeAreaBar(edge: .bottom)`, 미만:
      기존 `.safeAreaInset(edge: .bottom)` 폴백), `chatArea` 하단 입력바 부착을
      `.safeAreaInset(edge: .bottom) { inputBar }` → `.modifier(ChatBotBottomBar { inputBar })`로 교체
- [x] `tuist generate --no-open` 성공 확인
- [x] **빌드 검증** — `FeatureChatBotExample` / `FiveVoca` 빌드 성공, 신규 경고 0개
- [x] 시뮬레이터(iOS 26.2) 빌드+실행 확인 — 앱 정상 기동, 스크린샷 캡처
- [x] 변경 파일 요약 — 이 머신의 시뮬레이터 런타임이 26.0/26.2뿐이라 iOS 18~25
      폴백 경로는 빌드 성공 외 육안 검증 불가(코드는 기존 `safeAreaInset` 그대로라
      동작 변화 없음). 페이드가 ChatGPT처럼 충분히 부드러운지는 사용자가 실기기/
      시뮬레이터에서 직접 확인 필요 — 부족하면 `.scrollEdgeEffectStyle(.soft, for:
      .bottom)` 한 줄 추가하는 후속 조정 여지를 플랜에 남겨둠(2단계, 미적용)

### 하위 작업 24: WordDetail 예문 액션바 교체 + 챗봇 네비게이션 연결

사용자 요청: Figma node-id=129:5 디자인대로 WordDetail 예문의 "끊어읽기" 버튼을
"끊어읽기+챗봇" 2버튼 액션바로 교체하고("에셋도 이걸로 변경"), "챗봇" 버튼을
탭하면 해당 예문을 컨텍스트로 하는 챗봇 화면으로 navigation push. harness-plan →
solid-review 통과 후 구현.

- [x] `AlignLeft.imageset` / `MessageSquare.imageset` 생성 — Figma 실제 SVG
      다운로드(`svgAssets`, `stroke="black"`로 치환), `template-rendering-intent:
      template`로 만들어 `study300` 토큰으로 틴트(ErrorIcon과 달리 단색 스트로크라
      텍스트와 같은 색 토큰 공유)
- [x] `WordDetailPresentationModel.swift` — `level: Int` 필드 추가
- [x] `WordDetail+PresentationModel.swift` — `level: level` 매핑 추가
- [x] `WordDetailExampleRow.swift` — 액션바(2버튼, 끊어읽기는 chunks 있을 때만/
      챗봇은 항상) 구현, `onChatBotTapped` 파라미터 추가
- [x] `WordDetailExamplesView.swift` / `WordDetailContentView.swift` —
      `onChatBotTapped` 콜백 스레딩
- [x] `WordDetailPageView.swift` — `.loaded(let state)` 지점에서 `state` 캡처해
      `onChatBotTapped(state, example)`로 바인딩
- [x] `WordDetailViewModel.swift` — `import FeatureChatBot`, `Destination.chatBot`
      케이스, `didTapChatBot(state:example:)`(`levelLabel: "Level \(state.level)"`,
      가정 A1 — 초급/중급/고급 매핑이 저장소 어디에도 없어 기존
      `VocabularyListHeaderView` 선례인 "Level N" 형식 재사용)
- [x] `WordDetailView.swift` — `import FeatureChatBot`, 콜백 배선,
      `.navigationDestination(item: $viewModel.destination.chatBot)` 추가
- [x] `Project.swift`(Vocabulary) — `.feature(implements: .chatBot)` 의존성 추가
- [x] `tuist generate --no-open` 성공 확인(`DesignSystemAsset.alignLeft`/
      `.messageSquare` 생성 확인)
- [x] **빌드 검증** — `FeatureVocabularyExample` / `FiveVoca` 빌드 성공, 신규 경고
      0개
- [x] **테스트 작성** — `WordDetailViewModelTests.swift`에
      `test_didTapChatBot_예문컨텍스트로_챗봇destination을_세팅한다` 추가(destination이
      `.chatBot`, context의 term/sentence/levelLabel 검증), 기존
      `test_requestIfNeeded_index1_loaded이며_데이터가_올바르다`에 `pm.level`
      assertion 추가
- [x] 기존 테스트 회귀 확인 — `AllTest` 스킴 전체 84개 통과(신규 테스트 포함, 회귀
      없음)
- [x] 변경 파일 요약 — **육안 검증 미완**: `FeatureVocabularyExample`을
      시뮬레이터에 실행해 진입 화면(단어 목록)까지는 스크린샷으로 확인했으나, 이
      세션에 UI 자동화(탭) 도구가 없어 단어 상세 화면까지 실제로 들어가 액션바
      레이아웃/색/챗봇 push 전환을 육안으로는 확인하지 못함 — 코드 검토로만
      확인됨. 특히 액션바 배경(`study100.opacity(0.5)`)이 이미 같은 색의 카드
      배경(`study100.opacity(0.5)`) 위에 겹쳐져 Figma 스펙(#F1F7F4)보다 살짝 더
      진하게 보일 가능성 있음 — 사용자가 실기기/시뮬레이터에서 직접 확인 후 필요
      시 opacity 값 조정 필요

### 하위 작업 25: 끊어읽기 버튼 조건부 노출 제거

사용자 실기기 확인 결과 "챗봇 버튼은 잘 보이는데 끊어읽기가 사라졌다"는 리포트가
있었고, 원인 조사 중 사용자가 "청크는 모두 존재하니까 청크가 있는 경우에만
끊어읽기를 노출하는것은 제외하고, 모든 경우에서 보여줘라"라고 요청 — 실제 데이터에서
chunks가 항상 존재하므로 조건부 노출 로직 자체가 불필요하다고 판단, 제거.

- [x] `WordDetailExampleRow.swift` — `if let chunks = example.chunks, !chunks.isEmpty`
      조건 제거, 끊어읽기 버튼도 챗봇처럼 항상 노출(`didTapChunkReader`의 nil/empty
      가드는 방어 코드로 유지, 안전망 성격이라 제거하지 않음)
- [x] **빌드 검증** — `FeatureVocabularyExample` / `FiveVoca` 빌드 성공, 신규 경고
      0개
- [x] 기존 테스트 회귀 확인 — `AllTest` 스킴 전체 84개 통과
- [x] 변경 파일 요약 — 이전 리포트("챗봇만 보이고 끊어읽기가 사라짐")의 근본 원인은
      명확히 규명되지 않았음(코드 검토상 조건부 로직 자체는 정상이었음, 사용자
      환경의 빌드 캐시 문제였을 가능성 존재) — 이번 변경으로 조건 자체를 없애
      원인과 무관하게 문제가 해소됨

### 하위 작업 26: 액션바 배경색 제거

사용자 요청: "끊어읽기, 챗봇의 버튼 배경색은 제거해라." — 두 버튼을 감싸던 필
(pill) 배경(`study100.opacity(0.5)` 라운드 사각형)을 제거, 버튼 자체는 배경 없이
아이콘+텍스트만 남긴다. 카드 전체 배경(`study100.opacity(0.5)`, 예문 카드 자체)은
이번 요청 범위 밖이라 그대로 유지.

- [x] `WordDetailExampleRow.swift` — 액션바 HStack의
      `.padding(.horizontal, 12).padding(.vertical, 8).background(study100.opacity(0.5), in: .rect(cornerRadius: 12))`
      제거
- [x] **빌드 검증** — `FeatureVocabularyExample` / `FiveVoca` 빌드 성공, 신규 경고
      0개
- [x] 변경 파일 요약 — 순수 시각 변경(배경 제거)이라 로직 회귀 리스크 없음, 별도
      테스트 불필요(뷰 전용 변경)

### 하위 작업 27: 커밋 + swift-lint 결과 반영

사용자 요청: "커밋을 모두 진행하고 lint 스킬을 돌려라" — 세션 전체 변경분을
논리 단위 3개(챗봇 UX 개선 / WordDetail 액션바+네비게이션 / 문서)로 나눠 커밋,
이번 커밋에 포함된 Swift 파일 17개에 swift-lint 스킬 실행. Networking/SSE/SSEClient.swift의
무관한 공백/주석 변경은 이번 작업들과 관련 없어 커밋에서 제외(작업 트리에 그대로 둠).

- [x] 커밋 1: `[Feature] 챗봇 UX 개선` — ChatBot/* + ErrorIcon 에셋
- [x] 커밋 2: `[Feature] WordDetail 예문에 끊어읽기·챗봇 액션바 추가` — Vocabulary/* +
      AlignLeft/MessageSquare 에셋
- [x] 커밋 3: `[Docs] 진행 체크리스트 기록` — PLAN.md + .harness/plans/jolly-puzzling-taco.md
- [x] swift-lint 실행 — P1 3건(파라미터 3개 한 줄 1건, 레이아웃 컨테이너 중첩 1건은
      이번 세션 신규 코드, `ChatBotInputBar.buttonIcon`의 `@ViewBuilder` 1건은 기존
      코드라 참고만), P2 4건(전부 기존 코드/의도된 예외)
- [x] 사용자 지시로 P1 중 신규 코드 2건 수정 — `WordDetailExampleRow.swift`의
      `actionButton` 파라미터 3개를 한 줄에 하나씩으로, 액션바 HStack을 별도
      `private struct ActionBar: View`로 분리(레이아웃 컨테이너 1개 룰 준수)
- [x] **빌드 검증** — `FeatureVocabularyExample` / `FiveVoca` 빌드 성공, 신규 경고
      0개
- [x] 변경 파일 요약 — 순수 리팩터(구조 분리 + 줄바꿈)라 로직 변경 없음, 기존
      `WordDetailViewModelTests`가 이 뷰의 콜백 배선을 간접 검증
