# 개발 공통 기준

모든 변경에서 수정할 원본과 검증 범위를 판단하는 기준이다.
코드 책임은 [architecture.md](architecture.md), 작성 규칙은 [swift-style.md](swift-style.md)를 따른다.

## 수정할 원본

| 변경 대상 | 수정 위치 |
|---|---|
| 모듈·타겟·의존 방향 | `Projects/**/Project.swift` |
| 공통 타겟 생성 규칙 | `Plugins/DependencyPlugin/ProjectDescriptionHelpers/` |
| 외부 패키지 | `Tuist/Package.swift`, `Plugins/DependencyPlugin/ProjectDescriptionHelpers/Dependency+SPM.swift` |
| 전체 테스트 스킴 | `Workspace.swift`의 `AllTest` |
| 도구 버전 | `mise.toml` |
| 모듈 테스트 | 해당 모듈의 `Tests/` |

- Xcode 프로젝트·워크스페이스와 `Derived/`는 생성 산출물이다. 변경은 Tuist 원본에 반영한다.
- `Projects/App/Secrets.xcconfig`는 로컬 설정이며 커밋하지 않는다. 필요한 키 이름은 `Projects/App/Secrets.xcconfig.sample`을 참고한다.
- 공용 심볼·설정·디자인 토큰을 바꾸기 전에 사용처를 확인한다.
- 기존 미커밋 변경을 보존하고, 작업과 무관한 포맷·이름·구조 변경을 섞지 않는다.

## 공통 명령

저장소 루트에서 실행한다. 환경 준비와 프로젝트 생성은 필요한 경우에 수행한다.

| 목적 | 명령 |
|---|---|
| 의존성 설치·갱신 | `tuist install` |
| 프로젝트 생성 | `tuist generate --no-open` |
| 전체 테스트 | `tuist test AllTest` |

CI의 기준은 `.github/workflows/ci.yml`이다. 로컬 훅이 검증을 자동 실행한다고 가정하지 않는다.

## 변경별 검증

- Swift 동작 변경: 영향을 받는 테스트를 실행한다. 회귀 가능성이 있으면 해당 시나리오를 검증한다.
- 공용 계약·모듈 의존성 변경: 영향받는 소비처의 빌드·테스트를 확인한다.
- Tuist 설정·패키지 변경: 필요한 의존성 설치와 프로젝트 재생성 후 빌드·테스트를 확인한다.
- UI 변경: 관련 Example 또는 앱에서 화면·상태 전환을 확인하고, 로직 변경이 있으면 테스트도 실행한다.
- 문서만 변경: 경로·명령·내부 링크·문서 간 일관성을 확인한다. 앱 빌드는 요구하지 않는다.
- 전체 통합 검증은 `AllTest`를 기준으로 한다. 같은 변경에 성공한 검증을 이유 없이 반복하지 않는다.
- 실행한 검증과 미실행 항목을 구분해 보고한다. 환경 문제로 실행하지 못했으면 이유를 명시한다.

## 문서 유지 기준

- `docs/`의 각 문서는 200줄 이하로 유지하고, 상시 필요한 공통 규칙만 담는다.
- 작업별 절차·긴 예제·리팩터링 이력은 상시 문서에 누적하지 않는다.
- 동일 규칙은 한 문서에서 정의하고 다른 문서에서는 링크한다. 사실과 지향 정책을 구분한다.
