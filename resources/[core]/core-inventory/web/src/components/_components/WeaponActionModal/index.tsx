import { useEffect, useState } from "react";
import { createPortal } from "react-dom";

import type { IItem } from "@/types";

export interface WeaponAction {
  kind: "reload" | "attach";
  sourceSlot: string;
  targetSlot: string;
  source: IItem;
  weapon: IItem;
  /** teto de unidades; sempre 1 no acessório */
  max: number;
}

interface WeaponActionModalProps {
  action: WeaponAction | null;
  onCancel: () => void;
  onConfirm: (amount: number) => void;
}

/**
 * Confirmação de recarga e de acoplagem. A recarga pede a quantidade porque o
 * pente tem teto; o acessório é sempre uma peça, então só confirma.
 */
export function WeaponActionModal({
  action,
  onCancel,
  onConfirm,
}: WeaponActionModalProps) {
  const [amount, setAmount] = useState(1);

  useEffect(() => {
    if (action) setAmount(action.max);
  }, [action]);

  useEffect(() => {
    if (!action) return;

    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") onCancel();
      if (event.key === "Enter") onConfirm(amount);
    };

    window.addEventListener("keydown", handleKeyDown, true);
    return () => window.removeEventListener("keydown", handleKeyDown, true);
  }, [action, amount, onCancel, onConfirm]);

  if (!action) return null;

  const reloading = action.kind === "reload";

  return createPortal(
    <div className="inventory-modal-overlay" onMouseDown={onCancel}>
      <div
        className="inventory-modal"
        onMouseDown={(event) => event.stopPropagation()}
      >
        <header className="inventory-modal-header">
          <h2>{reloading ? "Carregar armamento" : "Acoplar acessório"}</h2>
          <p>
            {action.source.name} <span>&rarr;</span> {action.weapon.name}
          </p>
        </header>

        {reloading && (
          <div className="inventory-modal-body">
            <label htmlFor="weapon-action-amount">Quantidade</label>

            <div className="inventory-modal-amount">
              <input
                id="weapon-action-amount"
                type="number"
                min={1}
                max={action.max}
                value={amount}
                onChange={(event) =>
                  setAmount(
                    Math.max(
                      1,
                      Math.min(
                        action.max,
                        Math.floor(Number(event.target.value) || 1),
                      ),
                    ),
                  )
                }
              />

              <button type="button" onClick={() => setAmount(action.max)}>
                Máximo
              </button>
            </div>

            <span className="inventory-modal-hint">
              Cabem {action.max} nesta recarga
              {action.weapon.ammo ? ` · ${action.weapon.ammo} carregadas` : ""}
            </span>
          </div>
        )}

        <footer className="inventory-modal-footer">
          <button type="button" onClick={onCancel}>
            Cancelar
          </button>
          <button
            type="button"
            className="inventory-modal-confirm"
            onClick={() => onConfirm(reloading ? amount : 1)}
          >
            Confirmar
          </button>
        </footer>
      </div>
    </div>,
    document.body,
  );
}
