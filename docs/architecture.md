# 아키텍처

코드 배치·책임·의존 방향을 세 문서로 나누어 정의한다. 변경이 닿는 영역의 문서를 읽는다. 필요한 Good/Bad Case는 해당 문서에서 연결하는 별도 파일에 둔다.

| 영역 | 읽을 문서 | 핵심 기준 |
|---|---|---|
| Clean Architecture | [clean-architecture.md](architecture/clean-architecture.md) | 레이어 의존 방향, Repository/UseCase, DTO → Domain Model |
| Dependency Injection | [dependency-injection.md](architecture/dependency-injection.md) | `swift-dependencies`, 계약과 구현, 앱 조립 |
| Modulization | [modulization.md](architecture/modulization.md) | Domain·Networking·Feature 타겟 구성과 Interface 경계 |

작성·검토 규칙은 [lint.md](lint.md), SwiftUI 규칙은 [swift-style.md](swift-style.md)를 따른다.
