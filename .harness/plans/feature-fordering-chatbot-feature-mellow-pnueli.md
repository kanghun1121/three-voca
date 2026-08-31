# PLAN: Networking 모듈 기능별 폴더링

- 작업 ID: `090-feature-chatbot` (기존 워크트리 재사용, 새 하위 작업)
- 작성일: 2026-08-28
- 대상: `Projects/Networking` (`NetworkingInterface`/`Networking`/`NetworkingTests` 3-target)

> 이전 하위 작업들(ChatBot 모듈 스캐폴딩, SSE 스트리밍 클라이언트, 마크다운 렌더러)은 완료됨.
> 이 플랜은 이번 Networking 폴더링 작업 기준으로 새로 작성.

---

## Context

`Projects/Networking`에 HTTPClient, Endpoint(Requestable), SSE 세 가지 관심사가 전부 `Interface/`·
`Sources/`·`Tests/` 각각의 루트에 평평하게 섞여 있다. SSE 스트리밍 클라이언트가 이번 세션에 새로
추가되면서 파일 수가 늘었고, 사용자가 "SSE, HTTPClient, Endpoint 가 모두 들어가다보니, 파일 구분이
너무 어렵다"고 직접 지적했다. 로직 변경 없이 **파일 이동만으로** 기능별 폴더 구조를 만든다.

Tuist 글롭(`Sources/**`/`Interface/**`/`Tests/**`)이 재귀적이라 `Project.swift`나 `Workspace.swift`
수정 없이 파일 이동만으로 끝난다 — `Tests/Doubles/`가 이미 같은 방식으로 중첩돼 있고 정상 컴파일된다.

---

## 사전 검토

- [x] `Projects/Networking/Project.swift` 및 `Plugins/DependencyPlugin/ProjectDescriptionHelpers/SourcePathsExtensions.swift` 확인 — 글롭이 재귀적이라 폴더 이동에 매니페스트 수정 불필요
- [x] 33개 파일 전수 조사 (Explore 서브에이전트) + 매핑 검증 (Plan 서브에이전트가 실제 파일 내용 재확인)
- [x] `Requestable`/`HTTPMethod`/`HTTPBody`/`Encodable+Dictionary`가 SSE(`ClaudeMessagesRequest: Requestable`)에도 재사용되고 있음을 확인 — HTTP 전용이 아니라 별도 `Request/` 버킷으로 분리
- [x] `NetworkError`(HTTP+SSE+Request 케이스 전부 포함)와 `NetworkLogger`(HTTPClient+SSEClient 공용 로거)는 각각 유일한 모듈 전역 파일이라 폴더를 만들지 않고 루트에 유지 — Domain 모듈(`Interface/`는 `Model/Repository/UseCase/` 3폴더, `Sources/`는 `UseCase/` 1폴더만)처럼 Interface/Sources가 대칭일 필요는 없다는 선례 확인
- [x] `Networking.xcodeproj`는 `.gitignore`(`*.xcodeproj`) 대상이라 커밋 불필요 — `tuist generate`로 로컬 재생성만 하면 됨
- [x] 이번 세션에 추가된 SSE 관련 12개 파일이 아직 `git add`되지 않은 미추적 상태 — `git mv`는 추적 파일에만 동작하므로 이동 전에 먼저 스테이징 필요

---

## 최종 폴더 매핑

### `Interface/` (target `NetworkingInterface`)

| 폴더 | 파일 |
|---|---|
| `Request/` (요청 조립 공용 계층 — HTTP와 SSE가 함께 씀) | `Requestable.swift`, `HTTPMethod.swift`, `HTTPBody.swift`, `Encodable+Dictionary.swift` |
| `HTTP/` | `HTTPClienting.swift`, `HTTPClienting+Dependency.swift`, `AuthenticatedHTTPClienting+Dependency.swift`, `HTTPInterceptor.swift`, `TokenProvider.swift`, `SupabaseConfig.swift` |
| `SSE/` | `SSEClienting.swift`, `SSEClienting+Dependency.swift`, `ClaudeChatMessage.swift`, `ClaudeMessageStreamResponse.swift`, `ClaudeConfig.swift` |
| (루트, 이동 안 함) | `NetworkError.swift` — HTTP·SSE·Request 케이스를 전부 담는 유일한 모듈 전역 타입 |

### `Sources/` (target `Networking`)

| 폴더 | 파일 |
|---|---|
| `HTTP/` | `HTTPClient.swift`, `HTTPClienting+Live.swift`, `AuthenticatedHTTPClienting+Live.swift`, `TokenRefreshInterceptor.swift` |
| `SSE/` | `SSEClient.swift`, `SSEClienting+Live.swift`, `ClaudeSSEParser.swift`, `SSEFrameReader.swift` |
| (루트, 이동 안 함) | `NetworkLogger.swift` — `HTTPClient`/`SSEClient` 둘 다 쓰는 유일한 공용 파일 |

### `Tests/` (target `NetworkingTests`)

