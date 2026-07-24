#!/usr/bin/env bash
set -Eeuo pipefail
npm run build
V="$(node -p 'require("./dist/release.json").releaseVersion')"
mkdir -p artifacts
P="artifacts/openclaw-prompts-$V.tar.gz"
tar -czf "$P" -C dist .
if command -v sha256sum >/dev/null; then sha256sum "$P" > "$P.sha256"; else shasum -a 256 "$P" > "$P.sha256"; fi
echo "Created $P"
