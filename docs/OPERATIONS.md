# Runbook operacional

## Pré-deploy

- release aprovada;
- checksum válido;
- ambiente correto;
- versão compatível;
- backup gravável;
- sem deploy concorrente.

## Deploy

```bash
./scripts/deploy.sh --release ./dist --environment staging --agent main
./scripts/smoke-test.sh --release ./dist --environment staging --agent main
```

## Rollback

```bash
./scripts/rollback.sh --environment production --agent main --latest
```

Para mudanças críticas, renove a sessão do agente após o deploy ou rollback.
