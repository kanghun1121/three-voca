# ARCHITECTURE.md

## 레이어 구조와 의존 방향

```
App
 └── Feature  ──→  UseCase (Interface)
      └── ...  ──→  Shared
 └── UseCase (Implements)  ──→  Core  ──→  Shared
 └── Data  ──→  UseCase (Interface)
```

**허용되는 방향만 허용된다. 역방향은 없다.**

| 레이어 | 역할 | 참조 가능한 레이어 |
|---|---|---|
| `App` | 진입점. 의존성 주입 조립 | Feature, UseCase, Data, Shared |
| `Feature` | 화면과 UI 로직 | UseCaseInterface, Shared |
| `UseCase` | 비즈니스 로직 + Supabase 호출 | Core, Shared |
| `Data` | Repository의 liveValue(실제 API 구현) | UseCaseInterface |
| `Core` | 네트워크/인프라 유틸리티 | Shared |
| `Shared` | 디자인 시스템, 공통 유틸 | 없음 |

### Repository / UseCase 패턴

- `Repository`: 외부 API를 추상화한 포트. `UseCaseInterface`에 struct-of-closures로 선언한다(`Client`와 동일한 형태 — `TestDependencyKey`/`DependencyValues` extension 포함).
- `UseCase`: 화면이 실제로 호출하는 단위. `UseCaseInterface`에 선언하고, `UseCase` 타겟의 `liveValue`에서 `@Dependency`로 Repository를 주입받아 호출한다. ViewModel은 Repository가 아닌 UseCase만 호출한다.
- `Repository`의 `liveValue`(Supabase 등 실제 호출 구현)는 `Data` 모듈에 위치한다. 현재는 DataSource 레이어 없이 Repository가 직접 API를 호출하는 형태이며, 필요해지면 Repository와 실제 호출 사이에 DataSource를 끼워 넣는다.
- 기존 `Client` struct들(`WordClient` 등)은 위 패턴이 도입되기 전에 만들어진 것으로, Repository 없이 `UseCase` 타겟에서 직접 API를 호출한다. 신규 기능은 Repository/UseCase 패턴을 따른다.

---

## 4-Target 패턴

Feature 모듈 하나는 4개 타겟으로 구성된다.

| 타겟 | 네이밍 예시 | 역할 |
|---|---|---|
| Implements | `FeatureHome` | 실제 View, ViewModel 구현 |
| Tests | `FeatureHomeTests` | 단위 테스트. 외부에 노출 안 됨 |
| Example | `FeatureHomeExample` | 독립 실행 앱. Xcode Preview 대신 실제 기기로 격리 확인 |

> Interface 타겟은 모듈 간 컴파일 의존성을 끊어야 할 시점에 재도입한다.

---

## 3-Layer 데이터 모델

데이터는 항상 한 방향으로만 변환된다.

```
Entity (DTO)  ──→  Domain Model  ──→  ViewState
  (UseCase)      (UseCaseInterface)    (Feature)
```

**Entity (DTO)**
- Supabase 응답을 그대로 매핑하는 `Decodable` struct
- `UseCase` 타겟 내부에만 존재. Feature에 절대 노출되지 않는다

**Domain Model**
- 앱의 진짜 데이터 모델. UI와 무관하게 정의된다
- `UseCaseInterface` 타겟에 위치. Feature와 UseCase 양쪽이 참조한다
- 날짜는 `Date`, 수치는 `Double` — 포맷 없는 순수 값

**ViewState**
- View가 바로 렌더링할 수 있는 표시용 struct
- `Feature` 타겟 내부에만 존재. UseCase로 역참조하지 않는다
- 날짜는 `"2024.01.15"`, 정확도는 `"87%"` — 이미 포맷된 문자열

### 변환 규칙

변환 함수는 **변환 대상 타입의 extension**으로 작성한다. 별도 Mapper 클래스를 만들지 않는다.

```swift
// Entity → Domain: UseCase 타겟 내부
extension SessionDetailResponseDTO {
    func toDomain() -> Session { ... }
}

// Domain Model → ViewState: Feature 타겟 내부 (Session+ViewState.swift)
extension Session {
    func toSessionDetailViewState() -> SessionDetailViewState { ... }
}
```

**ViewState에 비즈니스 로직을 넣지 않는다.**  
`lowAccuracyThreshold` 같은 임곗값 판단은 ViewState 변환 시점에 처리하되, 판단 결과는 enum(`SessionIconKind`)으로 표현한다. View는 분기하지 않고 값을 그대로 쓴다.

---

## 내비게이션 — enum Destination (SOT)

내비게이션 상태는 ViewModel의 `destination` 프로퍼티 하나가 단일 진실 공급원(SOT)이다.

```swift
@Observable
final class HomeViewModel {
    var destination: Destination?

    @CasePathable
    enum Destination {
        case session(SessionDetailViewModel)
    }

    func sessionTapped(id: Int) {
        destination = .session(SessionDetailViewModel(sessionID: String(id)))
    }
}
```

View는 `destination`을 바인딩으로 연결하고, 분기 로직을 직접 갖지 않는다.

```swift
.navigationDestination(item: $viewModel.destination.session) { detailVM in
    SessionDetailView(viewModel: detailVM)
}
```

**이 패턴의 핵심 규칙**:

- `destination = nil` 이면 내비게이션 없음, `destination = .some(case)` 이면 해당 화면으로 이동 — 상태와 UI가 항상 동기화된다
- 다음 화면의 ViewModel(`SessionDetailViewModel`)을 `Destination` case의 연관값으로 넘긴다. View는 ViewModel을 직접 생성하지 않는다
- `@CasePathable`은 SwiftUINavigation이 `$viewModel.destination.session` 처럼 특정 case만 바인딩하기 위해 필요하다. 제거하면 컴파일 에러가 아닌 런타임 오작동이 발생하므로 반드시 유지한다

---

## DI 패턴 — swift-dependencies

모든 외부 의존성(Supabase, 시스템 API)은 `Client` struct로 감싼다.

```swift
// UseCaseInterface에 선언
public struct HomeClient: Sendable {
    public var fetchHomeOverview: @Sendable () async throws -> VocabularyLibrary
}

extension HomeClient: TestDependencyKey {
    public static let testValue = HomeClient(
        fetchHomeOverview: unimplemented("\(Self.self).fetchHomeOverview")
    )
    public static let previewValue = HomeClient(
        fetchHomeOverview: { .previewFixture }
    )
}
```

- `liveValue`: `UseCase` 타겟에서 Supabase 실제 구현 (Repository/UseCase 패턴의 `liveValue`는 `Data` 타겟에 위치 — 위 [Repository / UseCase 패턴](#repository--usecase-패턴) 참고)
- `testValue`: `unimplemented` — 호출 시 테스트 즉시 실패. 의도하지 않은 호출 감지
- `previewValue`: 고정 Fixture 반환

---
