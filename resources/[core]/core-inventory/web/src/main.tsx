import "@/style/global.css";

import lunchboxImage from "@/assets/lunchbox.svg";
import {
  Debugger,
  dispatchNuiDebugEvent,
  NUI_DEBUG_CALLBACK_EVENT,
  type NuiDebugCallbackFrame,
} from "@/utils/debugger";
import { Interface } from "@/components/Interface";
import { StrictMode } from "react";
import ReactDOM from "react-dom/client";
import { VisibilityProvider } from "@/providers/Visibility";
import { useContainerInventory, useItem, useTrade } from "@/stores/useNui";
import { mockExternalItems, mockExternalSection } from "@/utils/mocks";
import type {
  IChestUpgradeQuote,
  IContainerInventory,
  InventoryItems,
  InventorySection,
  NuiCallbackPayloadMap,
} from "@/types";

if (import.meta.env.DEV) {
  const mockContainer: IContainerInventory = {
    title: "Sua lancheira",
    description: "Comidas aqui dentro duram mais.",
    slots: 9,
    items: {
      "1": {
        item: "apple",
        peso: 0.2,
        name: "Maçã",
        amount: 3,
        type: "usavel",
        image: "https://cdn.blacknetwork.com.br/black_inventory/apple.png",
      },
      "2": {
        item: "apple",
        peso: 0.2,
        name: "Maçã",
        amount: 3,
        type: "usavel",
        image: "https://cdn.blacknetwork.com.br/black_inventory/apple.png",
      },
    },
  };

  const mockChestUpgradeQuote: IChestUpgradeQuote = {
    title: "Melhorar baú",
    description: "Aumente a capacidade deste baú para guardar mais itens.",
    price: 75000,
    currency: "R$",
    currentCapacity: 50,
    nextCapacity: 75,
    capacityUnit: "kg",
    confirmLabel: "Confirmar upgrade",
    cancelLabel: "Agora não",
  };
  const debugMode = new URLSearchParams(window.location.search).get("debug");

  new Debugger([
    {
      action: "setVisibility",
      data: true,
    },
    {
      action: "setProfile",
      data: {
        name: "Core Network",
        id: 237,
        vip: {
          time: 23,
          current: "Rebirth?",
        },
        image:
          "https://media.discordapp.net/attachments/1210407866557792337/1434346178832629890/e94ca96ff0ef94dff772ec417f8e09f1.jpg?ex=693185b9&is=69303439&hm=5db325b0d50ca58e5ccc838e6418e891a37c69fbd7f664dcf5eb9206a10dd5a5&=&format=webp&width=444&height=444",
        gens: 99999,
        weight: 25,
        maxWeight: 30,
        chestWeight: 3.2,
        chestMaxWeight: 50,
      },
    },
    {
      action: "updateBackpack",
      data: {
        "1": {
          item: "weapon_pistol_mk2",
          peso: 53,
          name: "Maçã",
          amount: 2,
          durability: 190000,
          days: 4,
          type: "usavel",
          maxAmount: 50,
          remaningUse: "Lim",
          description:
            "Você pode comer essa maçã, mas cuidado para não estar verde",
          image: "https://cdn.blacknetwork.com.br/black_inventory/apple.png",
        },
        "2": {
          item: "weapon_sniper_mk2",
          peso: 53,
          name: "Drone",
          amount: 2,
          type: "usavel",
          description:
            "Você pode comer essa maçã, mas cuidado para não estar verde",
          image: "https://cdn.blacknetwork.com.br/black_inventory/drone.png",
        },
        "3": {
          item: "mock_lunchbox",
          peso: 1.2,
          name: "Lancheira",
          amount: 1,
          type: "usavel",
          description: "Use com o botão direito para abrir.",
          image: lunchboxImage,
        },
        "4": {
          item: "mock_chest",
          peso: 2,
          name: "Baú de teste",
          amount: 1,
          type: "usavel",
          description:
            "Use com o botão direito para testar o inventário externo.",
          image: lunchboxImage,
        },
        "6": {
          item: "water",
          peso: 0.5,
          name: "Água",
          amount: 8,
          type: "usavel",
          description: "Use o botão direito para oferecer numa negociação.",
          image: "https://cdn.blacknetwork.com.br/black_inventory/water.png",
        },
        "7": {
          item: "apple",
          peso: 0.2,
          name: "Maçã",
          amount: 5,
          type: "usavel",
          description: "Use o botão direito para oferecer numa negociação.",
          image: "https://cdn.blacknetwork.com.br/black_inventory/apple.png",
        },
        "8": {
          item: "weapon_sawnoff",
          peso: 2.3,
          name: "Sawnoff",
          amount: 1,
          type: "arma",
          ammo: 97,
          serial: "UE305917",
          durability: 190000,
          days: 7,
          description: "Arma de cano serrado.",
          image: "https://cdn.blacknetwork.com.br/black_inventory/drone.png",
        },
      },
    },
    {
      action: "setInventory",
      data: {
        slot: 10,
        unlockedSlots: 20,
        maxSlots: 45,
        accent: "#dc1553",
        shop: "",
        vip: false,
      },
    },
    ...(debugMode === "external" || debugMode === "upgrade"
      ? [
          { action: "setGroundSection", data: mockExternalSection },
          { action: "updateDrop", data: mockExternalItems },
        ]
      : []),
    ...(debugMode === "upgrade"
      ? [{ action: "setChestUpgrade", data: mockChestUpgradeQuote }]
      : []),
  ]);

  const findFreeSlot = (items: InventoryItems, maximum: number) => {
    for (let slot = 1; slot <= maximum; slot += 1) {
      if (!items[String(slot)]) return String(slot);
    }
    return null;
  };

  // o servidor é quem move itens numa negociação real; aqui isso é simulado
  // para que o painel de visualização funcione de ponta a ponta no browser
  const applyMockTradeCallback = (
    eventName: string,
    payload: { slot?: string | number; amount?: number },
  ) => {
    const trade = useTrade.getState().current;
    if (!trade) return;

    if (eventName === "cancelTrade") {
      dispatchNuiDebugEvent({ action: "setTrade", data: null });
      return;
    }

    if (eventName === "confirmTrade") {
      dispatchNuiDebugEvent({
        action: "setTrade",
        data: { ...trade, self: { ...trade.self, confirmed: true } },
      });
      return;
    }

    if (eventName === "setTradeMoney") {
      const amount = Math.max(0, Math.floor(Number(payload.amount) || 0));
      dispatchNuiDebugEvent({
        action: "setTrade",
        data: { ...trade, self: { ...trade.self, money: amount } },
      });
      return;
    }

    const inventoryItems = { ...useItem.getState().item };
    const offerItems = { ...trade.self.items };

    if (eventName === "offerTradeItem") {
      const sourceSlot = String(payload.slot);
      const sourceItem = inventoryItems[sourceSlot];
      if (!sourceItem) return;

      const requested = Math.max(1, Math.floor(Number(payload.amount) || 1));
      const moveAmount = Math.min(sourceItem.amount, requested);
      const stackSlot = Object.keys(offerItems).find(
        (slot) => offerItems[slot]?.item === sourceItem.item,
      );
      const targetSlot = stackSlot ?? findFreeSlot(offerItems, trade.slots);
      if (!targetSlot) return;

      const targetItem = offerItems[targetSlot];
      offerItems[targetSlot] = targetItem
        ? { ...targetItem, amount: targetItem.amount + moveAmount }
        : { ...sourceItem, amount: moveAmount };

      const remainingAmount = sourceItem.amount - moveAmount;
      if (remainingAmount > 0) {
        inventoryItems[sourceSlot] = {
          ...sourceItem,
          amount: remainingAmount,
        };
      } else {
        delete inventoryItems[sourceSlot];
      }
    }

    if (eventName === "withdrawTradeItem") {
      const offerSlot = String(payload.slot);
      const offerItem = offerItems[offerSlot];
      if (!offerItem) return;

      const stackSlot = Object.keys(inventoryItems).find(
        (slot) => inventoryItems[slot]?.item === offerItem.item,
      );
      const targetSlot = stackSlot ?? findFreeSlot(inventoryItems, 45);
      if (!targetSlot) return;

      const targetItem = inventoryItems[targetSlot];
      inventoryItems[targetSlot] = targetItem
        ? { ...targetItem, amount: targetItem.amount + offerItem.amount }
        : offerItem;

      delete offerItems[offerSlot];
    }

    dispatchNuiDebugEvent({ action: "updateBackpack", data: inventoryItems });
    dispatchNuiDebugEvent({
      action: "setTrade",
      data: { ...trade, self: { ...trade.self, items: offerItems } },
    });
  };

  const moveMockContainerItem = (
    data: NuiCallbackPayloadMap["moveContainerItem"],
  ) => {
    const container = useContainerInventory.getState().current;
    if (!container) return;

    const isValidSlot = (section: InventorySection, slot: string) => {
      const numericSlot = Number(slot);
      if (!Number.isInteger(numericSlot) || numericSlot < 1) return false;
      return section === "container"
        ? numericSlot <= container.slots
        : numericSlot <= 200;
    };

    if (
      !isValidSlot(data.fromSection, data.fromSlot) ||
      !isValidSlot(data.toSection, data.toSlot)
    ) {
      return;
    }

    const inventoryItems = { ...useItem.getState().item };
    const containerItems = { ...container.items };
    const getItems = (section: InventorySection) =>
      section === "container" ? containerItems : inventoryItems;
    const sourceItems = getItems(data.fromSection);
    const targetItems = getItems(data.toSection);
    const sourceItem = sourceItems[data.fromSlot];
    const targetItem = targetItems[data.toSlot];

    if (!sourceItem) return;

    const requestedAmount = Number.isFinite(data.amount)
      ? Math.max(1, Math.floor(data.amount))
      : 1;
    const moveAmount = Math.min(sourceItem.amount, requestedAmount);

    if (targetItem && targetItem.item !== sourceItem.item) {
      sourceItems[data.fromSlot] = targetItem;
      targetItems[data.toSlot] = sourceItem;
    } else {
      const remainingAmount = sourceItem.amount - moveAmount;
      if (remainingAmount > 0) {
        sourceItems[data.fromSlot] = {
          ...sourceItem,
          amount: remainingAmount,
        };
      } else {
        delete sourceItems[data.fromSlot];
      }

      targetItems[data.toSlot] = targetItem
        ? { ...targetItem, amount: targetItem.amount + moveAmount }
        : { ...sourceItem, amount: moveAmount };
    }

    useItem.getState().set(inventoryItems);
    useContainerInventory.getState().set({
      ...container,
      items: containerItems,
    });
  };

  const handleDebugCallback = (event: Event) => {
    const { eventName, data } = (event as CustomEvent<NuiDebugCallbackFrame>)
      .detail;

    if (
      eventName === "useItem" &&
      data.section !== "container" &&
      String(data.slot) === "3"
    ) {
      dispatchNuiDebugEvent({
        action: "setContainer",
        data: mockContainer,
      });
      return;
    }

    if (
      eventName === "useItem" &&
      data.section !== "container" &&
      String(data.slot) === "4"
    ) {
      dispatchNuiDebugEvent({
        action: "setGroundSection",
        data: mockExternalSection,
      });
      dispatchNuiDebugEvent({
        action: "updateDrop",
        data: mockExternalItems,
      });
      return;
    }

    if (eventName === "requestChestUpgrade") {
      dispatchNuiDebugEvent({
        action: "setChestUpgrade",
        data: mockChestUpgradeQuote,
      });
      return;
    }

    if (eventName === "confirmChestUpgrade") {
      dispatchNuiDebugEvent({ action: "setChestUpgrade", data: null });
      return;
    }

    if (
      eventName === "offerTradeItem" ||
      eventName === "withdrawTradeItem" ||
      eventName === "setTradeMoney" ||
      eventName === "confirmTrade" ||
      eventName === "cancelTrade"
    ) {
      applyMockTradeCallback(eventName, data);
      return;
    }

    if (eventName === "moveContainerItem") moveMockContainerItem(data);
  };

  window.addEventListener(NUI_DEBUG_CALLBACK_EVENT, handleDebugCallback);
  import.meta.hot?.dispose(() => {
    window.removeEventListener(NUI_DEBUG_CALLBACK_EVENT, handleDebugCallback);
  });
}

ReactDOM.createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <VisibilityProvider>
      <Interface />
    </VisibilityProvider>
  </StrictMode>,
);
