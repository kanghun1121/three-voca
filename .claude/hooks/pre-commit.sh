#!/bin/bash
# pre-commit hook — Swift 파일 변경 시 테스트를 실행하고 실패하면 커밋을 차단한다.
# 설치: 이 파일은 .git/hooks/pre-commit 에서 호출된다. (bash scripts/setup-hooks.sh)
# 건너뛰기: git commit --no-verify

PROJECT_ROOT="$(git rev-parse --show-toplevel)"

# Swift 파일 변경이 없으면 스킵
git diff --cached --name-only | grep -q "\.swift$" || exit 0

echo "🔍 pre-commit: Swift 파일 변경 감지 — 테스트 실행 중..."
echo "   (건너뛰려면: git commit --no-verify)"
echo ""

WORKSPACE="$PROJECT_ROOT/FiveVoca.xcworkspace"
SCHEME="AllTest"
DESTINATION="platform=iOS Simulator,OS=18.6,name=iPhone 16"

TEST_OUTPUT=$(xcodebuild test \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -quiet 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  PASS_COUNT=$(echo "$TEST_OUTPUT" | grep -c "Test Case.*passed" || true)
  echo "✅ pre-commit: 테스트 PASS (${PASS_COUNT}개) — 커밋 진행"
  exit 0
else
  echo "❌ pre-commit: 테스트 실패 — 커밋이 차단됩니다."
  echo ""
  echo "$TEST_OUTPUT" | grep "Test Case.*failed" | head -10
  echo ""
  echo "수정 후 다시 커밋하세요."
  exit 1
fi