#!/bin/bash
# Stop Hook: 응답 종료 시점(파일 수정이 모두 끝난 뒤)에 Swift 변경사항이 있으면
# 빌드 + 테스트를 실행하고 결과를 .claude/last-test-status 에 기록한다.
# 시뮬레이터 창은 띄우지 않는다 (헤드리스 부팅, open -a Simulator 호출 없음).

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# 각 워크트리는 자신만의 .claude/hooks 사본을 가진 독립된 git worktree이므로,
# 훅 스크립트 자신의 위치로 계산한 PROJECT_ROOT가 곧 "지금 세션이 작업 중인 워크트리"다.
# 예전에는 .harness/active-task로 다른 워크트리를 가리켜 재검증했는데, 이는 여러
# 워크트리 세션이 공유하는 전역 파일이라 서로의 상태를 오염시켜 제거했다.
SOURCE_ROOT="$PROJECT_ROOT"

STATUS_FILE="$SOURCE_ROOT/.claude/last-test-status"
SCHEME="FiveVoca"
TEST_SCHEME="AllTest"
DEVICE_NAME="iPhone 16"

# 이번 응답 시점에 커밋 안 된 Swift 변경이 없으면 건드리지 않는다.
git -C "$SOURCE_ROOT" diff --name-only HEAD | grep -q "\.swift$" || exit 0

WORKSPACE="$SOURCE_ROOT/FiveVoca.xcworkspace"
# tuist generate 전이면 중단.
[ -d "$WORKSPACE" ] || exit 0

mkdir -p "$SOURCE_ROOT/.claude"

# ── 1. 빌드 (generic destination → 시뮬레이터를 전혀 띄우지 않음) ─────
BUILD_OUTPUT=$(
  xcodebuild build \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -destination "generic/platform=iOS Simulator" \
    -quiet 2>&1
)
if [ $? -ne 0 ]; then
  ERRORS=$(echo "$BUILD_OUTPUT" | grep "error:" | head -10)
  echo "FAIL $(date -u +"%Y-%m-%dT%H:%M:%SZ") build" > "$STATUS_FILE"
  echo "[hook] 빌드 실패. 오류를 수정한 뒤 재시도하세요." >&2
  echo "$ERRORS" >&2
  exit 2
fi

# ── 2. 테스트 (헤드리스 부팅 → Simulator.app 창 안 뜸) ────────────────
UDID=$(xcrun simctl list devices available \
  | grep -m1 "$DEVICE_NAME (" \
  | sed -E 's/^[^(]*\(([0-9A-F-]+)\).*/\1/')

if [ -z "$UDID" ]; then
  echo "FAIL $(date -u +"%Y-%m-%dT%H:%M:%SZ") no-simulator" > "$STATUS_FILE"
  echo "[hook] '$DEVICE_NAME' 시뮬레이터를 찾을 수 없습니다." >&2
  exit 2
fi

# 이미 부팅되어 있으면 아무 것도 하지 않고, 아니면 백그라운드로만 부팅한다.
xcrun simctl boot "$UDID" >/dev/null 2>&1 || true

TEST_OUTPUT=$(
  xcodebuild test \
    -workspace "$WORKSPACE" \
    -scheme "$TEST_SCHEME" \
    -destination "platform=iOS Simulator,id=$UDID" \
    -quiet 2>&1
)
TEST_EXIT=$?

if [ $TEST_EXIT -eq 0 ]; then
  PASS_COUNT=$(echo "$TEST_OUTPUT" | grep -c "Test Case.*passed" || true)
  echo "PASS $(date -u +"%Y-%m-%dT%H:%M:%SZ") ${PASS_COUNT}개" > "$STATUS_FILE"
  exit 0
else
  FAIL_LINES=$(echo "$TEST_OUTPUT" | grep "Test Case.*failed" | head -10)
  echo "FAIL $(date -u +"%Y-%m-%dT%H:%M:%SZ") test" > "$STATUS_FILE"
  echo "[hook] 테스트 실패. 코드를 수정하기 전에 어떤 요구사항이 실패했는지 먼저 설명하세요." >&2
  echo "$FAIL_LINES" >&2
  exit 2
fi
