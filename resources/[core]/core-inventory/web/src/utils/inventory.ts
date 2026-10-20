import {
  rectIntersection,
  type CollisionDetection,
  type UniqueIdentifier,
} from "@dnd-kit/core";

import type { IItem, InventorySection } from "@/types";

// Lista de IDs dos botões de ação que devem ser sempre "visíveis" para colisão
const ALWAYS_ACTIVE_BUTTONS = new Set<UniqueIdentifier>([
  "use-button",
  "send-button",
  "drop-item",
]);

function getNearestScrollContainer(el: HTMLElement | null): HTMLElement | null {
  return el?.closest<HTMLElement>(".scroll-inventory") ?? null;
}

function isPartiallyVisibleWithin(
  el: HTMLElement,
  container: HTMLElement,
): boolean {
  const rect = el.getBoundingClientRect();
  const cr = container.getBoundingClientRect();
  return (
    rect.bottom > cr.top &&
    rect.top < cr.bottom &&
    rect.right > cr.left &&
    rect.left < cr.right
  );
}

export const visibleCollisionDetection: CollisionDetection = (args) => {
  const collisions = rectIntersection(args);
  const droppableNodes = new Map(
    args.droppableContainers.map((container) => [
      container.id,
      container.node.current,
    ]),
  );

  return collisions.filter(({ id }) => {
    if (ALWAYS_ACTIVE_BUTTONS.has(id)) {
      return true;
    }

    const droppable = droppableNodes.get(id);
    if (!droppable) return false;

    const container = getNearestScrollContainer(droppable);
    if (!container) return true;

    return isPartiallyVisibleWithin(droppable, container);
  });
};

export function parseInventorySlot(id: unknown) {
  const match = /^(inventory|container|ground)-([1-9]\d*)$/.exec(String(id));
  if (!match) return null;

  return {
    section: match[1] as InventorySection,
    slot: match[2],
  };
}

/**
 * Arma é o que o servidor marcar como tal pelo `type`, ou o que vier com
 * munição — `ammo` só existe em armas.
 */
export function isWeaponItem(item: IItem) {
  const type = normalizeType(item);
  return (
    type === "arma" ||
    type === "weapon" ||
    type === "armamento" ||
    item.ammo !== undefined
  );
}

/** Tipo do item sem acento e em caixa baixa, para casar com o Type do Lua. */
function normalizeType(item: IItem) {
  return (item.type ?? "")
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .toLowerCase();
}

export function isAmmoItem(item: IItem) {
  return normalizeType(item) === "municao";
}

export function isAttachItem(item: IItem) {
  return normalizeType(item) === "attachs";
}

export function getRequestedAmount(
  requested: number | "",
  available: number,
  useAll = false,
): number {
  const safeAvailable = Math.max(1, Math.floor(Number(available) || 1));
  if (useAll) return safeAvailable;

  const safeRequested = Math.floor(Number(requested) || 1);
  return Math.min(safeAvailable, Math.max(1, safeRequested));
}
