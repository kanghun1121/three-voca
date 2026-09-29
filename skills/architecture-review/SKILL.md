---
name: architecture-review
description: >-
  모듈·레이어 의존성, Repository/UseCase/DataSource, 모델 변환 위치, 내비게이션·DI를 추가·변경하거나 코드 배치·아키텍처 검증을 요청할 때 사용한다. 구조 변경 없는 UI 수정·단순 버그 수정에는 사용하지 않는다.
---

# architecture-review

`docs/architecture.md`(저장소 루트)를 기준으로, 변경이 레이어 구조·의존 방향·패턴을 지키는지
검토한다. 문서 전체를 항상 읽을 필요는 없다 — 변경이 건드리는 레이어에 맞는 섹션만 읽는다.

## 트리거 케이스 vs 비-트리거 케이스

### ✅ 이 스킬을 사용한다

- 새 모듈/타겟 추가 (`Projects/` 아래 새 디렉터리, Tuist 타겟)
- 레이어 경계를 넘나드는 변경 — 예: `Data`가 `NetworkingInterface`가 아니라 `Networking`을 직접 참조하려 함, `Domain`이 `Core`/`Networking`을 참조하려 함
- 새 `Repository`/`UseCase` 도입, 또는 기존 것을 다른 레이어로 옮기려 함
- DTO(Entity) → Domain Model 변환 로직을 어디에 둘지 결정
- 새 Feature 모듈 이름 짓기, 기존 Feature의 라우트 경계 재조정
- `Destination` enum 기반 내비게이션 패턴을 새로 추가하거나 변형
- `@Dependency`/`swift-dependencies` DI 패턴을 새 의존성에 적용
- "이 코드 어디에 둬야 해?", "이 구조 맞아?", "아키텍처 리뷰해줘", "이 의존성 방향 괜찮아?", "새 모듈 만들어도 될까?"

### ❌ 이 스킬을 사용하지 않는다

- 순수 UI 스타일/색상/레이아웃 변경 (스타일은 `swift-lint` 스킬 영역)
- 기존 레이어·패턴 안에서 끝나는 단순 버그 수정
- 이미 있는 화면에 필드 하나 추가하는 등 구조에 영향 없는 변경

## 언제 문서 전체를 읽고, 언제 일부만 읽나

| 상황 | 읽을 섹션 |
|---|---|
| 레이어 소속/의존 방향이 헷갈림 | `## 레이어 구조와 의존 방향` (표 + Tests/Example 적용 범위) |
| Repository/UseCase를 새로 만들거나 위치를 정함 | `### Repository / UseCase 패턴` |
| Feature 모듈 새로 만들거나 이름 지음 | `## Feature 모듈 경계 규칙` (용어 사전 포함) |
| DTO를 Domain Model로 바꾸는 코드를 씀 | `## 데이터 모델: DTO → Domain Model` |
| 화면 전환/네비게이션 코드를 건드림 | `## 내비게이션 — enum Destination (SOT)` |
| `@Dependency`로 새 의존성을 주입함 | `## DI 패턴 — swift-dependencies` |
| 구조 전반을 처음부터 파악해야 함 | 문서 전체 |

## 검토 워크플로우

1. **관련 레이어 식별**: 변경/계획이 건드리는 파일 경로로 판단한다 (`Projects/Feature/*`,
   `Projects/Domain/*`, `Projects/Data/*`, `Projects/Core`, `Projects/DesignSystem`,
   `Projects/Networking/Sources`, `Projects/Networking/Interface`). 제품용 타겟과 Tests/Example을 구분한다.
2. **위 표를 기준으로 필요한 섹션만 읽는다.**
3. **의존 방향 위반 확인**: `## 레이어 구조와 의존 방향` 표의 "참조 가능한 레이어" 열과 대조한다.
   제품용 Domain 타겟의 Data 참조는 위반이다. Example의 앱 조립 의존을 같은 기준으로 판정하지 않는다.
4. **패턴 위반 확인**: 새 Repository/UseCase라면 `testValue`/`previewValue` 유무, `liveValue`
   위치(Repository → `Data/Sources`, UseCase → `Domain/Sources`)가 문서와 일치하는지 본다.
   `previewValue`를 모든 계약에 강제하지 않고, `unimplemented` 규칙을 인프라 전체로 확대하지 않는다.
   DataSource는 Local/Remote 책임을 구분하고, 새 의존성은 앱·Example의 조립 지점도 확인한다.
5. **네이밍/경계 위반 확인**: 새 Feature 모듈이면 `## Feature 모듈 경계 규칙`의 용어 사전과
   충돌하는 이름(특히 금지어로 명시된 것)이 없는지 확인한다.
6. **문서에 없는 새로운 판단이 필요하면** — 사용자에게 그 판단을 확인만 하고, 기존 문서 내용을
   추측으로 덮어써 보고하지 않는다. 문서 자체를 갱신할지는 사용자에게 먼저 묻는다.

## 보고 방식

발견한 위반은 다음 형식으로 짧게 정리한다:

```
- [레이어] <위반 요약> — docs/architecture.md §<섹션> 기준 <올바른 방향/위치>
```

위반이 없으면 "구조상 문제 없음"이라고 짧게 확인하고 넘어간다 — 위반이 없는데 장황하게
설명하지 않는다.
