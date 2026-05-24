#!/bin/bash
# git hooks 를 설치한다. 새로 클론한 후 한 번만 실행하면 된다.
# Usage: bash scripts/setup-hooks.sh

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

install_hook() {
  local name="$1"
  local source="$PROJECT_ROOT/.claude/hooks/${name}.sh"
  local target="$HOOKS_DIR/$name"

  if [ ! -f "$source" ]; then
    echo "⚠️  소스 없음: $source"
    return
  fi

  cat > "$target" <<EOF
#!/bin/bash
exec "$source"
EOF
  chmod +x "$target"
  echo "✅ $name 훅 설치 완료"
}

install_hook "pre-commit"

echo ""
echo "완료. 설치된 훅:"
ls -1 "$HOOKS_DIR"
