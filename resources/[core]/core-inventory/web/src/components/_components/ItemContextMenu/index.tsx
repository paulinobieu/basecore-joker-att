import { useEffect, useLayoutEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import {
  IconHandGrab,
  IconPackageExport,
  IconSend,
  IconTool,
  IconTrash,
} from "@tabler/icons-react";

import { Post } from "@/hooks/post";
import { useItemMenu } from "@/stores/useNui";
import type { NuiCallbackName } from "@/types";
import {
  getRequestedAmount,
  isWeaponItem,
  parseInventorySlot,
} from "@/utils/inventory";
import { QuantityModal } from "../QuantityModal";

const VIEWPORT_MARGIN = 8;

interface ItemContextMenuProps {
  quantity: number | "";
}

export function ItemContextMenu({ quantity }: ItemContextMenuProps) {
  const target = useItemMenu((state) => state.current);
  const close = useItemMenu((state) => state.close);
  const menuRef = useRef<HTMLDivElement | null>(null);
  const [position, setPosition] = useState({ x: 0, y: 0 });
  const [sending, setSending] = useState<number | null>(null);

  // O modal de envio é estado local: sem zerar quando o alvo muda, o próximo
  // clique direito abriria direto o envio em vez do menu.
  useEffect(() => {
    setSending(null);
  }, [target]);

  useEffect(() => {
    if (!target) return;

    const handlePointerDown = (event: MouseEvent) => {
      if (!menuRef.current?.contains(event.target as Node)) close();
    };
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") close();
    };

    window.addEventListener("mousedown", handlePointerDown);
    window.addEventListener("keydown", handleKeyDown, true);
    return () => {
      window.removeEventListener("mousedown", handlePointerDown);
      window.removeEventListener("keydown", handleKeyDown, true);
    };
  }, [target, close]);

  // reposiciona antes da pintura para o menu nunca sair da tela
  useLayoutEffect(() => {
    if (!target || !menuRef.current) return;

    const { width, height } = menuRef.current.getBoundingClientRect();
    const maxX = window.innerWidth - width - VIEWPORT_MARGIN;
    const maxY = window.innerHeight - height - VIEWPORT_MARGIN;

    setPosition({
      x: Math.max(VIEWPORT_MARGIN, Math.min(target.x, maxX)),
      y: Math.max(VIEWPORT_MARGIN, Math.min(target.y, maxY)),
    });
  }, [target]);

  if (!target) return null;

  const source = parseInventorySlot(target.id);
  if (!source || source.section === "ground") return null;

  const amount = getRequestedAmount(quantity, target.item.amount);
  const isWeapon = isWeaponItem(target.item);
  const hasAttachs = Object.keys(target.item.attachs ?? {}).length > 0;

  const run = (callback: NuiCallbackName) => {
    Post.send(callback, { section: source.section, slot: source.slot, amount });
    close();
  };

  if (sending !== null) {
    return (
      <QuantityModal
        title="Enviar item"
        subtitle={target.item.name}
        max={target.item.amount}
        initial={sending}
        confirmLabel="Enviar"
        onCancel={close}
        onConfirm={(confirmedAmount) => {
          Post.send("sendItem", {
            section: source.section,
            slot: source.slot,
            amount: confirmedAmount,
          });
          close();
        }}
      />
    );
  }

  return createPortal(
    <div
      ref={menuRef}
      role="menu"
      className="inventory-item-menu"
      aria-label={target.item.name}
      style={{ left: `${position.x}px`, top: `${position.y}px` }}
      onContextMenu={(event) => event.preventDefault()}
    >
      <button type="button" role="menuitem" onClick={() => run("useItem")}>
        <IconHandGrab aria-hidden="true" stroke={1.8} />
        Usar
      </button>

      {source.section === "inventory" && (
        <button
          type="button"
          role="menuitem"
          onClick={() => setSending(Math.max(1, amount))}
        >
          <IconSend aria-hidden="true" stroke={1.8} />
          Enviar
        </button>
      )}

      {isWeapon && (
        <button
          type="button"
          role="menuitem"
          className="inventory-item-menu-highlight"
          onClick={() => run("unloadWeapon")}
        >
          <IconPackageExport aria-hidden="true" stroke={1.8} />
          Descarregar
        </button>
      )}

      {isWeapon && hasAttachs && (
        <button
          type="button"
          role="menuitem"
          className="inventory-item-menu-highlight"
          onClick={() => run("detachWeapon")}
        >
          <IconTool aria-hidden="true" stroke={1.8} />
          Desmontar
        </button>
      )}

      <button
        type="button"
        role="menuitem"
        className="inventory-item-menu-danger"
        onClick={() => run("dropItem")}
      >
        <IconTrash aria-hidden="true" stroke={1.8} />
        Descartar
      </button>
    </div>,
    document.body,
  );
}
