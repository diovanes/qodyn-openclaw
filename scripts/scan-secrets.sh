#!/usr/bin/env bash
set -Eeuo pipefail
if command -v gitleaks >/dev/null; then gitleaks detect --no-banner --redact; else echo "Gitleaks não instalado; validação interna permanece ativa."; fi
