import { useState, useRef, useMemo, useEffect } from "react";
import { useAppStore } from "@app/stores/store";
import { fetchNui, sendNui } from "@app/utils/nui";
import {
  getVehicleImage,
  replaceMissingVehicleImage,
  formatCurrency,
} from "@app/utils/format";
import { Modal } from "./Modal";

const GROUP_OF: Record<string, string> = {
  car: "car",
  suv: "car",
  vip: "car",
  motorcycle: "moto",
  bike: "moto",
  truck: "truck",
  service: "truck",
  air: "air",
  vip_air: "air",
  water: "water",
  vip_water: "water",
};

const GROUP_LABEL: Record<string, string> = {
  car: "Carros",
  moto: "Motos",
  truck: "Caminhões",
  air: "Aéreos",
  water: "Náuticos",
  other: "Outros",
};

const GROUP_ORDER = ["car", "moto", "truck", "air", "water", "other"];

type ParkingAction = "out" | "in" | "near";

interface PendingParkingAction {
  action: ParkingAction;
  vehicle?: string;
}

export function Garage() {
  const garageData = useAppStore((s) => s.garageData);
  const close = useAppStore((s) => s.close);

  const [selectedKey, setSelectedKey] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [filter, setFilter] = useState("all");
  const borrowCooldownRef = useRef(false);
  const sellCooldownRef = useRef(false);
  const favoritePendingRef = useRef(new Set<string>());
  const trackerPendingRef = useRef(false);
  const [trackingPlate, setTrackingPlate] = useState<string | null>(null);
  const [pendingParking, setPendingParking] =
    useState<PendingParkingAction | null>(null);
  const [actionFeedback, setActionFeedback] = useState<string | null>(null);

  const [modal, setModal] = useState<null | {
    type: "borrow" | "revoke" | "sell" | "form";
    plate?: string;
    formData?: any;
  }>(null);

  useTicker();

  const isService = garageData?.type === "SERVICE";

  const allVehicles = useMemo(() => {
    if (!garageData?.myVehicles) return [];
    const arr: any[] = [];
    for (const plate in garageData.myVehicles) {
      const v = garageData.myVehicles[plate];
      if (v) {
        arr.push({ ...v, plate });
      }
    }
    arr.sort((a, b) => {
      const favoriteOrder = Number(Boolean(b.favorite)) - Number(Boolean(a.favorite));
      if (favoriteOrder !== 0) return favoriteOrder;
      const nameOrder = (a.name || "").localeCompare(b.name || "");
      if (nameOrder !== 0) return nameOrder;
      return (a.plate || "").localeCompare(b.plate || "");
    });
    return arr;
  }, [garageData]);

  const keyOf = (veh: any) => (isService ? veh.index : veh.plate);

  const tabs = useMemo(() => {
    const present = new Set<string>();
    for (const v of allVehicles) present.add(GROUP_OF[v.category] || "other");
    const list = GROUP_ORDER.filter((g) => present.has(g)).map((g) => ({
      id: g,
      label: GROUP_LABEL[g],
    }));
    if (list.length <= 1) return [];
    return [{ id: "all", label: "Todos" }, ...list];
  }, [allVehicles]);

  const vehicles = useMemo(() => {
    const q = search.trim().toLowerCase();
    return allVehicles.filter((v) => {
      if (filter !== "all" && (GROUP_OF[v.category] || "other") !== filter)
        return false;
      if (!q) return true;
      return (
        (v.name || "").toLowerCase().includes(q) ||
        (v.plate || "").toLowerCase().includes(q)
      );
    });
  }, [allVehicles, search, filter]);

  useEffect(() => {
    if (vehicles.length > 0) {
      const stillThere = vehicles.some((v) => keyOf(v) === selectedKey);
      if (!stillThere) setSelectedKey(keyOf(vehicles[0]));
    }
  }, [vehicles]);

  if (!garageData) return null;

  async function parkOutVehicle(vehicle: string, type: string) {
    if (pendingParking) return;
    setActionFeedback(null);
    setPendingParking({ action: "out", vehicle });

    try {
      const response: any = await fetchNui({
        action: "parkOutVehicle",
        vehicle,
        type,
      });

      if (response?.form) {
        setModal({ type: "form", formData: response.form });
        return;
      }

      if (response?.success) {
        handleClose();
        return;
      }

      setActionFeedback(
        "Não foi possível retirar o veículo. Confira o aviso e tente novamente."
      );
    } finally {
      setPendingParking(null);
    }
  }

  async function parkInVehicle(vehicle: string, type: string) {
    if (pendingParking) return;
    setActionFeedback(null);
    setPendingParking({ action: "in", vehicle });

    try {
      const response: any = await fetchNui({
        action: "parkInVehicle",
        vehicle,
        type,
      });

      if (response?.success) {
        handleClose();
        return;
      }

      setActionFeedback(
        "Não foi possível guardar o veículo. Confira se ele está próximo da garagem."
      );
    } finally {
      setPendingParking(null);
    }
  }

  async function tryParkNearVehicle() {
    if (pendingParking) return;
    setActionFeedback(null);
    setPendingParking({ action: "near" });

    try {
      const response = await fetchNui({ action: "tryParkNearVehicle" });
      if (response) {
        handleClose();
      } else {
        setActionFeedback(
          "Não foi possível verificar o veículo próximo. Tente novamente."
        );
      }
    } finally {
      setPendingParking(null);
    }
  }

  function tryGarageForm() {
    setModal(null);
    sendNui({ action: "tryGarageForm" });
  }

  function tryBorrowVehicle(plate: string, friendId: string) {
    if (borrowCooldownRef.current) return;
    if (!friendId || isNaN(Number(friendId)) || parseInt(friendId) <= 0) {
      setTimeout(() => (borrowCooldownRef.current = false), 500);
      return;
    }
    borrowCooldownRef.current = true;
    setActionFeedback(null);
    setModal(null);
    fetchNui({ action: "tryBorrowVehicle", plate, friendId }).then((r: any) => {
      if (r?.success) {
        garageData.myVehicles[plate].borrowedTo = r.borrowedTo;
        useAppStore.getState().openGarage({ ...garageData });
      } else {
        setActionFeedback(
          "Não foi possível compartilhar a chave. Confira o aviso do servidor."
        );
      }
      setTimeout(() => (borrowCooldownRef.current = false), 500);
    });
  }

  function revokeVehicleBorrow(plate: string) {
    if (borrowCooldownRef.current) return;
    borrowCooldownRef.current = true;
    setActionFeedback(null);
    setModal(null);
    fetchNui({ action: "tryRevokeVehicle", plate }).then((r: any) => {
      if (r?.success) {
        garageData.myVehicles[plate].borrowedTo = false;
        useAppStore.getState().openGarage({ ...garageData });
      } else {
        setActionFeedback(
          "Não foi possível retirar a chave compartilhada. Tente novamente."
        );
      }
      setTimeout(() => (borrowCooldownRef.current = false), 500);
    });
  }

  function trySellVehicle(plate: string, targetId: string, sellPrice: string) {
    if (sellCooldownRef.current) return;
    if (!targetId || isNaN(Number(targetId)) || parseInt(targetId) <= 0) {
      setTimeout(() => (sellCooldownRef.current = false), 500);
      return;
    }
    if (!sellPrice || isNaN(Number(sellPrice)) || parseInt(sellPrice) <= 0) {
      setTimeout(() => (sellCooldownRef.current = false), 500);
      return;
    }
    sellCooldownRef.current = true;
    setActionFeedback(null);
    fetchNui({ action: "trySellVehicle", plate, targetId, sellPrice }).then(
      (response: any) => {
        setModal(null);
        if (response?.success) {
          handleClose();
        } else {
          setActionFeedback(
            "Não foi possível enviar a proposta de venda. Confira o aviso do servidor."
          );
        }
        setTimeout(() => (sellCooldownRef.current = false), 500);
      }
    );
  }

  function updateLocalFavorite(plate: string, favorite: boolean) {
    const current = useAppStore.getState().garageData;
    const currentVehicle = current?.myVehicles?.[plate];
    if (!current || !currentVehicle) return;

    useAppStore.getState().openGarage({
      ...current,
      myVehicles: {
        ...current.myVehicles,
        [plate]: { ...currentVehicle, favorite },
      },
    });
  }

  async function toggleFavorite(veh: any) {
    if (isService || veh.borrowedFrom || favoritePendingRef.current.has(veh.plate))
      return;

    const nextFavorite = !Boolean(veh.favorite);
    favoritePendingRef.current.add(veh.plate);
    updateLocalFavorite(veh.plate, nextFavorite);

    try {
      const response: any = await fetchNui({
        action: "setVehicleFavorite",
        plate: veh.plate,
        favorite: nextFavorite,
      });

      if (!response?.success) {
        updateLocalFavorite(veh.plate, !nextFavorite);
      } else if (typeof response.favorite === "boolean") {
        updateLocalFavorite(veh.plate, response.favorite);
      }
    } catch {
      updateLocalFavorite(veh.plate, !nextFavorite);
    } finally {
      favoritePendingRef.current.delete(veh.plate);
    }
  }

  async function trackSelectedVehicle(veh: any) {
    if (isService || !veh?.plate || trackerPendingRef.current) return;

    trackerPendingRef.current = true;
    setActionFeedback(null);
    setTrackingPlate(veh.plate);

    try {
      const response: any = await fetchNui({
        action: "trackVehicle",
        vehicle: veh.plate,
        type: "personal",
      });
      if (response?.success) {
        handleClose();
      } else {
        setActionFeedback(
          "Não foi possível localizar este veículo. Confira o aviso do servidor."
        );
      }
    } finally {
      trackerPendingRef.current = false;
      setTrackingPlate(null);
    }
  }

  function handleClose() {
    sendNui({ action: "close" });
    close();
  }

  const selectedVeh =
    selectedKey != null
      ? vehicles.find((v) => keyOf(v) === selectedKey) || null
      : null;

  const brandLogo = (window as any).GARAGE_LOGO_URL as string | undefined;
  const brandName =
    garageData.name || (isService ? "Aluguel de Veículos" : "Garagem");

  const bodyPct = selectedVeh ? healthPct(selectedVeh).body : 0;
  const specs = selectedVeh ? buildSpecs(selectedVeh, isService) : [];
  const expireLabel = selectedVeh ? buildExpire(selectedVeh, isService) : null;
  const selectedTaxPaid = selectedVeh
    ? isService || taxIsPaid(selectedVeh)
    : true;
  const selectedPending =
    selectedVeh && pendingParking?.vehicle === keyOf(selectedVeh)
      ? pendingParking.action
      : null;

  return (
    <>
      <div id="garage-panel" className="ga">
        {/* ---------------------------- TOP ---------------------------- */}
        <div className="ga-top">
          <div className="ga-brand">
            {brandLogo ? (
              <img src={brandLogo} alt={brandName} />
            ) : (
              <span>{brandName}</span>
            )}
          </div>
          <button type="button" className="ga-exit" onClick={handleClose}>
            <div className="ga-key">ESC</div>
            <span>Pressione para sair</span>
          </button>
        </div>

        {/* ---------------------------- BODY --------------------------- */}
        <div className="ga-body">
          {/* ------------------------ SIDE ---------------------------- */}
          <div className="ga-side">
            {selectedVeh ? (
              <>
                <div className="ga-side-media">
                  {!isService && (
                    <button
                      type="button"
                      className={`ga-pin${trackingPlate === selectedVeh.plate ? " tracking" : ""}`}
                      aria-label={`Rastrear ${selectedVeh.name}`}
                      title="Rastrear veículo"
                      disabled={trackingPlate !== null}
                      onClick={() => trackSelectedVehicle(selectedVeh)}
                    >
                      <i className="fa-solid fa-location-dot" />
                    </button>
                  )}
                  <img
                    src={getVehicleImage(selectedVeh.index)}
                    onError={replaceMissingVehicleImage}
                  />
                  <div className="ga-cond-row">
                    <div className="ga-cond">
                      <div
                        className="ga-cond-fill"
                        style={{ width: `${bodyPct}%` }}
                      />
                    </div>
                    {!isService && (
                      <button
                        type="button"
                        className="ga-sell"
                        onClick={() =>
                          setModal({ type: "sell", plate: selectedVeh.plate })
                        }
                      >
                        Vender veículo <i className="fa-solid fa-arrow-right" />
                      </button>
                    )}
                  </div>
                </div>

                <div className="ga-side-body">
                  <div className="ga-side-label">Veículo selecionado</div>
                  <div className="ga-side-name">{selectedVeh.name}</div>
                  {!isService && (
                    <div className="ga-side-meta">
                      <span className="ga-plate">{selectedVeh.plate}</span>
                      {selectedVeh.borrowedFrom && (
                        <span className="ga-ownership">
                          <i className="fa-solid fa-key" /> Emprestado para você
                        </span>
                      )}
                      {selectedVeh.borrowedTo && (
                        <span className="ga-ownership">
                          <i className="fa-solid fa-user-group" /> Chave compartilhada
                        </span>
                      )}
                    </div>
                  )}

                  {expireLabel && <div className="ga-expire">{expireLabel}</div>}

                  <div className="ga-specs-title">
                    <i className="fa-solid fa-gear" />
                    <span>Especificações</span>
                  </div>

                  <div className="ga-specs">
                    {specs.map((s) => (
                      <div className="ga-spec" key={s.label}>
                        <div className="ga-spec-head">
                          <span>{s.label}</span>
                          <span>{s.value}</span>
                        </div>
                        <div className="ga-spec-bar">
                          <div
                            className="ga-spec-fill"
                            style={{ width: `${s.pct}%` }}
                          />
                        </div>
                      </div>
                    ))}
                  </div>

                  <div className="ga-actions">
                    {actionFeedback && (
                      <div className="ga-action-feedback" role="status" aria-live="polite">
                        <i className="fa-solid fa-circle-exclamation" />
                        <span>{actionFeedback}</span>
                      </div>
                    )}
                    <button
                      type="button"
                      className="ga-btn"
                      disabled={pendingParking !== null}
                      onClick={() =>
                        parkOutVehicle(
                          keyOf(selectedVeh),
                          isService ? "rental" : "personal"
                        )
                      }
                    >
                      {selectedPending === "out" && <LoadingIcon />}
                      {selectedPending === "out"
                        ? isService
                          ? "Alugando..."
                          : selectedTaxPaid
                          ? "Retirando..."
                          : "Consultando taxa..."
                        : isService
                        ? "Alugar veículo"
                        : selectedTaxPaid
                        ? "Retirar veículo"
                        : "Regularizar taxa"}
                    </button>
                    <button
                      type="button"
                      className="ga-btn ghost"
                      disabled={pendingParking !== null}
                      onClick={() =>
                        parkInVehicle(
                          keyOf(selectedVeh),
                          isService ? "rental" : "personal"
                        )
                      }
                    >
                      {selectedPending === "in" && <LoadingIcon />}
                      {selectedPending === "in"
                        ? "Guardando..."
                        : isService
                        ? "Devolver veículo"
                        : "Guardar selecionado"}
                    </button>
                    {!isService && (
                      <div className="ga-actions-row">
                        <button
                          type="button"
                          className="ga-btn small"
                          disabled={pendingParking !== null}
                          onClick={() =>
                            setModal({
                              type: selectedVeh.borrowedTo
                                ? "revoke"
                                : "borrow",
                              plate: selectedVeh.plate,
                            })
                          }
                        >
                          <i className="fa-solid fa-key" />
                          {selectedVeh.borrowedTo ? "Retirar chave" : "Dar chave"}
                        </button>
                        <button
                          type="button"
                          className="ga-btn small"
                          disabled={pendingParking !== null}
                          onClick={tryParkNearVehicle}
                        >
                          {pendingParking?.action === "near" ? (
                            <LoadingIcon />
                          ) : (
                            <i className="fa-solid fa-square-parking" />
                          )}
                          {pendingParking?.action === "near"
                            ? "Guardando..."
                            : "Guardar próximo"}
                        </button>
                      </div>
                    )}
                  </div>
                </div>
              </>
            ) : (
              <div className="ga-side-empty">
                <i className="fa-solid fa-car-side" />
                <span>Selecione um veículo</span>
              </div>
            )}
          </div>

          {/* ------------------------ MAIN ---------------------------- */}
          <div className="ga-main">
            <div className="ga-main-head">
              <div className="ga-main-title">
                <span className="ga-main-icon">
                  <i className="fa-solid fa-warehouse" />
                </span>
                <span>
                  {isService ? "VEÍCULOS PARA ALUGUEL" : "VEÍCULOS DISPONÍVEIS"}
                </span>
                <span className="ga-count">{vehicles.length}</span>
              </div>

              <div className="ga-head-tools">
                <div className="ga-search">
                  <i className="fa-solid fa-magnifying-glass" />
                  <input
                    aria-label="Pesquisar por nome ou placa"
                    placeholder="Pesquisar nome ou placa"
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                  />
                  {search && (
                    <button
                      type="button"
                      className="ga-search-clear"
                      aria-label="Limpar pesquisa"
                      onClick={() => setSearch("")}
                    >
                      <i className="fa-solid fa-xmark" />
                    </button>
                  )}
                </div>
                {tabs.length > 0 && (
                  <div className="ga-tabs">
                    {tabs.map((t) => (
                      <button
                        type="button"
                        key={t.id}
                        className={`ga-tab${filter === t.id ? " active" : ""}`}
                        aria-pressed={filter === t.id}
                        onClick={() => setFilter(t.id)}
                      >
                        {t.label}
                      </button>
                    ))}
                  </div>
                )}
              </div>
            </div>

            <div className="ga-banner">
              <span className="ga-banner-icon">
                <i className="fa-solid fa-circle-info" />
              </span>
              <span>
                {isService
                  ? "Os veículos desta garagem pertencem ao serviço e devem ser devolvidos ao fim do expediente. Retire apenas um veículo por vez e evite deixá-lo abandonado na via pública."
                  : "Selecione um veículo na lista para conferir placa, combustível, lataria e documentação. A garagem fecha automaticamente quando uma retirada ou guarda é concluída."}
              </span>
            </div>

            <div className="ga-grid">
              {vehicles.map((veh) => (
                <GarageCard
                  key={keyOf(veh)}
                  veh={veh}
                  isService={isService}
                  selected={selectedKey === keyOf(veh)}
                  onClick={() => {
                    setSelectedKey(keyOf(veh));
                    setActionFeedback(null);
                  }}
                  onPayClick={() => parkOutVehicle(veh.plate, "personal")}
                  favorite={!isService && Boolean(veh.favorite)}
                  onFavoriteClick={
                    !isService && !veh.borrowedFrom
                      ? () => toggleFavorite(veh)
                      : undefined
                  }
                />
              ))}
              {vehicles.length === 0 && (
                <div className="ga-empty">
                  <i className="fa-solid fa-circle-xmark" />
                  <span>
                    {isService
                      ? "Nenhum veículo disponível."
                      : search || filter !== "all"
                      ? "Nenhum veículo encontrado."
                      : "Você ainda não possui nenhum veículo."}
                  </span>
                  {(search || filter !== "all") && (
                    <button
                      type="button"
                      onClick={() => {
                        setSearch("");
                        setFilter("all");
                      }}
                    >
                      Limpar filtros
                    </button>
                  )}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {modal?.type === "borrow" && modal.plate && (
        <BorrowModal
          onConfirm={(friendId) => tryBorrowVehicle(modal.plate!, friendId)}
          onCancel={() => setModal(null)}
        />
      )}
      {modal?.type === "revoke" && modal.plate && (
        <RevokeModal
          borrowedTo={garageData.myVehicles[modal.plate]?.borrowedTo}
          onConfirm={() => revokeVehicleBorrow(modal.plate!)}
          onCancel={() => setModal(null)}
        />
      )}
      {modal?.type === "sell" && modal.plate && (
        <SellModal
          onConfirm={(targetId, price) =>
            trySellVehicle(modal.plate!, targetId, price)
          }
          onCancel={() => setModal(null)}
        />
      )}
      {modal?.type === "form" && modal.formData && (
        <Modal
          onConfirm={tryGarageForm}
          onCancel={() => setModal(null)}
          title={modal.formData.title}
          icon="fa-solid fa-circle-exclamation"
          showClose={false}
        >
          <div
            className="v-modal-description"
            dangerouslySetInnerHTML={{ __html: modal.formData.description }}
          />
        </Modal>
      )}
    </>
  );
}

/* ------------------------------------------------------------------ */
/* Card                                                                */
/* ------------------------------------------------------------------ */

function GarageCard({
  veh,
  isService,
  selected,
  onClick,
  onPayClick,
  favorite,
  onFavoriteClick,
}: {
  veh: any;
  isService: boolean;
  selected: boolean;
  onClick: () => void;
  onPayClick?: () => void;
  favorite: boolean;
  onFavoriteClick?: () => void;
}) {
  const hasBorrow = veh.borrowedFrom || veh.borrowedTo;
  const isPaid = isService || taxIsPaid(veh);

  return (
    <div
      className={`ga-card${selected ? " selected" : ""}${
        isPaid ? "" : " unpaid"
      }`}
      onClick={onClick}
    >
      <div className="ga-card-media">
        {hasBorrow && (
          <div className="ga-card-flag">
            <i className="fa-solid fa-user-group" />
          </div>
        )}
        <img
          src={getVehicleImage(veh.index)}
          onError={replaceMissingVehicleImage}
        />
        {!isPaid && (
          <button
            type="button"
            className="ga-card-pay"
            onClick={(e) => {
              e.stopPropagation();
              onPayClick?.();
            }}
          >
            PAGAR
          </button>
        )}
      </div>
      <div className="ga-card-foot">
        <span className="ga-card-identity">
          <span className="ga-card-name">{veh.name}</span>
          {!isService && <span className="ga-card-plate">{veh.plate}</span>}
        </span>
        {onFavoriteClick && (
          <button
            type="button"
            className={`ga-favorite${favorite ? " active" : ""}`}
            aria-label={favorite ? "Remover dos favoritos" : "Adicionar aos favoritos"}
            aria-pressed={favorite}
            title={favorite ? "Remover dos favoritos" : "Adicionar aos favoritos"}
            onClick={(event) => {
              event.stopPropagation();
              onFavoriteClick();
            }}
          >
            <i className={`${favorite ? "fa-solid" : "fa-regular"} fa-star`} />
          </button>
        )}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Helpers                                                             */
/* ------------------------------------------------------------------ */

function useTicker() {
  const [, force] = useState(0);
  useEffect(() => {
    const id = setInterval(() => force((n) => n + 1), 1000);
    return () => clearInterval(id);
  }, []);
}

function LoadingIcon() {
  return <i className="fa-solid fa-spinner ga-spinner" aria-hidden="true" />;
}

function healthPct(veh: any) {
  const fuel = parseInt(String(veh?.health?.[2] ?? 0)) || 0;
  const body = parseInt(String((veh?.health?.[1] ?? 0) / 10)) || 0;
  return { fuel: clampPct(fuel), body: clampPct(body) };
}

function clampPct(v: number) {
  return Math.max(0, Math.min(100, v));
}

function taxTimeOf(veh: any) {
  return veh?.expire_time > 0 ? veh.expire_time : veh?.tax;
}

function taxIsPaid(veh: any) {
  const t = taxTimeOf(veh);
  return !veh?.expired && !!t && t * 1000 > Date.now();
}

function buildExpire(veh: any, isService: boolean): string | null {
  if (isService) return null;
  const t = taxTimeOf(veh);
  if (!t) return null;
  const label = veh.expire_time > 0 ? "Aluguel" : "Taxa do veículo";
  const diff = t * 1000 - Date.now();
  if (diff <= 0) return `${label} está vencida`;
  return `${label} expira em: ${formatRemaining(diff)}`;
}

function formatRemaining(ms: number): string {
  const total = Math.floor(ms / 1000);
  const d = Math.floor(total / 86400);
  const h = Math.floor((total % 86400) / 3600);
  const m = Math.floor((total % 3600) / 60);
  const s = total % 60;
  return `${d}d ${h}h ${m}m ${s}s`;
}

function buildSpecs(veh: any, isService: boolean) {
  if (isService) {
    const price = veh.price && veh.price > 0 ? veh.price : 0;
    return [
      {
        label: "Valor do aluguel",
        value: price > 0 ? formatCurrency(price) : "Gratuito",
        pct: 100,
      },
    ];
  }
  const { fuel, body } = healthPct(veh);
  const trunk = Math.max(0, Number(veh.trunk) || 0);
  return [
    { label: "Combustível", value: `${fuel}%`, pct: fuel },
    { label: "Lataria", value: `${body}%`, pct: body },
    {
      label: "Capacidade do porta-malas",
      value: `${trunk} kg`,
      pct: clampPct(trunk),
    },
  ];
}

/* ------------------------------------------------------------------ */
/* Modais                                                              */
/* ------------------------------------------------------------------ */

function BorrowModal({
  onConfirm,
  onCancel,
}: {
  onConfirm: (friendId: string) => void;
  onCancel: () => void;
}) {
  const [friendId, setFriendId] = useState("");
  const [error, setError] = useState("");

  function confirm() {
    if (!friendId || !Number.isInteger(Number(friendId)) || Number(friendId) <= 0) {
      setError("Informe um passaporte válido.");
      return;
    }
    onConfirm(friendId);
  }

  return (
    <Modal
      onConfirm={confirm}
      onCancel={onCancel}
      title="CHAVE DO VEÍCULO"
      icon="fa-solid fa-key"
    >
      <div className="v-modal-description">
        Insira o <span className="v-text-highlight">passaporte</span> para qual
        deseja conceder uma <span className="v-text-highlight">chave</span> do
        veículo:
      </div>
      <input
        className="v-modal-input"
        placeholder="ID do passaporte"
        inputMode="numeric"
        autoFocus
        value={friendId}
        onChange={(e) => {
          setFriendId(e.target.value.replace(/\D/g, ""));
          setError("");
        }}
      />
      {error && <div className="ga-form-error">{error}</div>}
    </Modal>
  );
}

function RevokeModal({
  borrowedTo,
  onConfirm,
  onCancel,
}: {
  borrowedTo: string;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  return (
    <Modal
      onConfirm={onConfirm}
      onCancel={onCancel}
      title="CHAVE DO VEÍCULO"
      icon="fa-solid fa-key"
    >
      <div className="v-modal-description">
        <span className="v-text-highlight">{borrowedTo}</span> atualmente possuí
        uma chave do veículo. Deseja retirá-la?
      </div>
    </Modal>
  );
}

function SellModal({
  onConfirm,
  onCancel,
}: {
  onConfirm: (targetId: string, price: string) => void;
  onCancel: () => void;
}) {
  const [targetId, setTargetId] = useState("");
  const [price, setPrice] = useState("");
  const [error, setError] = useState("");

  function confirm() {
    if (!targetId || !Number.isInteger(Number(targetId)) || Number(targetId) <= 0) {
      setError("Informe um passaporte válido.");
      return;
    }
    if (!price || !Number.isInteger(Number(price)) || Number(price) <= 0) {
      setError("Informe um valor de venda válido.");
      return;
    }
    onConfirm(targetId, price);
  }

  return (
    <Modal
      onConfirm={confirm}
      onCancel={onCancel}
      title="VENDA DO VEÍCULO"
      icon="fa-solid fa-dollar-sign"
    >
      <div className="v-modal-description">
        Insira o <span className="v-text-highlight">passaporte</span> para qual
        deseja <span className="v-text-highlight">vender</span> o veículo:
      </div>
      <input
        className="v-modal-input"
        placeholder="ID do passaporte"
        inputMode="numeric"
        autoFocus
        value={targetId}
        onChange={(e) => {
          setTargetId(e.target.value.replace(/\D/g, ""));
          setError("");
        }}
      />
      <div className="v-modal-description">
        Insira o <span className="v-text-highlight">valor</span> da venda:
      </div>
      <input
        className="v-modal-input"
        placeholder="R$ 0"
        inputMode="numeric"
        value={price}
        onChange={(e) => {
          setPrice(e.target.value.replace(/\D/g, ""));
          setError("");
        }}
      />
      {error && <div className="ga-form-error">{error}</div>}
    </Modal>
  );
}
