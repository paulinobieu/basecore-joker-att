import type {
  IContainerInventory,
  IChestUpgradeQuote,
  IExternalInventory,
  IInventory,
  InventoryItems,
  IItem,
  IProfile,
  ITradeSession,
} from "@/types";

import { create } from "zustand";

interface IItemData {
  item: InventoryItems;
  set: (
    item: InventoryItems | ((prev: InventoryItems) => InventoryItems),
  ) => void;
}

export const useItem = create<IItemData>((set) => ({
  item: {},
  set: (itemOrFunction) => {
    if (typeof itemOrFunction === "function") {
      set((state) => ({ item: itemOrFunction(state.item) }));
    } else {
      set({ item: itemOrFunction });
    }
  },
}));

interface IProfileData {
  current: IProfile;
  set: (current: IProfile) => void;
}

export const useProfile = create<IProfileData>((set) => ({
  current: {
    image: "",
    name: "",
    id: 0,
    vip: {
      time: 0,
      current: "",
    },
    gens: 0,
    weight: 0,
    maxWeight: 100,
  },
  set: (current) => set({ current }),
}));

interface InventoryFrame {
  current: IInventory;
  set: (current: IInventory) => void;
}

export const useInventory = create<InventoryFrame>((set) => ({
  current: {
    slot: 0,
    unlockedSlots: 20,
    maxSlots: 45,
    accent: "#dc1553",
    shop: "",
    vip: false,
  },
  set: (current) => set({ current }),
}));

interface ContainerInventoryFrame {
  current: IContainerInventory | null;
  set: (current: IContainerInventory | null) => void;
}

export const useContainerInventory = create<ContainerInventoryFrame>((set) => ({
  current: null,
  set: (current) => set({ current }),
}));

export const useGroundItem = create<IItemData>((set) => ({
  item: {},
  set: (itemOrFunction) => {
    if (typeof itemOrFunction === "function") {
      set((state) => ({ item: itemOrFunction(state.item) }));
    } else {
      set({ item: itemOrFunction });
    }
  },
}));

interface ExternalInventoryFrame {
  current: IExternalInventory | null;
  set: (current: IExternalInventory | null) => void;
}

export const useGroundSection = create<ExternalInventoryFrame>((set) => ({
  current: null,
  set: (current) => set({ current }),
}));

interface TradeFrame {
  current: ITradeSession | null;
  set: (current: ITradeSession | null) => void;
}

export const useTrade = create<TradeFrame>((set) => ({
  current: null,
  set: (current) => set({ current }),
}));

export interface ItemMenuTarget {
  /** id do slot, no formato "<seção>-<slot>" */
  id: string;
  item: IItem;
  x: number;
  y: number;
}

interface ItemMenuFrame {
  current: ItemMenuTarget | null;
  open: (target: ItemMenuTarget) => void;
  close: () => void;
}

export const useItemMenu = create<ItemMenuFrame>((set) => ({
  current: null,
  open: (target) => set({ current: target }),
  close: () => set({ current: null }),
}));

interface ItemTooltipFrame {
  /** id do slot dono da tooltip aberta, no formato "<seção>-<slot>" */
  current: string | null;
  open: (id: string) => void;
  /** só fecha se a tooltip ainda for daquele slot */
  close: (id: string) => void;
}

/**
 * A tooltip é única na tela: guardar o dono aqui faz o slot novo apagar o
 * anterior, em vez de os dois se sobreporem enquanto o antigo expira.
 */
export const useItemTooltip = create<ItemTooltipFrame>((set) => ({
  current: null,
  open: (id) => set({ current: id }),
  close: (id) =>
    set((state) => (state.current === id ? { current: null } : state)),
}));

interface ChestUpgradeFrame {
  current: IChestUpgradeQuote | null;
  set: (current: IChestUpgradeQuote | null) => void;
}

export const useChestUpgrade = create<ChestUpgradeFrame>((set) => ({
  current: null,
  set: (current) => set({ current }),
}));
