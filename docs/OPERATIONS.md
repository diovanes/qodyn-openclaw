# Runbook operacional

## Estado atual: somente staging

Por enquanto, a VPS de `production` ainda não foi provisionada/configurada. Todos os deploys devem
ir para `staging`. O workflow `Deploy OpenClaw workspace` tem um input `promote_to_production`
(boolean, default `false`) que controla se o job `production` roda; deixe-o desmarcado (`false`)
até a VPS de produção ser configurada. Quando `production` estiver pronta, configure o Environment
conforme abaixo e passe `promote_to_production: true` para promover.

## Pré-requisitos no GitHub

Crie o Environment `staging` (e, futuramente, `production`). Em cada um, configure as variables:

- `OPENCLAW_SSH_HOST`, `OPENCLAW_SSH_USER` e `OPENCLAW_SSH_PORT`;
- `OPENCLAW_WORKSPACE_ROOT` e `OPENCLAW_BACKUP_ROOT`;
- `OPENCLAW_BIN` e as flags opcionais `OPENCLAW_RUN_*`.

Adicione `OPENCLAW_SSH_KEY` como secret do Environment. O usuário SSH deve poder gravar no workspace e no diretório de backups, além de executar o binário OpenClaw.

## Deploy

Em **Actions → Deploy OpenClaw workspace → Run workflow**, informe o commit SHA, tag ou branch, selecione o agente e defina `promote_to_production` (`false` enquanto só staging estiver configurada). A action:

1. valida e empacota uma única vez os arquivos declarados em `manifest.json`;
2. verifica o checksum e faz deploy em staging por SCP/SSH;
3. executa o smoke test em staging;
4. se `promote_to_production` for `true`, promove automaticamente o mesmo arquivo, com o mesmo checksum, para produção;
5. executa o smoke test em produção (somente quando o passo 4 rodar).

O workflow não recria o pacote entre staging e produção. Se houver regras de aprovação configuradas no Environment `production`, o GitHub poderá pausar a promoção até a aprovação; sem essa proteção, ela é automática após staging (quando `promote_to_production: true`).

## Escopo do pacote

Somente os arquivos em `deployment.agents` no `manifest.json` são copiados. Credenciais, sessões, dispositivos, logs, bancos SQLite e memória de runtime nunca entram no pacote.

`config/openclaw.json.example` é uma referência sanitizada e não é implantado como a configuração real do gateway.

## Rollback

Em **Actions → Roll back OpenClaw workspace → Run workflow**, selecione ambiente e agente. Informe um ID de backup ou deixe vazio para restaurar `LATEST`. O workflow lista os backups no host, restaura o conjunto de arquivos gerenciados e roda `openclaw config validate` quando o binário estiver disponível.
