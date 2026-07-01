# HARNESS.md

Claude와 Codex가 함께 사용하는 작업 하네스 규칙이다.

---

## 공용 경로

새 작업은 `.harness` 아래에 생성한다.

| 용도 | 경로 |
|---|---|
| 활성 작업 ID | `.harness/active-task` |
| 실행 계획 | `.harness/exec-plans/active/<task-id>/PLAN.md` |
| 완료 계획 | `.harness/exec-plans/completed/` |
| 격리 worktree | `.harness/worktrees/<task-id>/` |
| 검증 로그 | `.harness/logs/<task-id>/` |

기존 `.claude/worktrees`, `.claude/exec-plans`, `.claude/logs`는 과거 작업 호환용으로만 둔다. 기존 worktree는 `git worktree` 메타데이터가 연결되어 있으므로 수동으로 옮기지 않는다.

---

## 공용 스크립트

| 스크립트 | 역할 |
|---|---|
| `scripts/harness-config.sh` | 하네스 공용 경로 정의 |
| `scripts/start-task.sh` | PLAN, worktree, logs 생성 |
| `scripts/verify-task.sh` | 빌드, 테스트, 아키텍처 의존성 검증 |
| `scripts/phase-guard-hook.sh` | 검증 페이즈 파일 수정 차단 훅 |
| `scripts/verify-build-hook.sh` | 완료 전 Swift 변경 빌드 확인 훅 |
| `scripts/setup-hooks.sh` | Git hook 설치 |

---

## 분리 기준

- `.harness`: Claude와 Codex가 공유하는 작업 산출물
- `scripts`: 에이전트 공용 실행 로직
- `docs`: 에이전트 공용 규칙과 참고 문서
- `.claude`: Claude 전용 설정, 권한, 명령, Claude 스킬
- `/Users/kanghun/.codex/skills`: Codex 개인 스킬
