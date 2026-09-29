#!/usr/bin/env python3
"""claude -p --output-format stream-json --verbose 가 남긴 JSONL 을 run.json 으로 변환합니다.

측정하는 것 (2강의 run.json 스키마):
  usage      모델 호출 수, 누적 input, cache read/write, output, 최대 context (peak)
  context    읽은 파일, 검색 호출, gold file recall / precision, 모델에게 보인 tool 출력 줄 수
  execution  tool 호출 수, 재시도(코드 변경 없이 같은 호출 반복), 훅 차단 수, 소요 시간

입력은 두 가지 모두 됩니다.
  - claude -p --output-format stream-json --verbose 출력
  - 대화형 세션 로그: ~/.claude/projects/<프로젝트 경로를 -로 바꾼 이름>/<session-id>.jsonl
    (가장 최근 세션: ls -t ~/.claude/projects/-Users-kanghun-Desktop-FiveVoca/*.jsonl | head -1)
    이 경우 result 이벤트가 없어 wall_seconds / num_turns / cost 는 비고, usage 는 호출별 합계입니다.

사용:
  parse_transcript.py <session>.jsonl --run-id before-claude-md -o results/before-claude-md.json
  parse_transcript.py transcript.jsonl --task tasks/ui-001.json \
      --run-id ui-001-harness-r01 --variant harness --cache-state cold \
      --base-commit <sha> --grade grade.json -o results/ui-001-harness-r01.json

hook_blocks 는 tool 출력에 "[hook]" 문구가 있는 횟수입니다. 이 문구를 내는 훅이 없으면 항상 0 입니다.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

EDIT_TOOLS = {"Edit", "Write", "MultiEdit", "NotebookEdit"}
SEARCH_TOOLS = {"Grep", "Glob"}
READ_TOOLS = {"Read"}
HOOK_MARKER = "[hook]"


def load_events(path: Path) -> list[dict]:
    events = []
    with path.open(encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                events.append(json.loads(line))
            except json.JSONDecodeError:
                continue  # 스트림이 중간에 끊긴 줄은 건너뜁니다.
    return events


def blocks_of(event: dict) -> list[dict]:
    content = event.get("message", {}).get("content", [])
    if isinstance(content, str):
        return [{"type": "text", "text": content}]
    return [b for b in content if isinstance(b, dict)]


def text_of(content) -> str:
    if content is None:
        return ""
    if isinstance(content, str):
        return content
    parts = []
    for item in content:
        if isinstance(item, dict) and item.get("type") == "text":
            parts.append(item.get("text", ""))
        elif isinstance(item, str):
            parts.append(item)
    return "\n".join(parts)


def canonical(tool_input) -> str:
    return json.dumps(tool_input, sort_keys=True, ensure_ascii=False)


def percent(numer: int, denom: int) -> float | None:
    return round(numer / denom, 4) if denom else None


def parse(events: list[dict], gold_files: list[str] | None = None) -> dict:
    calls: list[dict] = []
    results: dict[str, str] = {}
    usage_by_message: dict[str, dict] = {}
    anonymous_usage: list[dict] = []
    model = None
    cwd = None
    result_event = None

    for ev in events:
        kind = ev.get("type")
        # 대화형 세션 로그(~/.claude/projects/**.jsonl)에는 init 이벤트가 없고 cwd 가 각 이벤트에 붙어 있습니다.
        cwd = cwd or ev.get("cwd")
        if kind == "system" and ev.get("subtype") == "init":
            model = ev.get("model") or model
            cwd = ev.get("cwd") or cwd
        elif kind == "assistant":
            message = ev.get("message", {})
            if not model and message.get("model") != "<synthetic>":
                model = message.get("model")
            usage = message.get("usage")
            if usage:
                msg_id = message.get("id")
                if msg_id:
                    usage_by_message[msg_id] = usage  # 같은 message id 는 한 번만 셉니다.
                else:
                    anonymous_usage.append(usage)
            for block in blocks_of(ev):
                if block.get("type") == "tool_use":
                    calls.append(
                        {"id": block.get("id"), "name": block.get("name", ""), "input": block.get("input", {})}
                    )
        elif kind == "user":
            for block in blocks_of(ev):
                if block.get("type") == "tool_result":
                    results[block.get("tool_use_id", "")] = text_of(block.get("content"))
        elif kind == "result":
            result_event = ev

    usages = list(usage_by_message.values()) + anonymous_usage

    def total(key: str) -> int:
        return sum(int(u.get(key) or 0) for u in usages)

    per_call_context = [
        int(u.get("input_tokens") or 0)
        + int(u.get("cache_read_input_tokens") or 0)
        + int(u.get("cache_creation_input_tokens") or 0)
        for u in usages
    ]

    # --- context ---
    reads_total = 0
    files_read: list[str] = []
    search_calls = 0
    edits = 0
    by_name: dict[str, int] = {}
    for call in calls:
        name = call["name"]
        by_name[name] = by_name.get(name, 0) + 1
        if name in READ_TOOLS:
            reads_total += 1
            path = str(call["input"].get("file_path") or call["input"].get("path") or "")
            if cwd and path.startswith(cwd.rstrip("/") + "/"):
                path = path[len(cwd.rstrip("/")) + 1:]   # workdir 기준 상대 경로 (사용자 홈 경로를 남기지 않음)
            if path and path not in files_read:
                files_read.append(path)
        elif name in SEARCH_TOOLS:
            search_calls += 1
        elif name in EDIT_TOOLS:
            edits += 1

    gold = gold_files or []
    recalled = [g for g in gold if any(p.endswith(g) for p in files_read)]

    visible_lines = sum(len(t.splitlines()) for t in results.values())
    visible_chars = sum(len(t) for t in results.values())
    hook_blocks = sum(1 for t in results.values() if HOOK_MARKER in t)

    # --- retries: 수정 도구 호출 없이 같은 (도구, 입력) 을 다시 호출한 횟수 ---
    retries = 0
    seen_since_edit: set[tuple[str, str]] = set()
    for call in calls:
        if call["name"] in EDIT_TOOLS:
            seen_since_edit.clear()
            continue
        key = (call["name"], canonical(call["input"]))
        if key in seen_since_edit:
            retries += 1
        else:
            seen_since_edit.add(key)

    wall_seconds = None
    num_turns = None
    cost = None
    thinking_tokens = None
    models_used: list[str] = []
    # 호출별 usage 합계가 기본값. result 이벤트의 usage 가 있으면 그것이 정본입니다.
    # (assistant 이벤트의 output_tokens 는 스트리밍 중간값이라 합계로 쓸 수 없습니다.)
    totals = {
        "input_tokens": total("input_tokens"),
        "cache_read_input_tokens": total("cache_read_input_tokens"),
        "cache_creation_input_tokens": total("cache_creation_input_tokens"),
        "output_tokens": total("output_tokens"),
    }
    if result_event:
        if result_event.get("duration_ms") is not None:
            wall_seconds = round(result_event["duration_ms"] / 1000, 1)
        num_turns = result_event.get("num_turns")
        cost = result_event.get("total_cost_usd")
        final_usage = result_event.get("usage") or {}
        for key in totals:
            if final_usage.get(key) is not None:
                totals[key] = int(final_usage[key])
        thinking_tokens = (final_usage.get("output_tokens_details") or {}).get("thinking_tokens")
        models_used = sorted((result_event.get("modelUsage") or {}).keys())

    cumulative_input = totals["input_tokens"] + totals["cache_read_input_tokens"] + totals["cache_creation_input_tokens"]

    return {
        "model": model,
        "usage": {
            "model_calls": len(usages),
            "input_tokens": totals["input_tokens"],
            "cached_input_tokens": totals["cache_read_input_tokens"],
            "cache_creation_tokens": totals["cache_creation_input_tokens"],
            "output_tokens": totals["output_tokens"],
            "thinking_tokens": thinking_tokens,
            "cumulative_input_tokens": cumulative_input,
            "peak_context_tokens": max(per_call_context) if per_call_context else 0,
            "total_tokens": cumulative_input + totals["output_tokens"],
            "api_cost_usd_reported": cost,
            "models_used": models_used,
        },
        "context": {
            "files_read": len(files_read),
            "file_reads_total": reads_total,
            "files_read_list": files_read,
            "search_calls": search_calls,
            "gold_files_total": len(gold),
            "gold_files_recalled": len(recalled),
            "relevant_file_recall": percent(len(recalled), len(gold)),
            "context_precision": percent(len(recalled), len(files_read)) if gold else None,  # gold 없으면 0 이 아니라 측정 불가
            "visible_tool_lines": visible_lines,
            "visible_tool_chars": visible_chars,
        },
        "execution": {
            "tool_calls": len(calls),
            "tool_calls_by_name": dict(sorted(by_name.items())),
            "edits": edits,
            "retries": retries,
            "hook_blocks": hook_blocks,
            "num_turns": num_turns,
            "wall_seconds": wall_seconds,
        },
    }


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("transcript", type=Path)
    ap.add_argument("--task", type=Path, help="tasks/<id>.json (gold_files 사용)")
    ap.add_argument("--run-id", default=None)
    ap.add_argument("--variant", default="unknown")
    ap.add_argument("--cache-state", default="unknown")
    ap.add_argument("--base-commit", default=None)
    ap.add_argument("--grade", type=Path, help="grade.py 출력 JSON (verification 으로 병합)")
    ap.add_argument("-o", "--output", type=Path)
    args = ap.parse_args(argv)

    task = json.loads(args.task.read_text(encoding="utf-8")) if args.task else {}
    parsed = parse(load_events(args.transcript), task.get("gold_files"))

    run = {
        "run_id": args.run_id or args.transcript.stem,
        "agent": "claude-code",
        "variant": args.variant,
        "task": task.get("task_id"),
        "model": parsed.pop("model"),
        "base_commit": args.base_commit,
        "cache_state": args.cache_state,
        **parsed,
        "verification": json.loads(args.grade.read_text(encoding="utf-8")) if args.grade else {},
    }

    text = json.dumps(run, indent=2, ensure_ascii=False)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(text + "\n", encoding="utf-8")
    else:
        print(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
