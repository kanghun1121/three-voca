#!/bin/sh
set -eu

repo_root="${CI_PRIMARY_REPOSITORY_PATH:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}"
cd "$repo_root"

if [ "${CI_XCODE_SCHEME:-threevoca-dev}" != "threevoca-dev" ]; then
    echo "Xcode Cloud must use the threevoca-dev scheme" >&2
    exit 1
fi

# Xcode Cloud stores these as secret workflow environment variables.
python3 - <<'PY'
import os
from pathlib import Path
from urllib.parse import urlsplit

required = ("SUPABASE_DEV_URL", "SUPABASE_DEV_ANON_KEY", "MW_DICTIONARY_API_KEY")
missing = [name for name in required if not os.environ.get(name)]
if missing:
    raise SystemExit("Missing Xcode Cloud environment variables: " + ", ".join(missing))

url = os.environ["SUPABASE_DEV_URL"]
parts = urlsplit(url)
if parts.scheme != "https" or not parts.netloc:
    raise SystemExit("SUPABASE_DEV_URL must be an HTTPS URL")

values = {name: os.environ.get(name, "") for name in (
    "SUPABASE_DEV_ANON_KEY", "MW_DICTIONARY_API_KEY",
    "DEV_ACCOUNT_EMAIL", "DEV_ACCOUNT_PASSWORD",
)}
for name, value in values.items():
    if any(char in value for char in "\r\n"):
        raise SystemExit(name + " must be a single line")

lines = [
    "SUPABASE_DEV_URL = " + url.replace("://", ":/$()/", 1),
    "SUPABASE_DEV_ANON_KEY = " + values["SUPABASE_DEV_ANON_KEY"],
    "MW_DICTIONARY_API_KEY = " + values["MW_DICTIONARY_API_KEY"],
    "DEV_ACCOUNT_EMAIL = " + values["DEV_ACCOUNT_EMAIL"],
    "DEV_ACCOUNT_PASSWORD = " + values["DEV_ACCOUNT_PASSWORD"],
]
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

scheme_file="Projects/App/FiveVoca.xcodeproj/xcshareddata/xcschemes/threevoca-dev.xcscheme"
if [ ! -f "$scheme_file" ]; then
    echo "Missing shared threevoca-dev scheme" >&2
    exit 1
fi
