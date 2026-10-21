---
name: code-review
description: PR/브랜치 전체를 종합 리뷰하고 승인·보류·에스컬레이션 여부까지 판단한다. "코드 리뷰해줘", "이거 머지해도 될까", "리뷰 코멘트 써줘"처럼 PR 단위 검토·승인 판단을 요청할 때 트리거한다. 버그·보안만 찾을 땐 find-bugs, 스타일만 볼 땐 swift-lint를 대신 쓴다.
---

# Code Review

버그/보안 탐지, 스타일 검사, 레이어 배치 판단은 각각 전용 스킬에 위임하고, 이 스킬은 그 결과를 모아
사람이 필요로 하는 최종 판단(테스트 커버리지, 승인/보류, 톤, 에스컬레이션)을 담당한다.

이 프로젝트에서는 빌트인 `/code-review`(및 `--comment`/`--fix` 옵션) 대신 이 스킬을 사용한다.
같은 이름의 프로젝트 스킬이 빌트인 스킬을 대체하기 때문에, "코드 리뷰해줘"/"PR 리뷰해줘" 요청은
전부 이 스킬로 온다. 단, `/review`처럼 빌트인 쪽 별칭으로 직접 호출하면 대체되지 않고 빌트인이 실행된다
— 이 저장소에서는 `/review`가 아니라 `/code-review` 또는 자연어 요청으로 트리거한다.

## 절차

### 1. 변경 파악

```bash
git diff dev...HEAD
```

변경된 파일 전체를 나열하고, 어떤 레이어(App/Core/Data/DesignSystem/Domain/Feature/Networking)가
영향받는지 먼저 파악한다.

### 2. 하위 스킬 위임 (필요한 만큼만)

- 버그·동시성·레이어 경계 위반·보안 → `find-bugs`
- 스타일·컨벤션 → `swift-lint`
- 새 모듈/레이어 배치, 의존 방향 판단 → `architecture-review` (구조가 실제로 바뀔 때만)

이 스킬 자체는 별도 버그·스타일 체크리스트를 복제하지 않는다. 위 스킬들의 결과를 입력으로 받는다.

### 3. 테스트 커버리지 확인 (이 저장소 관례 기준)

- 새 UseCase/Repository → `Domain/Tests`·`Data/Tests`에 대응 테스트가 있는가
- 새 ViewModel 로직·`Destination` 분기 → 해당 Feature의 `Tests/`에 대응 테스트가 있는가
- 버그 수정 → 회귀를 막을 테스트가 함께 추가됐는가. 없다면 이유를 확인한다
- 테스트 코드 자체가 과도한 분기·반복문을 갖고 있지 않은가

### 4. 장기 영향 판단 — 해당하면 사람 리뷰로 에스컬레이션 권고

- SwiftData 스키마 변경 (마이그레이션 영향)
- Repository/UseCase 계약(공개 API) 변경 — 다른 Feature 소비처까지 확인됐는가
- 새 프레임워크·패키지 도입
- 인증/토큰/Keychain 등 보안 민감 로직
- `Projects/App/Sources/RootView.swift`의 DI 조립 변경

### 5. 피드백 작성

- 구체적이고 실행 가능한 제안으로 말한다. 확신이 없으면 미확인 사항으로 남긴다.
- 사소한 이슈로 결론을 흐리지 않는다. 심각도 순으로만 정리한다.
- 목표는 리스크 감소다. 완벽한 코드를 요구하지 않는다.

## 흔한 패턴 예시

```swift
// Bad — 테스트에서 교체 불가능한 직접 의존
final class WordViewModel {
    private let repository = WordRepository.liveValue
}

// Good — @Dependency로 주입받아 테스트에서 withDependencies로 교체 가능
final class WordViewModel {
    @Dependency(\.wordRepository) private var repository
}
```

## 출력 형식

- **결론**: 승인 가능 / 보류(수정 필요) / 사람 에스컬레이션 필요 — 셋 중 하나
- **하위 스킬 결과 요약**: find-bugs/swift-lint/architecture-review 각각 몇 건, 어떤 심각도
- **테스트 커버리지 갭**: 있다면 어떤 시나리오가 비어 있는지
- **에스컬레이션 사유**: 4단계에 해당하면 구체적으로 어떤 항목 때문인지

결과는 대화로 그대로 전달한다. 개인 작업이라 PR에 인라인 코멘트를 게시하거나 자동으로 fix를 적용하지 않는다. 필요하면 별도로 요청한다.

## 트리거 케이스 vs 비-트리거 케이스

### ✅ 이 스킬을 사용한다
- "PR 리뷰해줘", "코드 리뷰해줘", "이거 머지해도 될까?", "종합적으로 리뷰해줘"

### ❌ 이 스킬을 사용하지 않는다
- 버그·보안만 찾으면 될 때 → `find-bugs` 단독 사용
- 스타일/컨벤션만 궁금할 때 → `swift-lint`
- 아키텍처 배치 자체가 궁금할 때 → `architecture-review`

## References

- 빌트인 스킬을 프로젝트 스킬로 대체하는 동작: [Claude Code Docs — Skills](https://code.claude.com/docs/en/skills)