| 폴더 | 파일 |
|---|---|
| `HTTP/` | `HTTPClientTests.swift`, `TokenRefreshInterceptorTests.swift` |
| `SSE/` | `SSEClientTests.swift`, `ClaudeSSEParserTests.swift`, `SSEFrameReaderTests.swift` |
| `Doubles/` (그대로 유지) | `MockURLProtocol.swift`(HTTP+SSE 공용), `SpyHTTPInterceptor.swift`, `StubRequestable.swift` |

**`SupabaseConfig`가 `HTTP/`인 이유**: 9개 참조 전부 `Projects/Data/Sources/{Auth,Home,Session,Word}`의
`Requestable` 구조체가 `HTTPClienting`을 통해 실행되는 요청의 `baseURL`로만 쓴다. SSE 참조 0건.
구조적 쌍인 `ClaudeConfig`가 SSE 전용인 것과 대칭 — `Request/`로 옮기면 "HTTP·SSE 공용"이라는
잘못된 신호를 준다.

**`Request/` 이름 — `Shared/`가 아닌 이유**: WordGame의 `Shared/`는 배경·뷰·사운드클라이언트·모델처럼
공통 주제가 없는 진짜 잔여 버킷이다. 이 5개 파일(`NetworkError` 제외)은 "선언적 엔드포인트를
`URLRequest`로 조립한다"는 하나의 명확한 책임을 공유하므로, 이름 없는 잔여 폴더가 아니라 그 책임의
이름(`Requestable`/`makeURLRequest()`에서 따온 `Request/`)을 붙인다.

---

## 실행 순서 (`git mv` 목록, `Projects/Networking/` 기준 상대 경로)

```bash
# 0. 이번 세션에 추가된 SSE 파일 12개가 미추적 상태 — git mv 전에 먼저 스테이징
git add -A Projects/Networking

# 1. NetworkingInterface (Interface/)
mkdir -p Projects/Networking/Interface/Request Projects/Networking/Interface/HTTP Projects/Networking/Interface/SSE

git mv Projects/Networking/Interface/Requestable.swift                            Projects/Networking/Interface/Request/Requestable.swift
git mv Projects/Networking/Interface/HTTPMethod.swift                             Projects/Networking/Interface/Request/HTTPMethod.swift
git mv Projects/Networking/Interface/HTTPBody.swift                               Projects/Networking/Interface/Request/HTTPBody.swift
git mv Projects/Networking/Interface/Encodable+Dictionary.swift                   Projects/Networking/Interface/Request/Encodable+Dictionary.swift

git mv Projects/Networking/Interface/HTTPClienting.swift                          Projects/Networking/Interface/HTTP/HTTPClienting.swift
git mv Projects/Networking/Interface/HTTPClienting+Dependency.swift               Projects/Networking/Interface/HTTP/HTTPClienting+Dependency.swift
git mv Projects/Networking/Interface/AuthenticatedHTTPClienting+Dependency.swift  Projects/Networking/Interface/HTTP/AuthenticatedHTTPClienting+Dependency.swift
git mv Projects/Networking/Interface/HTTPInterceptor.swift                        Projects/Networking/Interface/HTTP/HTTPInterceptor.swift
git mv Projects/Networking/Interface/TokenProvider.swift                          Projects/Networking/Interface/HTTP/TokenProvider.swift
git mv Projects/Networking/Interface/SupabaseConfig.swift                         Projects/Networking/Interface/HTTP/SupabaseConfig.swift

git mv Projects/Networking/Interface/SSEClienting.swift                           Projects/Networking/Interface/SSE/SSEClienting.swift
git mv Projects/Networking/Interface/SSEClienting+Dependency.swift                Projects/Networking/Interface/SSE/SSEClienting+Dependency.swift
git mv Projects/Networking/Interface/ClaudeChatMessage.swift                      Projects/Networking/Interface/SSE/ClaudeChatMessage.swift
git mv Projects/Networking/Interface/ClaudeMessageStreamResponse.swift            Projects/Networking/Interface/SSE/ClaudeMessageStreamResponse.swift
git mv Projects/Networking/Interface/ClaudeConfig.swift                           Projects/Networking/Interface/SSE/ClaudeConfig.swift
# Interface/NetworkError.swift — 루트 유지

# 2. Networking (Sources/)
mkdir -p Projects/Networking/Sources/HTTP Projects/Networking/Sources/SSE

git mv Projects/Networking/Sources/HTTPClient.swift                               Projects/Networking/Sources/HTTP/HTTPClient.swift
git mv Projects/Networking/Sources/HTTPClienting+Live.swift                       Projects/Networking/Sources/HTTP/HTTPClienting+Live.swift
git mv Projects/Networking/Sources/AuthenticatedHTTPClienting+Live.swift          Projects/Networking/Sources/HTTP/AuthenticatedHTTPClienting+Live.swift
git mv Projects/Networking/Sources/TokenRefreshInterceptor.swift                  Projects/Networking/Sources/HTTP/TokenRefreshInterceptor.swift

git mv Projects/Networking/Sources/SSEClient.swift                                Projects/Networking/Sources/SSE/SSEClient.swift
git mv Projects/Networking/Sources/SSEClienting+Live.swift                        Projects/Networking/Sources/SSE/SSEClienting+Live.swift
git mv Projects/Networking/Sources/ClaudeSSEParser.swift                          Projects/Networking/Sources/SSE/ClaudeSSEParser.swift
git mv Projects/Networking/Sources/SSEFrameReader.swift                           Projects/Networking/Sources/SSE/SSEFrameReader.swift
# Sources/NetworkLogger.swift — 루트 유지

# 3. NetworkingTests (Tests/)
mkdir -p Projects/Networking/Tests/HTTP Projects/Networking/Tests/SSE

git mv Projects/Networking/Tests/HTTPClientTests.swift                            Projects/Networking/Tests/HTTP/HTTPClientTests.swift
git mv Projects/Networking/Tests/TokenRefreshInterceptorTests.swift               Projects/Networking/Tests/HTTP/TokenRefreshInterceptorTests.swift

git mv Projects/Networking/Tests/SSEClientTests.swift                             Projects/Networking/Tests/SSE/SSEClientTests.swift
git mv Projects/Networking/Tests/ClaudeSSEParserTests.swift                       Projects/Networking/Tests/SSE/ClaudeSSEParserTests.swift
git mv Projects/Networking/Tests/SSEFrameReaderTests.swift                        Projects/Networking/Tests/SSE/SSEFrameReaderTests.swift
# Tests/Doubles/{MockURLProtocol,SpyHTTPInterceptor,StubRequestable}.swift — 변경 없음
```

