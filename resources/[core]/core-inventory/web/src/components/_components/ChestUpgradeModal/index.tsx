import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { IconArchive, IconArrowRight, IconX } from "@tabler/icons-react";

import { Post } from "@/hooks/post";
import { useChestUpgrade } from "@/stores/useNui";

const priceFormatter = new Intl.NumberFormat("pt-BR", {
  maximumFractionDigits: 2,
});

function getCallbackError(result: unknown) {
  if (result === false) return "Não foi possível concluir o upgrade.";
  if (!result || typeof result !== "object") return null;

  const response = result as {
    ok?: unknown;
    success?: unknown;
    message?: unknown;
  };
  if (response.ok !== false && response.success !== false) return null;

  return typeof response.message === "string" && response.message.length > 0
    ? response.message
    : "Não foi possível concluir o upgrade.";
}

export function ChestUpgradeModal() {
  const quote = useChestUpgrade((state) => state.current);
  const setQuote = useChestUpgrade((state) => state.set);
  const confirmButtonRef = useRef<HTMLButtonElement>(null);
  const [isConfirming, setIsConfirming] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!quote) return;
    setError("");
    setIsConfirming(false);
    confirmButtonRef.current?.focus();
  }, [quote]);

  if (!quote) return null;

  const hasCapacityComparison =
    quote.currentCapacity !== undefined && quote.nextCapacity !== undefined;
  const formatCapacity = (value: number) =>
    `${priceFormatter.format(value)}${quote.capacityUnit ? ` ${quote.capacityUnit}` : ""}`;

  const handleConfirm = async () => {
    if (isConfirming) return;

    setIsConfirming(true);
    setError("");
    try {
      const result = await Post.create("confirmChestUpgrade", {});
      const callbackError = getCallbackError(result);
      if (callbackError) {
        setError(callbackError);
        return;
      }

      setQuote(null);
    } catch {
      setError("Não foi possível concluir o upgrade.");
    } finally {
      setIsConfirming(false);
    }
  };

  return createPortal(
    <div className="inventory-upgrade-backdrop">
      <section
        className="inventory-upgrade-modal"
        role="dialog"
        aria-modal="true"
        aria-labelledby="inventory-upgrade-title"
        aria-describedby="inventory-upgrade-description"
      >
        <header className="inventory-upgrade-header">
          <div className="inventory-upgrade-heading">
            <span className="inventory-upgrade-icon" aria-hidden="true">
              <IconArchive stroke={2} />
            </span>
            <div>
              <h2 id="inventory-upgrade-title">{quote.title}</h2>
              <p id="inventory-upgrade-description">{quote.description}</p>
            </div>
          </div>

          <button
            type="button"
            className="inventory-upgrade-close"
            aria-label="Fechar upgrade"
            disabled={isConfirming}
            onClick={() => setQuote(null)}
          >
            <IconX aria-hidden="true" stroke={1.8} />
          </button>
        </header>

        {hasCapacityComparison && (
          <div className="inventory-upgrade-comparison">
            <div>
              <span>Atual</span>
              <strong>{formatCapacity(quote.currentCapacity!)}</strong>
            </div>
            <IconArrowRight aria-hidden="true" stroke={1.8} />
            <div>
              <span>Após o upgrade</span>
              <strong>{formatCapacity(quote.nextCapacity!)}</strong>
            </div>
          </div>
        )}

        <div className="inventory-upgrade-price">
          <span>Valor do upgrade</span>
          <strong>
            {quote.currency} {priceFormatter.format(quote.price)}
          </strong>
        </div>

        {error && (
          <p className="inventory-upgrade-error" role="alert">
            {error}
          </p>
        )}

        <footer className="inventory-upgrade-actions">
          <button
            type="button"
            className="inventory-upgrade-cancel"
            disabled={isConfirming}
            onClick={() => setQuote(null)}
          >
            {quote.cancelLabel || "Agora não"}
          </button>
          <button
            ref={confirmButtonRef}
            type="button"
            className="inventory-upgrade-confirm"
            aria-busy={isConfirming}
            disabled={isConfirming}
            onClick={handleConfirm}
          >
            {isConfirming
              ? "Confirmando..."
              : quote.confirmLabel || "Confirmar upgrade"}
          </button>
        </footer>
      </section>
    </div>,
    document.body,
  );
}
