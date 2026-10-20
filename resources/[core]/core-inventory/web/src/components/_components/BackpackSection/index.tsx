import { useMemo } from "react";
import { IconLock } from "@tabler/icons-react";

import { useInventory, useItem, useTrade } from "@/stores/useNui";

import { DraggableItem } from "../DraggableItem";
import { DroppableSlot } from "../DroppableSlot";
import { Post } from "@/hooks/post";
import { getRequestedAmount } from "@/utils/inventory";

const HOTBAR_SLOT_COUNT = 5;

interface BackpackSectionProps {
  quantity: number | "";
}

export function BackpackSection({ quantity }: BackpackSectionProps) {
  const item = useItem((state) => state.item);
  const info = useInventory((state) => state.current);
  const isTrading = useTrade((state) => state.current !== null);

  const unlockedSlots = info.unlockedSlots ?? info.slot ?? 20;
  const maximumSlots = Math.max(
    HOTBAR_SLOT_COUNT,
    info.maxSlots ?? HOTBAR_SLOT_COUNT,
  );
  const slots = useMemo(
    () =>
      Array.from(
        { length: maximumSlots - HOTBAR_SLOT_COUNT },
        (_, index) => index,
      ),
    [maximumSlots],
  );

  return (
    <div className="inventory-grid-wrap">
      <div className="scroll-inventory inventory-grid">
        {slots.map((index) => {
          const slotKey = index + HOTBAR_SLOT_COUNT + 1;
          const currentItem = item[slotKey];
          const isLocked = slotKey > unlockedSlots;

          if (isLocked) {
            return (
              <div
                key={`locked-${slotKey}`}
                className="inventory-slot inventory-slot-locked"
              >
                <IconLock
                  aria-hidden="true"
                  className="inventory-slot-locked-icon"
                  stroke={1.8}
                />
                <span className="sr-only">Slot bloqueado</span>
              </div>
            );
          }

          return (
            <DroppableSlot
              key={`inventory-${slotKey}`}
              id={`inventory-${slotKey}`}
            >
              {currentItem && (
                <DraggableItem
                  id={`inventory-${slotKey}`}
                  item={currentItem}
                  onClick={(event) => {
                    const amount = getRequestedAmount(
                      quantity,
                      currentItem.amount,
                      event.shiftKey,
                    );

                    // durante a negociação o botão direito oferece em vez de usar
                    if (isTrading && event.type === "contextmenu") {
                      Post.send("offerTradeItem", { slot: slotKey, amount });
                      return;
                    }

                    Post.send("useItem", { slot: slotKey, amount });
                  }}
                />
              )}
            </DroppableSlot>
          );
        })}
      </div>
    </div>
  );
}
