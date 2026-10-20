# core-customization

Loja de roupas e loja de tatuagem.

Estrutura e padrão de código do `core-pets-v2`: `Framework` como única camada
de adaptação com a base, módulos por domínio, `config/` documentado e o resto
do código só com separadores.

## Instalação

1. Copie a pasta para `resources/[core]/core-customization`.
2. Gere a interface e copie o resultado para `web/`:
   ```bash
   cd core-customization-front
   npm install && npm run build
   cp -r dist/* ../core-customization-openSource/web/
   ```
3. `ensure core-customization` depois de `vrp` e `oxmysql`.

## Armazenamento

Roupa e tatuagem são do personagem, então a gravação passa por dois ganchos —
e só por eles:

```lua
Framework.LoadOutfit(userId)                   -- { clothes = {...}, tattoos = {...} }
Framework.SaveOutfit(userId, clothes, tattoos) -- nil mantém o que já estava
```

`Customization.Storage.Mode` escolhe o corpo que vale:

| Modo | Onde grava | Quando usar |
| --- | --- | --- |
| `"character"` *(padrão)* | `core_characters`, pelos exports `GetOutfit`/`SetOutfit` do `core-character` | com o `core-character` no servidor |
| `"table"` | tabela própria, criada sozinha no primeiro start | sem o `core-character` |

No modo `"character"` o resource **não tem tabela e não toca em SQL**: a linha
do personagem é a única cópia, o que é justamente o que permite a seleção
montar o preview de cada slot sem consultar daqui.

No modo `"table"`, os nomes de tabela e coluna saem do config:

```lua
Customization.Storage = {
    Mode  = "table",
    Table = "core_customization",
    Columns = { Passport = "citizenid", Clothes = "clothes", Tattoos = "tattoos" },
}
```

Isso também serve para apontar para a tabela que o **seu** criador de
personagem já lê, desde que as colunas guardem JSON no formato daqui. Se o
formato for outro, troque o corpo de `LoadOutfit`/`SaveOutfit` em
`server/framework.lua` — é para isso que elas existem, e nada no resto do
resource muda.

## Organização

```
config/
  config.lua       comandos, cores, features, lojas, câmera, imagens
  clothes.lua      peças, roupa inicial e bloqueios
  tattoos.lua      zonas, roupa da cabine e catálogo por sexo
  language.lua     textos (Locale + L())
  webhooks.lua     logs de Discord

shared/
  clothes.lua      faixas escondidas, bloqueios e índice padrão de cada peça

client/
  framework.lua    ganchos: hud, animações, modelo, interação
  modules/
    common.lua     estado, validações, tema, notificação
    camera.lua     enquadramentos, FOV e rotação (lerp)
    clothes.lua    veste o ped, comandos de peça e API pública
    tattoos.lua    decorações do ped
    scene.lua      cenário compartilhado pelas duas lojas
    skinshop.lua   fluxo da loja de roupas
    tattooshop.lua fluxo da loja de tatuagem
    nui.lua        NUIActionHandlers e ponte com a interface
    catalog.lua    mede modelos e texturas dos dois peds
  client.lua       pontos de interação, exports e parada do resource

server/
  framework.lua    adaptação vRP: identidade, permissões, VIP e gravação
  modules/
    common.lua     log e cache de nomes
    outfit.lua     leitura, gravação, sanitização e catálogo da loja
    clothes.lua    abertura, gravação e comandos de peça
    tattoos.lua    abertura e gravação
  server.lua       despacho de ações, comandos e exports
```

## Adaptação

Tudo que fala com a base está em `client/framework.lua` e
`server/framework.lua`. Adapte **só o corpo** das funções — nenhum módulo
chama a base diretamente.

Ganchos que provavelmente precisam de atenção:

| Função | Papel |
| --- | --- |
| `Framework.CanCustomize` | algemado, preso, procurado ou em coma não troca de roupa |
| `Framework.HasPremium` | grupo de `Customization.PremiumGroup` |
| `Framework.ItemAmount` | item da mochila que libera os comandos de peça |
| `Framework.HasService` | polícia e resgate **de serviço**, para tirar props de terceiros |
| `Framework.Model` | modelo vestido; decide qual catálogo vale |
| `Framework.LoadOutfit` | lê a roupa e a tatuagem; ver Armazenamento |
| `Framework.SaveOutfit` | grava a roupa e a tatuagem; ver Armazenamento |
| `Framework.CreateShopPoint` | marcador + E; troque pelo seu sistema de interação |
| `Framework.PlayAnim` | animação de vestir/tirar |

