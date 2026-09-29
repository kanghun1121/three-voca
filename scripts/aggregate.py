#!/usr/bin/env python3
"""results/*.json 을 variant × cache_state 로 묶어 비교표를 만듭니다.

한 번의 실행으로 결론 내리지 않기 위한 도구입니다. 그룹마다 다음을 냅니다.
  n, solve rate, median / p90 누적 input, median peak context, median output,
  median 파일 읽기 수, recall / precision, retries, hook blocks, median runtime,
  Verified Token Efficiency (해결한 task 수 / 총 토큰 백만 단위),
  Cost per Solved (비용이 기록된 경우에만)

사용:
  aggregate.py results/                    # markdown 표
  aggregate.py results/ --format json
  aggregate.py results/ --group variant    # cache_state 무시하고 묶기
"""
from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path


def median(values: list[float]) -> float | None:
    vals = sorted(v for v in values if v is not None)
    if not vals:
        return None
    mid = len(vals) // 2
    if len(vals) % 2:
        return vals[mid]
    return (vals[mid - 1] + vals[mid]) / 2


def percentile(values: list[float], pct: float) -> float | None:
    """nearest-rank 방식. 표본이 적을 때 보간보다 해석이 단순합니다."""
    vals = sorted(v for v in values if v is not None)
    if not vals:
        return None
    rank = max(1, math.ceil(pct / 100 * len(vals)))
    return vals[rank - 1]


def get(run: dict, *keys, default=None):
    cur = run
    for k in keys:
        if not isinstance(cur, dict) or k not in cur:
            return default
        cur = cur[k]
    return cur


def summarize(runs: list[dict]) -> dict:
    n = len(runs)
    solved = sum(1 for r in runs if get(r, "verification", "solved") is True)
    graded = sum(1 for r in runs if get(r, "verification", "solved") is not None)  # 채점 없는 실제 세션은 제외
    total_tokens = [get(r, "usage", "total_tokens", default=0) for r in runs]
    cumulative = [get(r, "usage", "cumulative_input_tokens") for r in runs]
    costs = [get(r, "usage", "api_cost_usd_reported") for r in runs]
    token_sum = sum(t for t in total_tokens if t)

    cost_per_solved = None
    if costs and all(c is not None for c in costs) and solved:
        cost_per_solved = round(sum(costs) / solved, 4)

    return {
        "n": n,
        "solve_rate": round(solved / graded, 3) if graded else None,
        "median_cumulative_input": median(cumulative),
        "p90_cumulative_input": percentile(cumulative, 90),
        "median_peak_context": median([get(r, "usage", "peak_context_tokens") for r in runs]),
        "median_cached_input": median([get(r, "usage", "cached_input_tokens") for r in runs]),
        "median_model_calls": median([get(r, "usage", "model_calls") for r in runs]),
        "median_output": median([get(r, "usage", "output_tokens") for r in runs]),
        "median_cost_usd": round(median(costs), 4) if costs and all(c is not None for c in costs) else None,
        "median_files_read": median([get(r, "context", "files_read") for r in runs]),
        "median_recall": median([get(r, "context", "relevant_file_recall") for r in runs]),
        "median_precision": median([get(r, "context", "context_precision") for r in runs]),
        "median_visible_tool_lines": median([get(r, "context", "visible_tool_lines") for r in runs]),
        "retries_total": sum(get(r, "execution", "retries", default=0) or 0 for r in runs),
        "retries_max": max((get(r, "execution", "retries", default=0) or 0 for r in runs), default=0),
        "hook_blocks_total": sum(get(r, "execution", "hook_blocks", default=0) or 0 for r in runs),
        "median_wall_seconds": median([get(r, "execution", "wall_seconds") for r in runs]),
        "verified_token_efficiency": round(solved / (token_sum / 1_000_000), 3) if token_sum and graded else None,
        "cost_per_solved_usd": cost_per_solved,
    }


def load_runs(results_dir: Path) -> list[dict]:
    runs = []
    for path in sorted(results_dir.glob("*.json")):
        try:
            runs.append(json.loads(path.read_text(encoding="utf-8")))
        except json.JSONDecodeError:
            print(f"skip (invalid json): {path}", file=sys.stderr)
    return runs


def group_runs(runs: list[dict], keys: list[str]) -> dict[str, list[dict]]:
    groups: dict[str, list[dict]] = {}
    for r in runs:
        label = " / ".join(str(r.get(k, "?")) for k in keys)
        groups.setdefault(label, []).append(r)
    return groups


COLUMNS = [
    ("n", "n"),
    ("solve_rate", "Solve Rate"),
    ("median_cumulative_input", "Median Input"),
    ("p90_cumulative_input", "P90 Input"),
    ("median_peak_context", "Median Peak Ctx"),
    ("median_model_calls", "Calls"),
    ("median_output", "Output"),
    ("median_files_read", "Files Read"),
    ("median_recall", "Recall"),
    ("median_precision", "Precision"),
    ("median_visible_tool_lines", "Tool Lines"),
    ("retries_total", "Retries"),
    ("hook_blocks_total", "Hook Blocks"),
    ("median_wall_seconds", "Runtime(s)"),
    ("verified_token_efficiency", "Solved / 1M tok"),
    ("median_cost_usd", "Median Cost"),
    ("cost_per_solved_usd", "Cost / Solved"),
]


def fmt(value) -> str:
    if value is None:
        return "-"
    if isinstance(value, float):
        return f"{value:,.3f}".rstrip("0").rstrip(".") if value < 10 else f"{value:,.0f}"
    return f"{value:,}" if isinstance(value, int) else str(value)


def to_markdown(summary: dict[str, dict]) -> str:
    header = "| Variant | " + " | ".join(label for _, label in COLUMNS) + " |"
    sep = "| --- | " + " | ".join("---" for _ in COLUMNS) + " |"
    rows = [header, sep]
    for label, stats in summary.items():
        rows.append(f"| {label} | " + " | ".join(fmt(stats[k]) for k, _ in COLUMNS) + " |")
    return "\n".join(rows)


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("results_dir", type=Path)
    ap.add_argument("--group", default="variant,cache_state", help="묶는 키 (쉼표 구분)")
    ap.add_argument("--format", choices=["md", "json"], default="md")
    args = ap.parse_args(argv)

    runs = load_runs(args.results_dir)
    if not runs:
        print("no run.json found", file=sys.stderr)
        return 1
    summary = {label: summarize(rs) for label, rs in group_runs(runs, args.group.split(",")).items()}
    print(json.dumps(summary, indent=2, ensure_ascii=False) if args.format == "json" else to_markdown(summary))
    return 0


if __name__ == "__main__":
    sys.exit(main())
