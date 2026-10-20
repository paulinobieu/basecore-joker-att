export interface NuiMessageDataFrame<T = unknown> {
  action: string;
  data: T;
}

export interface NuiDebugEventFrame {
  action: string;
  data: unknown;
}

export interface IItem {
  id?: string;
  key?: string;
  item: string;
  peso: number;
  name: string;
  amount: number;
  maxAmount?: number | string;
  remaningUse?: number | string;
  image: string;
  description?: string;
  days?: number;
  durability?: number;
  type: string;
  serial?: string;
  /** munição carregada; presente apenas em armas */
  ammo?: number;
  /** acessórios instalados; chave é o item do acessório */
  attachs?: Record<string, boolean>;
  /** os mesmos acessórios já traduzidos para o nome de exibição */
  attachNames?: string[];
}

export type InventoryItems = Record<string, IItem | undefined>;
export type InventorySection = "inventory" | "container" | "ground";
export type ContainerSection = Exclude<InventorySection, "ground">;

export interface IProfile {
  image: string;
  name: string;
  id: number;
  vip?: {
    time: number;
    current: string;
  };
  gens?: number;
  weight: number;
  maxWeight: number;
  chestWeight?: number;
  chestMaxWeight?: number;
}

export interface IInventory {
  slot: number;
  unlockedSlots?: number;
  maxSlots?: number;
  accent?: string;
  shop: string;
  vip?: boolean;
}

export interface IContainerInventory {
  title: string;
  description: string;
  slots: number;
  items: InventoryItems;
}

export interface IExternalInventory {
  label: string;
  slot: number;
  description?: string;
  weight?: number;
  maxWeight?: number;
  canUpgrade?: boolean;
  /** painel é a lista de drops do chão, não um contêiner com slots fixos */
  drops?: boolean;
}

export interface ITradeOffer {
  items: InventoryItems;
  money: number;
  confirmed: boolean;
}

export interface ITradeSession {
  partnerName: string;
  partnerImage?: string;
  /** slots disponíveis em cada uma das duas ofertas */
  slots: number;
  partner: ITradeOffer;
  self: ITradeOffer;
}

export interface IChestUpgradeQuote {
  title: string;
  description: string;
  price: number;
  currency: string;
  currentCapacity?: number;
  nextCapacity?: number;
  capacityUnit?: string;
  confirmLabel?: string;
  cancelLabel?: string;
}

interface ItemActionPayload {
  section?: InventorySection;
  slot: string | number;
  amount: number;
}

interface ExternalMovePayload {
  slot: string;
  target: string;
  amount: number;
  item: string;
}

export interface NuiCallbackPayloadMap {
  useItem: ItemActionPayload;
  sendItem: ItemActionPayload | ExternalMovePayload;
  dropItem: ItemActionPayload;
  updateSlot: {
    slot: string;
    target: string;
    amount: number;
    item: string;
  };
  updateGroundSlot: ExternalMovePayload;
  pickupItem: ExternalMovePayload;
  moveContainerItem: {
    fromSection: ContainerSection;
    fromSlot: string;
    toSection: ContainerSection;
    toSlot: string;
    amount: number;
  };
  unloadWeapon: ItemActionPayload;
  detachWeapon: ItemActionPayload;
  reloadWeapon: {
    slot: string;
    target: string;
    amount: number;
  };
  attachWeapon: {
    slot: string;
    target: string;
  };
  closeContainer: Record<string, never>;
  emptyContainer: Record<string, never>;
  requestChestUpgrade: Record<string, never>;
  confirmChestUpgrade: Record<string, never>;
  offerTradeItem: {
    slot: string | number;
    amount: number;
  };
  withdrawTradeItem: {
    slot: string | number;
  };
  setTradeMoney: {
    amount: number;
  };
  confirmTrade: Record<string, never>;
  cancelTrade: Record<string, never>;
  removeFocus: Record<string, never>;
}

export type NuiCallbackName = keyof NuiCallbackPayloadMap;

export interface NuiInboundPayloadMap {
  setVisibility: boolean;
  setProfile: IProfile;
  setInventory: IInventory;
  updateBackpack: InventoryItems;
  setContainer: IContainerInventory | null;
  setGroundSection: IExternalInventory | null;
  updateDrop: InventoryItems;
  setChestUpgrade: IChestUpgradeQuote | null;
  setTrade: ITradeSession | null;
}

export type NuiInboundAction = keyof NuiInboundPayloadMap;
