---
name: architecture-review
description: >-
  모듈·레이어 의존성, Repository/UseCase/DataSource, 모델 변환 위치, DI를 추가·변경하거나 코드 배치·아키텍처 검증을 요청할 때 사용한다. 구조 변경 없는 UI 수정·단순 버그 수정에는 사용하지 않는다.
---

# architecture-review

`docs/architecture.md`를 진입점으로 삼고, 변경 영역에 맞는 `docs/architecture/` 하위 문서를 읽어
레이어 구조·의존 방향·패턴을 검토한다. 세 문서를 항상 모두 읽을 필요는 없다. 연결된 Good/Bad Case는 해당 판단에 구체적 사례가 필요할 때 읽는다.

## 트리거 케이스 vs 비-트리거 케이스

### ✅ 이 스킬을 사용한다

- 새 모듈/타겟 추가 (`Projects/` 아래 새 디렉터리, Tuist 타겟)
- 레이어 경계를 넘나드는 변경 — 예: `Data`가 `NetworkingInterface`가 아니라 `Networking`을 직접 참조하려 함, `Domain`이 `Core`/`Networking`을 참조하려 함
- 새 `Repository`/`UseCase` 도입, 또는 기존 것을 다른 레이어로 옮기려 함
- DTO(Entity) → Domain Model 변환 로직을 어디에 둘지 결정
- 새 Feature 모듈 이름 짓기, 기존 Feature의 화면 연결 경계 재조정
- `@Dependency`/`swift-dependencies` DI 패턴을 새 의존성에 적용
- "이 코드 어디에 둬야 해?", "이 구조 맞아?", "아키텍처 리뷰해줘", "이 의존성 방향 괜찮아?", "새 모듈 만들어도 될까?"

### ❌ 이 스킬을 사용하지 않는다

- 순수 UI 스타일/색상/레이아웃 변경 (스타일은 `swift-lint` 스킬 영역)
- 기존 레이어·패턴 안에서 끝나는 단순 버그 수정
- 이미 있는 화면에 필드 하나 추가하는 등 구조에 영향 없는 변경

## 언제 문서 전체를 읽고, 언제 일부만 읽나

| 상황 | 읽을 문서·섹션 |
|---|---|
| 레이어 소속/의존 방향이 헷갈림 | `docs/architecture/clean-architecture.md`의 `## 레이어 구조와 의존 방향` (Tuist 그래프) |
| Repository/UseCase를 새로 만들거나 위치를 정함 | `docs/architecture/clean-architecture.md`의 `## Repository / UseCase 패턴`; 사례가 필요하면 연결된 `examples.md` |
| Domain·Networking 타겟을 추가·변경함 | `docs/architecture/modulization.md`의 `## Interface 분리 철학`과 Domain·Networking 타겟 구성 |
| Feature 모듈 새로 만들거나 이름 지음 | `docs/architecture/modulization.md`의 `## Feature 모듈 타겟 구성`, `## Feature 모듈 경계 규칙` |
| DTO를 Domain Model로 바꾸는 코드를 씀 | `docs/architecture/clean-architecture.md`의 `## 데이터 모델: DTO → Domain Model` |
| 새 의존성이나 Example·테스트 데이터를 추가함 | `docs/architecture/dependency-injection.md`의 `## 원칙`; 사례가 필요하면 연결된 `examples.md` |
| 구조 전반을 처음부터 파악해야 함 | 세 문서 전체 |

## 검토 워크플로우

1. **관련 레이어 식별**: 변경/계획이 건드리는 파일 경로로 판단한다 (`Projects/Feature/*`,
   `Projects/Domain/*`, `Projects/Data/*`, `Projects/Core`, `Projects/DesignSystem`,
   `Projects/Networking/Sources`, `Projects/Networking/Interface`). 제품용 타겟과 Tests/Example을 구분한다.
2. **위 표를 기준으로 필요한 섹션만 읽는다.**
3. **의존 방향 위반 확인**: `docs/architecture/clean-architecture.md`의 Tuist 의존 그래프와 대조한다.
   제품용 Domain 타겟의 Data 참조는 위반이다. Example의 앱 조립 의존을 같은 기준으로 판정하지 않는다.
4. **패턴 위반 확인**: 값 타입 계약, `liveValue`, `UnimplementedTestDependencyKey`를 확인한다.
   객체가 다른 객체의 구현에 직접 의존하지 않는지 보고, `happyPath`·`emptyPath`와 테스트 스텁은
   Interface가 아니라 사용하는 Example·Tests 파일에 둔다. 새 의존성은 조립 지점도 확인한다.
5. **네이밍/경계 위반 확인**: 새 Feature 모듈이면 `docs/architecture/modulization.md`의 소유 화면과
   의존 방향 기준에 맞는지 확인한다.
6. **문서에 없는 새로운 판단이 필요하면** — 사용자에게 그 판단을 확인만 하고, 기존 문서 내용을
   추측으로 덮어써 보고하지 않는다. 문서 자체를 갱신할지는 사용자에게 먼저 묻는다.

## 보고 방식

발견한 위반은 다음 형식으로 짧게 정리한다:

```
- [레이어] <위반 요약> — docs/architecture/<관련 문서>.md §<섹션> 기준 <올바른 방향/위치>
```

위반이 없으면 "구조상 문제 없음"이라고 짧게 확인하고 넘어간다 — 위반이 없는데 장황하게
설명하지 않는다.
