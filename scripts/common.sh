#!/usr/bin/env bash
set -Eeuo pipefail
log(){ printf '[prompt-manager] %s\n' "$*"; }
fail(){ printf '[prompt-manager] ERROR: %s\n' "$*" >&2; exit 1; }
resolve_path(){ local value="$1"; eval "printf '%s\\n' \"$value\""; }
load_environment(){ local env="$1" root="$2" file="${root}/config/environments/${env}.env"; if [[ -f "$file" ]]; then set -a; source "$file"; set +a; fi; }
verify_checksums(){ local dir="$1"; [[ -f "$dir/SHA256SUMS" ]]||fail 'SHA256SUMS ausente'; (cd "$dir"; if command -v sha256sum >/dev/null; then sha256sum -c SHA256SUMS; else shasum -a 256 -c SHA256SUMS; fi); }
json_value(){ node -e 'const fs=require("fs"),o=JSON.parse(fs.readFileSync(process.argv[1],"utf8"));const v=process.argv[2].split(".").reduce((a,k)=>a?.[k],o);if(v===undefined)process.exit(2);process.stdout.write(String(v));' "$1" "$2"; }
version_ge(){ node -e 'const n=s=>s.replace(/^v/,"").split(/[+-]/)[0].split(".").map(Number),a=n(process.argv[1]),b=n(process.argv[2]);for(let i=0;i<3;i++){if((a[i]||0)>(b[i]||0))process.exit(0);if((a[i]||0)<(b[i]||0))process.exit(1)}' "$1" "$2"; }
