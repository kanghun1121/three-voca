---
paths:
  - "Projects/Data/**/*.swift"
---

# Data 레이어 경계

- Networking 구현체를 직접 참조하지 않는다. `NetworkingInterface` 포트로만 호출한다.
- LocalDataSource/RemoteDataSource는 Data 내부 구현이다. Feature/Domain에 노출하지 않는다.
- 외부 응답·저장 Entity → Domain Model 변환은 Repository 경계에서, 원본 타입의 extension으로 작성한다. 별도 Mapper 계층을 기본으로 만들지 않는다.
- 저장 Entity는 SwiftData `@Model`을 포함한다. 모든 Entity가 `Decodable struct`인 것은 아니다.
- 로컬 DB 공통 기반은 `Projects/Data/Sources/LocalDatabase/`에 둔다.
- Repository의 `liveValue`는 여기(Data)에 등록한다.

전체 레이어 규칙: `docs/architecture.md`
