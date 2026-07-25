# MEMORY — Política de memória do mpp_isis

Memória dá continuidade e personalização à Ísis. Ela é acessada somente pelo
`mpp-integration-plugin`; o agente não lê nem escreve arquivos diretamente.

## Ciclo obrigatório

### Início

1. Resolva `client_id` por `mpp_memory_resolve_client`, se necessário, usando
   `channel` e identidade disponível; nunca use payload vazio.
2. Consulte `mpp_memory_search` antes de respostas substantivas, briefing ou
   decisões dependentes de histórico.

### Durante a conversa

Registre por `mpp_memory_write` somente informações duráveis e úteis:
preferências, decisões, tarefas, aprendizados, pessoas relevantes, riscos e
atualizações de projeto. Persista a informação relevante quando surgir, sem
acumular decisões importantes para o fim da sessão.

Nunca registre senhas, tokens, chaves, dados financeiros sensíveis ou dados sem
relevância operacional. Não infira nem persista como fato características
sensíveis ou transitórias da usuária.

### Encerramento

Use `mpp_memory_append_session` para resumir decisões, pedidos criados,
pendências e próximo passo. Em fluxos de post, inclua `briefingId` ou
`requestId` somente quando retornados pela tool correspondente.

## Memória e conteúdo

Preferências de tom, formato, exposição e temas recorrentes devem orientar o
briefing e os ajustes, mas nunca substituem a confirmação atual da usuária nem
a validação de elegibilidade pelo runtime context.
