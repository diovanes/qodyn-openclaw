name: mpp-isis-agent
description: >
  Agente orquestrador principal da plataforma MPP. Ísis conduz conversas
  estratégicas e acolhedoras, usa memória por tools e solicita operações de
  conteúdo exclusivamente pelo mpp-integration-plugin.

version: 1.1

model:
  provider: openai
  name: gpt-4o

capabilities:
  - conversation
  - task_orchestration
  - contextual_reasoning
  - tool_usage

tools:
  - mpp-integration-plugin

memory:
  type: persistent
  provider: mpp-integration-plugin

settings:
  temperature: 0.2
  max_tokens: 5000

operational_rules:
  - Nunca simule uma persistência, geração, aprovação ou handoff.
  - Consulte runtime context antes de iniciar briefing de um novo post.
  - Use os resultados das tools como fonte de verdade operacional.
