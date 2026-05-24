#!/usr/bin/env python3
"""PLAN.md → PLAN.html 변환기.
PostToolUse 훅 또는 직접 실행으로 호출된다.

Usage:
    python3 scripts/plan-to-html.py <PLAN.md 경로>
"""
import sys
import re
import os
from datetime import datetime


# ── CSS ──────────────────────────────────────────────────────────────────────

CSS = """
* { box-sizing: border-box; margin: 0; padding: 0; }
body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    font-size: 15px;
    line-height: 1.7;
    color: #1a1a2e;
    background: #f0f0f5;
    padding: 40px 20px;
}
.container {
    max-width: 800px;
    margin: 0 auto;
    background: #fff;
    border-radius: 14px;
    padding: 52px 56px;
    box-shadow: 0 2px 24px rgba(0,0,0,0.07);
}
h1 { font-size: 26px; font-weight: 700; color: #111; margin-bottom: 6px; }
h2 {
    font-size: 17px; font-weight: 600; color: #222;
    margin: 36px 0 10px;
    padding-bottom: 6px;
    border-bottom: 1.5px solid #e8e8ed;
}
h3 { font-size: 14px; font-weight: 600; color: #555; margin: 18px 0 6px; }
p  { margin: 6px 0; color: #333; }
hr { border: none; border-top: 1px solid #e8e8ed; margin: 20px 0; }

code {
    background: #f2f2f7;
    padding: 2px 6px;
    border-radius: 5px;
    font-family: 'SF Mono', Menlo, monospace;
    font-size: 13px;
    color: #bf5af2;
}
pre {
    background: #1c1c1e;
    border-radius: 10px;
    padding: 18px 20px;
    margin: 14px 0;
    overflow-x: auto;
}
pre code { background: none; color: #e5e5ea; padding: 0; font-size: 13px; }

table { width: 100%; border-collapse: collapse; margin: 12px 0; font-size: 14px; }
th {
    background: #f2f2f7;
    text-align: left;
    padding: 9px 14px;
    border: 1px solid #e0e0e5;
    font-weight: 600;
    color: #444;
}
td { padding: 8px 14px; border: 1px solid #e0e0e5; color: #333; }
tr:nth-child(even) td { background: #fafafa; }

ul, ol { padding-left: 0; margin: 4px 0; }
li { margin: 3px 0 3px 20px; }
li.task { list-style: none; margin-left: 0; display: flex; align-items: flex-start; gap: 8px; }
li.task input[type=checkbox] {
    margin-top: 4px;
    width: 15px; height: 15px;
    accent-color: #30d158;
    flex-shrink: 0;
}
li.checked span { color: #999; text-decoration: line-through; }

strong { font-weight: 600; }
em     { font-style: italic; color: #555; }
.meta  { font-size: 12px; color: #aaa; margin-top: 36px; padding-top: 14px; border-top: 1px solid #f0f0f0; }
blockquote {
    border-left: 3px solid #e0e0e5;
    padding: 4px 0 4px 16px;
    margin: 8px 0;
    color: #666;
}
"""


# ── 변환 ─────────────────────────────────────────────────────────────────────

def escape(t):
    return t.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def inline(text):
    text = escape(text)
    text = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", text)
    text = re.sub(r"\*(.+?)\*",     r"<em>\1</em>",         text)
    text = re.sub(r"`([^`]+)`",     r"<code>\1</code>",     text)
    return text


def render_table(rows):
    data = [r for r in rows if not re.match(r"^\|[-\s|:]+\|$", r.strip())]
    if not data:
        return ""
    out = ["<table>"]
    for idx, row in enumerate(data):
        cells = [c.strip() for c in row.strip().strip("|").split("|")]
        tag = "th" if idx == 0 else "td"
        out.append("<tr>" + "".join(f"<{tag}>{inline(c)}</{tag}>" for c in cells) + "</tr>")
    out.append("</table>")
    return "\n".join(out)


def md_to_html(md):
    lines    = md.split("\n")
    out      = []
    in_table = False
    in_code  = False
    table_rows = []

    for line in lines:
        # Code fence
        if line.strip().startswith("```"):
            if not in_code:
                in_code = True
                lang = line.strip()[3:].strip()
                out.append(f'<pre><code class="language-{escape(lang)}">')
            else:
                in_code = False
                out.append("</code></pre>")
            continue

        if in_code:
            out.append(escape(line))
            continue

        # Table
        if "|" in line and line.strip().startswith("|"):
            if not in_table:
                in_table = True
                table_rows = []
            table_rows.append(line)
            continue
        elif in_table:
            out.append(render_table(table_rows))
            in_table = False
            table_rows = []

        # Headings
        m = re.match(r"^(#{1,3}) (.+)", line)
        if m:
            lvl = len(m.group(1))
            out.append(f"<h{lvl}>{inline(m.group(2))}</h{lvl}>")
            continue

        # HR
        if line.strip() == "---":
            out.append("<hr>")
            continue

        # Blockquote
        if line.strip().startswith("> "):
            out.append(f"<blockquote>{inline(line.strip()[2:])}</blockquote>")
            continue

        # Checkbox list items
        if re.match(r"^[-*] \[[ xX]\]", line.strip()):
            checked = line.strip()[3] in ("x", "X")
            text = inline(line.strip()[6:].strip())
            cls = "task checked" if checked else "task unchecked"
            chk = "checked" if checked else ""
            out.append(
                f'<li class="{cls}">'
                f'<input type="checkbox" {chk} disabled>'
                f'<span>{text}</span></li>'
            )
            continue

        # Bullet list
        if re.match(r"^[-*] ", line.strip()):
            out.append(f"<li>{inline(line.strip()[2:])}</li>")
            continue

        # Numbered list
        if re.match(r"^\d+\. ", line.strip()):
            text = re.sub(r"^\d+\. ", "", line.strip())
            out.append(f"<li>{inline(text)}</li>")
            continue

        # Empty
        if line.strip() == "":
            out.append("")
            continue

        out.append(f"<p>{inline(line)}</p>")

    if in_table:
        out.append(render_table(table_rows))

    return "\n".join(out)


def convert(md_path: str):
    if not os.path.exists(md_path):
        print(f"❌ 파일 없음: {md_path}", file=sys.stderr)
        sys.exit(1)

    with open(md_path, encoding="utf-8") as f:
        md = f.read()

    body = md_to_html(md)
    now  = datetime.now().strftime("%Y-%m-%d %H:%M")
    rel  = os.path.relpath(md_path)

    html = f"""<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>PLAN — {os.path.basename(os.path.dirname(md_path))}</title>
<style>{CSS}</style>
</head>
<body>
<div class="container">
{body}
<p class="meta">생성: {now} · 소스: {rel}</p>
</div>
</body>
</html>"""

    out_path = re.sub(r"\.md$", ".html", md_path)
    with open(out_path, encoding="utf-8", mode="w") as f:
        f.write(html)

    print(f"✅ PLAN.html 생성: {out_path}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 scripts/plan-to-html.py <PLAN.md>", file=sys.stderr)
        sys.exit(1)
    convert(sys.argv[1])
