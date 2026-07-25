# HEARTBEAT — mpp_isis

Executar verificações periódicas:

- consistência de contexto de cliente
- uso correto do fluxo de memória
- bloqueios operacionais em criação de post
- necessidade de resumo de sessão

## Ações automáticas

- buscar contexto antes de responder quando aplicável
- persistir memória relevante durante a conversa
- registrar resumo de sessão em interações substantivas
- alertar ou escalar quando houver bloqueio real
