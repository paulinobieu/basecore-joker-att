# Kush Inventory NUI

Interface de inventário do FiveM construída com React, TypeScript, Vite, Tailwind CSS, Zustand e `@dnd-kit`.

## Desenvolvimento

```bash
npm install
npm run dev
```

O modo de navegador usa os eventos simulados de `src/main.tsx`. No FiveM, a interface recebe mensagens com estas ações:

- `setVisibility`
- `setProfile`
- `setInventory`
- `updateBackpack`
- `setContainer`
- `setGroundSection`
- `updateDrop`
- `setChestUpgrade`

As ações enviadas da interface para o resource são:

- `useItem`
- `sendItem`
- `dropItem`
- `updateSlot`
- `updateGroundSlot`
- `pickupItem`
- `moveContainerItem`
- `closeContainer`
- `requestChestUpgrade`
- `confirmChestUpgrade`
- `removeFocus`

## Contrato dos callbacks

Os nomes dos callbacks foram mantidos para preservar a integração existente. A NUI envia somente os campos abaixo:

| Callback              | Payload                                                          |
| --------------------- | ---------------------------------------------------------------- |
| `useItem`             | `{ section?, slot, amount }`                                     |
| `sendItem`            | `{ section?, slot, amount }` ou `{ slot, target, amount, item }` |
| `dropItem`            | `{ section?, slot, amount }`                                     |
| `updateSlot`          | `{ slot, target, amount, item }`                                 |
| `updateGroundSlot`    | `{ slot, target, amount, item }`                                 |
| `pickupItem`          | `{ slot, target, amount, item }`                                 |
| `moveContainerItem`   | `{ fromSection, fromSlot, toSection, toSlot, amount }`           |
| `closeContainer`      | `{}`                                                             |
| `requestChestUpgrade` | `{}`                                                             |
| `confirmChestUpgrade` | `{}`                                                             |
| `removeFocus`         | `{}`                                                             |

O campo `item` de `updateSlot` foi mantido apenas por compatibilidade. O client/server Lua deve resolver o item real pelo slot e nunca confiar nesse valor recebido da NUI.

`setContainer` recebe `null` para fechar ou `{ title, description, slots, items }` para abrir um recipiente secundário. `title` e `description` são sempre definidos pelo back-end; a NUI não associa o painel a um tipo específico, permitindo reutilizá-lo para lancheiras, caixas, porta-malas e outros recipientes. O servidor deve manter o recipiente ativo associado ao `Passport`; `moveContainerItem` informa apenas a intenção de mover entre `inventory` e `container`, sem enviar identificador de dono ou recipiente como autoridade.

Baús e revistas reutilizam o contrato do front de referência. `setGroundSection` abre o inventário externo com `{ label, slot, description?, weight?, maxWeight? }`, enquanto `updateDrop` envia os itens indexados pelo slot. Para compatibilidade, o peso também pode continuar vindo em `setProfile` pelos campos `chestWeight` e `chestMaxWeight`. O mesmo painel atende baú e revista: o contexto real permanece exclusivamente no servidor.

As transferências do inventário para o painel externo usam `sendItem`; o caminho inverso usa `pickupItem`; e a organização interna usa `updateGroundSlot`. Nesses três callbacks, `slot`, `target`, `amount` e `item` mantêm o formato antigo. `item` é apenas compatibilidade e nunca deve ser tratado como autoridade pelo servidor.

Quando `setGroundSection` recebe `canUpgrade: true`, o painel exibe a ação de melhoria. Ao clicar, a NUI envia `requestChestUpgrade` sem parâmetros; o back-end deve responder enviando `setChestUpgrade` com `{ title, description, price, currency, currentCapacity?, nextCapacity?, capacityUnit?, confirmLabel?, cancelLabel? }`. O valor `null` fecha o modal.

Ao confirmar, a NUI envia somente `confirmChestUpgrade: {}`. O servidor deve recuperar o baú ativo associado ao `Passport`, recalcular nível, capacidade e preço, validar permissão, distância, saldo e estado atual, aplicar lock contra chamadas concorrentes e realizar cobrança e upgrade atomicamente. Preço e capacidade exibidos no modal são informativos e nunca devem ser aceitos de volta como autoridade.

Todo `RegisterNUICallback` deve responder `cb` em sucesso e falha. Operações de inventário precisam ser revalidadas no servidor: `source` para `Passport`, slots existentes e liberados, quantidade inteira e positiva, posse atual, limites/peso, distância e alvo no envio, além de lock ou rate limit por personagem. Após qualquer mutação, o servidor deve reenviar `updateBackpack` como estado autoritativo.

As requisições da NUI expiram após oito segundos para não manter promessas pendentes quando algum callback deixa de responder.

## Validação e build

```bash
npm run lint
npm run format:check
npm run build
```

O Vite gera o pacote de produção em `build/`, usando caminhos relativos compatíveis com a NUI do FiveM.
