---
paths:
  - "Projects/Domain/**/*.swift"
---

# Domain / DomainInterface 경계

- DomainInterface는 Data, Core, Networking, NetworkingInterface를 참조하지 않는다.
- Domain Model(`Projects/Domain/Interface/Model/`)은 SwiftUI·DesignSystem을 참조하지 않는다.
- UseCase 계약은 `Interface/UseCase`, 구현은 `Sources/UseCase`. `liveValue`는 Domain에 둔다.
- Repository/UseCase 계약의 `testValue`는 `unimplemented`로 의도치 않은 호출을 감지하게 작성한다.
- 용어: `Vocabulary`는 새 모듈·도메인 이름으로 쓰지 않는다. `Session`은 인증·채팅 세션 전용이며 학습 단위를 뜻하는 이름으로 쓰지 않는다.

전체 레이어 규칙: `docs/architecture.md`
