import { useMemo, useState } from "react";
import { IconArrowUp, IconWeight } from "@tabler/icons-react";

import { Post } from "@/hooks/post";
import { useGroundItem, useGroundSection, useProfile } from "@/stores/useNui";
import { DraggableItem } from "../DraggableItem";
import { DroppableSlot } from "../DroppableSlot";

const weightFormatter = new Intl.NumberFormat("pt-BR", {
  maximumFractionDigits: 1,
});

export function ExternalInventory() {
  const section = useGroundSection((state) => state.current);
  const items = useGroundItem((state) => state.item);
  const profile = useProfile((state) => state.current);
  const [isRequestingUpgrade, setIsRequestingUpgrade] = useState(false);
  const slots = useMemo(
    () => Array.from({ length: section?.slot ?? 0 }, (_, index) => index + 1),
    [section?.slot],
  );

  if (!section) return null;

  const currentWeight = section.weight ?? profile.chestWeight;
  const maximumWeight = section.maxWeight ?? profile.chestMaxWeight;
  const showsWeight =
    currentWeight !== undefined && maximumWeight !== undefined;

  const handleUpgradeRequest = async () => {
    if (isRequestingUpgrade) return;

    setIsRequestingUpgrade(true);
    try {
      await Post.create("requestChestUpgrade", {});
    } catch {
      // Post registra a falha; o botão volta a ficar disponível para tentar novamente.
    } finally {
      setIsRequestingUpgrade(false);
    }
  };

  return (
    <aside className="inventory-external-panel" aria-label={section.label}>
      <header className="inventory-external-header">
        <div className="inventory-external-title">
          <h2>{section.label || "Inventário"}</h2>
          {section.description && <p>{section.description}</p>}
        </div>

        <div className="inventory-external-controls">
          {showsWeight && (
            <div
              className="inventory-external-weight"
              aria-label="Peso ocupado"
            >
              <IconWeight aria-hidden="true" stroke={1.8} />
              <strong>{weightFormatter.format(currentWeight)}</strong>
              <span>/ {weightFormatter.format(maximumWeight)} kg</span>
            </div>
          )}

          {section.canUpgrade && (
            <button
              type="button"
              className="inventory-external-upgrade"
              aria-label="Melhorar baú"
              aria-busy={isRequestingUpgrade}
              disabled={isRequestingUpgrade}
              onClick={handleUpgradeRequest}
            >
              <IconArrowUp aria-hidden="true" stroke={2} />
            </button>
          )}
        </div>
      </header>

      <div className="inventory-external-grid scroll-inventory">
        {slots.map((slot) => {
          const currentItem = items[String(slot)];

          return (
            <DroppableSlot key={`ground-${slot}`} id={`ground-${slot}`}>
              {currentItem && (
                <DraggableItem id={`ground-${slot}`} item={currentItem} />
              )}
            </DroppableSlot>
          );
        })}
      </div>
    </aside>
  );
}
