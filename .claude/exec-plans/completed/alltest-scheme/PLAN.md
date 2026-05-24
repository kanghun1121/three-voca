# PLAN: AllTest Workspace 스킴 추가 및 verify/pre-commit 개선

- 작업 ID: `alltest-scheme`
- 생성일: 2026-05-24
- 기반 브랜치: dev
- Worktree: `.claude/worktrees/alltest-scheme`

---

## 목표

현재 `verify-task.sh`와 `pre-commit.sh`는 `FeatureSession` 스킴만 테스트한다.
`Workspace.swift`에 `AllTest` 스킴을 추가하고 Tuist로 재생성하여,
모든 모듈의 테스트(현재: FeatureHomeTests + FeatureSessionTests)를 한 번에 돌릴 수 있게 한다.

---

## 사전 검토

- [x] Workspace.swift: 현재 `projects: ["Projects/**"]`만 있음 — `schemes:` 파라미터 추가 가능
- [x] Tuist Workspace의 `.scheme()`은 cross-project TargetReference를 지원함
- [x] `tuist generate` 실행 후 `AllTest` 스킴이 xcworkspace에 반영됨
- [x] verify-task.sh + pre-commit.sh 의 `TEST_SCHEME` / `SCHEME` 변수만 교체하면 됨

---

## 단계별 계획

| 단계 | 작업 | 파일 |
|------|------|------|
| 1 | `Workspace.swift`에 `AllTest` 스킴 정의 추가 | `Workspace.swift` |
| 2 | `tuist generate` 실행 — xcworkspace 재생성 | (생성 파일) |
| 3 | `xcodebuild -workspace ... -list`로 `AllTest` 스킴 존재 확인 | - |
| 4 | `verify-task.sh`: `TEST_SCHEME="AllTest"` 로 변경 | `scripts/verify-task.sh` |
| 5 | `pre-commit.sh`: `SCHEME="AllTest"` 로 변경 | `.claude/hooks/pre-commit.sh` |

---

## Workspace.swift 변경 내용

```swift
import ProjectDescription

let workspace = Workspace(
    name: "FiveVoca",
    projects: ["Projects/**"],
    schemes: [
        .scheme(
            name: "AllTest",
            buildAction: .buildAction(targets: [
                .project(path: "Projects/Feature/Home", target: "FeatureHomeTests"),
                .project(path: "Projects/Feature/Session", target: "FeatureSessionTests"),
            ]),
            testAction: .targets([
                .testableTarget(
                    target: .project(path: "Projects/Feature/Home", target: "FeatureHomeTests")
                ),
                .testableTarget(
                    target: .project(path: "Projects/Feature/Session", target: "FeatureSessionTests")
                ),
            ])
        )
    ]
)
```

---

## 테스트 계획

이 작업은 인프라 변경이므로 별도 단위 테스트는 없다.
다음으로 동작 검증한다:

| 시나리오 | 확인 방법 |
|----------|-----------|
| AllTest 스킴 생성 확인 | `xcodebuild -workspace FiveVoca.xcworkspace -list` |
| 전체 테스트 통과 | `xcodebuild test -scheme AllTest ...` — FeatureHomeTests + FeatureSessionTests 모두 통과 |

---

## 체크리스트

- [x] 계획 수립 완료
- [ ] Workspace.swift 수정 완료
- [ ] `tuist generate` 완료 및 AllTest 스킴 생성 확인
- [ ] verify-task.sh + pre-commit.sh 스킴 변경 완료
- [ ] `bash scripts/verify-task.sh alltest-scheme` PASS
- [ ] 커밋 완료
