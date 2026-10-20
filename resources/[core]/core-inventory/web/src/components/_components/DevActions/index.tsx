import { IconArrowsExchange, IconBuildingStore, IconX } from "@tabler/icons-react";

import { dispatchNuiDebugEvent } from "@/utils/debugger";
import { isEnvBrowser } from "@/utils/misc";
import {
  mockExternalItems,
  mockExternalSection,
  mockTradeSession,
} from "@/utils/mocks";
import { useGroundSection, useTrade } from "@/stores/useNui";

/**
 * Atalhos de visualização que só existem fora do jogo. Em produção o modo baú
 * e a negociação chegam por evento do servidor; no browser não há servidor,
 * então os mesmos eventos são despachados na mão.
 */
export function DevActions() {
  const hasExternal = useGroundSection((state) => state.current !== null);
  const hasTrade = useTrade((state) => state.current !== null);

  if (!isEnvBrowser()) return null;

  const openExternal = () => {
    dispatchNuiDebugEvent({ action: "setTrade", data: null });
    dispatchNuiDebugEvent({
      action: "setGroundSection",
      data: mockExternalSection,
    });
    dispatchNuiDebugEvent({ action: "updateDrop", data: mockExternalItems });
  };

  const openTrade = () => {
    dispatchNuiDebugEvent({ action: "setGroundSection", data: null });
    dispatchNuiDebugEvent({ action: "setTrade", data: mockTradeSession });
  };

  const closeAll = () => {
    dispatchNuiDebugEvent({ action: "setGroundSection", data: null });
    dispatchNuiDebugEvent({ action: "setTrade", data: null });
  };

  return (
    <div className="inventory-dev-actions" aria-label="Ações de visualização">
      <span className="inventory-dev-actions-title">Visualização</span>

      <button
        type="button"
        className={`inventory-dev-action ${
          hasExternal ? "inventory-dev-action-active" : ""
        }`}
        onClick={openExternal}
      >
        <IconBuildingStore aria-hidden="true" stroke={1.8} />
        Baú
      </button>

      <button
        type="button"
        className={`inventory-dev-action ${
          hasTrade ? "inventory-dev-action-active" : ""
        }`}
        onClick={openTrade}
      >
        <IconArrowsExchange aria-hidden="true" stroke={1.8} />
        Negociação
      </button>

      <button
        type="button"
        className="inventory-dev-action"
        disabled={!hasExternal && !hasTrade}
        onClick={closeAll}
      >
        <IconX aria-hidden="true" stroke={1.8} />
        Fechar
      </button>
    </div>
  );
}
