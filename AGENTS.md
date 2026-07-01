# AGENTS.md — Codex 작업 규칙

Codex는 이 프로젝트에서 하네스 기반 작업 흐름을 기본값으로 따른다.

---

## 원칙

- 구현 작업은 계획 → 격리 worktree 작업 → 검증 → 커밋 순서로 진행한다.
- `master`, `dev` 브랜치에서 직접 구현하지 않는다.
- 사용자 변경사항을 되돌리지 않는다. 관련 없는 dirty worktree 변경은 그대로 둔다.
- 계획에 없는 변경은 추가하지 않는다. 작업 중 새 범위가 필요하면 계획을 갱신하고 사용자에게 알린다.
- 공용 하네스 규칙은 `docs/HARNESS.md`를 따른다.

---

## 1단계 — PLAN 생성

구현 작업을 시작할 때 먼저 작업 ID와 설명을 정하고 다음 스크립트를 실행한다.

```bash
bash scripts/start-task.sh <task-id> <description>
```

스크립트가 생성하는 산출물:

| 산출물 | 경로 |
|---|---|
| 계획서 | `.harness/exec-plans/active/<task-id>/PLAN.md` |
| 격리 worktree | `.harness/worktrees/<task-id>/` |
| 로그 디렉토리 | `.harness/logs/<task-id>/` |

계획서를 작성하기 전에 `docs/HARNESS.md`와 `docs/AGENTS_DOC_INDEX.md`를 확인하고, 작업에 필요한 문서를 읽는다.

---

## 2단계 — Worktree 작업

생성된 worktree로 이동해 작업한다.

```bash
cd .harness/worktrees/<task-id>
```

worktree 준비가 필요하면 Codex 스킬 `$setup-worktree`를 사용한다. 해당 스킬은 메인 루트의 `Secrets.xcconfig`를 worktree로 복사하고 `tuist install`을 실행한다.

---

## 3단계 — 테스트 작성

테스트는 사용자가 명시적으로 요청했거나, 변경 위험도가 높아 테스트 없이는 검증이 불충분한 경우에 작성한다.

테스트를 작성하지 않는 경우에도 PLAN의 테스트/검증 섹션에 그 이유와 대체 검증 방법을 적는다.

---

## 4단계 — 검증

검증 단계에 들어가면 `docs/VERIFICATION.md`를 읽고 다음 스크립트를 실행한다.

```bash
bash scripts/verify-task.sh <task-id>
```

검증 항목:

- 빌드
- 단위 테스트
- 아키텍처 의존성

검증 실패 시 원인을 수정하고 재검증한다. 실패 상태로 커밋하지 않는다.

---

## 5단계 — 커밋

검증 통과 후에만 커밋한다.

- 커밋 메시지는 컨벤셔널 커밋 형식을 사용한다.
- 커밋 전 `git status --short`로 변경 범위를 확인한다.
- 사용자 또는 다른 도구가 만든 관련 없는 변경은 커밋에 포함하지 않는다.
- 완료 후 필요하면 `.harness/exec-plans/active/<task-id>/PLAN.md`를 `.harness/exec-plans/completed/`로 이동한다.

---

## 문서 목차

기존 `AGENTS.md`의 참고 문서 목차는 `docs/AGENTS_DOC_INDEX.md`로 이동했다. 계획 작성 시 반드시 이 문서를 먼저 확인한다.
