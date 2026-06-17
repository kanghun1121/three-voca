#!/bin/bash
# Usage: bash scripts/start-task.sh <task-id> <description>
# 작업 시작: Worktree + EXEC_PLAN + 로그 디렉토리를 한 번에 생성한다.
#
# 예시:
#   bash scripts/start-task.sh feat/home-redesign "홈 화면 UI 개편"

set -e

TASK_ID="$1"
DESCRIPTION="$2"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE_BRANCH="dev"

# ── 인수 검증 ──────────────────────────────────────────────────
if [ -z "$TASK_ID" ] || [ -z "$DESCRIPTION" ]; then
  echo "❌ Usage: bash scripts/start-task.sh <task-id> <description>"
  echo "   예시 : bash scripts/start-task.sh feat/home-redesign '홈 화면 UI 개편'"
  exit 1
fi

# ── 1. Worktree 생성 ───────────────────────────────────────────
WORKTREE_PATH="$PROJECT_ROOT/.claude/worktrees/$TASK_ID"

if [ -d "$WORKTREE_PATH" ]; then
  echo "⚠️  Worktree 이미 존재: $WORKTREE_PATH"
else
  echo "▶ Worktree 생성 중 ($TASK_ID ← $BASE_BRANCH)..."
  git -C "$PROJECT_ROOT" worktree add "$WORKTREE_PATH" -b "$TASK_ID" "$BASE_BRANCH"
fi
  echo "$TASK_ID" > "$PROJECT_ROOT/.claude/active-task"

# ── 2. EXEC_PLAN 생성 ──────────────────────────────────────────
PLAN_DIR="$PROJECT_ROOT/.claude/exec-plans/active/$TASK_ID"
mkdir -p "$PLAN_DIR"

if [ ! -f "$PLAN_DIR/PLAN.md" ]; then
  cat > "$PLAN_DIR/PLAN.md" <<EOF
# PLAN: $DESCRIPTION

- 작업 ID: \`$TASK_ID\`
- 생성일: $(date '+%Y-%m-%d')
- 기반 브랜치: $BASE_BRANCH
- Worktree: \`.claude/worktrees/$TASK_ID\`

---

## 목표

$DESCRIPTION

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
- [ ] \`bash scripts/verify-task.sh $TASK_ID\` PASS
- [ ] 커밋 완료
EOF
  echo "▶ PLAN.md 생성 완료"
else
  echo "⚠️  PLAN.md 이미 존재, 건너뜀"
fi

# ── 3. 로그 디렉토리 생성 ──────────────────────────────────────
LOG_DIR="$PROJECT_ROOT/.claude/logs/$TASK_ID"
mkdir -p "$LOG_DIR"

# ── 완료 안내 ──────────────────────────────────────────────────
echo ""
echo "✅ 작업 환경 생성 완료"
echo ""
echo "  브랜치   : $TASK_ID  (← $BASE_BRANCH)"
echo "  worktree : $WORKTREE_PATH"
echo "  exec-plan: .claude/exec-plans/active/$TASK_ID/PLAN.md"
echo "  logs     : .claude/logs/$TASK_ID/"
echo ""
echo "▶ 다음 단계:"
echo "  1. .claude/exec-plans/active/$TASK_ID/PLAN.md 에 단계별 계획을 작성한다"
echo "  2. AGENTS.md 를 확인하고 필요한 문서를 읽는다"
echo "  3. Worktree에서 구현한다:"
echo "       cd $WORKTREE_PATH"
echo "  4. 검증:"
echo "       bash scripts/verify-task.sh \"$TASK_ID\""
