import { DraggableItem } from "../DraggableItem";
import { HotBarSlots } from "../Hotbar";
import { Post } from "@/hooks/post";
import { useItem, useTrade } from "@/stores/useNui";
import { getRequestedAmount } from "@/utils/inventory";

const HOTBAR_SLOTS = Array.from({ length: 5 }, (_, index) => index);

interface IHotBarProps {
  quantity: number | "";
}

export function HotbarSection({ quantity }: IHotBarProps) {
  const item = useItem((state) => state.item);
  const isTrading = useTrade((state) => state.current !== null);

  return (
    <div className="inventory-hotbar" aria-label="Atalhos rápidos">
      {HOTBAR_SLOTS.map((index) => {
        const slotKey = String(index + 1);
        const currentItem = item[slotKey];

        return (
          <HotBarSlots
            slot={index}
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
          </HotBarSlots>
        );
      })}
    </div>
  );
}
