# 아키텍처

코드 배치·책임·의존 방향을 정의한다.
빌드와 검증은 [development.md](development.md), 작성 규칙은 [swift-style.md](swift-style.md)를 따른다.

## 레이어 구조와 의존 방향

아래 표는 App과 제품용 라이브러리 타겟의 내부 모듈 의존 기준이다.
Apple 프레임워크·외부 패키지는 제외하며, Tests/Example의 의존은 아래 별도 기준을 따른다.
실제 직접 의존성은 각 `Projects/**/Project.swift`에 선언한다.

| 레이어/타겟 | 책임 | 참조 가능한 레이어 |
|---|---|---|
| App | 앱 진입점·의존성 조립 | Feature, Domain, Data, Networking, Core, DesignSystem |
| Feature | 화면·상태·사용자 이벤트 | DomainInterface, DesignSystem, 화면 연결에 필요한 Feature, Core(로깅) |
| DomainInterface | 도메인 모델·Repository/UseCase 계약 | 없음 |
| Domain | UseCase 구현·도메인 오케스트레이션 | DomainInterface |
| Data | Repository 구현·외부 데이터 접근·저장 | DomainInterface, Core, NetworkingInterface |
| NetworkingInterface | HTTP/SSE 및 인증 관련 포트 | 없음 |
| Networking | 네트워크 클라이언트·인터셉터 구현 | NetworkingInterface, Core |
| Core | Keychain·로깅 등 공통 인프라 | 없음 |
| DesignSystem | 디자인 토큰·공통 UI 표현 | 없음 |

- 의존 그래프는 비순환이어야 한다. 하위 레이어에서 Feature/App을 참조하지 않는다.
- Data는 Networking 구현체를 참조하지 않고 NetworkingInterface의 포트로 호출한다.
- Domain/DomainInterface는 Data, Core, Networking, NetworkingInterface를 참조하지 않는다.
- Feature의 Core 참조는 로깅 용도로 제한한다. Keychain 등 데이터 접근은 DomainInterface 계약을 통한다.
- Feature 간 참조는 화면 연결을 위한 방향으로 제한한다. 공용 데이터 접근은 DomainInterface를 통한다.
- 표에 없는 의존이 발견되면 선언과 사용처를 확인한다. 기존 코드의 존재만으로 새 허용 규칙을 만들지 않는다.
- Tests는 검증 대상 구현과 테스트에 필요한 계약·도구를 참조한다.
- Example은 독립 앱의 조립 지점이다. 실제 기능 실행에 필요한 Domain/Data/Networking 구현을 참조할 수 있다.
- Example의 구현 의존을 Feature 라이브러리의 허용 의존으로 확대하지 않는다.

### Repository / UseCase 패턴

| 구성 요소 | 선언/구현 위치 | 책임 |
|---|---|---|
| Repository 계약 | `Projects/Domain/Interface/Repository/` | 데이터·시스템 기능을 struct-of-closures로 추상화 |
| Repository 구현 | `Projects/Data/Sources/<영역>/` | API·저장소·시스템 호출, 데이터 조합·매핑·캐시 |
| UseCase 계약 | `Projects/Domain/Interface/UseCase/` | 화면에서 사용하는 복합 동작의 계약 |
| UseCase 구현 | `Projects/Domain/Sources/UseCase/` | Repository 호출 조합과 도메인 처리 |
| LocalDataSource | `Projects/Data/Sources/<영역>/` | 담당 데이터의 로컬 조회·저장 |
| RemoteDataSource | `Projects/Data/Sources/<영역>/` | 네트워크 요청·응답 수신·스트림 전송 처리 |

- 현재 ViewModel은 Repository와 UseCase를 모두 주입받는다. UseCase만 허용한다고 가정하지 않는다.
- 단순 조회·구독·개별 기능은 Repository를 직접 사용할 수 있다.
- 여러 Repository 호출을 조합하거나 부수 효과의 순서를 관리하는 동작은 UseCase에 둔다.
- 예: `LoadLessonDetailUseCase`는 레슨 조회와 오디오 준비를 조합한다.
- ViewModel에서 네트워크·Keychain·DB를 직접 호출하지 않는다.
- LocalDataSource/RemoteDataSource는 Data 내부 구현이다. Feature/Domain에 노출하지 않는다.
- RemoteDataSource는 NetworkingInterface로 요청하고, Repository는 응답을 Domain Model로 매핑한다.
- 여러 DataSource의 결과 조합·캐시 정책·저장 흐름은 Repository가 담당한다.
- 로컬 DB 공통 기반은 `Projects/Data/Sources/LocalDatabase/`에 둔다.

## Feature 모듈 타겟 구성

| 타겟 | 위치 | 용도 |
|---|---|---|
| `Feature<Name>` | `Projects/Feature/<Name>/Sources/` | View·ViewModel·화면 전용 모델 |
| `Feature<Name>Tests` | 같은 모듈의 `Tests/` | 단위 테스트 |
| `Feature<Name>Example` | 같은 모듈의 `Example/` | 독립 실행·격리 확인 |

- Domain과 Networking은 각각 `Interface/`와 `Sources/`를 별도 타겟으로 구성한다.
- `NetworkingInterface`는 별도 프로젝트 폴더가 아니라 `Projects/Networking/Interface/` 타겟이다.
- Feature Interface 타겟을 관성적으로 추가하지 않는다. 의존 경계를 분리할 실제 필요가 있을 때 검토한다.

