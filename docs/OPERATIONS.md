# Runbook operacional

## Pré-requisitos no GitHub

Crie os Environments `staging` e `production`. Em cada um, configure as variables:

- `OPENCLAW_SSH_HOST`, `OPENCLAW_SSH_USER` e `OPENCLAW_SSH_PORT`;
- `OPENCLAW_WORKSPACE_ROOT` e `OPENCLAW_BACKUP_ROOT`;
- `OPENCLAW_BIN` e as flags opcionais `OPENCLAW_RUN_*`.

Adicione `OPENCLAW_SSH_KEY` como secret do Environment. O usuário SSH deve poder gravar no workspace e no diretório de backups, além de executar o binário OpenClaw.

## Deploy

Em **Actions → Deploy OpenClaw workspace → Run workflow**, informe o commit SHA, tag ou branch e selecione o agente. A action:

1. valida e empacota uma única vez os arquivos declarados em `manifest.json`;
2. verifica o checksum e faz deploy em staging por SCP/SSH;
3. executa o smoke test em staging;
4. promove automaticamente o mesmo arquivo, com o mesmo checksum, para produção;
5. executa o smoke test em produção.

O workflow não recria o pacote entre staging e produção. Se houver regras de aprovação configuradas no Environment `production`, o GitHub poderá pausar a promoção até a aprovação; sem essa proteção, ela é automática após staging.

## Escopo do pacote

Somente os arquivos em `deployment.agents` no `manifest.json` são copiados. Credenciais, sessões, dispositivos, logs, bancos SQLite e memória de runtime nunca entram no pacote.

`config/openclaw.json.example` é uma referência sanitizada e não é implantado como a configuração real do gateway.

## Rollback

Em **Actions → Roll back OpenClaw workspace → Run workflow**, selecione ambiente e agente. Informe um ID de backup ou deixe vazio para restaurar `LATEST`. O workflow lista os backups no host, restaura o conjunto de arquivos gerenciados e roda `openclaw config validate` quando o binário estiver disponível.
