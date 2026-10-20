import { useDndContext, useDroppable } from "@dnd-kit/core";
import type { ReactNode } from "react";

interface DroppableSlotProps {
  id: string;
  children?: ReactNode;
}

export function DroppableSlot({ id, children }: DroppableSlotProps) {
  const { active } = useDndContext();
  const { isOver, setNodeRef } = useDroppable({
    id,
  });
  const isSourceSlotDragging = active?.id === id;
  const hasVisibleChildren = Boolean(children) && !isSourceSlotDragging;

  return (
    <div
      ref={setNodeRef}
      className={`inventory-slot ${isOver ? "inventory-slot-over" : ""} ${
        hasVisibleChildren ? "inventory-slot-filled" : ""
      }`}
    >
      {hasVisibleChildren ? children : null}
    </div>
  );
}
