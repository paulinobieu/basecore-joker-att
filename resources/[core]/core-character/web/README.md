# core-character-front

NUI do `core-character` em React 18 + TypeScript + Vite + Tailwind + Zustand.

Reescrita da interface de referência (Vue 3 + PrimeVue) mantendo design e
comportamento, no padrão de código e organização do template React de NUI.

## Telas

| Tela | Rota | Arquivo |
| --- | --- | --- |
| Criação de personagem | `#/character` | [Character](src/views/pages/Character/index.tsx) |
| Barbearia | `#/barber` | [BarberShop](src/views/pages/BarberShop/index.tsx) |
| Seleção de personagem | `#/select` | [Select](src/views/pages/Select/index.tsx) |
| Seleção de spawn | `#/spawn` | [SelectSpawn](src/views/pages/SelectSpawn/index.tsx) |

## Estrutura

```
src/
├── app/                    lógica: nada de JSX
│   ├── constants/          contrato NUI, opções, menus, paletas, mapeamentos
│   ├── hooks/              mensagens NUI, câmera, menus, teclado
│   ├── mocks/              payloads de desenvolvimento no navegador
│   ├── router/
│   ├── stores/             zustand: Character, Config, Screen, Visibility, Toast, Confirm
│   └── utils/              fetchNui, cores, preview, conversão de importação
└── views/                  apresentação
    ├── components/ui/      primitivas (Panel, Button, Toggle, Slider, Dialog, ...)
    ├── components/creator/ cards de opção, painel lateral, câmera, importação
    ├── layout/
    ├── pages/
    └── styles/             reset, tokens e breakpoints — sem design system em CSS
```

O estilo vive nos componentes, em Tailwind + `cva`. O `index.css` guarda só
reset, scrollbar, breakpoints e os **tokens** (gradientes e superfícies) como
custom properties, expostos como utilitários no `tailwind.config.js`
(`bg-accent`, `bg-panel`, `bg-raise`, `text-ink-muted`, `shadow-glow`, ...).

## Contrato NUI

Definido em [callbacks.ts](src/app/constants/callbacks.ts) e implementado em
`core-character-openSource/client/modules/nui.lua`.

Segue o padrão dos resources Core: **um único** `RegisterNUICallback` com o
nome do resource, despachando pela chave `action`. No front isso é o
`nuiAction(action, data)` / `postNui(action, data)` de
[fetchNui.ts](src/app/utils/fetchNui.ts).

```
POST https://core-character/core-character
{ "action": "setGender", "gender": "mp_f_freemode_01" }
```

### client → NUI (`SendNUIMessage`)

O payload é sempre `{ action, payload }`.

| `action` | `payload` |
| --- | --- |
| `setup` | `{ colors, logo, palettes?, paths: { face }, config: { buyPerson, buyPersonPrice, eyesBarber } }` |
| `open` | `{ screen, hairs?, gender?, character?, slots?, locations?, admin? }` |
| `close` | — |
| `notify` | `{ severity, title, message?, duration? }` |
| `actionResult` | `{ ok, action?, err? }` |

`screen`: `character` \| `select` \| `spawn` \| `barber`.
`severity`: `success` \| `info` \| `warn` \| `error`.

### NUI → client (chave `action`)

| `action` | Dados | Quando |
| --- | --- | --- |
| `ready` | — | NUI montou; o client responde com `setup` |
| `unlock` | — | setup aplicado, telas liberadas |
| `close` | — | jogador pediu para fechar (Escape) |
| `setGender` | `{ gender }` | troca de modelo |
| `updateFace` | `{ config }` | preview de rosto |
| `updateSkin` | `{ config }` | preview de herança/pele |
| `updateHead` | `{ config }` | preview de cabelo, barba e sobreposições |
| `finishCharacter` | `{ name, lastname, gender }` | criar personagem |
| `rotateCharacter` | `{ side }` | teclas A/D |
| `setFov` | `{ fov }` | roda do mouse |
| `setHeading` | `{ angle }` | arrastar sobre a cena |
| `updateCamera` | `{ index, rotation, fov, cam, pose }` | painel de câmera; responde `{ fov }` ou `"ok"` |
| `selectCharacter` | `{ characterId }` | entrar com o personagem |
| `previewCharacter` | `{ characterId }` | trocar o ped em exibição |
| `createCharacter` | — | abrir o criador |
| `buySlot` | — | comprar slot |
| `previewLocation` | `{ hash }` | pré-visualizar spawn |
| `confirmSpawn` | `{ index }` | confirmar spawn |
| `saveBarber` | — | salvar alterações |
| `cancelBarber` | — | sair restaurando o backup do servidor |

Os três callbacks de preview mandam `config` como o mapa plano de atributos
(`{ noseWidth: 0.3, ... }`), conforme
[mappings.ts](src/app/constants/mappings.ts). Só o grupo afetado pela opção
alterada é reenviado, com uma janela de 50 ms para o arraste do slider não
virar um POST por frame.

## Desenvolvimento

```bash
npm install
npm run dev      # http://127.0.0.1:1904/?screen=character
npm run build    # gera dist/ para o web/ do resource
npm run lint
```

No navegador, `?screen=` emula a tela aberta: `character`, `select`, `spawn`
ou `barber`. Os payloads estão em [mocks](src/app/mocks/index.ts).

## Importação de personagem

O modal de importação aceita JSON dos criadores **Core**, **Guardian** e
**Nation** — este é o único ponto onde o nome Guardian permanece, porque
identifica o formato de origem. O mapa de tradução está em
[converterCharacter.ts](src/app/utils/converterCharacter.ts); chaves sem
equivalente são descartadas e uma chave desconhecida invalida o JSON inteiro.
