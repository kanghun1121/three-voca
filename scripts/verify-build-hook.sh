#!/bin/bash
# Stop Hook: run a build before reporting completion when Swift files changed.

MAIN_ROOT="/Users/kanghun/Desktop/FiveVoca"
PROJECT_ROOT="$MAIN_ROOT"
source "$PROJECT_ROOT/scripts/harness-config.sh"

ACTIVE_TASK=$(cat "$HARNESS_ACTIVE_TASK_FILE" 2>/dev/null)
if [ -z "$ACTIVE_TASK" ]; then
  ACTIVE_TASK=$(cat "$LEGACY_ACTIVE_TASK_FILE" 2>/dev/null)
fi

WORKTREE_PATH="$HARNESS_WORKTREES_DIR/$ACTIVE_TASK"
if [ ! -d "$WORKTREE_PATH" ]; then
  WORKTREE_PATH="$LEGACY_WORKTREES_DIR/$ACTIVE_TASK"
fi

if [ -n "$ACTIVE_TASK" ] && [ -d "$WORKTREE_PATH" ]; then
  SOURCE_ROOT="$WORKTREE_PATH"
else
  SOURCE_ROOT="$MAIN_ROOT"
fi

# Skip when no Swift files changed.
git -C "$SOURCE_ROOT" diff --name-only HEAD | grep -q "\.swift$" || exit 0

WORKSPACE="$SOURCE_ROOT/FiveVoca.xcworkspace"

# Skip before tuist generate.
[ -d "$WORKSPACE" ] || exit 0

BUILD_OUTPUT=$(
  xcodebuild build \
    -workspace "$WORKSPACE" \
    -scheme "FiveVoca" \
    -destination "generic/platform=iOS Simulator" \
    -quiet 2>&1
)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  ERRORS=$(echo "$BUILD_OUTPUT" | grep "error:" | head -10)
  python3 - <<PYEOF
import json
errors = """$ERRORS"""
print(json.dumps({
  "continue": False,
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "additionalContext": "빌드 실패. 오류를 수정한 뒤 재시도하세요.\n\n" + errors
  }
}))
PYEOF
fi
