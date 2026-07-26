#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/common.sh
source "$SCRIPT_DIR/common.sh"
AGENT=""; BACKUP=""; LATEST=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent) AGENT="$2"; shift 2 ;;
    --backup) BACKUP="$2"; shift 2 ;;
    --latest) LATEST=true; shift ;;
    *) fail "Argumento desconhecido: $1" ;;
  esac
done
[[ -n "$AGENT" ]] || fail '--agent é obrigatório'
[[ "$AGENT" =~ ^[A-Za-z0-9_-]+$ ]] || fail 'Id de agente inválido'
[[ -z "$BACKUP" || "$BACKUP" =~ ^[A-Za-z0-9._-]+$ ]] || fail 'Id de backup inválido'
WORKSPACE_ROOT="${OPENCLAW_WORKSPACE_ROOT:-$HOME/.openclaw/workspaces}"
BACKUP_ROOT="${OPENCLAW_BACKUP_ROOT:-$HOME/.openclaw/prompt-backups}"
BASE="$BACKUP_ROOT/$AGENT"
TARGET="$WORKSPACE_ROOT/$AGENT"
if [[ "$LATEST" == true ]]; then [[ -f "$BASE/LATEST" ]] || fail 'LATEST ausente'; BACKUP="$(<"$BASE/LATEST")"; fi
[[ -n "$BACKUP" && -d "$BASE/$BACKUP" ]] || fail 'Backup inválido'
SOURCE="$BASE/$BACKUP"
[[ -f "$SOURCE/MANAGED_FILES" ]] || fail 'Backup incompatível: MANAGED_FILES ausente'

BACKUP_FILES=()
while IFS= read -r file; do [[ -z "$file" ]] || BACKUP_FILES+=("$file"); done < "$SOURCE/MANAGED_FILES"
CURRENT_FILES=("")
while IFS= read -r file; do [[ -z "$file" ]] || CURRENT_FILES+=("$file"); done < <(metadata_files "$TARGET/.prompt-release.json")
for file in "${BACKUP_FILES[@]}" "${CURRENT_FILES[@]}"; do [[ -z "$file" ]] || safe_relative_path "$file"; done

PRE="$BASE/pre-rollback-$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$PRE"
RESTORE_FILES=()
while IFS= read -r file; do [[ -z "$file" ]] || RESTORE_FILES+=("$file"); done < <(printf '%s\n' "${BACKUP_FILES[@]}" "${CURRENT_FILES[@]}" | sed '/^$/d' | sort -u)
printf '%s\n' "${RESTORE_FILES[@]}" > "$PRE/MANAGED_FILES"
for file in "${RESTORE_FILES[@]}"; do
  [[ -e "$TARGET/$file" ]] || continue
  mkdir -p "$PRE/$(dirname "$file")"
  cp -a "$TARGET/$file" "$PRE/$file"
done
[[ ! -f "$TARGET/.prompt-release.json" ]] || cp -a "$TARGET/.prompt-release.json" "$PRE/.prompt-release.json"

for file in "${RESTORE_FILES[@]}"; do
  if [[ -f "$SOURCE/$file" ]]; then
    mkdir -p "$TARGET/$(dirname "$file")"
    install -m 600 "$SOURCE/$file" "$TARGET/$file"
  else
    rm -f "$TARGET/$file"
  fi
done
if [[ -f "$SOURCE/.prompt-release.json" ]]; then
  install -m 600 "$SOURCE/.prompt-release.json" "$TARGET/.prompt-release.json"
else
  rm -f "$TARGET/.prompt-release.json"
fi
log "Rollback para $BACKUP concluído"
