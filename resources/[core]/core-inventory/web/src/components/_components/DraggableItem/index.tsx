import { memo, useEffect, useRef, useState, type MouseEvent } from "react";
import { createPortal } from "react-dom";
import {
  IconBarcode,
  IconClock,
  IconPackageExport,
  IconTargetArrow,
  IconTool,
  IconUnlink,
  IconWeight,
} from "@tabler/icons-react";
import {
  useDndContext,
  useDraggable,
  type UniqueIdentifier,
} from "@dnd-kit/core";

import { Post } from "@/hooks/post";
import { useItemMenu, useItemTooltip, useTrade } from "@/stores/useNui";
import type { IItem } from "@/types";
import { isWeaponItem, parseInventorySlot } from "@/utils/inventory";

/** folga para o ponteiro atravessar o vão entre o slot e a tooltip */
const TOOLTIP_CLOSE_DELAY = 220;

const amountFormatter = new Intl.NumberFormat("pt-BR");
const weightFormatter = new Intl.NumberFormat("pt-BR", {
  maximumFractionDigits: 1,
});

function formatAmount(value: unknown) {
  const numericValue = Number(value);
  return Number.isFinite(numericValue)
    ? amountFormatter.format(numericValue)
    : "0";
}

function formatWeight(value: unknown) {
  const numericValue = Number(value);
  return `${weightFormatter.format(Number.isFinite(numericValue) ? numericValue : 0)} kg`;
}

/**
 * `item.days` é o `Durability` do Item.lua, que está em HORAS — o servidor usa
 * `3600 * Durability` para decidir se o item quebrou. O formato é compacto de
 * propósito: a linha do tooltip não quebra.
 */
function formatDurability(item: IItem) {
  const elapsedSeconds = Number(item.durability);
  const lifespanHours = Number(item.days);
  if (
    !Number.isFinite(elapsedSeconds) ||
    !Number.isFinite(lifespanHours) ||
    elapsedSeconds < 0 ||
    lifespanHours <= 0
  ) {
    return null;
  }

  const remainingSeconds = Math.max(
    0,
    Math.floor(lifespanHours * 3600 - elapsedSeconds),
  );
  if (remainingSeconds === 0) return "Agora";

  const remainingDays = Math.floor(remainingSeconds / 86400);
  const remainingHours = Math.floor((remainingSeconds % 86400) / 3600);

  if (remainingDays > 0) {
    return remainingHours > 0
      ? `${remainingDays}d ${remainingHours}h`
      : `${remainingDays}d`;
  }

  if (remainingHours > 0) return `${remainingHours}h`;

  return "< 1h";
}

function isItemBroken(item: IItem) {
  const elapsedSeconds = Number(item.durability);
  const lifespanDays = Number(item.days);

  return (
    Number.isFinite(elapsedSeconds) &&
    Number.isFinite(lifespanDays) &&
    elapsedSeconds >= 0 &&
    lifespanDays > 0 &&
    elapsedSeconds >= lifespanDays * 86400
  );
}

function ItemContent({
  item,
  hideMeta = false,
  broken = false,
}: {
  item: IItem;
  hideMeta?: boolean;
  broken?: boolean;
}) {
  return (
    <>
      {!hideMeta && (
        <div className="inventory-item-meta">
          <span className="inventory-item-amount">
            x{formatAmount(item.amount)}
          </span>
        </div>
      )}
      {broken && (
        <IconUnlink
          aria-hidden="true"
          className="inventory-item-broken-icon"
          stroke={2}
        />
      )}
      <img className="inventory-item-image" src={item.image} alt="" />
    </>
  );
}

type TooltipAlignment = "left" | "right";

interface DraggableItemProps {
  id: UniqueIdentifier;
  item: IItem;
  onClick?: (event: MouseEvent<HTMLButtonElement>) => void;
}

