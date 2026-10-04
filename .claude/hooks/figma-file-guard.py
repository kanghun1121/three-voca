#!/usr/bin/env python3
"""app-to-figma 작업 중 Figma MCP 호출이 지정된 쓰리보카 시트 밖으로 나가지 못하게 막는 PreToolUse 훅.

- 허용 파일의 fileKey는 저장소에 적지 않는다. 로컬 파일 ~/.claude/figma-allowed-file-key 에서 읽는다.
- fileKey가 다르거나 허용 파일 설정이 없으면 차단한다.
- 새 파일을 만드는 도구(create_new_file 등)는 무조건 차단한다.
- fileKey가 없는 도구는 whoami만 허용한다.
차단은 exit code 2 + stderr 메시지로 전달한다. 메시지에도 fileKey·URL은 출력하지 않는다.
"""
import json
import os
import sys

KEY_FILE = os.path.expanduser("~/.claude/figma-allowed-file-key")
ALWAYS_BLOCKED = {"create_new_file", "generate_figma_design", "create_generative_plugin", "create_shader"}
NO_FILE_ALLOWED = {"whoami"}


def block(reason: str) -> None:
    sys.stderr.write(
        f"[figma-file-guard] 차단: {reason}\n"
        "Figma 작업은 쓰리보카 시트 하나에서만 허용된다. "
        "새 파일 생성이나 다른 파일 사용은 사용자가 이 훅을 직접 수정하기 전에는 하지 않는다. "
        "호출 한도에 걸렸다면 우회하지 말고 사용자에게 보고하고 멈춘다.\n"
    )
    sys.exit(2)


def allowed_key() -> str:
    try:
        with open(KEY_FILE, encoding="utf-8") as f:
            return f.read().strip()
    except OSError:
        return ""


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except Exception:
        block("훅 입력을 해석하지 못했다")
    short = str(data.get("tool_name", "")).split("__")[-1]
    args = data.get("tool_input") or {}

    if short in ALWAYS_BLOCKED:
        block(f"{short}는 새 Figma 파일/리소스를 만들므로 허용하지 않는다")

    key = args.get("fileKey")
    if key is None:
        if short in NO_FILE_ALLOWED:
            return
        block(f"{short} 호출에 fileKey가 없어 대상 파일을 확인할 수 없다")
    allowed = allowed_key()
    if not allowed:
        block("허용 파일 설정(~/.claude/figma-allowed-file-key)이 없어 모든 Figma 파일 호출을 막는다")
    if key != allowed:
        block("허용되지 않은 파일이다")


main()
