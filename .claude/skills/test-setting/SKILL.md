---
name: test-setting
description: 멀티 모듈 Tuist 저장소에서 각 모듈의 테스트 타겟이 Workspace.swift의 AllTest 스킴에 전부 등록돼 있는지 감사하고 누락분을 채워 넣는다.
---

# test-setting

## 배경

이 저장소는 모듈별로 `Project.swift`가 흩어져 있고, 각 모듈의 테스트 타겟은 `Plugins/DependencyPlugin`의 팩토리 함수(`.core(tests:)`, `.domain(tests:)`, `.networking(tests:)`, `.feature(tests:)`)로 선언된다. 하지만 실제로 `xcodebuild test`가 도는 범위는 `Workspace.swift`의 `AllTest` 스킴에 **수동으로 나열된 target 목록**뿐이다.

즉 모듈에 테스트 타겟을 새로 만들어도 `Workspace.swift`에 추가하는 걸 잊으면, 그 테스트는 로컬에서 Xcode로 개별 실행하면 통과하는 것처럼 보여도 `AllTest` 스킴 기반 검증(`.claude/hooks/run-tests-after-edit.sh`)에서는 **조용히 스킵**된다. 이 드리프트를 잡는 게 이 스킬의 목적이다.

## 타겟 이름 규칙

| 모듈 위치 | 생성되는 타겟 이름 | 소스 |
|---|---|---|
| `Projects/Core` | `CoreTests` | `Target+Core.swift` |
| `Projects/Domain` | `DomainTests` | `Target+Domain.swift` |
| `Projects/Networking` | `NetworkingTests` | `Target+Networking.swift` |
| `Projects/Feature/<Name>` | `Feature<Name>Tests` | `Target+Feature.swift` (`f.name = "Feature\(module.rawValue)Tests"`) |

## 절차

### 1. 실제 선언된 테스트 타겟 전수 조사

```bash
for f in $(find Projects -iname "Project.swift" | sort); do
  grep -Hn "tests:" "$f" || true
done
```

`tests:` 팩토리가 있는 모든 `Project.swift`를 찾고, 위 표를 기준으로 실제 생성될 타겟 이름 + 프로젝트 경로(`Projects/...`)를 도출한다.

### 2. Workspace.swift와 대조

`Workspace.swift`의 `AllTest` 스킴은 `buildAction.targets`와 `testAction.targets` **두 배열 모두**에 각 타겟이 들어가 있어야 한다 (하나만 있으면 빌드는 되지만 테스트 실행에서 빠지거나 그 반대).

1단계에서 도출한 타겟 목록과 두 배열을 비교해서:
- **buildAction에는 있는데 testAction에 없음** → 빌드만 되고 테스트는 안 도는 상태
- **둘 다 없음** → 완전히 빠진 모듈
- **Workspace.swift엔 있는데 Project.swift에 해당 타겟이 더 이상 없음** → 모듈 삭제/리네임 후 정리 안 된 죽은 참조

셋 다 보고한다.

### 3. 누락분 채우기

`Workspace.swift`의 `buildAction.targets`와 `testAction.targets`에 기존 항목과 동일한 포맷으로 누락된 타겟을 추가한다.

```swift
// buildAction.targets 에 추가
.project(path: "Projects/Feature/Analysis", target: "FeatureAnalysisTests"),

// testAction.targets 에 추가
.testableTarget(
    target: .project(path: "Projects/Feature/Analysis", target: "FeatureAnalysisTests")
),
```

죽은 참조는 제거하기 전에 사용자에게 먼저 확인한다 — 모듈이 정말 삭제된 건지, 아니면 이름만 바뀐 건지 착각할 수 있기 때문이다.

### 4. 검증

```bash
tuist generate
bash .claude/hooks/run-tests-after-edit.sh
```

`Workspace.swift`는 `.swift` 파일이라 이 변경 자체가 `run-tests-after-edit.sh`의 diff 감지 조건에 걸리므로 바로 실행된다. 출력에서 방금 추가한 모듈의 `Test Case` 라인이 실제로 등장하는지 확인한다. 등장하지 않으면 타겟 이름이나 경로가 틀린 것이므로 1단계로 돌아간다.

## 주의

- `AllTest` 스킴에 추가하는 것과 그 모듈의 테스트가 실제로 통과하는 것은 별개다. 이 스킬은 "빠짐없이 실행되게" 만드는 것까지가 범위고, 테스트 자체의 성공/실패는 `harness-debug` 스킬의 영역이다.
- Example 타겟(`.feature(example:)`)은 테스트 타겟이 아니므로 `AllTest`에 넣지 않는다.
