# Base Core aberta

Entrega com fontes Lua e web completos, sem autenticacao de licenca Core/Combo.
Os blocos de auth, seus timers e webhooks, os modulos de licenca da vRP e os
loaders obrigatorios do PL_PROTECT foram removidos. As permissoes de admin,
whitelist, identificacao dos jogadores e integracoes opcionais foram mantidas.

## Instalar

1. Importe database.sql em um banco MySQL/MariaDB.
2. Configure mysql_connection_string, sv_licenseKey (Cfx) e steam_webApiKey
   no server.cfg. A chave Steam e entregue vazia.
3. Instale os artifacts do FXServer em artifacts/, com FXServer.exe nessa pasta.
4. Instale os resources externos citados no cfg que sua cidade utiliza
   (smartphone, roupas, veiculos e mapas, por exemplo). Eles nao fazem parte
   desta entrega quando ausentes da pasta resources da base de origem.
5. Execute server.bat no Windows.

O catalogo em resources/[core-catalog] e opcional e nao inicia automaticamente.
As interfaces incluem os fontes e os builds disponiveis na base de origem.
Esta entrega nao substitui as chaves exigidas pelo FXServer e pela Steam.

## Atualizar a entrega

No repositorio de origem core-base:

```powershell
node tools/publish-open.mjs -m "feat: atualiza base aberta"
```
