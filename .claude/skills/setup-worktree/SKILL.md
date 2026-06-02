---
name: setup-worktree
description: 현재 worktree에 Secrets.xcconfig를 복사하고 tuist install을 실행해 'tuist generate'만 치면 Xcode가 열리는 상태를 만든다. 사용자가 'worktree 설정', 'tuist 설정', 'Xcode 열기 전 준비', 'setup worktree', '/setup-worktree'라고 하면 트리거한다.
---

# setup-worktree

현재 worktree에서 `tuist generate`만 입력하면 Xcode IDE가 열릴 수 있도록 환경을 준비한다.

## 실행 절차

다음 단계를 순서대로 실행한다.

### 1단계 — 경로 확인

```bash
# 현재 디렉토리가 worktree인지 확인하고 메인 루트를 구한다
git worktree list --porcelain
```

출력의 첫 번째 `worktree` 줄이 메인 루트다. 현재 디렉토리(`pwd`)와 비교해 worktree 여부를 판단한다.

- 현재 디렉토리 == 메인 루트: "메인 루트에서 실행 중입니다. worktree 디렉토리로 이동 후 실행해주세요." 라고 안내하고 중단.
- 현재 디렉토리가 메인 루트 하위의 `.claude/worktrees/` 경로: 정상 진행.

### 2단계 — xcconfig 복사

메인 루트의 두 xcconfig 파일을 현재 worktree의 동일 경로에 복사한다.

```bash
MAIN_ROOT="<1단계에서 확인한 메인 루트>"
WORKTREE="<현재 디렉토리>"

cp "$MAIN_ROOT/Projects/App/Secrets.xcconfig" "$WORKTREE/Projects/App/Secrets.xcconfig"
cp "$MAIN_ROOT/Projects/Core/Example/Secrets.xcconfig" "$WORKTREE/Projects/Core/Example/Secrets.xcconfig"
```

복사할 원본 파일이 없으면 에러를 출력하고 중단한다. `.sample` 파일로 대체하지 않는다 (실제 키 값이 없으면 빌드가 깨지므로).

### 3단계 — tuist install

```bash
cd "$WORKTREE" && tuist install
```

### 완료 안내

성공하면 다음을 출력한다:

```
✅ 환경 준비 완료.
   tuist generate 를 실행하면 Xcode가 열립니다.
```
