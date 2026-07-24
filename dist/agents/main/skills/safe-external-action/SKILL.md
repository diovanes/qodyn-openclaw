---
name: safe-external-action
description: Controla ações externas, destrutivas, irreversíveis ou capazes de gerar duplicidade.
---

# Ação externa segura

## Antes de executar

1. Identifique ação, destino e conteúdo.
2. Confirme autorização.
3. Solicite confirmação quando houver efeito externo relevante.
4. Verifique idempotência quando disponível.

## Resultado

- `CONFIRMED_SUCCESS`
- `CONFIRMED_FAILURE`
- `AMBIGUOUS`

Nunca repita automaticamente uma ação `AMBIGUOUS`.
