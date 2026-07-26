#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/common.sh
source "$SCRIPT_DIR/common.sh"
AGENT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent) AGENT="$2"; shift 2 ;;
    *) fail "Argumento desconhecido: $1" ;;
  esac
done
[[ "$AGENT" =~ ^[A-Za-z0-9_-]+$ ]] || fail '--agent válido é obrigatório'
BASE="${OPENCLAW_BACKUP_ROOT:-$HOME/.openclaw/prompt-backups}/$AGENT"
[[ -d "$BASE" ]] || exit 0
find "$BASE" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort -r
