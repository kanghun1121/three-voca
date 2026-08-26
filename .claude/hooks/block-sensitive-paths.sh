#!/bin/bash
# PreToolUse Hook: 민감 파일 / 저장소 밖 경로 접근을 차단한다.
# Hook 입력은 stdin으로 JSON 형태로 들어온다.
#
# REPO_ROOT는 하드코딩하지 않고 스크립트 자신의 위치($0) 기준으로 계산한다.
# 그래야 다른 계정/다른 경로에 클론해도 그대로 동작한다.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

input="$(cat)"

path="$(echo "$input" | jq -r '
  .tool_input.file_path //
  .tool_input.path //
  .tool_input.notebook_path //
  empty
')"

cmd="$(echo "$input" | jq -r '
  .tool_input.command //
  empty
')"

target="$path $cmd"

# 민감 파일: 저장소 내부여도 차단
if echo "$target" | grep -E '(^|/| )\.env($|[./ ])|\.ssh|id_rsa|id_ed25519' >/dev/null; then
  echo "[hook] Blocked access to sensitive file: $target" >&2
  exit 2
fi

# 상위 디렉터리 접근 차단
if echo "$target" | grep -E '(^| )\.\./' >/dev/null; then
  echo "[hook] Blocked parent directory access: $target" >&2
  exit 2
fi

# 저장소 밖 절대경로/홈 디렉터리 접근 차단 (저장소 루트 자체는 허용)
if echo "$target" | grep -E '/Users/|/home/|~/|Desktop|Downloads|Library/' >/dev/null; then
  if ! echo "$target" | grep -qF "$REPO_ROOT"; then
    echo "[hook] Blocked access outside repository: $target" >&2
    exit 2
  fi
fi

exit 0
