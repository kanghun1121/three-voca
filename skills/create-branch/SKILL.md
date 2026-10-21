---
name: create-branch
description: 브랜치 네이밍 규칙에 따라 `dev`에서 새 브랜치 + worktree를 만든다. "브랜치 만들어줘", "워크트리 만들어줘", "새 작업 시작", "이슈 #87로 시작해줘"처럼 새 작업을 시작할 때 트리거한다.
argument-hint: '[이슈 번호 또는 작업 설명]'
---

# Create Branch

브랜치 네이밍 규칙에 따라 `dev`에서 분기한 브랜치와 그 worktree를 만든다.
사용자가 이름을 직접 고르겠다고 명시하지 않는 한 비대화형으로 진행한다.

## Workflow

### 1. 작업 설명 확정

- `$ARGUMENTS`가 이슈 번호(`#87`, `87`)면 확인한다:
  ```bash
  gh issue view <issue-number>
  ```
  제목/본문에서 짧은 설명을 뽑는다.
- `$ARGUMENTS`가 텍스트 설명이면 그대로 쓴다.
- 인자가 없으면 로컬 변경으로 유추한다:
  ```bash
  git diff
  git diff --cached
  git status --short
  ```
- 이슈도 변경도 없으면 추측해서 진행하지 않는다. 이 저장소의 모든 활성 브랜치는 이슈 번호를 갖고 있으므로, 이슈 번호나 설명을 사용자에게 확인한다.

### 2. 타입 분류

이 저장소가 실제로 쓰는 커밋 태그와 동일하게 5개만 쓴다([Feature]/[Fix]/[Refactor]/[Chore]/[Docs] 커밋 태그 기준).

| Type | 쓰는 경우 |
|------|-----------|
| `feature` | 새 기능 |
| `fix` | 깨진 동작 수정 |
| `refactor` | 동작은 동일, 구조만 변경 |
| `chore` | 설정·도구·의존성 등 유지보수 |
| `docs` | 문서만 |

애매하면: 새로 생기는 것 → `feature`, 구조 재배치 → `refactor`, 그 외 유지보수 → `chore`.

### 3. 브랜치 이름 생성

```
<이슈번호 3자리>-<type>-<kebab-description>
```

- `<kebab-description>`은 영문 소문자, ASCII, 3~6단어.
- 이슈 번호가 없는 예외적인 경우 `<type>-<kebab-description>`만 쓰고, 왜 이슈 번호가 없는지 결과 보고에 한 줄로 남긴다.

예: 이슈 `#129`, 청크 오디오 엔드포인트 연동 → `129-feature-chunk-audio-endpoint`

### 4. 베이스 브랜치

항상 `dev`에서 분기한다. 이 저장소는 현재 브랜치를 베이스로 추정하지 않는다 — `dev`가 고정 베이스다.

```bash
git rev-parse --verify dev >/dev/null || echo "dev 브랜치를 찾을 수 없음. 확인 필요."
```

### 5. 충돌 확인

```bash
git rev-parse --verify "<branch-name>" 2>/dev/null
git ls-remote --heads origin "<branch-name>"
```

이미 있으면 번호를 붙여 새로 만들지 않는다. 대신 사용자에게 기존 브랜치/worktree를 재사용할지 확인한다 — 이 저장소는 연관 작업에 새 worktree 대신 기존 것을 재사용하는 쪽을 기본으로 한다.

### 6. 브랜치 + worktree 생성

이 저장소는 브랜치를 만들 때 항상 worktree로 분리한다 (in-place `checkout -b`가 아니다).

```bash
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
git -C "$PROJECT_ROOT" worktree add "$PROJECT_ROOT/.harness/worktrees/<branch-name>" -b "<branch-name>" dev
```

### 7. 결과 보고

브랜치명과 worktree 경로만 보고하고 확인을 기다리지 않는다.

```
브랜치   : <branch-name>  (← dev)
worktree : .harness/worktrees/<branch-name>
```

이후 작업은 이 worktree 안에서 계속한다 — 메인 루트가 아니다.

## References

- 최근 브랜치 예: `107-refactor-feature-modules`, `129-feature-chunk-audio-endpoint`, `126-fix-home-color`
