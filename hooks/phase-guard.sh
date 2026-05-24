#!/bin/bash
# PreToolUse Hook — 검증 페이즈에서 파일 수정을 하드 차단한다.
# 오케스트레이터가 /tmp/fivevoca-phase 에 현재 페이즈를 기록한다.

PHASE=$(cat /tmp/fivevoca-phase 2>/dev/null || echo "free")

if [ "$PHASE" != "verify" ]; then
  exit 0
fi

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name')

if [[ "$TOOL" == "Write" || "$TOOL" == "Edit" ]]; then
  echo '{"decision":"deny","reason":"검증 페이즈: 파일 수정 불가. 테스트 실행만 허용됩니다."}'
fi
