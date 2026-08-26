---
name: setup-worktree
description: 이슈 번호를 받으면 이슈 내용을 확인하고, 브랜치/워크트리/문제정의 파일/PLAN.md/로그 디렉토리를 생성한 뒤 Secrets.xcconfig 복사 + tuist install까지 끝내서 'tuist generate'만 치면 Xcode가 열리는 상태를 만든다. 사용자가 이슈 번호(#87 등)를 던지며 새 작업을 시작하자고 하면, 또는 '워크트리 만들어', 'worktree 설정', 'tuist 설정', 'Xcode 열기 전 준비', 'setup worktree', '/setup-worktree'라고 하면 트리거한다.
---

# setup-worktree

이슈 확인부터 Xcode를 열 수 있는 상태까지 한 번에 준비한다. 이전에는 `scripts/start-task.sh`(브랜치/PLAN/로그)와 이 스킬(xcconfig/tuist)이 분리돼 있었지만, 지금은 이 스킬 하나로 전부 처리한다.

## 실행 절차

### 0단계 — 이슈 확인

```bash
gh issue view <issue-number>
```

제목과 본문을 확인한다. 이슈 없이 시작하는 작업이면 사용자에게 먼저 확인한다.

### 1단계 — task-id 결정

CLAUDE.md의 Branches 규칙을 따른다:

`<이슈번호 3자리>-<type>-<kebab-description>`

- `<type>`: feature, fix, refactor, chore, docs 중 하나 (소문자, 이슈 내용으로 판단)
- 예: 이슈 `#87`, 어휘 검색 필터 기능 → `087-feature-vocabulary-search-filter`

### 2단계 — 브랜치/워크트리 생성

이미 존재하면 건너뛴다.

```bash
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
source "$PROJECT_ROOT/.claude/hooks/harness-config.sh"

WORKTREE_PATH="$HARNESS_WORKTREES_DIR/<task-id>"
mkdir -p "$(dirname "$WORKTREE_PATH")"
git -C "$PROJECT_ROOT" worktree add "$WORKTREE_PATH" -b "<task-id>" dev

mkdir -p "$HARNESS_ROOT"
echo "<task-id>" > "$HARNESS_ACTIVE_TASK_FILE"
```

이후 단계는 전부 이 워크트리(`$WORKTREE_PATH`) 안에서 수행한다 — 메인 루트가 아니다.

### 3단계 — 문제정의 파일 생성

**반드시 2단계에서 만든 워크트리 안에** 0단계에서 확인한 이슈 제목/본문을 바탕으로 작성한다. 메인 루트나 다른 워크트리에 쓰지 않는다.

```bash
mkdir -p "$WORKTREE_PATH/.harness/problems"
```

`$WORKTREE_PATH/.harness/problems/<이슈번호 3자리>-<도메인제목>.md`에 이슈 제목/본문을 근거로 문제정의를 작성한다. 이 파일이 이후 `harness-plan` 스킬 0단계가 읽는 대상이다.

### 4단계 — PLAN.md 생성

```bash
PLAN_DIR="$HARNESS_EXEC_PLANS_DIR/active/<task-id>"
mkdir -p "$PLAN_DIR"
```

`$PLAN_DIR/PLAN.md`가 없으면 아래 템플릿으로 생성한다 (이미 있으면 건너뜀):

```markdown
# PLAN: <description>

- 작업 ID: `<task-id>`
- 생성일: <YYYY-MM-DD>
- 기반 브랜치: dev
- Worktree: `.harness/worktrees/<task-id>`
- 문제정의: `.harness/problems/<이슈번호 3자리>-<도메인제목>.md`

---

## 목표

<description>

---

## 사전 검토

- [ ] docs/ARCHITECTURE.md 검토 완료
- [ ] 관련 docs/ 문서 검토 완료
- [ ] 영향받는 모듈/파일 파악 완료

---

## 단계별 계획

1. [단계] → 검증: [확인 방법]
2. [단계] → 검증: [확인 방법]

---

## 테스트 계획

| 시나리오 | 유형 | 파일 |
|---|---|---|
| 정상 동작 | unit | Tests/??Tests.swift |
| 엣지 케이스 | unit | |

---

## 체크리스트

- [ ] 계획 수립 완료
- [ ] 구현 완료
- [ ] 테스트 작성 완료
- [ ] 커밋 완료
```

### 5단계 — 로그 디렉토리 생성

```bash
mkdir -p "$HARNESS_LOGS_DIR/<task-id>"
```

### 6단계 — 경로 확인

```bash
git worktree list --porcelain
```

출력의 첫 번째 `worktree` 줄이 메인 루트다. 2단계에서 만든 워크트리로 이동했는지(`pwd`) 확인한다.

### 7단계 — xcconfig 복사

메인 루트의 두 xcconfig 파일을 현재 worktree의 동일 경로에 복사한다.

```bash
MAIN_ROOT="<6단계에서 확인한 메인 루트>"
WORKTREE="<현재 디렉토리>"

cp "$MAIN_ROOT/Projects/App/Secrets.xcconfig" "$WORKTREE/Projects/App/Secrets.xcconfig"
cp "$MAIN_ROOT/Projects/Core/Example/Secrets.xcconfig" "$WORKTREE/Projects/Core/Example/Secrets.xcconfig"
```

복사할 원본 파일이 없으면 에러를 출력하고 중단한다. `.sample` 파일로 대체하지 않는다 (실제 키 값이 없으면 빌드가 깨지므로).

### 8단계 — tuist install

```bash
cd "$WORKTREE" && tuist install
```

### 완료 안내

성공하면 다음을 출력한다:

```
✅ 작업 환경 생성 완료

  브랜치   : <task-id>  (← dev)
  worktree : <WORKTREE_PATH>
  문제정의 : .harness/problems/<이슈번호 3자리>-<도메인제목>.md
  exec-plan: .harness/exec-plans/active/<task-id>/PLAN.md
  logs     : .harness/logs/<task-id>/

tuist generate 를 실행하면 Xcode가 열립니다.
```

이후 `harness-plan` 스킬로 넘어간다.

## 이미 존재하는 워크트리에서 실행한 경우

1~5단계는 전부 건너뛰고 7~8단계(xcconfig, tuist install)만 수행한다.
