#!/bin/sh
set -eu

repo_root="${CI_PRIMARY_REPOSITORY_PATH:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}"
cd "$repo_root"

scheme="${CI_XCODE_SCHEME:-threevoca-dev}"
case "$scheme" in
    threevoca-dev|threevoca-prod) ;;
    *) echo "Unsupported Xcode Cloud scheme: $scheme" >&2; exit 1 ;;
esac
export scheme

# Xcode Cloud stores these as secret workflow environment variables.
python3 - <<'PY'
import os
import re
from pathlib import Path
from urllib.parse import urlsplit

prod = os.environ["scheme"] == "threevoca-prod"
required = (
    ("SUPABASE_PROD_URL", "SUPABASE_ANON_KEY", "MW_DICTIONARY_API_KEY", "CI_TAG")
    if prod else
    ("SUPABASE_DEV_URL", "SUPABASE_DEV_ANON_KEY", "MW_DICTIONARY_API_KEY")
)
missing = [name for name in required if not os.environ.get(name)]
if missing:
    raise SystemExit("Missing Xcode Cloud environment variables: " + ", ".join(missing))

url_name = "SUPABASE_PROD_URL" if prod else "SUPABASE_DEV_URL"
url = os.environ[url_name]
parts = urlsplit(url)
if parts.scheme != "https" or not parts.netloc:
    raise SystemExit(url_name + " must be an HTTPS URL")

names = (
    ("SUPABASE_ANON_KEY", "MW_DICTIONARY_API_KEY")
    if prod else
    ("SUPABASE_DEV_ANON_KEY", "MW_DICTIONARY_API_KEY", "DEV_ACCOUNT_EMAIL", "DEV_ACCOUNT_PASSWORD")
)
values = {name: os.environ.get(name, "") for name in names}
for name, value in values.items():
    if any(char in value for char in "\r\n"):
        raise SystemExit(name + " must be a single line")

lines = [url_name + " = " + url.replace("://", ":/$()/", 1)]
lines += [name + " = " + value for name, value in values.items()]
if prod:
    match = re.fullmatch(r"v?(\d+)\.(\d+)\.(\d+)", os.environ["CI_TAG"])
    if not match:
        raise SystemExit("Production tag must be vMAJOR.MINOR.PATCH (for example, v1.2.3)")
    lines.append("MARKETING_VERSION = " + ".".join(match.groups()))
path = Path("Projects/App/Secrets.xcconfig")
path.write_text("\n".join(lines) + "\n")
path.chmod(0o600)
PY

if ! command -v mise >/dev/null 2>&1; then
    curl -fsSL https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

mise install
mise exec -- tuist install
mise exec -- tuist generate --no-open

scheme_file="Projects/App/FiveVoca.xcodeproj/xcshareddata/xcschemes/$scheme.xcscheme"
if [ ! -f "$scheme_file" ]; then
    echo "Missing shared $scheme scheme" >&2
    exit 1
fi

bundle_id="$({
    xcodebuild \
        -project Projects/App/FiveVoca.xcodeproj \
        -scheme "$scheme" \
        -showBuildSettings
} | awk -F ' = ' '/^[[:space:]]*PRODUCT_BUNDLE_IDENTIFIER = / { print $2; exit }')"

expected_bundle_id="com.kangdev.threevoca"
if [ "$scheme" = "threevoca-dev" ]; then
    expected_bundle_id="$expected_bundle_id.dev"
fi
if [ "$bundle_id" != "$expected_bundle_id" ]; then
    echo "$scheme must use $expected_bundle_id (resolved: ${bundle_id:-missing})" >&2
    exit 1
fi
