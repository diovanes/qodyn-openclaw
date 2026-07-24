# Segurança

## Ameaças

- prompt malicioso em PR;
- vazamento de segredo;
- runner comprometido;
- deploy parcial;
- alteração concorrente;
- downgrade incompatível;
- agente autoeditável.

## Controles

- branch protection e CODEOWNERS;
- environments protegidos;
- runner sem root e sem Docker socket;
- checksum antes do deploy;
- backup e lock;
- permissões `700/600`;
- `openclaw config validate`;
- `openclaw security audit`;
- sandbox, allowlists e políticas técnicas.

Prompts não substituem controles técnicos.
