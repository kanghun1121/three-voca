#!/bin/bash
# 작업 완료 전 빌드를 자동 검증하는 Stop Hook.
# 빌드 실패 시 Claude가 완료를 보고하지 못하게 막고 오류를 반환한다.

MAIN_ROOT="/Users/kanghun/Desktop/FiveVoca"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$MAIN_ROOT")"

# Swift 파일 변경이 없으면 빌드 검증 스킵
git -C "$PROJECT_ROOT" diff --name-only HEAD | grep -q "\.swift$" || exit 0

WORKSPACE="FiveVoca.xcworkspace"
SCHEME="FiveVoca"
DESTINATION="generic/platform=iOS Simulator"

BUILD_OUTPUT=$(
  xcodebuild build \
    -workspace "$PROJECT_ROOT/$WORKSPACE" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -quiet 2>&1
)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  ERRORS=$(echo "$BUILD_OUTPUT" | grep "error:" | head -10)
  python3 - <<EOF
import json
errors = """$ERRORS"""
print(json.dumps({
  "continue": False,
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "additionalContext": "빌드 실패. 오류를 수정한 뒤 재시도하세요.\n\n" + errors
  }
}))
EOF
fi
