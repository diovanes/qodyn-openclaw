# GitHub Setup

## Branch protection

- PR obrigatório;
- dois revisores para mudanças críticas;
- CODEOWNERS;
- checks obrigatórios;
- impedir force push e exclusão.

## Environments

O deploy roda em `ubuntu-latest` e se conecta à VPS de destino por SSH/SCP (ver `docs/OPERATIONS.md`),
não em runner self-hosted.

### staging

Configurada. Todos os deploys vão para cá enquanto `production` não existir.

### production

Ainda não configurada. O workflow `Deploy OpenClaw workspace` só promove para produção quando o
input `promote_to_production` é `true`; mantenha-o `false` até este Environment ser criado.

## Variáveis e secrets

Ver a lista completa e o passo a passo em `docs/OPERATIONS.md` (`OPENCLAW_SSH_HOST`,
`OPENCLAW_SSH_USER`, `OPENCLAW_SSH_PORT`, `OPENCLAW_WORKSPACE_ROOT`, `OPENCLAW_BACKUP_ROOT`,
`OPENCLAW_BIN`, `OPENCLAW_RUN_*` e o secret `OPENCLAW_SSH_KEY`).

## Tags

```text
prompts-v1.0.0
```
