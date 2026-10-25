# Modulization

Domain·Networking·Feature의 타겟 구성과 모듈 경계를 정의한다.

## 공통 Interface 분리 원칙

호출하는 모듈은 구현체가 아니라 필요한 기능의 계약에 의존한다. `Interface/`는 다른 모듈이 알아야 할 모델·포트를 제공하고, 실제 동작은 책임에 따라 Domain·Data·Networking의 구현 타겟에 둔다. 앱의 조립 지점에서 구현을 주입한다. Feature는 Domain/Data 구현을, Data는 Networking 구현을 직접 참조하지 않는다. 테스트나 독립 실행 앱에서는 필요한 구현을 따로 조립할 수 있다.

## Domain의 Interface 분리 이유

Domain의 계약에는 화면과 Data가 공유하는 도메인 모델, Repository·UseCase 계약이 있다. UseCase 구현은 별도 타겟에 두고, Repository 구현은 Data가 제공한다. 따라서 Feature는 `DomainInterface`만 참조해 도메인 계약을 사용할 수 있다.

## Domain 타겟 구성

| 타겟 | 위치 | 용도 |
|---|---|---|
| `DomainInterface` | `Projects/Domain/Interface/` | 도메인 모델·Repository/UseCase 계약·의존성 등록 |
| `Domain` | `Projects/Domain/Sources/` | UseCase의 실제 구현과 도메인 동작 조합 |
| `DomainTests` | `Projects/Domain/Tests/` | 도메인 계약·구현의 단위 테스트 |
| `DomainExample` | `Projects/Domain/Example/` | Domain/Data 구현을 조립해 실행하는 독립 앱 |

## Networking의 Interface 분리 이유

Data가 필요한 것은 특정 HTTP/SSE 클라이언트 구현이 아니라 요청·응답과 스트림을 다루는 포트다. `NetworkingInterface`에 포트와 요청 타입을 두고, `Networking`에 클라이언트·인터셉터 구현을 둔다. Data는 `NetworkingInterface`를 참조하고, 앱이 실제 Networking 구현을 연결한다.

## Networking 타겟 구성

| 타겟 | 위치 | 용도 |
|---|---|---|
| `NetworkingInterface` | `Projects/Networking/Interface/` | HTTP/SSE 포트·요청 타입·네트워크 오류 등 계약 |
| `Networking` | `Projects/Networking/Sources/` | HTTP/SSE 클라이언트·인터셉터 구현 |
| `NetworkingTests` | `Projects/Networking/Tests/` | 네트워크 구현의 단위 테스트 |

`NetworkingInterface`는 별도 프로젝트 폴더가 아니라 `Projects/Networking/Interface/` 타겟이다. 현재 Networking에는 별도 Example 타겟이 없다.

## Feature 모듈 타겟 구성

| 타겟 | 위치 | 용도 |
|---|---|---|
| `Feature<Name>` | `Projects/Feature/<Name>/Sources/` | View·ViewModel·화면 전용 모델 |
| `Feature<Name>Tests` | 같은 모듈의 `Tests/` | 단위 테스트 |
| `Feature<Name>Example` | 같은 모듈의 `Example/` | 독립 실행·격리 확인 |

- 다른 Feature가 열어야 하는 화면에만 `Feature<Name>Interface` 타겟(`Interface/`)을 둔다. 호출되지 않는 Feature에는 추가하지 않는다.
- Interface 미주입 환경(Example, 프리뷰, 테스트)은 Interface가 제공하는 Placeholder 구현(빈 화면)을 쓴다.

## Feature 모듈 경계 규칙

- Feature 이름은 소유한 화면 묶음을 나타낸다. Domain 엔티티와 일대일 대응할 필요가 없다.
- 단일 화면이면 화면명, 여러 화면이면 공통 화면 계층의 이름을 사용한다.
- 한 화면과 전용 View·ViewModel·모델은 한 Feature 모듈이 소유한다.
- 다른 Feature에 필요하다는 이유만으로 화면 전용 코드를 Domain/Core로 옮기지 않는다.
- 공유 위치는 소비처와 의존 방향으로 결정하며 순환 의존을 만들지 않는다.
