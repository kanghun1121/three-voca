---
paths:
  - "Projects/Feature/**/*.swift"
---

# Feature 레이어 경계

- 참조 가능: DomainInterface, DesignSystem, 화면 연결에 필요한 다른 Feature, Core(로깅 용도로만).
- ViewModel에서 네트워크·Keychain·DB를 직접 호출하지 않는다. Repository/UseCase를 통한다.
- Home/Lesson/Word는 ViewModel의 `Destination` enum + `destination` 바인딩을 내비게이션 기본 패턴으로 쓴다. MyPage/Login은 예외 패턴이 있다.
- "다른 Feature도 필요하다"는 이유만으로 화면 전용 코드를 Domain/Core로 옮기지 않는다.
- Feature Interface 타겟은 실제 의존 경계 분리가 필요할 때만 추가한다.
- ViewModel은 Domain Model을 그대로 상태로 보유한다. 중복되는 PresentationModel 계층을 만들지 않는다.

전체 레이어 규칙: `docs/architecture.md`
