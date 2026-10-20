import { useEffect, useState } from "react";
import { createPortal } from "react-dom";

interface QuantityModalProps {
  title: string;
  subtitle?: string;
  /** teto de unidades disponíveis no slot */
  max: number;
  /** valor inicial do campo; recortado no intervalo válido */
  initial?: number;
  confirmLabel?: string;
  onCancel: () => void;
  onConfirm: (amount: number) => void;
}

/**
 * Confirmação de quantidade. O componente é montado sob demanda — o estado
 * nasce junto com o alvo, então não precisa sincronizar com props depois.
 */
export function QuantityModal({
  title,
  subtitle,
  max,
  initial,
  confirmLabel = "Confirmar",
  onCancel,
  onConfirm,
}: QuantityModalProps) {
  const available = Math.max(1, Math.floor(Number(max) || 1));
  const [amount, setAmount] = useState(() =>
    Math.max(1, Math.min(available, Math.floor(Number(initial) || available))),
  );

  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") onCancel();
      if (event.key === "Enter") onConfirm(amount);
    };

    window.addEventListener("keydown", handleKeyDown, true);
    return () => window.removeEventListener("keydown", handleKeyDown, true);
  }, [amount, onCancel, onConfirm]);

  return createPortal(
    <div className="inventory-modal-overlay" onMouseDown={onCancel}>
      <div
        className="inventory-modal"
        onMouseDown={(event) => event.stopPropagation()}
      >
        <header className="inventory-modal-header">
          <h2>{title}</h2>
          {subtitle && <p>{subtitle}</p>}
        </header>

        <div className="inventory-modal-body">
          <label htmlFor="quantity-modal-amount">Quantidade</label>

          <div className="inventory-modal-amount">
            <input
              id="quantity-modal-amount"
              type="number"
              autoFocus
              min={1}
              max={available}
              value={amount}
              onChange={(event) =>
                setAmount(
                  Math.max(
                    1,
                    Math.min(
                      available,
                      Math.floor(Number(event.target.value) || 1),
                    ),
                  ),
                )
              }
            />

            <button type="button" onClick={() => setAmount(available)}>
              Máximo
            </button>
          </div>

          <span className="inventory-modal-hint">
            Você tem {available} no slot
          </span>
        </div>

        <footer className="inventory-modal-footer">
          <button type="button" onClick={onCancel}>
            Cancelar
          </button>
          <button
            type="button"
            className="inventory-modal-confirm"
            onClick={() => onConfirm(amount)}
          >
            {confirmLabel}
          </button>
        </footer>
      </div>
    </div>,
    document.body,
  );
}