총 28개 파일 이동(그중 새 SSE 파일 9개는 최초 커밋 없이 바로 새 경로로 스테이징됨), 5개 파일
(`NetworkError.swift`, `NetworkLogger.swift`, `Doubles/` 3개)은 위치 유지.

**로직 변경 없음**: import문, 접근제어자, 타입 참조 전부 그대로 — 파일이 같은 타겟(`Interface/`→
`Interface/`, `Sources/`→`Sources/`, `Tests/`→`Tests/`) 안에서만 이동하므로 Swift 컴파일에 영향 없음.
`Project.swift`/`Workspace.swift` 수정 불필요.

---

## 범위 밖 — 발견했지만 이번엔 처리하지 않는 것

- **`SSEClient.swift`가 타입 3개(`SSEClient`/`ClaudeMessagesRequest`/`ClaudeMessagesRequestBody`)를
  한 파일에 담고 있음** — `docs/FRONTEND.md`의 "한 파일 한 타입" 규칙과 다소 긴장 관계지만, 그 규칙은
  SwiftUI 뷰 분리 맥락이라 명백한 위반은 아니다. 원하면 `Sources/SSE/`에 파일 3개로 쪼개는 후속 작업
  가능 — `ClaudeMessagesRequestBody`는 `SSEClientTests`가 직접 인코딩 검증하려고 일부러 `internal`
  (private 아님)이라 분리 시 접근 수준을 유지해야 함.
- **`Requestable.makeURLRequest()` 자체를 검증하는 테스트 파일이 없음** — 현재 `HTTPClientTests`를
  통해 간접적으로만 커버됨. 이번 폴더링 후 `Tests/`에 `Request/` 폴더가 생기지 않는 이유이기도 함.
- **`SSE/`가 범용 SSE 프로토콜 코드(`SSEFrameReader`)와 Claude 전용 코드
  (`ClaudeSSEParser`/`ClaudeMessagesRequest`/`ClaudeChatMessage` 등)를 한 폴더에 섞어 둠** — 파일
  9개(Interface 5 + Sources 4) 규모에서 `SSE/Claude/` 하위 폴더까지 만드는 건 과설계. 두 번째 SSE
  제공자가 생기면 그때 분리.
- **`SupabaseConfig`/`ClaudeConfig` 둘 다 `Bundle.main` Info.plist 키를 읽음** — 네트워킹보다는 앱
  설정에 가까운 책임일 수 있으나, 모듈을 옮기는 건 이번 폴더링과 다른 작업이라 범위 밖.

---

## 검증 방법

1. Xcode 종료 (파일 이동 중 프로젝트가 열려 있으면 충돌 가능)
2. 위 `git mv` 목록 실행 (선행 `git add -A Projects/Networking` 포함)
3. `tuist generate --no-open` — `Networking.xcodeproj`는 gitignore 대상이라 재생성만 하면 됨
4. `Networking`/`NetworkingInterface` 빌드 확인 (컴파일 에러 없어야 함 — 있다면 파일 이동이 아닌
   다른 원인이므로 즉시 조사)
5. `tuist test AllTest --no-selective-testing`(또는 `NetworkingTests` 스킴 단독)으로 8개 테스트
   파일이 전부 실행되는지 확인 — 글롭 기반 이동에서 가장 흔한 실패 모드는 파일이 조용히 타겟에서
   빠지는 것이므로, 테스트 개수가 이동 전(기존 총합)과 같은지 반드시 대조
6. `git status`로 각 파일이 "rename"으로 인식됐는지 확인 (내용이 그대로면 git이 자동 감지)
