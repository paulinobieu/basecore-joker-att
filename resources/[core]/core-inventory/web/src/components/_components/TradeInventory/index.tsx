import { useEffect, useMemo, useState } from "react";
import {
  IconArrowsExchange,
  IconCheck,
  IconCoin,
  IconUser,
  IconX,
} from "@tabler/icons-react";

import { Post } from "@/hooks/post";
import { useTrade } from "@/stores/useNui";
import type { ITradeOffer } from "@/types";

const moneyFormatter = new Intl.NumberFormat("pt-BR");
const amountFormatter = new Intl.NumberFormat("pt-BR");

function formatMoney(value: number) {
  return `R$ ${moneyFormatter.format(Number.isFinite(value) ? value : 0)}`;
}

interface OfferGridProps {
  offer: ITradeOffer;
  onWithdraw?: (slot: string) => void;
}

/** só os slots ocupados são renderizados: a oferta nasce vazia e cresce */
function OfferGrid({ offer, onWithdraw }: OfferGridProps) {
  const filledSlots = useMemo(
    () =>
      Object.keys(offer.items)
        .filter((slot) => offer.items[slot])
        .sort((first, second) => Number(first) - Number(second)),
    [offer.items],
  );

  if (filledSlots.length === 0) {
    return <p className="inventory-trade-empty">Nada oferecido ainda.</p>;
  }

  return (
    <div className="inventory-trade-grid">
      {filledSlots.map((slot) => {
        const item = offer.items[slot];
        if (!item) return null;

        const content = (
          <>
            <div className="inventory-item-meta">
              <span className="inventory-item-amount">
                x{amountFormatter.format(item.amount)}
              </span>
            </div>
            <img className="inventory-item-image" src={item.image} alt="" />
          </>
        );

        if (!onWithdraw) {
          return (
            <div
              key={slot}
              className="inventory-slot"
              aria-label={`${item.name}, ${item.amount}`}
            >
              {content}
            </div>
          );
        }

        return (
          <button
            key={slot}
            type="button"
            className="inventory-slot inventory-item inventory-trade-item"
            aria-label={`Retirar ${item.name} da oferta`}
            onClick={() => onWithdraw(slot)}
          >
            {content}
            <span aria-hidden="true" className="inventory-trade-remove">
              <IconX stroke={3} />
            </span>
          </button>
        );
      })}
    </div>
  );
}

export function TradeInventory() {
  const trade = useTrade((state) => state.current);
  const [moneyDraft, setMoneyDraft] = useState("");

  const selfMoney = trade?.self.money ?? 0;
  const selfConfirmed = trade?.self.confirmed ?? false;

  // o servidor é a fonte de verdade: enquanto não estamos editando o campo,
  // ele reflete o valor confirmado da sessão
  useEffect(() => {
    setMoneyDraft(selfMoney > 0 ? String(selfMoney) : "");
  }, [selfMoney]);

  if (!trade) return null;

  const commitMoney = () => {
    const parsed = Number(moneyDraft);
    const amount =
      Number.isFinite(parsed) && parsed > 0 ? Math.floor(parsed) : 0;

    setMoneyDraft(amount > 0 ? String(amount) : "");
    if (amount !== selfMoney) Post.send("setTradeMoney", { amount });
  };

  const handleWithdraw = (slot: string) => {
    if (selfConfirmed) return;
    Post.send("withdrawTradeItem", { slot });
  };

  return (
    <aside className="inventory-trade-panel" aria-label="Negociação">
      <header className="inventory-trade-header">
        <div className="inventory-trade-identity">
          <span className="inventory-trade-tag">
            <IconArrowsExchange aria-hidden="true" stroke={2} />
            Negociação
          </span>
          <strong className="inventory-trade-partner">
            {trade.partnerName}
          </strong>
        </div>

        <div className="inventory-trade-avatar">
          {trade.partnerImage ? (
            <img
              className="inventory-avatar-image"
              src={trade.partnerImage}
              alt=""
            />
          ) : (
            <IconUser
              aria-hidden="true"
              className="inventory-avatar-placeholder"
              stroke={1.5}
            />
          )}
        </div>
      </header>

      <section className="inventory-trade-offer">
        <div className="inventory-trade-offer-head">
          <span className="inventory-label">A pessoa está oferecendo</span>
          <span
            className={`inventory-trade-status ${
              trade.partner.confirmed ? "inventory-trade-status-ready" : ""
            }`}
          >
            {trade.partner.confirmed ? "Confirmado" : "Aguardando..."}
          </span>
        </div>

        <OfferGrid offer={trade.partner} />

        <div className="inventory-trade-money">
          <span>
            <IconCoin aria-hidden="true" stroke={1.8} />
            Dinheiro
          </span>
          <strong>{formatMoney(trade.partner.money)}</strong>
        </div>
      </section>

      <section className="inventory-trade-offer">
        <div className="inventory-trade-offer-head">
          <span className="inventory-label">Sua oferta</span>
          <span
            className={`inventory-trade-status ${
              selfConfirmed ? "inventory-trade-status-ready" : ""
            }`}
          >
            {selfConfirmed ? "Confirmado" : "Editando"}
          </span>
        </div>

        <OfferGrid offer={trade.self} onWithdraw={handleWithdraw} />

        <div className="inventory-trade-money">
          <span>
            <IconCoin aria-hidden="true" stroke={1.8} />
            Dinheiro
          </span>
          <input
            type="number"
            min={0}
            step={1}
            inputMode="numeric"
            className="inventory-trade-money-input"
            aria-label="Dinheiro oferecido"
            placeholder="0"
            value={moneyDraft}
            disabled={selfConfirmed}
            onChange={(event) => setMoneyDraft(event.target.value)}
            onBlur={commitMoney}
            onKeyDown={(event) => {
              if (event.key === "Enter") event.currentTarget.blur();
            }}
          />
        </div>

        <p className="inventory-trade-hint">
          Clique com o <strong>botão direito</strong> num item do inventário
          para oferecê-lo.
        </p>
      </section>

      <div className="inventory-trade-actions">
        <button
          type="button"
          className="inventory-trade-cancel"
          onClick={() => Post.send("cancelTrade", {})}
        >
          <IconX aria-hidden="true" stroke={2} />
          Cancelar
        </button>
        <button
          type="button"
          className="inventory-trade-confirm"
          disabled={selfConfirmed}
          onClick={() => Post.send("confirmTrade", {})}
        >
          <IconCheck aria-hidden="true" stroke={2} />
          {selfConfirmed ? "Aguardando" : "Confirmar"}
        </button>
      </div>
    </aside>
  );
}
