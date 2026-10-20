import { useEffect, useRef, useState } from "react";
import type { DragEndEvent, DragStartEvent } from "@dnd-kit/core";
import { IconSend, IconTrash } from "@tabler/icons-react";
import { Post } from "@/hooks/post";
import {
  useContainerInventory,
  useGroundItem,
  useGroundSection,
  useItem,
  useTrade,
} from "@/stores/useNui";
import type { IItem, InventorySection } from "@/types";
import {
  getRequestedAmount,
  isAmmoItem,
  isAttachItem,
  isWeaponItem,
  parseInventorySlot,
} from "@/utils/inventory";
import { BackpackSection } from "./_components/BackpackSection";
import { Profile } from "./_components/BackpackSection/components/Profile";
import { DragAndDropContext } from "./_components/DragAndDropContext";
import { HotbarSection } from "./_components/HotbarSection";
import { DroppableButton, QuantityInput } from "./_components/QuantityInput";
import { QuantityModal } from "./_components/QuantityModal";
import { ContainerInventory } from "./_components/ContainerInventory";
import { ExternalInventory } from "./_components/ExternalInventory";
import { TradeInventory } from "./_components/TradeInventory";
import { ChestUpgradeModal } from "./_components/ChestUpgradeModal";
import { ItemContextMenu } from "./_components/ItemContextMenu";
import {
  WeaponActionModal,
  type WeaponAction,
} from "./_components/WeaponActionModal";
import { DevActions } from "./_components/DevActions";

const ITEM_ACTIONS = {
  "use-button": "useItem",
  "send-button": "sendItem",
  "drop-item": "dropItem",
} as const;

/** item largado no botão Enviar, à espera da quantidade */
interface SendRequest {
  section: InventorySection;
  slot: string;
  item: IItem;
  amount: number;
}

function isInventoryItem(value: unknown): value is IItem {
  if (!value || typeof value !== "object") return false;
  const item = value as Partial<IItem>;
  return (
    typeof item.item === "string" &&
    item.item.length > 0 &&
    typeof item.amount === "number" &&
    Number.isFinite(item.amount) &&
    item.amount > 0
  );
}

function isRejectedCallbackResult(value: unknown) {
  if (value === false) return true;
  if (!value || typeof value !== "object") return false;

  const result = value as { ok?: unknown; success?: unknown };
  return result.ok === false || result.success === false;
}

