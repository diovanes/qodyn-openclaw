# Estrutura do workspace OpenClaw

Este repositório representa o conteúdo de `/root/.openclaw/workspace` descrito no relatório de mapeamento de 25 de julho de 2026.

## Agentes

| Agente | Estrutura local |
|---|---|
| `admin_master` | `.openclaw/`, `agent/`, `memory/` e prompts no diretório do agente |
| `aura_test01_default` | `.openclaw/`, `agent/` e prompts no diretório do agente |
| `auraflow_main` | `.openclaw/`, `agent/` e prompts no diretório do agente |
| `auraflow_orchestrator_isis` | `.openclaw/`, `agent/` e prompts no diretório do agente |
| `main` | `.openclaw/`, `agent/`, `memory/`, `state/` e prompts no diretório do agente |
| `mpp_isis` | `.openclaw/`, `agent/`, `memory.md` e prompts no diretório do agente |

Os oito documentos textuais de `mpp_isis` que foram transcritos no relatório foram copiados literalmente para `agents/mpp_isis/`. Os prompts já presentes no repositório foram preservados sem alteração de conteúdo; `support` foi apenas renomeado para `aura_test01_default` para acompanhar a distribuição atual.

O relatório não transcreve o conteúdo dos prompts de `admin_master`, `auraflow_main` e `auraflow_orchestrator_isis`. Por isso, seus diretórios foram preparados sem criar prompts vazios ou inventar conteúdo: importe os arquivos textuais originais antes de ativar esses agentes.

## Configuração global

`config/openclaw.json.example` é a versão sanitizada da configuração global reportada. O registro de plugin fica em `config/global/plugins/`; credenciais, dispositivos e logs têm diretórios próprios, intencionalmente ignorados pelo Git.

## Dados não versionados

Não adicione credenciais, tokens, sessões, bancos SQLite, estados de autenticação, logs ou memória de clientes. Esses itens pertencem ao runtime e estão cobertos por `.gitignore`. Para restaurar um ambiente, faça o provisionamento dessas informações fora do Git e valide os valores de `openclaw.json` antes de iniciar o gateway.
