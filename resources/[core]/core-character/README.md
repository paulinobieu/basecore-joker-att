# core-character

Seleção, criação e edição de personagem, barbearia e escolha de spawn.

Estrutura e padrão de código do `core-pets-v2`: `Framework` como única camada
de adaptação com a base, módulos por domínio, `config/` documentado e o resto
do código só com separadores.

## Instalação

1. Copie a pasta para `resources/[core]/core-character`.
2. Gere a interface e copie o resultado para `web/`:
   ```bash
   cd core-character-front
   npm install && npm run build
   cp -r dist/* ../core-character-openSource/web/
   ```
3. `ensure core-character` depois de `vrp` e `oxmysql`.

A tabela `core_characters` é criada sozinha no primeiro start. Ela é do
resource e guarda modelo, visual, roupa e tatuagem por personagem:

```sql
CREATE TABLE IF NOT EXISTS `core_characters` (
  `id`         INT(11) NOT NULL AUTO_INCREMENT,
  `identifier` VARCHAR(255) NOT NULL,   -- license da conta
  `citizenid`  VARCHAR(255) NOT NULL,   -- id do personagem
  `model`      VARCHAR(50)  NOT NULL DEFAULT 'mp_m_freemode_01',
  `chardata`   TEXT NOT NULL,           -- visual
  `clothes`    TEXT NOT NULL,
  `tattoos`    TEXT NOT NULL,
  `reset`      TINYINT(1) NOT NULL DEFAULT 1,
  `deleted`    TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_citizenid` (`citizenid`),
  INDEX `idx_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

Esta tabela é a **única** cópia do personagem: o resource escreve `model` e
`chardata`, e o `core-customization` lê e escreve `clothes` e `tattoos` pelos
exports `GetOutfit`/`SetOutfit`. É o que permite a seleção montar o preview de
cada slot sem consultar outro sistema.

As tabelas de **conta e personagem da base** (`characters`, `accounts`) não são
tocadas diretamente: todo acesso passa por `Framework`.

## Organização

```
config/
  config.lua       comandos, cores, features, slots, cenário, spawn, barbearia
  appearance.lua   sobreposições e cabelos escondidos, roupas, poses, cutscene
  language.lua     textos (Locale + L())
  webhooks.lua     logs de Discord

client/
  framework.lua    ganchos: hud, skin, roupas, tatuagens, pose, interação
  modules/
    common.lua     estado, validações, tema, helpers
    camera.lua     câmeras do criador, FOV e rotação (lerp)
    appearance.lua aplica herança, rosto e cabeça no ped
    cutscene.lua   cutscene de chegada
    creator.lua    fluxo de criação
    barber.lua     fluxo da barbearia
    select.lua     cena e fluxo da seleção
    spawn.lua      cartões e câmera da escolha de local
    nui.lua        NUIActionHandlers e ponte com a interface
  client.lua       fumaça do cenário, exports e parada do resource

server/
  framework.lua    adaptação vRP: identidade, grupos, banco, personagem, moeda
  modules/
    common.lua     validações, mensagens, log, cache de nomes
    database.lua   tabela core_characters, cache e teto de slots
    appearance.lua lista de cabelos (GlobalState) e sanitização do visual
    characters.lua slots, seleção, criação e compra de slot
    creator.lua    routing bucket, gravação e barbearia
  server.lua       despacho de ações, comandos e exports
```

## Adaptação

Tudo que fala com a base está em `client/framework.lua` e
`server/framework.lua`. Adapte **só o corpo** das funções — nenhum módulo
chama a base diretamente.

Ganchos que provavelmente precisam de atenção:

| Função | Papel |
| --- | --- |
| `Framework.CountCharacters` | quantos personagens a conta tem |
| `Framework.ListCharacters` | lista `{ id, name }` da conta |
| `Framework.AccountSlots` | slots a que a conta tem direito |
| `Framework.AddAccountSlot` | soma um slot na compra |
| `Framework.CreateCharacter` | cria o personagem na base e devolve o id |
| `Framework.SaveIdentity` | grava nome, sobrenome e sexo |
| `Framework.LastPosition` | última posição, para o primeiro cartão do spawn |
| `Framework.CharacterChosen` | entra no personagem escolhido |
| `Framework.SkinCharacter` | persiste o modelo (sexo) |
| `Framework.SpawnPoints` | casas e bases que aparecem na tela de spawn |
| `Framework.OnCharacterCreated` | ponto para itens iniciais, registros, etc. |
| `Framework.OnCharacterSpawned` | jogador entrou no mundo |
| `Framework.CreateBarberPoint` | marcador + E; troque pelo seu sistema de interação |
| `Framework.OpenClothing` | loja de roupas, com `Features.Clothing` ligado |

## Fluxo

```
onClientResourceStart
  └─ mede as variações de cabelo dos dois modelos → GlobalState
  └─ requestSelect ─────────────► servidor monta os slots
                                    │
              sem personagem ───────┴─► cria um e entra no criador
              com personagem ─────────► tela de seleção

