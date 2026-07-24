# GitHub Setup

## Branch protection

- PR obrigatório;
- dois revisores para mudanças críticas;
- CODEOWNERS;
- checks obrigatórios;
- impedir force push e exclusão.

## Environments

### staging

Runner: `self-hosted, linux, openclaw-staging`.

### production

Runner: `self-hosted, linux, openclaw-production`, com aprovação obrigatória.

## Variáveis

- `OPENCLAW_WORKSPACE_ROOT`
- `OPENCLAW_BACKUP_ROOT`
- `OPENCLAW_CONFIG_PATH`
- `OPENCLAW_STATE_DIR`

## Tags

```text
prompts-v1.0.0
```
