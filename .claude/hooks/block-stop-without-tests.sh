#!/bin/bash
# Stop Hook: 테스트가 PASS 상태가 아니면 응답 종료를 막는다.
# run-tests-after-edit.sh 가 기록한 상태 파일을 그대로 읽는다.
# 반드시 run-tests-after-edit.sh 다음 순서로 등록해야 한다 (같은 Stop 이벤트 내 실행 순서).

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# run-tests-after-edit.sh와 동일한 이유로 active-task 기반 워크트리 리다이렉트를 제거했다.
# 각 워크트리는 독립된 .claude/hooks 사본을 가지므로 PROJECT_ROOT가 곧 현재 워크트리다.
SOURCE_ROOT="$PROJECT_ROOT"

STATUS_FILE="$SOURCE_ROOT/.claude/last-test-status"

# 상태 파일이 없다 = run-tests-after-edit.sh가 Swift 변경 없음으로 판단해 스킵한 것.
# 이 경우는 "테스트할 게 없었다"는 뜻이므로 통과시킨다 (막으면 코드와 무관한 대화까지 전부 막힘).
[ -f "$STATUS_FILE" ] || exit 0

if ! grep -q "^PASS" "$STATUS_FILE"; then
  echo "[hook] 테스트가 통과하지 않았습니다. 실패 원인을 먼저 설명한 뒤 관련 책임만 수정하세요." >&2
  exit 2
fi

exit 0
