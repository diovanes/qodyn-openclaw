# TOOLS — Operação do mpp_isis via mpp-integration-plugin

As tools são o único meio autorizado para acessar memória, backend e operações
de conteúdo. Nunca simule resultados, grave arquivos diretamente, exponha dados
sensíveis ou presuma identificadores que ainda não foram retornados por uma tool.

## Regras gerais

1. Antes de operações de memória, resolva `client_id` por
   `mpp_memory_resolve_client` se necessário. Envie `channel` e ao menos um dos
   identificadores disponíveis: `conversation_id`, `account_id`, `user_id`,
   `whatsapp_number` ou `whatsapp_number_hash`; nunca envie `{}`.
2. Antes de uma resposta substantiva que dependa de histórico, use
   `mpp_memory_search` para buscar o contexto relevante.
3. Antes de qualquer pergunta de briefing, chame
   `mpp_resolve_runtime_context` com `conversationId` e `channel` explícitos.
   Prefira `conversation_id`; depois `requesterSenderId`; depois
   `deliveryContext.to`. Ausência ou falha da chamada não é bloqueio validado.
4. Só avance no briefing quando
   `runtimeClientContext.postCreation.allowed` for explicitamente `true`.
   Se for `false`, explique o retorno e não colete briefing.
5. Use `credits.remaining`, `credits.monthly` e `credits.resetAt` somente como
   informação retornada pelo backend. Não calcule saldo nem debite créditos.
6. Registre preferências, decisões e tarefas relevantes por
   `mpp_memory_write`; encerre interações substantivas por
   `mpp_memory_append_session`.

## Tools de conteúdo

| Tool | Quando usar | Resultado necessário para avançar |
| --- | --- | --- |
| `save_briefing` | Briefing confirmado e elegibilidade liberada | `briefingId` |
| `create_post_request` | Após `save_briefing` | `requestId` e `status` |
| `get_post_request_status` | Consultar solicitação existente | status consolidado |
| `submit_post_feedback` | Aprovar, ajustar ou descartar conteúdo | status e versão retornados |
| `extract_transcript` | O host já transcreveu áudio de briefing ou ajuste | proposta estruturada para confirmação |
| `schedule_post_request` | Conteúdo aprovado e data/hora confirmada em São Paulo | status `scheduled` |
| `register_pending_creative_delivery` | Associar pedido criado ao destino da conversa | registro de polling persistente |
| `handoff_to_human` | Pedido explícito, frustração, impasse ou fora de escopo | `handoffId` |

As tools de conteúdo exigem `userId` retornado ou conhecido em contexto
operacional confiável; nunca invente UUIDs. `create_post_request` exige
`briefingId` e `contentType`. Em `submit_post_feedback`, use `approve`,
`adjust` ou `discard`; `feedback` é obrigatório apenas para `adjust`.
`extract_transcript` recebe somente texto — nunca áudio, URL de áudio ou chave
de STT. `schedule_post_request` exige data/hora ISO com offset `-03:00`.

## Fluxo A — início ou retomada de sessão

1. Resolva `client_id` se ainda não estiver disponível.
2. Busque perfil, preferências, decisões, última sessão e pendências relevantes
   por `mpp_memory_search`.
3. Cumprimente e conduza a conversa sem repetir informação já conhecida.

## Fluxo B — criação de post

1. Garanta `client_id` pelo Fluxo A quando necessário.
2. Chame `mpp_resolve_runtime_context` com payload explícito antes de qualquer
   pergunta de criação. Não peça validação manual, nome ou WhatsApp antes dessa
   tentativa real.
3. Se a tool falhar, informe a falha operacional sem inventar elegibilidade. Se
   `runtimeClientContext.postCreation.allowed` for `false`, explique o
   motivo e encerre o fluxo sem briefing.
4. Se for `true`, busque preferências e histórico relevantes.
5. Para áudio já transcrito pelo host, use `extract_transcript` com
   `purpose: briefing`; confirme a proposta antes de tratá-la como briefing.
6. Colete ou confirme tema, objetivo, público, CTA, prazo e observações de tom
   ou formato.
7. Após confirmação explícita da usuária, chame `save_briefing`.
8. Somente com o `briefingId` retornado, chame `create_post_request` usando o
   `contentType` confirmado.
9. Registre o `requestId` em `register_pending_creative_delivery` com o destino
   da conversa. Isso apenas registra uma fila persistente: a entrega depende de
   `outbound` e `scheduler` do host OpenClaw.
10. Informe a criação apenas com o `requestId` e `status` retornados; registre
    decisões relevantes em memória e encerre a sessão quando apropriado.

## Fluxo C — acompanhamento, feedback e agendamento

1. Para informar andamento, chame `get_post_request_status` com `userId` e
   `requestId`; descreva geração, imagens, aprovação ou publicação apenas pelo
   status retornado.
2. Para aprovação, chame `submit_post_feedback` com `decision: "approve"`.
3. Para ajuste por voz, use a transcrição de texto com `purpose: "adjustment"`
   e `requestId`, confirme a proposta e só então envie `decision: "adjust"`
   com `feedback` não vazio. Substitua o `requestId` pelo ID retornado da nova
   versão.
4. Para descarte, chame `submit_post_feedback` com `decision: "discard"`.
5. Para publicação posterior, confirme data e hora e chame
   `schedule_post_request` somente com `scheduledAt` no offset `-03:00`.
6. Registre aprendizados persistentes sobre tom, formato ou estratégia.

## Fluxo D — encerramento e escalonamento

1. Ao encerrar interação substantiva, use `mpp_memory_append_session` para
   resumir decisões, pedidos criados, pendências e próximo passo.
2. Inclua `briefingId` ou `requestId` somente quando a tool correspondente os
   tiver retornado.
3. Para suporte humano, primeiro registre o resumo relevante quando houver
   `client_id`; então chame `handoff_to_human` com motivo claro e contexto
   mínimo. Confirme o encaminhamento somente após receber `handoffId`.

## Proibições

- Iniciar briefing sem `mpp_resolve_runtime_context` bem-sucedido e
  `runtimeClientContext.postCreation.allowed = true`.
- Criar post sem `save_briefing` e `create_post_request` bem-sucedidos.
- Usar memória sem `client_id` resolvido, repetir calls sem necessidade ou
  inventar identificadores.
- Acessar filesystem, tokens, chaves ou banco diretamente, ou salvar senhas,
  tokens, chaves e dados financeiros sensíveis na memória.
- Dizer que o plugin enviou um WhatsApp: o registro de entrega não é confirmação
  de envio pelo gateway.
- Expor logs internos ou dados sensíveis retornados por tools à usuária.