## Fluxo

```
onClientResourceStart
  └─ mede os dois modelos (peças e texturas) → interface → unlock
                                                             │
interação / comando ──► servidor valida ─────────────────────┴─► loja abre
                                                                    │
                  cada ajuste ──► updatePreview ──► veste o ped     │
                                                                    │
        salvar ──► servidor filtra e grava (Customization.Storage)
        sair   ──► client devolve o que estava no ped ao abrir
```

O catálogo é medido **no cliente**: quantos modelos e texturas cada peça tem
depende das DLCs instaladas, então não dá para deixar em config.

## Segurança

- Todo `action` da NUI passa por `Handlers` no servidor, que só roda com
  `Passport` resolvido.
- Abrir qualquer loja passa por `Framework.CanCustomize`: algemado, preso,
  procurado ou em coma não abre.
- O que é gravado passa por um filtro **de forma, não de conteúdo**:
  `SanitizeClothes` aceita as peças de `config/clothes.lua` com item e textura
  inteiros, e `SanitizeTattoos` aceita qualquer `{ nome, coleção }` de texto.
  Nenhum índice é conferido contra catálogo — roupa e tatuagem de addon vivem
  fora da faixa do jogo base, e um teto aqui apagaria o visual ao salvar.
- Os comandos de peça revalidam o item da mochila e o VIP no servidor.
- Os comandos administrativos conferem grupo e nível em `Customization.AdminLevels`.

## Exports

### Servidor

| Export | Retorno |
| --- | --- |
| `GetOutfit(passport)` | `{ clothes, tattoos }` gravados |
| `SetOutfit(passport, clothes, tattoos)` | grava e veste; `nil` no que não muda |
| `OpenClothesShop(passport)` | abre a loja de roupas |
| `OpenTattooShop(passport)` | abre a loja de tatuagem |
| `LockClothes(passport, state)` | trava as trocas enquanto de uniforme |

### Cliente

| Export | Retorno |
| --- | --- |
| `IsDefaultPart(passport, part)` | server: a peça está no padrão, ou seja, o jogador não usa nenhuma |
| `GetClothes()` | `{ [peça] = { item, texture } }` |
| `GetTattoos()` | `{ [nome] = { coleção } }` |
| `ChangePart(part, item, texture, save)` | troca uma peça com animação |
| `TogglePart(part, put, otherPed)` | tira/recoloca sem gravar |
| `ListParts()` | peças em uso, em ordem, para o inventário |
| `IsLocked()` | o jogador está de uniforme |
| `IsOpen()` | alguma loja aberta |

## Eventos

| Evento | Realm | Uso |
| --- | --- | --- |
| `core-customization:wearClothes` | client | veste um conjunto sem gravar |
| `core-customization:wearTattoos` | client | aplica tatuagens sem gravar |
| `core-customization:reloadClothes` | client | pede ao servidor o que está gravado |
| `core-customization:applyTemporary` | client | uniforme: veste e guarda o anterior |
| `core-customization:returnTemporary` | client | devolve a roupa de antes |
| `core-customization:overlayClothes` | client | sobrepõe peças ao que já está vestido |
| `core-customization:lockClothes` | client | trava/destrava as trocas |
| `core-customization:openCreator` | client | a criação de personagem abre a loja |
| `core-customization:addClothesShop` | client | acrescenta uma loja em runtime |
| `core-customization:addTattooShop` | client | acrescenta uma loja em runtime |
| `core-customization:setParts(parts)` | client | força peças e passa a lembrar delas, sem gravar |
| `core-customization:togglePart(part)` | client | tira se está vestindo, recoloca se não |
| `core-customization:requestClothes` | client | abre a loja de roupas de onde estiver |
| `core-customization:requestTattoos` | client | abre a loja de tatuagem de onde estiver |
| `core-customization:removeProps(parts)` | server | serviço tira props de quem está perto; aceita um nome ou uma lista |
| `core-character:finishedClothing` | client | disparado ao sair da loja vinda da criação |

## Comandos

| Comando | Quem usa |
| --- | --- |
| `/camisa 15 0` e a família de `Customization.PartCommands` | jogador com o item de roupas |
| `/skinshop` | administrador ou `Customization.PremiumGroup` |
| `/tattooshop` | administrador ou `Customization.PremiumGroup` |
| `/printpreset id` | administrador |

Trocar o modelo do ped é do `core-character` (`/skin`), não daqui: o modelo
manda no visual do personagem, e este resource só veste o que já existe.
