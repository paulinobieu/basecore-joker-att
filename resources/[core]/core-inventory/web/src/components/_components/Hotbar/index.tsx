import { useDndContext, useDroppable } from "@dnd-kit/core";
import type { ReactNode } from "react";

interface DroppableSlotProps {
  id: string;
  slot: number;
  children?: ReactNode;
}

export function HotBarSlots({ id, slot, children }: DroppableSlotProps) {
  const { active } = useDndContext();
  const { isOver, setNodeRef } = useDroppable({ id });
  const isSourceSlotDragging = active?.id === id;
  const hasVisibleChildren = Boolean(children) && !isSourceSlotDragging;

  return (
    <div
      ref={setNodeRef}
      className={`inventory-slot inventory-hotbar-slot ${
        isOver ? "inventory-slot-over" : ""
      } ${hasVisibleChildren ? "inventory-slot-filled" : ""}`}
    >
      <span className="inventory-hotbar-number">{slot + 1}</span>
      {hasVisibleChildren ? children : null}
    </div>
  );
}