export const DraggableItem = memo(function DraggableItem({
  id,
  item,
  onClick,
}: DraggableItemProps) {
  const { active } = useDndContext();
  const openItemMenu = useItemMenu((state) => state.open);
  const isTrading = useTrade((state) => state.current !== null);
  const { attributes, listeners, setNodeRef, transform, isDragging } =
    useDraggable({
      id,
      data: item,
    });
  const tooltipId = String(id);
  const showTooltip = useItemTooltip((state) => state.current === tooltipId);
  const openTooltip = useItemTooltip((state) => state.open);
  const dismissTooltip = useItemTooltip((state) => state.close);
  const [tooltipPosition, setTooltipPosition] = useState<{
    x: number;
    y: number;
    align: TooltipAlignment;
  }>({ x: 0, y: 0, align: "right" });
  const tooltipDelayRef = useRef<number | null>(null);

  // a tooltip virou o painel do armamento: item comum não tem o que mostrar
  const isWeapon = isWeaponItem(item);
  const source = parseInventorySlot(id);
  // descarregar e desmontar mexem no meta do slot da mochila; contêiner e chão
  // não passam por esses callbacks
  const canAct = isWeapon && source?.section === "inventory";
  const hasAttachs = Object.keys(item.attachs ?? {}).length > 0;

  const clearTooltipDelay = () => {
    if (tooltipDelayRef.current !== null) {
      window.clearTimeout(tooltipDelayRef.current);
      tooltipDelayRef.current = null;
    }
  };

  // arrastar cancela a tooltip; sair da tela sem fechar deixaria o alvo preso
  useEffect(() => {
    if (!active) return;

    if (tooltipDelayRef.current !== null) {
      window.clearTimeout(tooltipDelayRef.current);
      tooltipDelayRef.current = null;
    }
    dismissTooltip(tooltipId);
  }, [active, tooltipId, dismissTooltip]);

  useEffect(
    () => () => {
      if (tooltipDelayRef.current !== null) {
        window.clearTimeout(tooltipDelayRef.current);
        tooltipDelayRef.current = null;
      }
      dismissTooltip(tooltipId);
    },
    [tooltipId, dismissTooltip],
  );

  const handleMouseEnter = (event: MouseEvent<HTMLButtonElement>) => {
    if (active || !isWeapon) return;

    const slotBounds = event.currentTarget.getBoundingClientRect();
    const slotCenter = slotBounds.left + slotBounds.width / 2;
    const align = slotCenter > window.innerWidth / 2 ? "left" : "right";
    const anchorX = align === "left" ? slotBounds.left : slotBounds.right;
    const anchorY = slotBounds.top + slotBounds.height / 2;

    setTooltipPosition({
      x: (anchorX / window.innerWidth) * 100,
      y: (anchorY / window.innerHeight) * 100,
      align,
    });

    clearTooltipDelay();
    tooltipDelayRef.current = window.setTimeout(() => {
      openTooltip(tooltipId);
      tooltipDelayRef.current = null;
    }, 160);
  };

  // fechamento adiado: os botões vivem dentro da tooltip, então o ponteiro
  // precisa poder sair do slot e chegar nela sem que ela suma no caminho
  const handleMouseLeave = () => {
    clearTooltipDelay();
    if (!isWeapon) return;

    tooltipDelayRef.current = window.setTimeout(() => {
      dismissTooltip(tooltipId);
      tooltipDelayRef.current = null;
    }, TOOLTIP_CLOSE_DELAY);
  };

  const closeTooltip = () => {
    clearTooltipDelay();
    dismissTooltip(tooltipId);
  };

  const handleRightClick = (event: MouseEvent<HTMLButtonElement>) => {
    event.preventDefault();
    closeTooltip();

    // durante a negociação o botão direito oferece o item direto, sem menu
    if (isTrading) {
      onClick?.(event);
      return;
    }

    openItemMenu({
      id: String(id),
      item,
      x: event.clientX,
      y: event.clientY,
    });
  };

  const runWeaponAction = (callback: "unloadWeapon" | "detachWeapon") => {
    if (!source) return;

    Post.send(callback, {
      section: source.section,
      slot: source.slot,
      amount: 1,
    });
    closeTooltip();
  };

  const durabilityRemaining = formatDurability(item);
  const broken = isItemBroken(item);
  const hasAmmo = typeof item.ammo === "number" && Number.isFinite(item.ammo);
  const tooltipDetails = [
    ...(hasAmmo
      ? [
          {
            key: "ammo",
            icon: IconTargetArrow,
            label: "Munição",
            value: formatAmount(item.ammo),
          },
        ]
      : []),
    ...(item.attachNames?.length
      ? [
          {
            key: "attachs",
            icon: IconTool,
            label: "Acessórios",
            value: item.attachNames.join(", "),
          },
        ]
      : []),
    ...(item.serial
      ? [
          {
            key: "serial",
            icon: IconBarcode,
            label: "Serial",
            value: item.serial,
          },
        ]
      : []),
    ...(durabilityRemaining
      ? [
          {
            key: "durability",
            icon: IconClock,
            label: "Quebra em",
            value: durabilityRemaining,
          },
        ]
      : []),
  ];

  return (
    <>
      <button
        type="button"
        aria-label={`${item.name}${broken ? ", quebrado" : ""}`}
        ref={setNodeRef}
        {...listeners}
        {...attributes}
        onClick={onClick}
        onMouseEnter={handleMouseEnter}
        onMouseLeave={handleMouseLeave}
        onContextMenu={handleRightClick}
        className={`inventory-slot inventory-item ${
          isDragging ? "inventory-item-dragging" : ""
        }`}
        style={{
          transform: transform
            ? `translate3d(${transform.x}px, ${transform.y}px, 0)`
            : undefined,
        }}
      >
        <ItemContent item={item} hideMeta={isDragging} broken={broken} />
      </button>

      {isWeapon &&
        showTooltip &&
        !active &&
        createPortal(
          <div
            className="inventory-tooltip-layer"
            onMouseEnter={clearTooltipDelay}
            onMouseLeave={handleMouseLeave}
            style={{
              left: `${tooltipPosition.x}vw`,
              top: `${tooltipPosition.y}vh`,
              transform:
                tooltipPosition.align === "left"
                  ? "translate(calc(-100% - 0.75rem), -50%)"
                  : "translate(0.75rem, -50%)",
            }}
          >
            <div className="inventory-tooltip">
              <div className="inventory-tooltip-header">
                <span className="inventory-tooltip-title">{item.name}</span>
                <span className="inventory-tooltip-weight">
                  <IconWeight aria-hidden="true" stroke={1.8} />
                  {formatWeight(item.peso)}
                </span>
              </div>

              {tooltipDetails.length > 0 && (
                <dl className="inventory-tooltip-details">
                  {tooltipDetails.map(
                    ({ key, icon: DetailIcon, label, value }) => (
                      <div key={key}>
                        <dt>
                          <DetailIcon aria-hidden="true" stroke={1.8} />
                          {label}
                        </dt>
                        <dd>{value}</dd>
                      </div>
                    ),
                  )}
                </dl>
              )}

              {canAct && (
                <div className="inventory-tooltip-actions">
                  <button
                    type="button"
                    onClick={() => runWeaponAction("unloadWeapon")}
                  >
                    <IconPackageExport aria-hidden="true" stroke={1.8} />
                    Descarregar
                  </button>

                  {hasAttachs && (
                    <button
                      type="button"
                      onClick={() => runWeaponAction("detachWeapon")}
                    >
                      <IconTool aria-hidden="true" stroke={1.8} />
                      Desmontar
                    </button>
                  )}
                </div>
              )}
            </div>
          </div>,
          document.body,
        )}
    </>
  );
});

export const DragOverlayItem = memo(function DragOverlayItem({
  item,
}: {
  item: IItem;
}) {
  const broken = isItemBroken(item);

  return (
    <div
      aria-hidden="true"
      className="inventory-slot inventory-item inventory-drag-overlay"
    >
      <ItemContent item={item} broken={broken} />
    </div>
  );
});
