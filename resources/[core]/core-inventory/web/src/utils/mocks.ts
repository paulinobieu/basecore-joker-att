import type {
  IExternalInventory,
  ITradeSession,
  InventoryItems,
} from "@/types";

const IMAGE_BASE = "https://cdn.blacknetwork.com.br/black_inventory";

export const mockExternalSection: IExternalInventory = {
  label: "Baú da residência",
  description: "Armazenamento compartilhado da residência.",
  slot: 30,
  canUpgrade: true,
};

export const mockExternalItems: InventoryItems = {
  "1": {
    item: "water",
    peso: 0.5,
    name: "Água",
    amount: 4,
    type: "usavel",
    image: `${IMAGE_BASE}/water.png`,
  },
  "2": {
    item: "apple",
    peso: 0.2,
    name: "Maçã",
    amount: 6,
    type: "usavel",
    image: `${IMAGE_BASE}/apple.png`,
  },
};

export const mockTradeSession: ITradeSession = {
  partnerName: "Pessoa próxima",
  slots: 10,
  // a negociação começa vazia dos dois lados, como em jogo
  partner: {
    items: {},
    money: 0,
    confirmed: false,
  },
  self: {
    items: {},
    money: 0,
    confirmed: false,
  },
};
