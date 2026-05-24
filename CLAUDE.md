# CLAUDE.md

Claude가 따라야 할 프로젝트 운영 규칙.

---

## 작업 사이클

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
