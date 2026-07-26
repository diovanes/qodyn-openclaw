# Changelog

## [1.0.0] - 2026-07-24

### Added

- Estrutura GitOps inicial.
- Agentes `main` e `support`.
- Skills de exemplo.
- Validação, testes declarativos, build e checksums.
- Deploy, smoke test, backup e rollback.
- GitHub Actions para CI, release e promoção.

## [Unreleased] - 2026-07-26 13:02

### Fixed

- `scripts/check-shell.sh`: adicionado `-x` ao ShellCheck para seguir `source` relativo.
- `scripts/deploy.sh`, `scripts/rollback.sh`, `scripts/smoke-test.sh`, `scripts/list-backups.sh`: adicionada diretiva `# shellcheck source=scripts/common.sh` para resolver o `source "$SCRIPT_DIR/common.sh"` corretamente.
- Corrige falha do workflow `Validate workspace` (job `validate`, passo `npm run test:shell`), que só era reproduzida em CI porque o ShellCheck não estava instalado localmente até esta verificação.
