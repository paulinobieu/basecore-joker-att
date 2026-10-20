# core-customization-front

Interface das lojas de roupa e de tatuagem: React 18, Vite, Tailwind e
Zustand, no mesmo padrão de código e organização do template React.

Não existe folha de estilo de design system. As superfícies e os
gradientes vivem em custom properties (`src/views/styles/index.css`),
o `tailwind.config.js` expõe cada uma como utilitário (`bg-panel`,
`bg-accent`, `shadow-glow`, …) e as primitivas visuais são componentes
em `src/views/components/ui`.

## Rodar

```bash
npm install
npm run dev     # http://127.0.0.1:1905
npm run build   # dist/ -> web/ do resource
npm run lint
```

No navegador a loja é escolhida por query string, e os dados vêm dos
mocks em `src/app/mocks`:

```
http://127.0.0.1:1905/?screen=clothes
http://127.0.0.1:1905/?screen=tattoos
```

## Organização

```
src/app/
  constants/
    callbacks.ts   ACTIONS (NUI -> client) e MESSAGES (client -> NUI)
    clothes.ts     regiões, peças e limites padrão
    tattoos.ts     zonas do corpo
    icons.ts       nome de ícone do client -> componente
  hooks/
    useLayout.ts       ponte entre as mensagens do client e as stores
    useClothesItem.ts  navegação da peça em edição
    useSceneCamera.ts  arrasto, roda e A/D sobre a cena
    useStoreExit.ts    salvar, sair e Escape
    useNuiMessage.ts   assinatura de uma mensagem do client
    useKeyPress.ts     atalho de tecla
  stores/            Clothes, Tattoos, Textures, Config, Screen,
                     Toast, Confirm, Visibility
  utils/             colors, fetchNui, updateClient, debugData, ...

src/views/
  components/ui/             primitivas (Panel, Toggle, Input, Rail, ...)
  components/customization/  ItemRail, ZoneRail, StepperMenu, ItemGrid,
                             TattooGrid, CameraPanel, StoreActions
  components/icons/          ícones que o Tabler não cobre
  pages/Clothes  pages/Tattoos
  layout/                    visibilidade, logo, toasts, tooltip
```

## Contrato NUI

O resource expõe **um callback só**, com o nome dele, e despacha pela
chave `action`:

```lua
RegisterNUICallback("core-customization", function(data, cb)
    -- data.action + o resto do payload
end)
```

### NUI -> client (`ACTIONS`)

| Ação | Payload | Uso |
| --- | --- | --- |
| `ready` | — | NUI montada; o client responde com `setup` |
| `unlock` | — | catálogo recebido; libera abrir as lojas |
| `updatePreview` | `{ config }` | veste o preview no ped |
| `applyClothes` | — | salva a roupa e fecha |
| `cancelClothes` | — | devolve a roupa anterior e fecha |
| `toggleTattoo` | `{ zone, index }` | aplica ou remove a tatuagem |
| `applyTattoos` | — | salva as tatuagens e fecha |
| `cancelTattoos` | — | devolve as tatuagens anteriores e fecha |
| `rotateCharacter` | `{ side }` | `left` \| `right` (teclas D e A) |
| `setFov` | `{ fov }` | roda do mouse sobre a cena |
| `setHeading` | `{ angle }` | arrasto sobre a cena |
| `updateCamera` | `{ index, rotation, fov, cam, pose }` | painel de câmera |

`updatePreview` manda só o que o client precisa para vestir o ped:

```json
{ "config": { "tshirt": { "item": 15, "texture": 0 }, "pants": { ... } } }
```

`updateCamera` com `index = "cam"` pode responder `{ fov }`; qualquer
outra resposta é ignorada.

### client -> NUI (`MESSAGES`)

`SendNUIMessage({ action = "...", payload = {...} })`.

| Mensagem | Payload |
| --- | --- |
| `setup` | `{ colors, logo }` |
| `textures` | `{ Male = {...}, Female = {...} }` |
| `open` | `{ screen, pedType, admin, clothes, tattoos }` |
| `close` | — |
| `notify` | `{ severity, title, message, duration }` |

`textures` é o catálogo medido no boot do client, vestindo os dois
modelos. Enquanto ele não chega, a loja não abre: a grade e o contador
de texturas leem daqui.

```json
{ "Male": { "tshirt": { "0": { "image": "...", "max": 12 } } } }
```

`open` leva o que a loja daquele ponto oferece:

```json
{
  "screen": "clothes",
  "pedType": "Male",
  "admin": false,
  "clothes": { "head": { "hat": { "item": -1, "texture": 0, "negative": true,
                                  "infos": { "maxItem": 193, "icon": "chapeu",
                                             "name": "CHAPÉU" } } } },
  "tattoos": { "available": { "rightarm": [ { "name": "...", "part": "...",
                                              "link": "..." } ] },
               "active": ["FM_Tat_M_001"] }
}
```

## Atalhos

| Tecla | Efeito |
| --- | --- |
| ← → | modelo anterior / próximo |
| ↑ ↓ | recua / avança uma linha da grade (3 modelos) |
| Enter | próxima textura |
| A D | gira o personagem |
| 1–4 | posição predefinida da câmera |
| Esc | sai sem salvar (admin sai direto, sem confirmação) |

Roda do mouse e arrasto valem sobre a área da cena, à direita do painel.
