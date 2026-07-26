#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
RELEASE=""; ENVIRONMENT="local"; AGENT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --release) RELEASE="$2"; shift 2 ;;
    --environment) ENVIRONMENT="$2"; shift 2 ;;
    --agent) AGENT="$2"; shift 2 ;;
    *) fail "Argumento desconhecido: $1" ;;
  esac
done
[[ -n "$RELEASE" && -n "$AGENT" ]] || fail '--release e --agent são obrigatórios'
RELEASE="$(cd "$RELEASE" && pwd)"
verify_checksums "$RELEASE"
TARGET="${OPENCLAW_WORKSPACE_ROOT:-$HOME/.openclaw/workspaces}/$AGENT"
test -f "$TARGET/.prompt-release.json"
FILES=()
while IFS= read -r file; do [[ -z "$file" ]] || FILES+=("$file"); done < <(release_files "$RELEASE/release.json" "$AGENT")
[[ ${#FILES[@]} -gt 0 ]] || fail 'Agente ausente na release'
for file in "${FILES[@]}"; do safe_relative_path "$file"; test -f "$TARGET/$file"; done

BIN="${OPENCLAW_BIN:-openclaw}"
if command -v "$BIN" >/dev/null; then
  "$BIN" --version
  [[ "${OPENCLAW_RUN_CONFIG_VALIDATE:-true}" != true ]] || "$BIN" config validate
  [[ "${OPENCLAW_RUN_SECURITY_AUDIT:-false}" != true ]] || "$BIN" security audit
  [[ "${OPENCLAW_RUN_DEEP_SECURITY_AUDIT:-false}" != true ]] || "$BIN" security audit --deep
  [[ "${OPENCLAW_RUN_GATEWAY_STATUS:-false}" != true ]] || "$BIN" gateway status --deep
  [[ "${OPENCLAW_RUN_AGENTS_LIST:-false}" != true ]] || "$BIN" agents list --json
else
  log 'OpenClaw indisponível; smoke limitado ao filesystem'
fi
log "Smoke test concluído para $AGENT em $ENVIRONMENT"