criador → finishCharacter → servidor valida, grava e responde
  └─ loja de roupas (opcional, devolve por core-character:finishedClothing)
       └─ cutscene (opcional) → tela de spawn (opcional) → mundo
```

As etapas opcionais são ligadas em `Character.Features`. Com todas
desligadas, o jogador cai direto em `Character.SpawnCoords`.

## Segurança

- Todo `action` da NUI passa por `Handlers` no servidor, que só roda com
  `Passport` resolvido e banco pronto.
- O id de personagem enviado pela interface é conferido contra os slots que
  **aquele source** recebeu (`OwnsCharacter`).
- Criar personagem e comprar slot revalidam o limite da conta no banco.
- O visual passa por um filtro **de forma, não de conteúdo**:
  `SanitizeAppearance` aceita as chaves de `Appearance.Default` como número,
  sem teto de valor. Cabelo, cor e sobreposição de addon vivem fora da faixa do
  jogo base, e um limite aqui apagaria o visual ao gravar.
- O preview enviado à interface é recortado: a `license` da conta nunca sai
  do servidor.
- Cancelar na barbearia restaura o backup guardado **no servidor**, nunca o
  que a NUI mandar.
- Nome e sobrenome são revalidados no servidor com a mesma regra da interface.

## Exports

### Servidor

| Export | Retorno |
| --- | --- |
| `OpenBarber(passport)` | abre a barbearia |
| `OpenCreator(passport)` | reabre a criação para editar o visual |
| `OpenSpawnScreen(passport)` | abre a escolha de local |
| `GetAppearance(passport)` | visual salvo, já sanitizado |
| `SetAppearance(passport, appearance)` | grava e aplica no jogador |
| `GetOutfit(passport)` | `{ clothes, tattoos }` gravados |
| `SetOutfit(passport, clothes, tattoos)` | grava; `nil` no que não muda |
| `NeedsCreator(passport)` | personagem ainda não passou pelo criador |
| `DeleteCharacter(passport)` | marca a linha como apagada |
| `GetSlots(source)` | `{ used, total }` da conta |

### Cliente

| Export | Retorno |
| --- | --- |
| `OpenBarber()` | pede a barbearia ao servidor |
| `IsOpen()` | alguma tela aberta |
| `CurrentScreen()` | `character` \| `select` \| `spawn` \| `barber` |
| `GetAppearance()` | visual em edição |
| `ApplyAppearance(appearance)` | aplica no ped local |

## Comandos

| Comando | Nível | Uso |
| --- | --- | --- |
| `/barbearia` | `AdminLevels.Barber` | abre a barbearia |
| `/skin id mp_m_freemode_01` | `AdminLevels.Model` | troca o modelo do ped |
| `/newchar [id]` | `AdminLevels.Create` | cria um personagem novo |
| `/resetchar [id]` | `AdminLevels.Reset` | devolve o personagem ao criador |

`/resetchar` reabre a criação na hora, com o visual atual já carregado e sem
mexer no banco: o personagem continua o mesmo, e nome, sexo e visual só mudam
quando o jogador confirma. Sem `id`, vale para quem digitou. Depois de
confirmar, o fluxo segue igual ao de um personagem novo — loja de roupas (se
`Features.Clothing`) e escolha de spawn (se `Features.SelectSpawn`) — só que
mantendo a roupa que ele já tinha em vez de vestir a inicial.

## Eventos

| Evento | Realm | Uso |
| --- | --- | --- |
| `core-character:addBarber` | client | acrescenta um ponto de barbearia em runtime |
| `core-character:applyAppearance` | client | aplica um visual vindo do servidor |
| `core-character:finishedClothing` | client | a loja de roupas devolveu o jogador |
| `core-character:applySkin` | client | troca o modelo do ped e reaplica visual e roupa |
| `core-character:insertPlayer` | server | personagem criado; nada escuta por padrão |
| `core-character:playerSpawned` | server | jogador entrou no mundo; nada escuta por padrão |

Os dois eventos de servidor são ganchos vazios, para você pendurar o que
precisar. Os itens iniciais não passam por eles: quem entrega é a base, no
`Framework.CharacterChosen`.
