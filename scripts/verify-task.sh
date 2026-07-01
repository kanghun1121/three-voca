#!/bin/bash
# Usage: bash scripts/verify-task.sh <task-id>
# 전체 검증: 빌드 + 테스트 + 아키텍처 의존성
#
# 예시:
#   bash scripts/verify-task.sh feat/home-redesign

TASK_ID="${1:-unknown}"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$PROJECT_ROOT/scripts/harness-config.sh"
LOG_DIR="$HARNESS_LOGS_DIR/$TASK_ID"
SCHEME="FiveVoca"
TEST_SCHEME="AllTest"
DESTINATION="platform=iOS Simulator,OS=18.6,name=iPhone 16"
FAILED=0

# Worktree가 있으면 Worktree 기준으로 빌드, 없으면 메인 레포 기준
WORKTREE_PATH="$HARNESS_WORKTREES_DIR/$TASK_ID"
if [ ! -d "$WORKTREE_PATH" ]; then
  WORKTREE_PATH="$LEGACY_WORKTREES_DIR/$TASK_ID"
fi
if [ -d "$WORKTREE_PATH" ]; then
  SOURCE_ROOT="$WORKTREE_PATH"
else
  SOURCE_ROOT="$PROJECT_ROOT"
fi
WORKSPACE="$SOURCE_ROOT/FiveVoca.xcworkspace"

# tuist generate 전이면 중단
if [ ! -d "$WORKSPACE" ]; then
  echo "❌ xcworkspace 없음: $WORKSPACE"
  echo "   먼저 tuist generate 를 실행하세요."
  exit 1
fi

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/verify-$(date '+%Y%m%d-%H%M%S').log"

log() {
  echo "$1" | tee -a "$LOG_FILE"
}

log "══════════════════════════════════════"
log " 검증 시작: $TASK_ID"
log " $(date '+%Y-%m-%d %H:%M:%S')"
log "══════════════════════════════════════"

# ── 1. 빌드 ────────────────────────────────────────────────────
log ""
log "[ 1/3 ] 빌드 검증..."

BUILD_OUTPUT=$(xcodebuild build \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -quiet 2>&1)
BUILD_EXIT=$?

if [ $BUILD_EXIT -eq 0 ]; then
  log "  ✅ 빌드: PASS"
else
  log "  ❌ 빌드: FAIL"
  echo "$BUILD_OUTPUT" | grep "error:" | head -10 | while IFS= read -r line; do
    log "     $line"
  done
  FAILED=1
fi

# ── 2. 테스트 ───────────────────────────────────────────────────
log ""
log "[ 2/3 ] 테스트 검증..."

TEST_OUTPUT=$(xcodebuild test \
  -workspace "$WORKSPACE" \
  -scheme "$TEST_SCHEME" \
  -destination "$DESTINATION" \
  -quiet 2>&1)
TEST_EXIT=$?

if [ $TEST_EXIT -eq 0 ]; then
  PASS_COUNT=$(echo "$TEST_OUTPUT" | grep -c "Test Case.*passed" || true)
  log "  ✅ 테스트: PASS (${PASS_COUNT}개)"
else
  FAIL_LINES=$(echo "$TEST_OUTPUT" | grep "Test Case.*failed" | head -10)
  FAIL_COUNT=$(echo "$FAIL_LINES" | grep -c "." || true)
  log "  ❌ 테스트: FAIL (${FAIL_COUNT}개 실패)"
  echo "$FAIL_LINES" | while IFS= read -r line; do
    log "     $line"
  done
  FAILED=1
fi

# ── 3. 아키텍처 의존성 ─────────────────────────────────────────
log ""
log "[ 3/3 ] 아키텍처 의존성 검사..."

# Domain이 Feature를 import 하면 안 됨 (역방향 의존성)
DOMAIN_VIOLATION=$(grep -rn "^import.*Feature" \
  "$SOURCE_ROOT/Projects/Domain" \
  --include="*.swift" 2>/dev/null | grep -v "^[[:space:]]*//" || true)

# Core가 Domain/Feature를 import 하면 안 됨 (역방향 의존성)
CORE_VIOLATION=$(grep -rn "^import.*\(Domain\|Feature\)" \
  "$SOURCE_ROOT/Projects/Core" \
  --include="*.swift" 2>/dev/null | grep -v "^[[:space:]]*//" || true)

if [ -z "$DOMAIN_VIOLATION" ] && [ -z "$CORE_VIOLATION" ]; then
  log "  ✅ 아키텍처 의존성: PASS"
else
  log "  ❌ 아키텍처 의존성: FAIL (역방향 의존성 발견)"
  if [ -n "$DOMAIN_VIOLATION" ]; then
    log "     [Domain → Feature 위반]"
    echo "$DOMAIN_VIOLATION" | head -5 | while IFS= read -r line; do
      log "       $line"
    done
  fi
  if [ -n "$CORE_VIOLATION" ]; then
    log "     [Core → Domain/Feature 위반]"
    echo "$CORE_VIOLATION" | head -5 | while IFS= read -r line; do
      log "       $line"
    done
  fi
  FAILED=1
fi

# ── 결과 ────────────────────────────────────────────────────────
log ""
log "══════════════════════════════════════"
if [ $FAILED -eq 0 ]; then
  log " 판정: ✅ PASS — 커밋 가능"
else
  log " 판정: ❌ FAIL — 수정 후 재시도"
fi
log " 로그: $LOG_FILE"
log "══════════════════════════════════════"

exit $FAILED
