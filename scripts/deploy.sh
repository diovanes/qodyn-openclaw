#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/common.sh"
RELEASE=""; ENVIRONMENT=local; AGENT=""; DRY_RUN=false
while [[ $# -gt 0 ]]; do case "$1" in --release) RELEASE="$2";shift 2;;--environment) ENVIRONMENT="$2";shift 2;;--agent) AGENT="$2";shift 2;;--dry-run) DRY_RUN=true;shift;;*) fail "Argumento desconhecido: $1";;esac;done
[[ -n "$RELEASE" && -n "$AGENT" ]]||fail '--release e --agent são obrigatórios'
RELEASE="$(cd "$RELEASE"&&pwd)"; PROJECT_ROOT="$(cd "$SCRIPT_DIR/.."&&pwd)"; load_environment "$ENVIRONMENT" "$PROJECT_ROOT"
OPENCLAW_WORKSPACE_ROOT="$(resolve_path "${OPENCLAW_WORKSPACE_ROOT:-$HOME/.openclaw/workspaces}")"; OPENCLAW_BACKUP_ROOT="$(resolve_path "${OPENCLAW_BACKUP_ROOT:-$HOME/.openclaw/prompt-backups}")"; OPENCLAW_BIN="${OPENCLAW_BIN:-openclaw}"
verify_checksums "$RELEASE"; [[ -d "$RELEASE/agents/$AGENT" ]]||fail 'Agente ausente na release'
VERSION="$(json_value "$RELEASE/release.json" releaseVersion)"; MIN="$(json_value "$RELEASE/release.json" minimumOpenClawVersion)"; TARGET="$OPENCLAW_WORKSPACE_ROOT/$AGENT"; ID="$(date -u +%Y%m%dT%H%M%SZ)-$VERSION"; BACKUP="$OPENCLAW_BACKUP_ROOT/$AGENT/$ID"; LOCK="$OPENCLAW_WORKSPACE_ROOT/.$AGENT.prompt-deploy.lock"; mkdir -p "$OPENCLAW_WORKSPACE_ROOT" "$OPENCLAW_BACKUP_ROOT/$AGENT" "$TARGET"; mkdir "$LOCK" 2>/dev/null||fail 'Outro deploy em execução'; trap 'rmdir "$LOCK" 2>/dev/null||true' EXIT
if command -v "$OPENCLAW_BIN" >/dev/null; then INSTALLED="$($OPENCLAW_BIN --version|grep -Eo '[0-9]+\.[0-9]+\.[0-9]+'|head -1||true)"; [[ -z "$INSTALLED" ]]||version_ge "$INSTALLED" "$MIN"||fail "OpenClaw $INSTALLED inferior a $MIN"; fi
log "release=$VERSION ambiente=$ENVIRONMENT agente=$AGENT destino=$TARGET"; [[ "$DRY_RUN" != true ]]||exit 0
mkdir -p "$BACKUP"; for i in AGENTS.md SOUL.md IDENTITY.md USER.md TOOLS.md HEARTBEAT.md BOOTSTRAP.md skills .prompt-release.json; do [[ ! -e "$TARGET/$i" ]]||cp -a "$TARGET/$i" "$BACKUP/"; done
for i in AGENTS.md SOUL.md IDENTITY.md USER.md TOOLS.md HEARTBEAT.md BOOTSTRAP.md; do [[ ! -f "$RELEASE/agents/$AGENT/$i" ]]||install -m 600 "$RELEASE/agents/$AGENT/$i" "$TARGET/$i"; done
if [[ -d "$RELEASE/agents/$AGENT/skills" ]]; then rm -rf "$TARGET/.skills.next"; cp -a "$RELEASE/agents/$AGENT/skills" "$TARGET/.skills.next"; find "$TARGET/.skills.next" -type d -exec chmod 700 {} +; find "$TARGET/.skills.next" -type f -exec chmod 600 {} +; rm -rf "$TARGET/.skills.previous"; [[ ! -d "$TARGET/skills" ]]||mv "$TARGET/skills" "$TARGET/.skills.previous"; mv "$TARGET/.skills.next" "$TARGET/skills"; fi
node -e 'const fs=require("fs"),r=JSON.parse(fs.readFileSync(process.argv[1],"utf8"));fs.writeFileSync(process.argv[2],JSON.stringify({...r,agent:process.argv[3],environment:process.argv[4],deployedAt:new Date().toISOString(),backupId:process.argv[5]},null,2)+"\n",{mode:0o600});' "$RELEASE/release.json" "$TARGET/.prompt-release.json" "$AGENT" "$ENVIRONMENT" "$ID"
printf '%s\n' "$ID" > "$OPENCLAW_BACKUP_ROOT/$AGENT/LATEST"; chmod 600 "$OPENCLAW_BACKUP_ROOT/$AGENT/LATEST"; log 'Deploy concluído'
