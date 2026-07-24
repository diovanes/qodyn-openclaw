#!/usr/bin/env bash
set -Eeuo pipefail
if command -v shellcheck >/dev/null; then mapfile -t f < <(find scripts -maxdepth 1 -name "*.sh" -type f); shellcheck "${f[@]}"; else echo "ShellCheck não instalado; ignorado."; fi
