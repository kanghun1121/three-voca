---
paths:
  - "Projects/Networking/**/*.swift"
---

# Networking / NetworkingInterface 경계

- NetworkingInterface는 참조 가능한 레이어가 없다. HTTP/SSE·인증 포트 정의만 둔다.
- Networking(구현체)은 NetworkingInterface, Core만 참조할 수 있다.

전체 레이어 규칙: `docs/architecture.md`
