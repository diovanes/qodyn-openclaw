Relatório concluído, somente leitura. O caminho correto é `/root/.openclaw`; `/root/.opeclaw` não existe. O OpenClaw está ativo, a configuração é válida e há 36 itens diretamente na raiz.

**Não remover**

| Item | Função |
|---|---|
| `openclaw.json` | Configuração ativa: agentes, canais, plugins, modelos e gateway. |
| `agents/` | Perfis, autenticação e sessões isoladas dos 4 agentes. |
| `workspace/` | Workspaces, instruções, memórias e arquivos de trabalho dos agentes. |
| `credentials/` | Credenciais de provedores e canais. |
| `identity/` | Identidade criptográfica/local da instalação. |
| `devices/` | Pareamentos e tokens de dispositivos. |
| `state/` | Estado persistente do gateway e conversas. |
| `npm/` | Dependências locais do OpenClaw/Codex. Ocupa cerca de 3 GB. |
| `extensions/` | Plugins instalados, incluindo `mpp-integration-plugin`. |
| `plugins/` | Registro e metadados das instalações de plugins. |
| `node_modules/`, `package.json`, `package-lock.json` | Metadados e dependências locais do Node. |
| `memory/` | Base de memória persistente. |
| `flows/`, `tasks/` | Estado de fluxos e tarefas duráveis. |
| `telegram/` | Estado operacional do canal Telegram. |
| `media/` | Mídias associadas a conversas e operações. |
| `workspace-attestations/` | Comprovações de integridade/autorizações dos workspaces. |
| `exec-approvals.json` | Política de autorização para comandos. |
| `locks/` | Arquivos de coordenação para evitar processos concorrentes. |

**Manter, mas pode limpar conteúdo com política de retenção**

| Item | Função | Observação |
|---|---|---|
| `logs/` (15 MB) | Logs do gateway e plugins. | Pode remover logs antigos, mantendo o diretório e os arquivos recentes. |
| `.trash/` (328 KB) | Área de descarte recuperável. | Candidata segura para esvaziamento após conferir que nada precisa ser restaurado. |
| `media/` (168 KB) | Anexos e mídia. | Limpeza libera espaço, mas remove acesso a arquivos históricos. |
| `canvas/` | Dados do Canvas. | Removível apenas se esse recurso não for usado; perde conteúdo salvo. |
| `completions/` (524 KB) | Cache/artefatos de autocompletar shell. | Pode ser regenerado. |
| `tui/` | Preferências/estado da interface de terminal. | Pode ser recriado, com perda de preferências locais. |
| `skill-workshop/` | Estado e propostas de skills. | Removível se não houver propostas/workflows a preservar. |
| `qqbot/` | Estado de canal QQBot. | Não há QQBot ativo na configuração atual; provável candidato, mas recomendo confirmar que não será reativado. |

**Arquivos de recuperação e históricos: removíveis sem afetar a execução atual**

| Item | Função |
|---|---|
| `openclaw.json.back1507` | Backup da configuração. |
| `openclaw.json.bak` | Backup da configuração. |
| `openclaw.json.bak.1` | Backup da configuração. |
| `openclaw.json.bak.2` | Backup da configuração. |
| `openclaw.json.bak.3` | Backup da configuração. |
| `openclaw.json.bak.4` | Backup da configuração. |
| `openclaw.json.clobbered.2026-05-06T12-17-32-201Z` | Snapshot de recuperação de conflito antigo. |
| `openclaw.json.clobbered.2026-05-14T19-53-45-815Z` | Snapshot de recuperação de conflito antigo. |
| `openclaw.json.last-good` | Última configuração validada conhecida. |
| `gateway-supervisor-restart-handoff.json` | Marcador temporário de reinício do gateway, já expirado. |
| `update-check.json.migrated` | Histórico de verificação de atualizações. |

Minha recomendação: preservar `openclaw.json.last-good` e ao menos um backup `.bak` recente; os demais backups históricos podem ser eliminados sem afetar o funcionamento atual. O ganho de espaço, porém, será pequeno: os backups somam apenas algumas dezenas de KB. Os maiores alvos são `npm/`, `agents/` e `workspace/`, mas eles não devem ser removidos diretamente porque sustentam o runtime, agentes e dados de trabalho.