# Arquitetura

## Componentes

- **Repositório fonte:** prompts, skills, políticas, testes e automação.
- **Artefato:** unidade imutável promovida entre ambientes.
- **Workspace ativo:** diretório lido pelo OpenClaw.
- **Backup:** cópia dos arquivos gerenciados antes do deploy.

## Fluxo

```text
source → validation → tests → build → checksum → staging → approval → production
```

## Memória

```text
Git + aprovação → AGENTS.md, SOUL.md, TOOLS.md, SKILL.md
runtime/agente  → MEMORY.md, memory/
```

O deploy não remove nem sobrescreve memória.