## Feature 모듈 경계 규칙

- Feature 이름은 소유한 화면 묶음을 나타낸다. Domain 엔티티와 일대일 대응할 필요가 없다.
- 단일 화면이면 화면명, 여러 화면이면 공통 화면 계층의 이름을 사용한다.
- 한 화면과 전용 View·ViewModel·모델은 한 Feature 모듈이 소유한다.
- 다른 Feature에 필요하다는 이유만으로 화면 전용 코드를 Domain/Core로 옮기지 않는다.
- 공유 위치는 소비처와 의존 방향으로 결정하며 순환 의존을 만들지 않는다.

### 용어 사전

| 용어 | 의미/사용 기준 |
|---|---|
| Level | CEFR 레벨. Lesson을 포함한다 |
| Lesson | 학습 단위. 단어와 학습 진행을 묶는다 |
| Word | 문맥에 따라 `Lesson.Word` 또는 `WordDetail`을 사용한다 |
| LearningLibrary | 레벨·레슨의 전체 진행률 |
| LearningHistory | 레슨별 학습 이력 |
| Session | 인증·채팅 세션처럼 수명이 있는 문맥. 학습 단위를 뜻하는 이름으로 쓰지 않는다 |
| Vocabulary | 새 모듈·도메인 이름으로 사용하지 않는다 |

## 데이터 모델: DTO → Domain Model

- 네트워크 DTO, Seed DTO, 저장 Entity는 Data 내부 모델이다. 서로 같은 종류라고 가정하지 않는다.
- 저장 Entity는 SwiftData `@Model`을 포함한다. 모든 Entity가 `Decodable struct`인 것은 아니다.
- 외부 응답·저장 Entity를 Repository 경계에서 Domain Model로 변환해 반환한다.
- 변환은 Data 내부에서 원본 타입의 extension으로 작성한다. 별도 Mapper 계층은 기본으로 만들지 않는다.
- Domain Model은 `Projects/Domain/Interface/Model/`에 둔다. SwiftUI·DesignSystem을 참조하지 않는다.
- 날짜·수치는 표시 문자열이 아닌 의미에 맞는 `Date`, `Int`, `Double` 등의 값으로 보관한다.
- ViewModel은 Domain Model을 상태로 보유한다. 동일 데이터를 복제하는 PresentationModel 계층을 만들지 않는다.
- 화면용 그룹핑·라벨·상태 판정은 해당 Feature 안의 Domain Model extension으로 표현한다.
- 상태 판정은 enum으로 표현하고, 색상·아이콘 매핑은 View 표현 코드에 둔다.
- 화면별 짧은 파생 로직의 중복보다 올바른 모듈 경계를 우선한다.
- UI와 무관한 도메인 불변식은 DomainInterface에 둔다. 예: `Lesson.Word.primaryMeaning`.

## 내비게이션 — enum Destination (SOT)

- Home·Lesson·Word의 상세 화면 이동은 ViewModel의 `Destination` enum과 `destination`을 기본 패턴으로 쓴다.
- 다음 화면의 ViewModel이 필요한 이동은 Destination 연관값으로 전달하고, View는 바인딩으로 표시한다.
- 단순 sheet·alert는 ViewModel 연관값이 필수가 아니다. MyPage는 무연관값 case와 `AlertState`를 사용한다.
- Login의 약관·개인정보 sheet는 기존 Bool 상태로 관리한다. 독립 표시 상태와 중복된 전환 상태를 구분한다.
- 같은 전환을 별도의 Bool·선택 상태로 중복 관리하지 않는다.
- enum case 바인딩에 필요한 `@CasePathable`과 SwiftUINavigation 패턴을 유지한다.
- 화면 전환의 판단은 ViewModel, 표시와 바인딩은 View의 책임이다.

## DI 패턴 — swift-dependencies

- Repository/UseCase는 struct-of-closures 계약과 `DependencyValues` 등록을 사용한다.
- 소비자는 `@Dependency`로 주입받는다. 구현체 생성·시스템 접근을 소비자에 흩어 놓지 않는다.
- Repository의 `liveValue`는 Data, UseCase의 `liveValue`는 Domain에 둔다.
- Repository/UseCase 계약의 `testValue`는 의도하지 않은 호출을 감지하도록 `unimplemented`를 사용한다.
- 이 규칙을 모든 인프라 의존성에 확대하지 않는다. Logger는 no-op, DataSource는 하위 의존을 교체할 수 있는 객체를 사용한다.
- 테스트는 필요한 동작을 `withDependencies`로 교체한다.
- `previewValue`는 화면·Example에서 필요한 계약에 둔다. Repository에도 존재하며 모든 계약에 필수는 아니다.
- 앱의 조립 지점은 `Projects/App/Sources/RootView.swift`의 `withDependencies`다.
- 이곳의 명시적 `liveValue` 등록은 정적 링크 시 구현 연결을 유지하기 위한 장치이므로 임의로 제거하지 않는다.
- 새 의존성을 추가하면 계약·구현·`DependencyValues`와 함께 앱 및 해당 Example의 주입 구성을 확인한다.
- UI 격리·비동기 계약의 `@MainActor`, `Sendable`, `@Sendable` 요구를 변경 시 함께 확인한다.
