# core-inventory

Recurso unico de inventario, bau e revista da Core Network.

## Arquivos editaveis

- `config/config.lua`: recursos habilitados, limites, pontos e modos dos baus.
- `config/shared.lua`: configuracoes compartilhadas herdadas do inventario.
- `config/language.lua`: textos exibidos ao jogador.
- `client/framework.lua`: integracoes client-side com HUD, notificacoes e interacao.
- `server/framework.lua`: integracoes server-side com framework, identidade e logs.

Esses arquivos estao em `escrow_ignore` no `fxmanifest.lua`. A logica interna fica
organizada em `client/modules` e `server/modules`, seguindo o padrao do
`core-character`.

## Compatibilidade

Os eventos publicos `inventory:*`, `chest:*` e `inspect:*` foram mantidos para os
outros recursos da base. A interface Tunnel interna e unica:
`core-inventory`.
