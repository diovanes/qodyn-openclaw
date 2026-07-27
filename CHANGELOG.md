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

## [Unreleased] - 2026-07-26 22:21

### Changed

- `.github/workflows/deploy.yml`: adicionado input `promote_to_production` (boolean, default `false`) ao `workflow_dispatch`; o job `production` agora só roda quando esse input é `true`. Enquanto a VPS de produção não é configurada, todos os deploys ficam restritos a `staging`.
- `docs/OPERATIONS.md`: documenta o estado atual (somente `staging` configurada) e o novo input `promote_to_production`.
- `docs/GITHUB_SETUP.md`: removidas referências obsoletas a runners self-hosted e às variáveis `OPENCLAW_CONFIG_PATH`/`OPENCLAW_STATE_DIR` (não usadas em nenhum script ou workflow atual); passa a apontar para `docs/OPERATIONS.md` como fonte da lista de variáveis/secrets.

### GitHub configuration (fora do controle de versão)

- Criado o Environment `staging` no repositório e migradas as 11 variables (`OPENCLAW_SSH_HOST`, `OPENCLAW_SSH_USER`, `OPENCLAW_SSH_PORT`, `OPENCLAW_WORKSPACE_ROOT`, `OPENCLAW_BACKUP_ROOT`, `OPENCLAW_BIN`, `OPENCLAW_RUN_*`) do escopo de repositório para o escopo do Environment `staging`, eliminando o fallback que faria o job `production` reusar silenciosamente os valores de staging. O secret `OPENCLAW_SSH_KEY` permanece no escopo de repositório (a API do GitHub não permite ler o valor de um secret existente para movê-lo).
