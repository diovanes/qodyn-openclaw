#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/common.sh"; AGENT=""; ENVIRONMENT=local
while [[ $# -gt 0 ]]; do case "$1" in --agent)AGENT="$2";shift 2;;--environment)ENVIRONMENT="$2";shift 2;;*)fail "Argumento: $1";;esac;done
[[ -n "$AGENT" ]]||fail '--agent obrigatório'; ROOT="$(cd "$SCRIPT_DIR/.."&&pwd)"; load_environment "$ENVIRONMENT" "$ROOT"; BR="$(resolve_path "${OPENCLAW_BACKUP_ROOT:-$HOME/.openclaw/prompt-backups}")"; find "$BR/$AGENT" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;|sort -r
