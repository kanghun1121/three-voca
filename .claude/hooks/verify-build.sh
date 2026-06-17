#!/bin/bash
# 작업 완료 전 빌드를 자동 검증하는 Stop Hook.
# 빌드 실패 시 Claude가 완료를 보고하지 못하게 막고 오류를 반환한다.

MAIN_ROOT="/Users/kanghun/Desktop/FiveVoca"

ACTIVE_TASK=$(cat "$MAIN_ROOT/.claude/active-task" 2>/dev/null)
WORKTREE_PATH="$MAIN_ROOT/.claude/worktrees/$ACTIVE_TASK"

if [ -n "$ACTIVE_TASK" ] && [ -d "$WORKTREE_PATH" ]; then
  SOURCE_ROOT="$WORKTREE_PATH"
else
  SOURCE_ROOT="$MAIN_ROOT"
fi

# Swift 파일 변경이 없으면 빌드 검증 스킵
git -C "$SOURCE_ROOT" diff --name-only HEAD | grep -q "\.swift$" || exit 0

WORKSPACE="$SOURCE_ROOT/FiveVoca.xcworkspace"

# tuist generate 전이면 스킵
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