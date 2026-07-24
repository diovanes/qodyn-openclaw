#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/common.sh"
AGENT=""; BACKUP=""; LATEST=false; ENVIRONMENT=local
while [[ $# -gt 0 ]]; do case "$1" in --agent)AGENT="$2";shift 2;;--backup)BACKUP="$2";shift 2;;--latest)LATEST=true;shift;;--environment)ENVIRONMENT="$2";shift 2;;*)fail "Argumento: $1";;esac;done
[[ -n "$AGENT" ]]||fail '--agent obrigatório'; ROOT="$(cd "$SCRIPT_DIR/.."&&pwd)"; load_environment "$ENVIRONMENT" "$ROOT"; WR="$(resolve_path "${OPENCLAW_WORKSPACE_ROOT:-$HOME/.openclaw/workspaces}")"; BR="$(resolve_path "${OPENCLAW_BACKUP_ROOT:-$HOME/.openclaw/prompt-backups}")"; BASE="$BR/$AGENT"; TARGET="$WR/$AGENT"
if [[ "$LATEST" == true ]]; then [[ -f "$BASE/LATEST" ]]||fail 'LATEST ausente'; BACKUP="$(cat "$BASE/LATEST")"; fi; [[ -n "$BACKUP" && -d "$BASE/$BACKUP" ]]||fail 'Backup inválido'; SRC="$BASE/$BACKUP"; PRE="$BASE/pre-rollback-$(date -u +%Y%m%dT%H%M%SZ)"; mkdir -p "$PRE"
for i in AGENTS.md SOUL.md IDENTITY.md USER.md TOOLS.md HEARTBEAT.md BOOTSTRAP.md skills .prompt-release.json; do [[ ! -e "$TARGET/$i" ]]||cp -a "$TARGET/$i" "$PRE/"; done
for i in AGENTS.md SOUL.md IDENTITY.md USER.md TOOLS.md HEARTBEAT.md BOOTSTRAP.md; do if [[ -f "$SRC/$i" ]]; then install -m 600 "$SRC/$i" "$TARGET/$i"; else rm -f "$TARGET/$i"; fi; done
if [[ -d "$SRC/skills" ]]; then rm -rf "$TARGET/skills"; cp -a "$SRC/skills" "$TARGET/skills"; fi; [[ ! -f "$SRC/.prompt-release.json" ]]||cp -p "$SRC/.prompt-release.json" "$TARGET/.prompt-release.json"; log "Rollback para $BACKUP concluído"
