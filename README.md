# OpenClaw Workspace

Este repositório versiona a estrutura do workspace OpenClaw mapeada em `docs/relatorio-openclaw-mapeamento-2026-07-25.md`.

## Estrutura principal

```text
.
├── agents/
│   ├── admin_master/
│   ├── aura_test01_default/
│   ├── auraflow_main/
│   ├── auraflow_orchestrator_isis/
│   ├── main/
│   └── mpp_isis/
├── clients/
├── config/
│   └── global/
├── extensions/
├── memory/
├── state/
└── Workflow/
```

Os documentos de prompt residem diretamente no diretório de cada agente. Os estados de runtime, credenciais, sessões, logs e memórias operacionais não são versionados.

## Configuração

- Use `config/openclaw.json.example` como referência sanitizada para a configuração global.
- Provisionar `credentials/`, `devices/` e `logs/` somente no ambiente OpenClaw.
- Mantenha o código distribuível do `mpp-integration-plugin` em `extensions/mpp-integration-plugin/`, sem bundles ou dependências geradas.

## Verificação

```bash
npm run check
```

## Deploy

O deploy é iniciado manualmente pela action **Deploy OpenClaw workspace**. Ela gera um pacote temporário a partir do ref selecionado, instala-o por SSH em staging e promove automaticamente o mesmo pacote para produção após o smoke test. Consulte o [runbook operacional](docs/OPERATIONS.md) para as variables e o secret SSH necessários.

Consulte [a estrutura detalhada](docs/WORKSPACE_LAYOUT.md) e [o relatório de mapeamento](docs/relatorio-openclaw-mapeamento-2026-07-25.md) antes de adicionar arquivos ao workspace.
