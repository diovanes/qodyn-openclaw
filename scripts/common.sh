#!/usr/bin/env bash
set -Eeuo pipefail

log(){ printf '[openclaw-workspace] %s\n' "$*"; }
fail(){ printf '[openclaw-workspace] ERROR: %s\n' "$*" >&2; exit 1; }
verify_checksums(){ local dir="$1"; [[ -f "$dir/SHA256SUMS" ]] || fail 'SHA256SUMS ausente'; (cd "$dir"; if command -v sha256sum >/dev/null; then sha256sum --check SHA256SUMS; else shasum -a 256 --check SHA256SUMS; fi); }
safe_relative_path(){ local file="$1"; [[ -n "$file" && "$file" != /* && "$file" != *".."* && "$file" =~ ^[A-Za-z0-9._/-]+$ ]] || fail "Caminho relativo inválido: $file"; }
release_files(){ node -e 'const fs=require("fs"),r=JSON.parse(fs.readFileSync(process.argv[1],"utf8")),a=r.agents.find(x=>x.id===process.argv[2]);if(!a)process.exit(2);for(const f of a.files)console.log(f)' "$1" "$2"; }
metadata_files(){ [[ -f "$1" ]] || return 0; node -e 'const fs=require("fs"),r=JSON.parse(fs.readFileSync(process.argv[1],"utf8"));for(const f of r.managedFiles||[])console.log(f)' "$1"; }
