import { useEffect, useMemo, useState } from "react";
import { IconPackageExport, IconPaperBag, IconX } from "@tabler/icons-react";

import { Post } from "@/hooks/post";
import { useMountTransition } from "@/hooks/transition";
import { useContainerInventory } from "@/stores/useNui";
import { getRequestedAmount } from "@/utils/inventory";
import { DraggableItem } from "../DraggableItem";
import { DroppableSlot } from "../DroppableSlot";

// espelha a duração de .inventory-container-panel no global.css
const PANEL_TRANSITION_MS = 220;

interface ContainerInventoryProps {
  quantity: number | "";
}

export function ContainerInventory({ quantity }: ContainerInventoryProps) {
  const container = useContainerInventory((state) => state.current);
  const setContainer = useContainerInventory((state) => state.set);
  const { shouldRender, isVisible } = useMountTransition(
    container !== null,
    PANEL_TRANSITION_MS,
  );
  // o painel continua montado durante a saída, quando o container já é null
  const [lastContainer, setLastContainer] = useState(container);

  useEffect(() => {
    if (container) setLastContainer(container);
  }, [container]);

  const visibleContainer = container ?? lastContainer;
  const hasItems = Object.keys(visibleContainer?.items ?? {}).length > 0;
  const slots = useMemo(
    () =>
      Array.from(
        { length: visibleContainer?.slots ?? 0 },
        (_, index) => index + 1,
      ),
    [visibleContainer?.slots],
  );

  if (!shouldRender || !visibleContainer) return null;

  const handleClose = () => {
    setContainer(null);
    Post.send("closeContainer", {});
  };

  return (
    <aside
      className={`inventory-container-panel ${
        isVisible ? "" : "inventory-container-panel-hidden"
      }`}
      aria-label={visibleContainer.title}
    >
      <header className="inventory-container-header">
        <div>
          <h2>
            <IconPaperBag aria-hidden="true" stroke={2} />
            <span>{visibleContainer.title}</span>
          </h2>
          <p>{visibleContainer.description}</p>
        </div>
        <button
          type="button"
          className="inventory-container-close"
          aria-label="Fechar recipiente"
          onClick={handleClose}
        >
          <IconX aria-hidden="true" stroke={1.8} />
        </button>
      </header>

      <div className="inventory-container-grid scroll-inventory">
        {slots.map((slot) => {
          const currentItem = visibleContainer.items[String(slot)];

          return (
            <DroppableSlot key={`container-${slot}`} id={`container-${slot}`}>
              {currentItem && (
                <DraggableItem
                  id={`container-${slot}`}
                  item={currentItem}
                  onClick={(event) =>
                    Post.send("useItem", {
                      section: "container",
                      slot,
                      amount: getRequestedAmount(
                        quantity,
                        currentItem.amount,
                        event.shiftKey,
                      ),
                    })
                  }
                />
              )}
            </DroppableSlot>
          );
        })}
      </div>

      <button
        type="button"
        className="inventory-container-empty"
        disabled={!hasItems}
        onClick={() => {
          void Post.create("emptyContainer", {});
        }}
      >
        <IconPackageExport aria-hidden="true" stroke={1.8} />
        Remover todos
      </button>
    </aside>
  );
}
