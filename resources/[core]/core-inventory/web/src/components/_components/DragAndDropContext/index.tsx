import {
  DndContext,
  DragOverlay,
  type DragEndEvent,
  type DragStartEvent,
} from "@dnd-kit/core";
import type { ReactNode } from "react";

import { DragOverlayItem } from "../DraggableItem";
import type { IItem } from "@/types";
import { visibleCollisionDetection } from "@/utils/inventory";

interface DragAndDropContextProps {
  children: ReactNode;
  draggedItem: IItem | null;
  onDragStart: (event: DragStartEvent) => void;
  onDragEnd: (event: DragEndEvent) => void;
  onDragCancel: () => void;
}

export function DragAndDropContext({
  children,
  draggedItem,
  onDragStart,
  onDragEnd,
  onDragCancel,
}: DragAndDropContextProps) {
  return (
    <DndContext
      onDragStart={onDragStart}
      onDragEnd={onDragEnd}
      onDragCancel={onDragCancel}
      autoScroll={false}
      collisionDetection={visibleCollisionDetection}
    >
      {children}
      <DragOverlay>
        {draggedItem && <DragOverlayItem item={draggedItem} />}
      </DragOverlay>
    </DndContext>
  );
}
