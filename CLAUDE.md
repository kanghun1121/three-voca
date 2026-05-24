# CLAUDE.md

Claude가 따라야 할 프로젝트 운영 규칙.

---

## 1. 린트 규칙
  
코드 작성 또는 수정 후 `swift-lint` 스킬로 반드시 검토한다.

핵심 규칙:

- `import` 는 알파벳 오름차순 정렬
- 함수 파라미터가 3개 이상일 때만 줄바꿈
- 타입 어노테이션은 항상 명시 (타입 추론 남용 금지)
- 클로저 파라미터에 `$0`, `$1` 남용 금지 — 의미 있는 이름 사용

---

## 2. 건드리면 안 되는 파일

아래 파일은 **새 모듈 추가 또는 의존성 변경 외에는 수정하지 않는다.**

| 파일 / 경로 | 이유 |
|---|---|
| `Plugins/DependencyPlugin/**` | 모든 모듈의 의존성 선언 원천. 잘못 수정하면 전체 빌드 깨짐 |
| `Workspace.swift` | 워크스페이스 구성. 임의 수정 시 Xcode 프로젝트 인식 불가 |
| `Tuist.swift` | Tuist 버전 및 플러그인 선언. 임의 변경 금지 |
| `Projects/*/Project.swift` (레이어 aggregator) | 새 모듈 추가 시에만 수정하며, `micro-feature` 스킬을 통해서만 건드린다 |

**Manifest 파일 수정 후에는 반드시 `tuist generate`를 실행한다.**

---

## 3. 테스트 명령과 완료 기준

### 명령

모든 명령은 **XcodeBuildMCP**를 통해 실행한다. 직접 `xcodebuild` CLI를 쓰지 않는다.

- 빌드: `build_sim`
- 빌드 + 실행: `build_run_sim`
- 테스트: `test_sim`

### 완료 기준

아래 세 가지를 모두 통과해야 작업 완료다.

- [ ] `build_sim` 성공 (warning은 허용, error는 불가)
- [ ] `test_sim` 전체 통과
- [ ] `swift-lint` 스킬 검토 후 위반 없음

하나라도 실패하면 완료로 보고하지 않는다. 원인을 먼저 수정한다.

---

## 4. 작업 사이클

모든 구현 작업은 **5단계를 순서대로** 따른다. 단계를 건너뛰지 않는다.  
검증 실패 시 1단계부터 다시 시작한다.

---

### 1단계 — PLAN 생성

```bash
bash scripts/start-task.sh <task-id> <description>
```

스크립트가 자동으로 생성한다:

| 산출물 | 경로 |
|---|---|
| 계획서 | `exec-plans/active/<task-id>/PLAN.md` |
| 격리 브랜치 | `.claude/worktrees/<task-id>/` |
| 로그 디렉토리 | `logs/<task-id>/` |

**계획서를 먼저 작성한다.** 계획 없이 코드를 먼저 작성하지 않는다.

---

### 2단계 — Worktree 작업

생성된 Worktree 디렉토리로 이동하여 작업한다.

```bash
cd .claude/worktrees/<task-id>
```

- `ARCHITECTURE.md` → 관련 `docs/` 문서를 순서대로 읽는다.
- `master`, `dev` 브랜치에서 직접 코드를 수정하지 않는다.
- 계획서(`PLAN.md`)에 없는 코드는 추가하지 않는다.

---

### 3단계 — 테스트 작성

구현한 기능에 대해 단위 테스트를 반드시 작성한다.

| 유형 | 테스트 기준 |
|---|---|
| 새 기능 | 정상 동작 + 엣지 케이스 |
| 버그 수정 | 재현 테스트 (fix 전 실패 → fix 후 통과) |
| 리팩토링 | 기존 동작 보존 확인 |

---

### 4단계 — 검증

```bash
bash scripts/verify-task.sh <task-id>
```

검증 항목:

- [ ] 빌드 (error 0개)
- [ ] 단위 테스트 전체 통과
- [ ] 아키텍처 의존성 (역방향 import 없음)

검증을 통과하지 못하면 커밋하지 않는다. 원인을 수정한 뒤 재시도한다.  
상세 검증은 `docs/VERIFICATION.md`의 3-Layer 프로세스를 따른다.

---

### 5단계 — 커밋

`git:commit` 스킬 또는 컨벤셔널 커밋 메시지로 커밋한다.

**pre-commit 훅이 Swift 파일 변경 시 테스트를 자동 실행한다.** 실패 시 커밋이 차단된다.  
긴급 건너뛰기: `git commit --no-verify` (남용 금지)

완료 후 `exec-plans/active/<task-id>/PLAN.md` 를 `exec-plans/completed/` 로 이동한다.