export function Interface() {
  const setItem = useItem((state) => state.set);
  const setGroundItem = useGroundItem((state) => state.set);
  const hasOpenContainer = useContainerInventory(
    (state) => state.current !== null,
  );
  const hasOpenExternalInventory = useGroundSection(
    (state) => state.current !== null,
  );
  const hasOpenTrade = useTrade((state) => state.current !== null);
  const isDropsSection = useGroundSection(
    (state) => state.current?.drops === true,
  );
  const [draggedItem, setDraggedItem] = useState<IItem | null>(null);
  const [weaponAction, setWeaponAction] = useState<WeaponAction | null>(null);
  const [sendRequest, setSendRequest] = useState<SendRequest | null>(null);
  const [quantity, setQuantity] = useState<number | "">("");
  const isShiftPressedRef = useRef(false);
  const draggedItemRef = useRef<IItem | null>(null);

  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Shift") {
        isShiftPressedRef.current = true;
        if (draggedItemRef.current) {
          setQuantity(draggedItemRef.current.amount);
        }
      }
    };

    const handleKeyUp = (event: KeyboardEvent) => {
      if (event.key === "Shift") {
        isShiftPressedRef.current = false;
      }
    };

    const handleRightClick = (event: MouseEvent) => {
      if (!draggedItemRef.current) return;
      event.preventDefault();
      setQuantity(draggedItemRef.current.amount);
    };

    window.addEventListener("keydown", handleKeyDown);
    window.addEventListener("keyup", handleKeyUp);
    window.addEventListener("contextmenu", handleRightClick);

    return () => {
      window.removeEventListener("keydown", handleKeyDown);
      window.removeEventListener("keyup", handleKeyUp);
      window.removeEventListener("contextmenu", handleRightClick);
    };
  }, []);

  const resetDragState = () => {
    draggedItemRef.current = null;
    setDraggedItem(null);
    setQuantity("");
  };

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;
    if (!over) {
      resetDragState();
      return;
    }

    const source = parseInventorySlot(active.id);
    const action = ITEM_ACTIONS[over.id as keyof typeof ITEM_ACTIONS];

    if (action && draggedItem && source && source.section !== "ground") {
      const amount = getRequestedAmount(
        quantity,
        draggedItem.amount,
        isShiftPressedRef.current,
      );

      // enviar sai do inventário para outra pessoa: confirma a quantidade antes
      if (over.id === "send-button") {
        setSendRequest({
          section: source.section,
          slot: source.slot,
          item: draggedItem,
          amount,
        });
        resetDragState();
        return;
      }

      Post.send(action, {
        section: source.section,
        slot: source.slot,
        amount,
      });
      resetDragState();
      return;
    }

    const target = parseInventorySlot(over.id);
    if (source && target && draggedItem) {
      if (source.section === "inventory" && target.section === "inventory") {
        handleUpdateSlot(source.slot, target.slot);
      } else if (source.section === "ground" && target.section === "ground") {
        handleUpdateGroundSlot(source.slot, target.slot);
      } else if (
        (source.section === "inventory" && target.section === "ground") ||
        (source.section === "ground" && target.section === "inventory")
      ) {
        handleExternalTransfer(source, target);
      } else if (
        source.section !== "ground" &&
        target.section !== "ground" &&
        (source.section !== target.section || source.slot !== target.slot)
      ) {
        Post.send("moveContainerItem", {
          fromSection: source.section,
          fromSlot: source.slot,
          toSection: target.section,
          toSlot: target.slot,
          amount: getRequestedAmount(
            quantity,
            draggedItem.amount,
            isShiftPressedRef.current,
          ),
        });
      }
    }

    resetDragState();
  };

  const handleWeaponAction = (amount: number) => {
    if (!weaponAction) return;

    if (weaponAction.kind === "reload") {
      Post.send("reloadWeapon", {
        slot: weaponAction.sourceSlot,
        target: weaponAction.targetSlot,
        amount,
      });
    } else {
      Post.send("attachWeapon", {
        slot: weaponAction.sourceSlot,
        target: weaponAction.targetSlot,
      });
    }

    setWeaponAction(null);
  };

  const handleUpdateSlot = (fromSlot: string, toSlot: string) => {
    if (!draggedItem) return;
    if (fromSlot === toSlot) return;

    const moveQuantity = getRequestedAmount(
      quantity,
      draggedItem.amount,
      isShiftPressedRef.current,
    );
    const currentItems = useItem.getState().item;
    const fromItem = currentItems[fromSlot];
    const toItem = currentItems[toSlot];
    if (!fromItem) return;

    // Munição ou acessório solto em cima de um armamento não troca de slot:
    // abre a confirmação e vai para o meta da arma.
    if (toItem && isWeaponItem(toItem)) {
      if (isAmmoItem(fromItem)) {
        const ceiling = toItem.item === "WEAPON_PETROLCAN" ? 5000 : 250;
        const free = Math.max(0, ceiling - (toItem.ammo ?? 0));

        if (free > 0) {
          setWeaponAction({
            kind: "reload",
            sourceSlot: fromSlot,
            targetSlot: toSlot,
            source: fromItem,
            weapon: toItem,
            max: Math.min(free, fromItem.amount),
          });
          return;
        }
      }

      if (isAttachItem(fromItem)) {
        setWeaponAction({
          kind: "attach",
          sourceSlot: fromSlot,
          targetSlot: toSlot,
          source: fromItem,
          weapon: toItem,
          max: 1,
        });
        return;
      }
    }

    const updatedItems = { ...currentItems };
    if (toItem && fromItem.item !== toItem.item) {
      updatedItems[fromSlot] = toItem;
      updatedItems[toSlot] = fromItem;
    } else {
      const remainingAmount = fromItem.amount - moveQuantity;
      if (remainingAmount > 0) {
        updatedItems[fromSlot] = { ...fromItem, amount: remainingAmount };
      } else {
        delete updatedItems[fromSlot];
      }

      updatedItems[toSlot] = toItem
        ? { ...toItem, amount: toItem.amount + moveQuantity }
        : { ...fromItem, amount: moveQuantity };
    }

    setItem(updatedItems);
    const rollbackOptimisticMove = () => {
      if (useItem.getState().item === updatedItems) {
        setItem(currentItems);
      }
    };

    void Post.create("updateSlot", {
      slot: fromSlot,
      target: toSlot,
      amount: moveQuantity,
      item: fromItem.item,
    })
      .then((result) => {
        if (isRejectedCallbackResult(result)) rollbackOptimisticMove();
      })
      .catch(rollbackOptimisticMove);
  };

  const handleUpdateGroundSlot = (fromSlot: string, toSlot: string) => {
    if (!draggedItem || fromSlot === toSlot) return;

    // o chão é uma lista de sacolas, não um contêiner: reordenar não existe lá,
    // e o servidor recusaria a troca depois de a interface já ter movido o item
    if (isDropsSection) return;

    const moveQuantity = getRequestedAmount(
      quantity,
      draggedItem.amount,
      isShiftPressedRef.current,
    );
    const currentItems = useGroundItem.getState().item;
    const fromItem = currentItems[fromSlot];
    const toItem = currentItems[toSlot];
    if (!fromItem) return;

    const updatedItems = { ...currentItems };
    if (toItem && fromItem.item !== toItem.item) {
      updatedItems[fromSlot] = toItem;
      updatedItems[toSlot] = fromItem;
    } else {
      const remainingAmount = fromItem.amount - moveQuantity;
      if (remainingAmount > 0) {
        updatedItems[fromSlot] = { ...fromItem, amount: remainingAmount };
      } else {
        delete updatedItems[fromSlot];
      }

      updatedItems[toSlot] = toItem
        ? { ...toItem, amount: toItem.amount + moveQuantity }
        : { ...fromItem, amount: moveQuantity };
    }

    setGroundItem(updatedItems);
    const rollbackOptimisticMove = () => {
      if (useGroundItem.getState().item === updatedItems) {
        setGroundItem(currentItems);
      }
    };

    void Post.create("updateGroundSlot", {
      slot: fromSlot,
      target: toSlot,
      amount: moveQuantity,
      item: fromItem.item,
    })
      .then((result) => {
        if (isRejectedCallbackResult(result)) rollbackOptimisticMove();
      })
      .catch(rollbackOptimisticMove);
  };

  const handleExternalTransfer = (
    source: { section: InventorySection; slot: string },
    target: { section: InventorySection; slot: string },
  ) => {
    if (!draggedItem) return;

    const inventoryIsSource = source.section === "inventory";
    const currentInventoryItems = useItem.getState().item;
    const currentGroundItems = useGroundItem.getState().item;
    const sourceItems = inventoryIsSource
      ? currentInventoryItems
      : currentGroundItems;
    const targetItems = inventoryIsSource
      ? currentGroundItems
      : currentInventoryItems;
    const fromItem = sourceItems[source.slot];
    const toItem = targetItems[target.slot];
    if (!fromItem) return;

    // descartar no chão sempre cria uma sacola nova: o slot em que o item caiu
    // é só o ponto de largada, então não precisa ser compatível com o de origem
    const droppingOnGround = inventoryIsSource && isDropsSection;
    if (!droppingOnGround && toItem && toItem.item !== fromItem.item) return;

    const moveQuantity = getRequestedAmount(
      quantity,
      fromItem.amount,
      isShiftPressedRef.current,
    );
    const updatedSourceItems = { ...sourceItems };
    const updatedTargetItems = { ...targetItems };
    const remainingAmount = fromItem.amount - moveQuantity;

    if (remainingAmount > 0) {
      updatedSourceItems[source.slot] = {
        ...fromItem,
        amount: remainingAmount,
      };
    } else {
      delete updatedSourceItems[source.slot];
    }

    // O chão não tem slot de destino: cada descarte vira uma sacola própria,
    // com id gerado pelo servidor. Escrever no slot que recebeu o arraste
    // desalinha a lista — aqui só tira do inventário e espera o refresh.
    if (!droppingOnGround) {
      updatedTargetItems[target.slot] = toItem
        ? { ...toItem, amount: toItem.amount + moveQuantity }
        : { ...fromItem, amount: moveQuantity };
    }

    const updatedInventoryItems = inventoryIsSource
      ? updatedSourceItems
      : updatedTargetItems;
    const updatedGroundItems = inventoryIsSource
      ? updatedTargetItems
      : updatedSourceItems;

    setItem(updatedInventoryItems);
    setGroundItem(updatedGroundItems);

    const rollbackOptimisticMove = () => {
      if (
        useItem.getState().item === updatedInventoryItems &&
        useGroundItem.getState().item === updatedGroundItems
      ) {
        setItem(currentInventoryItems);
        setGroundItem(currentGroundItems);
      }
    };
    const callback = inventoryIsSource ? "sendItem" : "pickupItem";

    void Post.create(callback, {
      slot: source.slot,
      target: target.slot,
      amount: moveQuantity,
      item: fromItem.item,
    })
      .then((result) => {
        if (isRejectedCallbackResult(result)) rollbackOptimisticMove();
      })
      .catch(rollbackOptimisticMove);
  };

  const handleDragStart = (event: DragStartEvent) => {
    const nextItem = event.active.data.current;
    if (!isInventoryItem(nextItem)) {
      resetDragState();
      return;
    }

    draggedItemRef.current = nextItem;
    setDraggedItem(nextItem);

    if ("shiftKey" in event.activatorEvent && event.activatorEvent.shiftKey) {
      isShiftPressedRef.current = true;
      setQuantity(nextItem.amount);
    }
  };

  return (
    <DragAndDropContext
      draggedItem={draggedItem}
      onDragStart={handleDragStart}
      onDragEnd={handleDragEnd}
      onDragCancel={resetDragState}
    >
      <main
        className={`inventory-shell ${
          hasOpenContainer ? "inventory-shell-with-container" : ""
        } ${hasOpenExternalInventory ? "inventory-shell-with-external" : ""} ${
          hasOpenTrade ? "inventory-shell-with-trade" : ""
        }`}
      >
        <Profile />

        <section className="inventory-content">
          <BackpackSection quantity={quantity} />
        </section>

        <footer className="inventory-footer-wrap">
          <div className="inventory-footer">
            <HotbarSection quantity={quantity} />

            <DroppableButton id="drop-item">
              <button
                type="button"
                aria-label="Descartar item"
                className={`inventory-action ${
                  draggedItem ? "inventory-action-dragging" : ""
                }`}
              >
                <IconTrash aria-hidden="true" stroke={1.8} />
                <span>Descartar</span>
              </button>
            </DroppableButton>

            <DroppableButton id="send-button">
              <button
                type="button"
                aria-label="Enviar item"
                className="inventory-action"
              >
                <IconSend aria-hidden="true" stroke={1.8} />
                <span>Enviar</span>
              </button>
            </DroppableButton>
          </div>

          <QuantityInput />
        </footer>

        <ContainerInventory quantity={quantity} />
        <ExternalInventory />
        <TradeInventory />
        <ChestUpgradeModal />

        <WeaponActionModal
          action={weaponAction}
          onCancel={() => setWeaponAction(null)}
          onConfirm={handleWeaponAction}
        />

        {sendRequest && (
          <QuantityModal
            title="Enviar item"
            subtitle={sendRequest.item.name}
            max={sendRequest.item.amount}
            initial={sendRequest.amount}
            confirmLabel="Enviar"
            onCancel={() => setSendRequest(null)}
            onConfirm={(amount) => {
              Post.send("sendItem", {
                section: sendRequest.section,
                slot: sendRequest.slot,
                amount,
              });
              setSendRequest(null);
            }}
          />
        )}
      </main>

      <ItemContextMenu quantity={quantity} />

      {/* fora da shell: ela tem transform, que viraria o containing block
          de qualquer position: fixed aninhado */}
      <DevActions />
    </DragAndDropContext>
  );
}
