# OpenClaw Prompt Management Template

Projeto modelo profissional para governança, versionamento, validação, teste, empacotamento, implantação e rollback de prompts e skills de agentes OpenClaw.

> Baseline de compatibilidade configurada no exemplo: OpenClaw `2026.7.1`. Antes de produção, confirme a versão instalada com `openclaw --version` e valide os comandos com `openclaw <comando> --help`.

## 1. Objetivo

Este repositório implementa um fluxo GitOps para prompts:

```text
Alteração em branch
  → Pull Request
  → lint + validação + testes
  → artefato imutável
  → staging
  → smoke test
  → aprovação manual
  → produção
  → rollback rastreável
```

A proposta evita editar diretamente `AGENTS.md`, `SOUL.md`, `TOOLS.md` ou `SKILL.md` no servidor. Os prompts são tratados como código: possuem histórico, revisão, testes, checksums, releases e rollback.

## 2. Princípios

1. Um workspace por agente.
2. Regras gerais em `AGENTS.md`.
3. Identidade e tom em `SOUL.md`.
4. Processos especializados em `skills/<skill>/SKILL.md`.
5. Memória operacional separada da governança.
6. Deploy somente de artefato validado.
7. Backup antes da atualização.
8. Promoção do mesmo artefato entre ambientes.
9. Produção protegida por aprovação.
10. O agente não modifica livremente os próprios arquivos de governança.

## 3. Estrutura

```text
.
├── agents/
│   ├── main/
│   └── support/
├── config/
│   ├── environments/
│   └── examples/
├── docs/
├── schemas/
├── scripts/
├── tests/
├── .github/workflows/
├── manifest.json
├── package.json
└── CHANGELOG.md
```

## 4. Arquivos do workspace

| Arquivo | Responsabilidade |
|---|---|
| `AGENTS.md` | missão, prioridades, fluxo operacional e guardrails |
| `SOUL.md` | personalidade, voz, tom e limites de comunicação |
| `IDENTITY.md` | nome e identidade curta |
| `USER.md` | preferências duráveis e não sensíveis do público |
| `TOOLS.md` | convenções de uso de ferramentas |
| `HEARTBEAT.md` | regras de execução periódica |
| `BOOTSTRAP.md` | ritual inicial, quando aplicável |
| `MEMORY.md` | memória durável; não é gerenciada por este pipeline |
| `skills/*/SKILL.md` | processos especializados carregados sob demanda |

## 5. Pré-requisitos

### Desenvolvimento

- Node.js 22+
- npm
- Bash 4+
- Git
- `tar`
- `sha256sum` ou `shasum`
- opcional: ShellCheck
- opcional: Gitleaks

### Ambiente OpenClaw

- OpenClaw instalado e configurado;
- usuário de deploy sem root;
- workspaces previamente definidos;
- acesso de escrita apenas aos workspaces gerenciados e backups;
- credenciais fora deste repositório.

## 6. Instalação

```bash
git clone <url> openclaw-prompt-management
cd openclaw-prompt-management
npm ci
npm run check
```

## 7. Comandos

| Comando | Finalidade |
|---|---|
| `npm run lint:md` | valida Markdown |
| `npm run validate` | valida manifesto, arquivos, front matter e skills |
| `npm run test:prompts` | executa testes declarativos |
| `npm run test:shell` | executa ShellCheck se instalado |
| `npm run scan:secrets` | executa Gitleaks se instalado |
| `npm run check` | executa todas as verificações |
| `npm run build` | cria release em `dist/` |
| `npm run package` | cria `.tar.gz` e checksum |
| `npm run clean` | remove artefatos gerados |

## 8. Criar um agente

```bash
cp -R agents/main agents/meu-agente
```

Atualize o front matter dos arquivos e adicione ao `manifest.json`:

```yaml
agents:
  - id: meu-agente
    source: agents/meu-agente
    description: Agente de exemplo.
    files:
      - AGENTS.md
      - SOUL.md
    skills:
      - safe-external-action
```

Depois:

```bash
npm run check
```

## 9. Criar uma skill

Crie:

```text
agents/<agente>/skills/<slug>/SKILL.md
```

Exemplo:

```markdown
---
name: atendimento-seguro
description: Exige confirmação antes de ações externas.
---

# Atendimento seguro

1. Confirme destino e conteúdo.
2. Verifique autorização.
3. Execute uma única vez.
4. Registre o resultado.
```

O campo `name` deve coincidir com o diretório e com o manifesto.

## 10. Versionamento

Use SemVer:

```text
PATCH → correção sem mudança comportamental relevante
MINOR → nova regra ou skill compatível
MAJOR → mudança de fluxo, identidade ou comportamento incompatível
```

Atualize em conjunto:

- `manifest.json > release.version`;
- front matter dos arquivos de agente;
- `CHANGELOG.md`;
- tag Git `prompts-vX.Y.Z`.

## 11. Build

```bash
npm run build
```

Saída:

```text
dist/
├── agents/
├── scripts/
├── manifest.json
├── release.json
└── SHA256SUMS
```

O build remove o front matter dos arquivos injetados no agente, mas preserva o front matter obrigatório das skills.

Empacotamento:

```bash
npm run package
```

## 12. Deploy local

```bash
npm run build
./scripts/deploy.sh \
  --release ./dist \
  --environment local \
  --agent main
```

O script:

- valida checksum;
- confere versão mínima do OpenClaw, quando disponível;
- cria lock por agente;
- cria backup;
- instala apenas arquivos gerenciados;
- substitui skills de forma controlada;
- preserva `MEMORY.md` e `memory/`;
- grava `.prompt-release.json`.

Dry run:

```bash
./scripts/deploy.sh --release ./dist --environment local --agent main --dry-run
```

## 13. Smoke test

```bash
./scripts/smoke-test.sh \
  --release ./dist \
  --environment local \
  --agent main
```

Verifica filesystem e, de forma configurável:

```bash
openclaw --version
openclaw config validate
openclaw security audit
openclaw security audit --deep
openclaw gateway status --deep
openclaw agents list --json
```

## 14. Rollback

Listar backups:

```bash
./scripts/list-backups.sh --environment local --agent main
```

Rollback mais recente:

```bash
./scripts/rollback.sh --environment local --agent main --latest
```

Rollback específico:

```bash
./scripts/rollback.sh \
  --environment production \
  --agent main \
  --backup 20260724T180000Z-1.0.0
```

## 15. GitHub Actions

### `validate.yml`

Executa em Pull Requests e pushes:

- instalação reproduzível;
- lint Markdown;
- validação estrutural;
- testes declarativos;
- ShellCheck;
- secret scan;
- build e upload do candidato.

### `release.yml`

Em tags `prompts-v*`:

- valida tag versus manifesto;
- executa checks;
- empacota;
- publica GitHub Release com checksum.

### `deploy.yml`

Execução manual:

- checkout da tag;
- build reproduzível;
- deploy em staging;
- smoke test;
- aprovação via GitHub Environment;
- deploy da mesma versão em produção.

## 16. Configuração do GitHub

Crie os environments:

- `staging` — runner label `openclaw-staging`;
- `production` — runner label `openclaw-production`, com aprovação obrigatória.

Variáveis recomendadas:

```text
OPENCLAW_WORKSPACE_ROOT
OPENCLAW_BACKUP_ROOT
OPENCLAW_CONFIG_PATH
OPENCLAW_STATE_DIR
```

O runner deve:

- usar usuário dedicado sem root;
- não montar Docker socket;
- não usar SSH Agent forwarding;
- não receber PRs não confiáveis para deploy;
- não possuir credenciais de modelo quando desnecessárias.

Leia `docs/GITHUB_SETUP.md` e `docs/SECURITY.md`.

## 17. Ativação das mudanças

Alterações em arquivos de workspace e skills não devem depender de reinício do Gateway. Porém, uma sessão existente pode manter contexto anterior. Para mudanças críticas:

1. conclua o deploy;
2. execute smoke test;
3. abra uma nova sessão do agente conforme seu procedimento operacional;
4. monitore regressões.

## 18. Segurança

Prompts não são uma barreira de segurança. Enforcement real deve permanecer em:

- sandbox;
- allowlists;
- políticas de ferramentas;
- permissões do sistema operacional;
- isolamento do Gateway;
- aprovação humana;
- idempotência e contratos de aplicação.

Nunca coloque segredos, dados reais, URLs assinadas ou credenciais nos prompts.

## 19. Documentação adicional

- `docs/ARCHITECTURE.md`
- `docs/PROMPT_GUIDE.md`
- `docs/OPERATIONS.md`
- `docs/SECURITY.md`
- `docs/GITHUB_SETUP.md`
- `docs/MODEL_EVALUATION.md`

## 20. Referências oficiais

- https://docs.openclaw.ai/concepts/agent-workspace
- https://docs.openclaw.ai/concepts/agent
- https://docs.openclaw.ai/concepts/context
- https://docs.openclaw.ai/concepts/system-prompt
- https://docs.openclaw.ai/tools/skills
- https://docs.openclaw.ai/tools/creating-skills
- https://docs.openclaw.ai/tools/skills-config
- https://docs.openclaw.ai/cli/config
- https://docs.openclaw.ai/gateway/security
- https://docs.openclaw.ai/cli/security
- https://docs.openclaw.ai/concepts/multi-agent

## Licença

MIT. Ajuste conforme as políticas da organização.
