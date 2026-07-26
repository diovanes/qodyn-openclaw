#!/usr/bin/env bash
set -Eeuo pipefail
if command -v shellcheck >/dev/null; then
  files=()
  while IFS= read -r file; do files+=("$file"); done < <(find scripts -maxdepth 1 -name "*.sh" -type f)
  shellcheck -x "${files[@]}"
else
  echo "ShellCheck não instalado; ignorado."
fi
