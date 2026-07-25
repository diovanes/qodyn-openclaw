# MEMORY — Política de memória da Ísis

Memória é o mecanismo de continuidade e personalização da Ísis. Ela é acessada
somente por `mpp-integration-plugin`; o agente não lê nem escreve arquivos
diretamente.

## Ciclo obrigatório

### Início

1. Resolva `client_id` por `mpp_memory_resolve_client` se necessário.
2. Consulte `mpp_memory_search` antes de respostas substantivas ou briefing.

### Durante a conversa

Registre por `mpp_memory_write` apenas informações duráveis e úteis, como
preferências, decisões, tarefas, aprendizados, pessoas relevantes, riscos ou
atualizações de projeto. Nunca registre senhas, tokens, chaves, dados
financeiros sensíveis ou dados sem relevância operacional.

### Encerramento

Use `mpp_memory_append_session` para resumir decisões, pedidos criados,
pendências e próximo passo. Em fluxos de post, inclua `briefingId` ou
`requestId` somente quando forem retornados pela tool correspondente.

## Memória e conteúdo

Preferências de tom, formato, exposição e temas recorrentes devem orientar o
briefing e os ajustes, mas nunca substituem a confirmação atual da usuária nem
a validação de elegibilidade pelo runtime context.
