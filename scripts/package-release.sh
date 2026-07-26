#!/usr/bin/env bash
set -Eeuo pipefail

npm run build -- "$@"
AGENT="${1:-all}"
if [[ "$AGENT" == "--agent" ]]; then AGENT="${2:?--agent exige um id}"; fi
COMMIT="$(node -e 'const fs=require("fs");process.stdout.write(JSON.parse(fs.readFileSync("dist/release.json","utf8")).sourceCommit)')"
mkdir -p artifacts
PACKAGE="artifacts/openclaw-workspace-${AGENT}-${COMMIT}.tar.gz"
tar -czf "$PACKAGE" -C dist .
if command -v sha256sum >/dev/null; then sha256sum "$PACKAGE" > "$PACKAGE.sha256"; else shasum -a 256 "$PACKAGE" > "$PACKAGE.sha256"; fi
printf '%s\n' "Created $PACKAGE"
