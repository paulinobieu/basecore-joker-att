import { useEffect, useRef } from "react";

import type {
  NuiInboundAction,
  NuiInboundPayloadMap,
  NuiMessageDataFrame,
} from "@/types";

type NuiHandlerSignature<T> = (data: T) => void;

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isSafeNumber(
  value: unknown,
  minimum = 0,
  maximum = 1_000_000_000,
): value is number {
  return (
    typeof value === "number" &&
    Number.isFinite(value) &&
    value >= minimum &&
    value <= maximum
  );
}

function isSafeString(value: unknown, maximumLength: number): value is string {
  return typeof value === "string" && value.length <= maximumLength;
}

function isValidItem(value: unknown) {
  if (!isRecord(value)) return false;

  return (
    isSafeString(value.item, 128) &&
    value.item.length > 0 &&
    isSafeString(value.name, 128) &&
    isSafeString(value.image, 2048) &&
    isSafeString(value.type, 64) &&
    isSafeNumber(value.amount, 1) &&
    isSafeNumber(value.peso) &&
    (value.ammo === undefined || isSafeNumber(value.ammo))
  );
}

function isValidProfile(value: Record<string, unknown>) {
  const vip = value.vip;
  return (
    isSafeString(value.image, 2048) &&
    isSafeString(value.name, 128) &&
    isSafeNumber(value.id) &&
    (value.gens === undefined || isSafeNumber(value.gens)) &&
    isSafeNumber(value.weight) &&
    isSafeNumber(value.maxWeight) &&
    (value.chestWeight === undefined || isSafeNumber(value.chestWeight)) &&
    (value.chestMaxWeight === undefined ||
      isSafeNumber(value.chestMaxWeight)) &&
    (vip === undefined ||
      (isRecord(vip) &&
        isSafeNumber(vip.time) &&
        isSafeString(vip.current, 64)))
  );
}

function isValidInventory(value: Record<string, unknown>) {
  return (
    Number.isInteger(value.slot) &&
    isSafeNumber(value.slot, 0, 200) &&
    (value.unlockedSlots === undefined ||
      (Number.isInteger(value.unlockedSlots) &&
        isSafeNumber(value.unlockedSlots, 0, 200))) &&
    isSafeString(value.shop, 128) &&
    (value.vip === undefined || typeof value.vip === "boolean")
  );
}

function isValidItemCollection(value: unknown, maximumSlots: number) {
  // Tabela Lua vazia vira `[]` no JSON, não `{}`. Sem esta saída o painel de um
  // contêiner vazio era descartado aqui e nunca chegava a abrir.
  if (Array.isArray(value)) return value.length === 0;
  if (!isRecord(value)) return false;

  const entries = Object.entries(value);
  return (
    entries.length <= maximumSlots &&
    entries.every(
      ([slot, item]) =>
        /^[1-9]\d{0,2}$/.test(slot) &&
        Number(slot) <= maximumSlots &&
        isValidItem(item),
    )
  );
}

function isValidContainer(value: unknown) {
  if (!isRecord(value)) return false;
  if (!Number.isInteger(value.slots) || !isSafeNumber(value.slots, 1, 30)) {
    return false;
  }

  return (
    isSafeString(value.title, 64) &&
    value.title.length > 0 &&
    isSafeString(value.description, 180) &&
    isValidItemCollection(value.items, value.slots)
  );
}

function isValidGroundSection(value: unknown) {
  if (!isRecord(value)) return false;

  return (
    isSafeString(value.label, 64) &&
    Number.isInteger(value.slot) &&
    isSafeNumber(value.slot, 1, 200) &&
    (value.description === undefined || isSafeString(value.description, 180)) &&
    (value.weight === undefined || isSafeNumber(value.weight)) &&
    (value.maxWeight === undefined || isSafeNumber(value.maxWeight)) &&
    (value.canUpgrade === undefined || typeof value.canUpgrade === "boolean")
  );
}

function isValidTradeOffer(value: unknown, maximumSlots: number) {
  if (!isRecord(value)) return false;

  return (
    isValidItemCollection(value.items, maximumSlots) &&
    isSafeNumber(value.money) &&
    typeof value.confirmed === "boolean"
  );
}

function isValidTrade(value: unknown) {
  if (!isRecord(value)) return false;
  if (!Number.isInteger(value.slots) || !isSafeNumber(value.slots, 1, 30)) {
    return false;
  }

  return (
    isSafeString(value.partnerName, 128) &&
    value.partnerName.length > 0 &&
    (value.partnerImage === undefined ||
      isSafeString(value.partnerImage, 2048)) &&
    isValidTradeOffer(value.partner, value.slots) &&
    isValidTradeOffer(value.self, value.slots)
  );
}

function isValidChestUpgrade(value: unknown) {
  if (!isRecord(value)) return false;

  const hasCurrentCapacity = value.currentCapacity !== undefined;
  const hasNextCapacity = value.nextCapacity !== undefined;

  return (
    isSafeString(value.title, 64) &&
    value.title.length > 0 &&
    isSafeString(value.description, 180) &&
    isSafeNumber(value.price) &&
    isSafeString(value.currency, 16) &&
    value.currency.length > 0 &&
    hasCurrentCapacity === hasNextCapacity &&
    (!hasCurrentCapacity ||
      (isSafeNumber(value.currentCapacity) &&
        isSafeNumber(value.nextCapacity))) &&
    (value.capacityUnit === undefined ||
      isSafeString(value.capacityUnit, 16)) &&
    (value.confirmLabel === undefined ||
      (isSafeString(value.confirmLabel, 32) &&
        value.confirmLabel.length > 0)) &&
    (value.cancelLabel === undefined ||
      (isSafeString(value.cancelLabel, 32) && value.cancelLabel.length > 0))
  );
}

function isValidPayload(action: NuiInboundAction, data: unknown): boolean {
  if (action === "setVisibility") return typeof data === "boolean";
  if (action === "setContainer") {
    return data === null || isValidContainer(data);
  }
  if (action === "setGroundSection") {
    return data === null || isValidGroundSection(data);
  }
  if (action === "setChestUpgrade") {
    return data === null || isValidChestUpgrade(data);
  }
  if (action === "setTrade") {
    return data === null || isValidTrade(data);
  }
  if (!isRecord(data)) return false;

  if (action === "updateBackpack" || action === "updateDrop") {
    return isValidItemCollection(data, 200);
  }

  if (action === "setProfile") return isValidProfile(data);
  return isValidInventory(data);
}

export const useNuiEvent = <K extends NuiInboundAction>(
  action: K,
  handler: NuiHandlerSignature<NuiInboundPayloadMap[K]>,
) => {
  const savedHandler = useRef(handler);

  useEffect(() => {
    savedHandler.current = handler;
  }, [handler]);

  useEffect(() => {
    const eventListener = (event: MessageEvent<unknown>) => {
      if (!isRecord(event.data) || event.data.action !== action) return;
      if (!isValidPayload(action, event.data.data)) return;

      const frame = event.data as unknown as NuiMessageDataFrame<
        NuiInboundPayloadMap[K]
      >;
      savedHandler.current(frame.data);
    };

    window.addEventListener("message", eventListener);
    return () => window.removeEventListener("message", eventListener);
  }, [action]);
};
