import { useDroppable } from "@dnd-kit/core";
import { IconMouse2 } from "@tabler/icons-react";
import type { ReactNode } from "react";

interface DroppableButtonProps {
  id: string;
  children: ReactNode;
}

export function DroppableButton({ id, children }: DroppableButtonProps) {
  const { setNodeRef, isOver } = useDroppable({ id });

  return (
    <div
      ref={setNodeRef}
      className={isOver ? "inventory-action-drop-active" : undefined}
    >
      {children}
    </div>
  );
}

export function QuantityInput() {
  return (
    <div className="inventory-shortcuts" aria-label="Atalhos do inventário">
      <div className="inventory-shortcut">
        <span>Mover</span>
        <kbd aria-label="Botão do mouse">
          <IconMouse2 aria-hidden="true" stroke={2.2} />
        </kbd>
      </div>

      <DroppableButton id="use-button">
        <div className="inventory-shortcut inventory-use-shortcut">
          <span>Usar</span>
          <kbd aria-label="Botão do mouse">
            <IconMouse2 aria-hidden="true" stroke={2.2} />
          </kbd>
        </div>
      </DroppableButton>

      <div className="inventory-shortcut">
        <span>Separar</span>
        <kbd className="inventory-shortcut-combination">
          <IconMouse2 aria-hidden="true" stroke={2.2} />
          <span aria-hidden="true">+</span>
          <span>CTRL</span>
        </kbd>
      </div>
    </div>
  );
}
