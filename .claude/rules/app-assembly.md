---
paths:
  - "Projects/App/**/*.swift"
---

# App 조립 지점

- DI 조립은 `Projects/App/Sources/RootView.swift`의 `withDependencies`에서 한다.
- 이곳의 명시적 `liveValue` 등록은 정적 링크 시 구현 연결을 유지하는 장치다. 임의로 제거하지 않는다.
- 새 의존성을 추가하면 App뿐 아니라 해당 Feature의 Example 주입 구성도 같이 확인한다.

전체 레이어 규칙: `docs/architecture.md`
