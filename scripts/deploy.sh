#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

RELEASE=""; ENVIRONMENT="local"; AGENT=""; DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --release) RELEASE="$2"; shift 2 ;;
    --environment) ENVIRONMENT="$2"; shift 2 ;;
    --agent) AGENT="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) fail "Argumento desconhecido: $1" ;;
  esac
done
[[ -n "$RELEASE" && -n "$AGENT" ]] || fail '--release e --agent são obrigatórios'
[[ "$AGENT" =~ ^[A-Za-z0-9_-]+$ ]] || fail 'Id de agente inválido'
RELEASE="$(cd "$RELEASE" && pwd)"
verify_checksums "$RELEASE"

NEW_FILES=()
while IFS= read -r file; do [[ -z "$file" ]] || NEW_FILES+=("$file"); done < <(release_files "$RELEASE/release.json" "$AGENT")
[[ ${#NEW_FILES[@]} -gt 0 ]] || fail 'Release sem arquivos gerenciados'
for file in "${NEW_FILES[@]}"; do
  safe_relative_path "$file"
  [[ -f "$RELEASE/agents/$AGENT/$file" ]] || fail "Arquivo ausente na release: $file"
done

OPENCLAW_WORKSPACE_ROOT="${OPENCLAW_WORKSPACE_ROOT:-$HOME/.openclaw/workspaces}"
OPENCLAW_BACKUP_ROOT="${OPENCLAW_BACKUP_ROOT:-$HOME/.openclaw/prompt-backups}"
TARGET="$OPENCLAW_WORKSPACE_ROOT/$AGENT"
ID="$(date -u +%Y%m%dT%H%M%SZ)-$(node -e 'const fs=require("fs");process.stdout.write(JSON.parse(fs.readFileSync(process.argv[1],"utf8")).sourceCommit.slice(0,12))' "$RELEASE/release.json")"
BACKUP="$OPENCLAW_BACKUP_ROOT/$AGENT/$ID"
LOCK="$OPENCLAW_WORKSPACE_ROOT/.$AGENT.workspace-deploy.lock"
mkdir -p "$TARGET" "$OPENCLAW_BACKUP_ROOT/$AGENT"
mkdir "$LOCK" 2>/dev/null || fail 'Outro deploy do agente está em execução'
trap 'rmdir "$LOCK" 2>/dev/null || true' EXIT

log "commit=$(node -e 'const fs=require("fs");process.stdout.write(JSON.parse(fs.readFileSync(process.argv[1],"utf8")).sourceCommit)' "$RELEASE/release.json") ambiente=$ENVIRONMENT agente=$AGENT destino=$TARGET"
[[ "$DRY_RUN" != true ]] || exit 0

OLD_FILES=("")
while IFS= read -r file; do [[ -z "$file" ]] || OLD_FILES+=("$file"); done < <(metadata_files "$TARGET/.prompt-release.json")
for file in "${OLD_FILES[@]}"; do [[ -z "$file" ]] || safe_relative_path "$file"; done
BACKUP_FILES=()
while IFS= read -r file; do [[ -z "$file" ]] || BACKUP_FILES+=("$file"); done < <(printf '%s\n' "${OLD_FILES[@]}" "${NEW_FILES[@]}" | sed '/^$/d' | sort -u)
mkdir -p "$BACKUP"
printf '%s\n' "${BACKUP_FILES[@]}" > "$BACKUP/MANAGED_FILES"
for file in "${BACKUP_FILES[@]}"; do
  [[ -e "$TARGET/$file" ]] || continue
  mkdir -p "$BACKUP/$(dirname "$file")"
  cp -a "$TARGET/$file" "$BACKUP/$file"
done
[[ ! -f "$TARGET/.prompt-release.json" ]] || cp -a "$TARGET/.prompt-release.json" "$BACKUP/.prompt-release.json"

for file in "${NEW_FILES[@]}"; do
  mkdir -p "$TARGET/$(dirname "$file")"
  install -m 600 "$RELEASE/agents/$AGENT/$file" "$TARGET/$file"
done
for file in "${OLD_FILES[@]}"; do
  [[ -z "$file" ]] && continue
  if ! printf '%s\n' "${NEW_FILES[@]}" | grep -Fqx -- "$file"; then rm -f "$TARGET/$file"; fi
done

node -e 'const fs=require("fs"),r=JSON.parse(fs.readFileSync(process.argv[1],"utf8"));fs.writeFileSync(process.argv[2],JSON.stringify({...r,agent:process.argv[3],environment:process.argv[4],managedFiles:JSON.parse(process.argv[5]),deployedAt:new Date().toISOString(),backupId:process.argv[6]},null,2)+"\n",{mode:0o600})' "$RELEASE/release.json" "$TARGET/.prompt-release.json" "$AGENT" "$ENVIRONMENT" "$(printf '%s\n' "${NEW_FILES[@]}" | node -e 'let b="";process.stdin.on("data",d=>b+=d).on("end",()=>console.log(JSON.stringify(b.trim().split("\n").filter(Boolean))))')" "$ID"
printf '%s\n' "$ID" > "$OPENCLAW_BACKUP_ROOT/$AGENT/LATEST"
chmod 600 "$OPENCLAW_BACKUP_ROOT/$AGENT/LATEST"
log 'Deploy concluído'
