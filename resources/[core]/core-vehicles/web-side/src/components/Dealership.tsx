import { useState, useRef, useMemo, useEffect } from "react";
import { useAppStore } from "@app/stores/store";
import { fetchNui, sendNui } from "@app/utils/nui";
import {
  getVehicleImage,
  replaceMissingVehicleImage,
  formatCurrency,
  formatCurrencyJSX,
  formatDateFromTime,
  getRGBFromHex,
} from "@app/utils/format";
import { Modal } from "./Modal";

type DealerViewMode = "shop" | "garage";

const QUICK_COLORS = ["#1FCB63", "#1B62F0", "#FFFFFF", "#15181D"];

export function Dealership() {
  const dealerData = useAppStore((s) => s.dealerData);
  const close = useAppStore((s) => s.close);

  const [activeCategory, setActiveCategory] = useState("");
  const [viewMode, setViewMode] = useState<DealerViewMode>("shop");
  const [selectedVeh, setSelectedVeh] = useState<any>(null);
  const [vehicleStats, setVehicleStats] = useState<any>(null);
  const [showTestDriveBtn, setShowTestDriveBtn] = useState(false);
  const [categoryMenuOpen, setCategoryMenuOpen] = useState(false);
  const [colorPickerOpen, setColorPickerOpen] = useState(false);

  const cooldownRef = useRef(false);
  const listRef = useRef<HTMLDivElement>(null);
  const categoryMenuRef = useRef<HTMLDivElement>(null);
  const colorPickerRef = useRef<HTMLDivElement>(null);
  const rotateAtRef = useRef(0);

  const [purchase, setPurchase] = useState<{
    veh: any;
    colors: [string, string];
    rentDays: number;
  } | null>(null);

  const [modal, setModal] = useState<null | {
    type: "purchase" | "rent" | "renew" | "sell" | "testDrive";
    plate?: string;
  }>(null);

  const [search, setSearch] = useState("");
  const searchTO = useRef<ReturnType<typeof setTimeout> | null>(null);
  const [debouncedSearch, setDebouncedSearch] = useState("");

  const sortedCategories = useMemo(() => {
    if (!dealerData) return [];
    const cats: [string, string][] = [];
    for (const catId in dealerData.vehicles) {
      if (
        dealerData.vehicles[catId]?.length > 0 &&
        dealerData.categories[catId]
      ) {
        if (dealerData.disabledCategories?.[catId]) continue;
        cats.push([catId, dealerData.categories[catId]]);
        dealerData.vehicles[catId].sort((a: any, b: any) =>
          a.index.localeCompare(b.index)
        );
      }
    }
    cats.sort((a, b) => a[1].localeCompare(b[1]));
    const carIdx = cats.findIndex(([id]) => id === "car");
    if (carIdx > 0) {
      const car = cats.splice(carIdx, 1)[0];
      cats.unshift(car);
    }
    return cats;
  }, [dealerData]);

  useEffect(() => {
    if (sortedCategories.length > 0 && !activeCategory) {
      const first =
        sortedCategories.find(([id]) => id === "car")?.[0] ||
        sortedCategories[0][0];
      selectCategory(first);
    }
  }, [sortedCategories]);

  useEffect(() => {
    if (!categoryMenuOpen) return;

    function closeCategoryMenu(event: MouseEvent) {
      if (!categoryMenuRef.current?.contains(event.target as Node)) {
        setCategoryMenuOpen(false);
      }
    }

    document.addEventListener("mousedown", closeCategoryMenu);
    return () => document.removeEventListener("mousedown", closeCategoryMenu);
  }, [categoryMenuOpen]);

  useEffect(() => {
    if (!colorPickerOpen) return;

    function closeColorPicker(event: MouseEvent) {
      if (!colorPickerRef.current?.contains(event.target as Node)) {
        setColorPickerOpen(false);
      }
    }

    document.addEventListener("mousedown", closeColorPicker);
    return () => document.removeEventListener("mousedown", closeColorPicker);
  }, [colorPickerOpen]);

  if (!dealerData) return null;

  function selectCategory(catId: string) {
    setCategoryMenuOpen(false);
    setColorPickerOpen(false);
    if (cooldownRef.current) return;
    cooldownRef.current = true;
    setViewMode("shop");
    setSearch("");
    setDebouncedSearch("");

    fetchNui({ action: "dealerSelectedVehicle", index: false }).then(() => {
      setActiveCategory(catId);
      setSelectedVeh(null);
      setVehicleStats(null);
      setShowTestDriveBtn(false);
      if (listRef.current) listRef.current.scrollTop = 0;
      setTimeout(() => (cooldownRef.current = false), 500);
    });
  }

  function showGarage() {
    setCategoryMenuOpen(false);
    setColorPickerOpen(false);
    if (cooldownRef.current) return;
    cooldownRef.current = true;

    fetchNui({ action: "dealerSelectedVehicle", index: false }).then(() => {
      setViewMode("garage");
      setActiveCategory("");
      setSelectedVeh(null);
      setVehicleStats(null);
      setShowTestDriveBtn(false);
      if (listRef.current) listRef.current.scrollTop = 0;
      setTimeout(() => (cooldownRef.current = false), 500);
    });
  }

  function selectDealerVehicle(veh: any) {
    if (cooldownRef.current) return;
    cooldownRef.current = true;

    fetchNui({ action: "dealerSelectedVehicle", index: veh.index }).then(
      (r: any) => {
        const stats = r?.stats || {};
        setVehicleStats(stats);
        const p = {
          veh,
          colors: ["#000000", "#ffffff"] as [string, string],
          rentDays: 1,
        };
        setPurchase(p);
        setSelectedVeh(veh);
        setShowTestDriveBtn(true);
        updateModelViewerColor(p.colors);
        cooldownRef.current = false;
      }
    );
  }

  function selectGarageVehicle(plate: string) {
    if (cooldownRef.current) return;
    cooldownRef.current = true;
    const veh = dealerData.myVehicles[plate];
    if (!veh) return;

    fetchNui({
      action: "dealerSelectedVehicle",
      index: veh.index,
      plate,
    }).then(() => {
      setPurchase({
        veh: { ...veh, plate },
        colors: ["#000000", "#ffffff"],
        rentDays: 1,
      });
      setSelectedVeh({ ...veh, plate });
      setShowTestDriveBtn(false);
      cooldownRef.current = false;
    });
  }

  function updateModelViewerColor(colors: [string, string]) {
    sendNui({
      action: "updateModelViewerColor",
      primary: getRGBFromHex(colors[0]),
      secondary: getRGBFromHex(colors[1]),
    });
  }

  function applyPrimaryColor(hex: string) {
    if (!purchase) return;
    const newColors: [string, string] = [hex, purchase.colors[1]];
    setPurchase({ ...purchase, colors: newColors });
    updateModelViewerColor(newColors);
  }

  function handleSearch(value: string) {
    setSearch(value);
    if (searchTO.current) clearTimeout(searchTO.current);
    searchTO.current = setTimeout(() => {
      setDebouncedSearch(value.toLowerCase().trim());
    }, 500);
  }

  function scrollListDown() {
    listRef.current?.scrollBy({ top: 320, behavior: "smooth" });
  }

  function handleWheelRotate(e: React.WheelEvent) {
    if (!selectedVeh || e.deltaY === 0 || categoryMenuOpen || colorPickerOpen) {
      return;
    }

    const now = Date.now();
    if (now - rotateAtRef.current < 40) return;
    rotateAtRef.current = now;
    sendNui({ action: "rotateModelViewer", side: e.deltaY > 0 });
  }

  function handleClose() {
    sendNui({ action: "close" });
    close();
  }

  // --- Purchase/Rent/Renew/Sell logic ---

  function tryBuyDealerVehicle() {
    if (cooldownRef.current || !purchase) return;
    cooldownRef.current = true;
    setModal(null);
    fetchNui({
      action: "tryBuyDealerVehicle",
      index: purchase.veh.index,
      primary: getRGBFromHex(purchase.colors[0]),
      secondary: getRGBFromHex(purchase.colors[1]),
    }).then((r: any) => {
      if (r?.success && r.plate && r.nvdata) {
        dealerData.myVehicles[r.plate] = r.nvdata;
        sendNui({ action: "close" });
        close();
      }
      setTimeout(() => (cooldownRef.current = false), 500);
    });
  }

  function tryRentDealerVehicle() {
    if (cooldownRef.current || !purchase) return;
    cooldownRef.current = true;
    setModal(null);
    fetchNui({
      action: "tryRentDealerVehicle",
      index: purchase.veh.index,
    }).then((r: any) => {
      if (r?.success && r.plate && r.nvdata) {
        dealerData.myVehicles[r.plate] = r.nvdata;
        sendNui({ action: "close" });
        close();
      }
      setTimeout(() => (cooldownRef.current = false), 500);
    });
  }

  function tryRenewDealerRentalVehicle(plate: string) {
    if (cooldownRef.current || !purchase) return;
    cooldownRef.current = true;
    setModal(null);
    fetchNui({
      action: "tryRenewDealerRentalVehicle",
      plate,
    }).then((r: any) => {
      if (r?.success && r.newExpireTime) {
        dealerData.myVehicles[plate].expire_time = r.newExpireTime;
        sendNui({ action: "close" });
        close();
      }
      setTimeout(() => (cooldownRef.current = false), 500);
    });
  }

  function tryDealerSellVehicle(plate: string) {
    if (cooldownRef.current) return;
    cooldownRef.current = true;
    setModal(null);
    fetchNui({ action: "tryDealerSellVehicle", plate }).then((r: any) => {
      if (r?.success) {
        fetchNui({ action: "dealerSelectedVehicle", index: false }).then(() => {
          setSelectedVeh(null);
          setTimeout(() => (cooldownRef.current = false), 500);
        });
      } else {
        setTimeout(() => (cooldownRef.current = false), 500);
      }
    });
  }

  function tryTestDrive() {
    if (cooldownRef.current || !purchase) return;
    cooldownRef.current = true;
    setModal(null);
    fetchNui({ action: "tryTestDrive", model: purchase.veh.index }).then(
      (r: any) => {
        if (r?.success) {
          sendNui({ action: "close" });
          close();
        }
        setTimeout(() => (cooldownRef.current = false), 500);
      }
    );
  }

  // --- Lists ---

  const shopVehicles = useMemo(() => {
    if (
      viewMode !== "shop" ||
      !activeCategory ||
      !dealerData.vehicles[activeCategory]
    )
      return [];
    return dealerData.vehicles[activeCategory].filter((v: any) => {
      if (
        !dealerData.infiniteStock &&
        (!dealerData.stock[v.index] || dealerData.stock[v.index] <= 0)
      )
        return false;
      if (debouncedSearch && !v.name.toLowerCase().includes(debouncedSearch))
        return false;
      return true;
    });
  }, [viewMode, activeCategory, dealerData, debouncedSearch]);

  const garageVehicles = useMemo(() => {
    if (viewMode !== "garage" || !dealerData.myVehicles) return [];
    const arr: any[] = [];
    for (const plate in dealerData.myVehicles) {
      const v = dealerData.myVehicles[plate];
      if (v) {
        v.plate = plate;
        arr.push(v);
      }
    }
    arr.sort((a, b) => a.name.localeCompare(b.name));
    if (debouncedSearch) {
      return arr.filter((v) => v.name.toLowerCase().includes(debouncedSearch));
    }
    return arr;
  }, [viewMode, dealerData, debouncedSearch]);

  const categoryName = (veh: any) =>
    veh?.class || dealerData.categories?.[veh?.category] || "VEÍCULO";

  const balanceMoney = dealerData.balance?.money ?? 0;
  const balanceGems = dealerData.balance?.gems ?? 0;

  const panelTitle = viewMode === "garage" ? "SEUS VEÍCULOS" : "CONCESSIONÁRIA";
  const panelBadge = viewMode === "garage" ? "GARAGEM" : "BEM-VINDO(A)";

  // --- Right panel ---

  function renderShopInfo() {
    if (!selectedVeh || !vehicleStats) return null;

    const spd = vehicleStats.speed || 0;
    const acc = vehicleStats.acceleration || 0;
    const brk = vehicleStats.braking || 0;
    const trc = vehicleStats.traction || 0;

    return (
      <>
        <div className="dz-veh-name">{selectedVeh.name.toUpperCase()}</div>
        <div className="dz-veh-desc">
          {vehicleDescription(selectedVeh, categoryName(selectedVeh))}
        </div>

        <div className="dz-section-label">
          <span>CARACTERÍSTICAS DO VEÍCULO</span>
          <i className="dz-caret" />
        </div>

        <div className="dz-stats">
          <StatRow
            label="VELOCIDADE MÁXIMA"
            value={`${spd} KM/H`}
            pct={Math.min(100, Math.round((spd / 300) * 100))}
          />
          <StatRow
            label="ACELERAÇÃO"
            value={String(acc)}
            pct={Math.min(100, acc)}
          />
          <StatRow
            label="FRENAGEM"
            value={String(brk)}
            pct={Math.min(100, brk)}
          />
          <StatRow
            label="TRAÇÃO"
            value={String(trc)}
            pct={Math.min(100, Math.round((trc / 3) * 100))}
          />
        </div>

        <div
          className="dz-buy"
          onClick={() =>
            selectedVeh.rental
              ? setModal({ type: "rent" })
              : setModal({ type: "purchase" })
          }
        >
          <span>{selectedVeh.rental ? "ALUGAR" : "COMPRAR"}</span>
          <i className="fa-solid fa-arrow-right-long" />
        </div>

        {showTestDriveBtn && (
          <div
            className="dz-testdrive"
            onClick={() => purchase && setModal({ type: "testDrive" })}
          >
            <SteeringWheelIcon />
            <span>TESTE DRIVE</span>
          </div>
        )}
      </>
    );
  }

  function renderGarageInfo() {
    if (!selectedVeh || !selectedVeh.plate) return null;
    const veh = selectedVeh;
    const taxType = veh.expire_time > 0 ? "ALUGUEL ATÉ" : "IPVA ATÉ";
    const taxTime = veh.expire_time > 0 ? veh.expire_time : veh.tax;

    return (
      <>
        <div className="dz-veh-name">{veh.name.toUpperCase()}</div>
        <div className="dz-veh-desc">
          {vehicleDescription(veh, categoryName(veh))}
        </div>

        <div className="dz-section-label">
          <span>DADOS DO VEÍCULO</span>
          <i className="dz-caret" />
        </div>

        <div className="dz-stats">
          <StatRow label="PLACA" value={veh.plate.toUpperCase()} pct={100} />
          <StatRow
            label={taxType}
            value={formatDateFromTime(taxTime * 1000)}
            pct={100}
          />
          <StatRow
            label="PORTA-MALAS"
            value={`${veh.trunk || veh.weights?.trunk || 0} KG`}
            pct={Math.min(100, (veh.trunk || veh.weights?.trunk || 0) / 2)}
          />
        </div>

        {veh.expire_time > 0 ? (
          <div
            className="dz-buy"
            onClick={() => setModal({ type: "renew", plate: veh.plate })}
          >
            <span>RENOVAR ALUGUEL</span>
            <i className="fa-solid fa-arrow-right-long" />
          </div>
        ) : (
          <div
            className="dz-buy"
            onClick={() => setModal({ type: "sell", plate: veh.plate })}
          >
            <span>VENDER</span>
            <i className="fa-solid fa-arrow-right-long" />
          </div>
        )}
      </>
    );
  }

  return (
    <>
      <div id="dealership" className="dz" onWheel={handleWheelRotate}>
        {/* ---------- TOP BAR ---------- */}
        <div className="dz-top">
          <div
            ref={categoryMenuRef}
            className={`dz-category-select${categoryMenuOpen ? " open" : ""}`}
          >
            <button
              type="button"
              className="dz-category-trigger"
              aria-haspopup="listbox"
              aria-expanded={categoryMenuOpen}
              onClick={() => {
                setColorPickerOpen(false);
                setCategoryMenuOpen((open) => !open);
              }}
            >
              <span className="dz-category-current">
                {viewMode === "garage"
                  ? "Seus Veículos"
                  : sortedCategories.find(([id]) => id === activeCategory)?.[1] ||
                    "Selecionar categoria"}
              </span>
              <i className="fa-solid fa-chevron-down dz-category-chevron" />
            </button>

            {categoryMenuOpen && (
              <div
                className="dz-category-menu"
                role="listbox"
                aria-label="Categorias de veículos"
                onWheel={(event) => event.stopPropagation()}
              >
                {sortedCategories.map(([catId, catName]) => {
                  const active =
                    viewMode === "shop" && activeCategory === catId;

                  return (
                    <button
                      key={catId}
                      type="button"
                      role="option"
                      aria-selected={active}
                      className={`dz-category-option${active ? " active" : ""}`}
                      onClick={() => selectCategory(catId)}
                    >
                      <span>{catName}</span>
                      {active && <i className="fa-solid fa-check" />}
                    </button>
                  );
                })}

                <div className="dz-category-divider" />
                <button
                  type="button"
                  role="option"
                  aria-selected={viewMode === "garage"}
                  className={`dz-category-option dz-category-garage${
                    viewMode === "garage" ? " active" : ""
                  }`}
                  onClick={showGarage}
                >
                  <span>Seus Veículos</span>
                  {viewMode === "garage" && (
                    <i className="fa-solid fa-check" />
                  )}
                </button>
              </div>
            )}
          </div>

          <div className="dz-wallet">
            <div className="dz-wallet-item">
              <i className="fa-regular fa-gem dz-ic-gem" />
              <span>{Number(balanceGems).toLocaleString("pt-BR")}</span>
            </div>
            <div className="dz-wallet-item">
              <span className="dz-ic-money">$</span>
              <span>{Number(balanceMoney).toLocaleString("pt-BR")}</span>
            </div>
            <div className="dz-exit" onClick={handleClose}>
              <span>SAIR</span>
              <div className="dz-exit-box">
                <i className="fa-solid fa-arrow-right-long" />
              </div>
            </div>
          </div>
        </div>

        <div className="dz-body">
        {/* ---------- LEFT PANEL ---------- */}
        <div className="dz-left">
          <div className="dz-badge">{panelBadge}</div>
          <div className="dz-heading">{panelTitle}</div>

          <div className="dz-search">
            <input
              id="dealer-search"
              placeholder="PESQUISAR"
              value={search}
              onChange={(e) => handleSearch(e.target.value)}
            />
            <i className="fa-solid fa-magnifying-glass" />
          </div>

          <div className="dz-list-label">
            <i className="dz-caret-r" />
            <span>
              {viewMode === "garage" ? "SEUS VEÍCULOS" : "LISTA DE VEÍCULOS"}
            </span>
          </div>

          <div
            className="dz-list"
            ref={listRef}
            onWheel={(e) => e.stopPropagation()}
          >
            {viewMode === "shop" &&
              (shopVehicles.length > 0 ? (
                shopVehicles.map((veh: any) => (
                  <VehicleCard
                    key={veh.index}
                    top={categoryName(veh)}
                    name={veh.name}
                    image={getVehicleImage(veh.index)}
                    badge={formatCurrencyJSX(veh.price, veh.paymentType)}
                    badgeVariant={
                      veh.paymentType === "secondary" ? "gems" : undefined
                    }
                    selected={selectedVeh?.index === veh.index}
                    onClick={() => selectDealerVehicle(veh)}
                  />
                ))
              ) : (
                <div className="dz-empty">
                  <i className="fa-solid fa-circle-xmark" />
                  Nenhum veículo disponível nesta categoria.
                </div>
              ))}

            {viewMode === "garage" &&
              (garageVehicles.length > 0 ? (
                garageVehicles.map((veh: any) => (
                  <VehicleCard
                    key={veh.plate}
                    top={categoryName(veh)}
                    name={veh.name}
                    image={getVehicleImage(veh.index)}
                    badge={veh.plate.toUpperCase()}
                    selected={selectedVeh?.plate === veh.plate}
                    icon={
                      veh.borrowedFrom || veh.borrowedTo
                        ? "fa-solid fa-user-group"
                        : veh.expire_time > 0
                        ? "fa-solid fa-calendar"
                        : undefined
                    }
                    onClick={() => selectGarageVehicle(veh.plate)}
                  />
                ))
              ) : (
                <div className="dz-empty">
                  <i className="fa-solid fa-circle-xmark" />
                  Você ainda não possui nenhum veículo.
                </div>
              ))}
          </div>

          <div className="dz-list-more" onClick={scrollListDown}>
            <i className="fa-solid fa-chevron-down" />
          </div>

          <div className="dz-left-note">
            Selecione um modelo na lista para visualizá-lo no showroom. Use o
            scroll do mouse para girar o veículo em exposição.
          </div>
        </div>

        {/* ---------- RIGHT PANEL ---------- */}
        <div className="dz-right">
          {selectedVeh &&
            (viewMode === "shop" ? renderShopInfo() : renderGarageInfo())}
        </div>
        </div>

        {/* ---------- BOTTOM ---------- */}
        <div className="dz-bottom">
          <div
            ref={colorPickerRef}
            className={`dz-colors${colorPickerOpen ? " open" : ""}`}
          >
            {viewMode === "shop" && selectedVeh && purchase && (
              <div className="dz-color-picker">
                <button
                  type="button"
                  className="dz-color-trigger"
                  aria-haspopup="dialog"
                  aria-expanded={colorPickerOpen}
                  onClick={() => {
                    setCategoryMenuOpen(false);
                    setColorPickerOpen((open) => !open);
                  }}
                >
                  <span
                    className="dz-color-current"
                    style={{ backgroundColor: purchase.colors[0] }}
                  />
                  <span>Cor do veículo</span>
                  <i className="fa-solid fa-chevron-up" />
                </button>

                {colorPickerOpen && (
                  <div
                    className="dz-color-popover"
                    role="dialog"
                    aria-label="Selecionar cor do veículo"
                    onWheel={(event) => event.stopPropagation()}
                  >
                    <div className="dz-color-popover-head">
                      <span>COR PRINCIPAL</span>
                      <strong>{purchase.colors[0].toUpperCase()}</strong>
                    </div>
                    <div className="dz-color-controls">
                      <div className="dz-hexes">
                        {QUICK_COLORS.map((hex, i) => (
                          <button
                            type="button"
                            key={hex}
                            aria-label={`Selecionar cor ${hex}`}
                            className={`dz-hex dz-hex-${i}${
                              purchase.colors[0].toLowerCase() === hex.toLowerCase()
                                ? " active"
                                : ""
                            }`}
                            onClick={() => applyPrimaryColor(hex)}
                          >
                            <span style={{ background: hex }} />
                          </button>
                        ))}
                      </div>
                      <ColorWheel onPick={applyPrimaryColor} />
                    </div>
                  </div>
                )}
              </div>
            )}
          </div>

          <div className="dz-hints">
            <div className="dz-hint">
              <div className="dz-key">SCROLL</div>
              <span>USE O SCROLL PARA GIRAR O VEÍCULO</span>
            </div>
            <div className="dz-hint">
              <div className="dz-key">ESC</div>
              <span>PRESSIONE PARA SAIR</span>
            </div>
          </div>
        </div>
      </div>

      {/* Modals */}
      {modal?.type === "purchase" && purchase && (
        <PurchaseModal
          veh={purchase.veh}
          colors={purchase.colors}
          colorOptions={dealerData.purchaseColorOptions}
          onColorChange={(type, hex) => {
            const newColors: [string, string] = [...purchase.colors];
            newColors[type === 1 ? 0 : 1] = hex;
            setPurchase({ ...purchase, colors: newColors });
            updateModelViewerColor(newColors);
          }}
          onConfirm={tryBuyDealerVehicle}
          onCancel={() => setModal(null)}
        />
      )}
      {modal?.type === "testDrive" && purchase && (
        <TestDriveModal
          veh={purchase.veh}
          payment={dealerData.testDrive?.payment}
          onConfirm={tryTestDrive}
          onCancel={() => setModal(null)}
        />
      )}
      {modal?.type === "rent" && purchase && (
        <RentModal
          veh={purchase.veh}
          onConfirm={tryRentDealerVehicle}
          onCancel={() => setModal(null)}
        />
      )}
      {modal?.type === "renew" && purchase && modal.plate && (
        <RenewModal
          veh={purchase.veh}
          onConfirm={() => tryRenewDealerRentalVehicle(modal.plate!)}
          onCancel={() => setModal(null)}
        />
      )}
      {modal?.type === "sell" && purchase && modal.plate && (
        <DealerSellModal
          veh={purchase.veh}
          sellPercent={dealerData.sellBackPercentFromPrice}
          onConfirm={() => tryDealerSellVehicle(modal.plate!)}
          onCancel={() => setModal(null)}
        />
      )}
    </>
  );
}

/* ------------------------------------------------------------------ */
/* Sub componentes                                                     */
/* ------------------------------------------------------------------ */

function VehicleCard({
  top,
  name,
  image,
  badge,
  badgeVariant,
  selected,
  icon,
  onClick,
}: {
  top: string;
  name: string;
  image: string;
  badge: React.ReactNode;
  badgeVariant?: "gems";
  selected: boolean;
  icon?: string;
  onClick: () => void;
}) {
  return (
    <div className={`dz-card${selected ? " selected" : ""}`} onClick={onClick}>
      <div className="dz-card-info">
        <div className="dz-card-top">{top.toUpperCase()}</div>
        <div className="dz-card-name">{name.toUpperCase()}</div>
        <div className={`dz-card-badge${badgeVariant ? ` ${badgeVariant}` : ""}`}>
          {badge}
        </div>
      </div>
      <img src={image} onError={replaceMissingVehicleImage} />
      {icon && <i className={`dz-card-icon ${icon}`} />}
    </div>
  );
}

function SteeringWheelIcon() {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      className="dz-steering-wheel"
      aria-hidden="true"
    >
      <path stroke="none" d="M0 0h24v24H0z" fill="none" />
      <path d="M3 12a9 9 0 1 0 18 0a9 9 0 1 0 -18 0" />
      <path d="M10 12a2 2 0 1 0 4 0a2 2 0 1 0 -4 0" />
      <path d="M12 14l0 7" />
      <path d="M10 12l-6.75 -2" />
      <path d="M14 12l6.75 -2" />
    </svg>
  );
}

function StatRow({
  label,
  value,
  pct,
}: {
  label: string;
  value: string;
  pct: number;
}) {
  return (
    <div className="dz-stat">
      <div className="dz-stat-head">
        <span className="dz-stat-value">{value}</span>
        <span className="dz-stat-label">{label}</span>
      </div>
      <div className="dz-stat-bar">
        <div className="dz-stat-fill" style={{ width: `${pct}%` }} />
      </div>
    </div>
  );
}

function ColorWheel({ onPick }: { onPick: (hex: string) => void }) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const SIZE = 150;

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    const r = SIZE / 2;
    const image = ctx.createImageData(SIZE, SIZE);
    for (let y = 0; y < SIZE; y++) {
      for (let x = 0; x < SIZE; x++) {
        const dx = x - r + 0.5;
        const dy = y - r + 0.5;
        const dist = Math.sqrt(dx * dx + dy * dy);
        if (dist > r) continue;
        const hue = ((Math.atan2(dy, dx) * 180) / Math.PI + 450) % 360;
        const [cr, cg, cb] = hsvToRgb(hue, Math.min(1, dist / r), 1);
        const i = (y * SIZE + x) * 4;
        image.data[i] = cr;
        image.data[i + 1] = cg;
        image.data[i + 2] = cb;
        image.data[i + 3] =
          dist > r - 1.5 ? Math.round(((r - dist) / 1.5) * 255) : 255;
      }
    }
    ctx.putImageData(image, 0, 0);
  }, []);

  function pick(e: React.MouseEvent<HTMLCanvasElement>) {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const rect = canvas.getBoundingClientRect();
    const r = rect.width / 2;
    const dx = e.clientX - rect.left - r;
    const dy = e.clientY - rect.top - r;
    const dist = Math.sqrt(dx * dx + dy * dy);
    if (dist > r) return;
    const hue = ((Math.atan2(dy, dx) * 180) / Math.PI + 450) % 360;
    const [cr, cg, cb] = hsvToRgb(hue, Math.min(1, dist / r), 1);
    onPick(rgbToHex(cr, cg, cb));
  }

  return (
    <canvas
      ref={canvasRef}
      width={SIZE}
      height={SIZE}
      className="dz-wheel"
      onClick={pick}
    />
  );
}

/* ------------------------------------------------------------------ */
/* Helpers                                                             */
/* ------------------------------------------------------------------ */

function vehicleDescription(veh: any, categoryName: string): string {
  if (veh?.description) return veh.description;
  const trunk = veh?.trunk || veh?.weights?.trunk || 0;
  let text = `${veh?.name || "Veículo"} é um modelo da linha ${categoryName.toLowerCase()}, disponível para visualização completa no showroom.`;
  if (trunk > 0) {
    text += ` Conta com porta-malas de ${trunk} kg de capacidade.`;
  }
  return text;
}

function hsvToRgb(h: number, s: number, v: number): [number, number, number] {
  const c = v * s;
  const x = c * (1 - Math.abs(((h / 60) % 2) - 1));
  const m = v - c;
  let r = 0;
  let g = 0;
  let b = 0;
  if (h < 60) [r, g, b] = [c, x, 0];
  else if (h < 120) [r, g, b] = [x, c, 0];
  else if (h < 180) [r, g, b] = [0, c, x];
  else if (h < 240) [r, g, b] = [0, x, c];
  else if (h < 300) [r, g, b] = [x, 0, c];
  else [r, g, b] = [c, 0, x];
  return [
    Math.round((r + m) * 255),
    Math.round((g + m) * 255),
    Math.round((b + m) * 255),
  ];
}

function rgbToHex(r: number, g: number, b: number): string {
  return (
    "#" +
    [r, g, b]
      .map((v) => Math.max(0, Math.min(255, v)).toString(16).padStart(2, "0"))
      .join("")
  );
}

/* ------------------------------------------------------------------ */
/* Modais                                                              */
/* ------------------------------------------------------------------ */

function PurchaseModal({
  veh,
  colors,
  colorOptions,
  onColorChange,
  onConfirm,
  onCancel,
}: {
  veh: any;
  colors: [string, string];
  colorOptions: any;
  onColorChange: (type: 1 | 2, hex: string) => void;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  const [activeColor, setActiveColor] = useState<1 | 2>(1);
  const isGemPayment = veh.paymentType === "secondary";
  const palette =
    activeColor === 1 ? colorOptions.primary : colorOptions.secondary;

  return (
    <Modal
      title="COMPRAR VEÍCULO"
      icon="fa-solid fa-cart-shopping"
      onConfirm={onConfirm}
      onCancel={onCancel}
      confirmLabel={isGemPayment ? "COMPRAR COM GEMAS" : "COMPRAR VEÍCULO"}
      contentClassName={`dealer-purchase-modal${isGemPayment ? " gems" : ""}`}
    >
      <div className="dealer-purchase-summary">
        <div className="dealer-purchase-vehicle-icon">
          <i className="fa-solid fa-car-side" />
        </div>
        <div className="dealer-purchase-model">
          <small>MODELO</small>
          <strong>{veh.name}</strong>
        </div>
        <div className={`dealer-purchase-price${isGemPayment ? " gems" : ""}`}>
          <small>VALOR</small>
          <strong>
            {isGemPayment ? (
              <>
                <i className="fa-regular fa-gem" />
                {Number(veh.price).toLocaleString("pt-BR")}
              </>
            ) : (
              formatCurrency(veh.price)
            )}
          </strong>
        </div>
      </div>

      <div className="dealer-purchase-section-head">
        <div>
          <small>PERSONALIZAÇÃO</small>
          <strong>Escolha as cores do veículo</strong>
        </div>
        <span>{activeColor === 1 ? "COR PRIMÁRIA" : "COR SECUNDÁRIA"}</span>
      </div>

      <div className="dealer-color-switch">
        <button
          type="button"
          className={activeColor === 1 ? "active" : ""}
          onClick={() => setActiveColor(1)}
        >
          <span style={{ backgroundColor: colors[0] }} />
          <div>
            <small>COR</small>
            <strong>Primária</strong>
          </div>
          {activeColor === 1 && <i className="fa-solid fa-check" />}
        </button>
        <button
          type="button"
          className={activeColor === 2 ? "active" : ""}
          onClick={() => setActiveColor(2)}
        >
          <span style={{ backgroundColor: colors[1] }} />
          <div>
            <small>COR</small>
            <strong>Secundária</strong>
          </div>
          {activeColor === 2 && <i className="fa-solid fa-check" />}
        </button>
      </div>

      <div className="dealer-color-palette">
        {palette.map((hex: string, index: number) => {
          const selected = colors[activeColor - 1] === hex;
          return (
            <button
              key={`${hex}-${index}`}
              type="button"
              className={selected ? "selected" : ""}
              style={{ backgroundColor: hex }}
              aria-label={`Selecionar cor ${hex}`}
              aria-pressed={selected}
              onClick={() => onColorChange(activeColor, hex)}
            >
              {selected && <i className="fa-solid fa-check" />}
            </button>
          );
        })}
      </div>
    </Modal>
  );
}

function TestDriveModal({
  veh,
  payment,
  onConfirm,
  onCancel,
}: {
  veh: any;
  payment: number;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  return (
    <Modal
      title="TEST DRIVE"
      icon={<SteeringWheelIcon />}
      onConfirm={onConfirm}
      onCancel={onCancel}
    >
      <div className="v-modal-description">
        {payment > 0 ? (
          <>
            Deseja realizar um teste drive com o veículo <b>{veh.name}</b> por{" "}
            <b>{formatCurrency(payment)}</b>?
          </>
        ) : (
          <>
            Deseja iniciar um teste drive com o veículo <b>{veh.name}</b>?
          </>
        )}
      </div>
    </Modal>
  );
}

function RentModal({
  veh,
  onConfirm,
  onCancel,
}: {
  veh: any;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  return (
    <Modal
      title="ALUGUEL DE VEÍCULO"
      icon="fa-solid fa-key"
      onConfirm={onConfirm}
      onCancel={onCancel}
    >
      <label className="v-modal-label">Modelo</label>
      <input className="v-modal-input" value={veh.name} readOnly />
      <label className="v-modal-label">Valor</label>
      <input
        className="v-modal-input"
        value={formatCurrency(veh.price, veh.paymentType)}
        readOnly
      />
      <label className="v-modal-label">Duração</label>
      <input
        className="v-modal-input"
        value={`${veh.rental?.days || 0} dias`}
        readOnly
      />
    </Modal>
  );
}

function RenewModal({
  veh,
  onConfirm,
  onCancel,
}: {
  veh: any;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  return (
    <Modal
      title="RENOVAR ALUGUEL"
      icon="fa-solid fa-rotate"
      onConfirm={onConfirm}
      onCancel={onCancel}
    >
      <label className="v-modal-label">Modelo</label>
      <input className="v-modal-input" value={veh.name} readOnly />
      <label className="v-modal-label">Placa</label>
      <input className="v-modal-input" value={veh.plate} readOnly />
      <label className="v-modal-label">Valor</label>
      <input
        className="v-modal-input"
        value={formatCurrency(veh.price, veh.paymentType)}
        readOnly
      />
      <label className="v-modal-label">Duração</label>
      <input
        className="v-modal-input"
        value={`${veh.rental?.days || 0} dias`}
        readOnly
      />
    </Modal>
  );
}

function DealerSellModal({
  veh,
  sellPercent,
  onConfirm,
  onCancel,
}: {
  veh: any;
  sellPercent: number;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  return (
    <Modal
      title="VENDER VEÍCULO"
      icon="fa-solid fa-circle-dollar-to-slot"
      onConfirm={onConfirm}
      onCancel={onCancel}
    >
      <label className="v-modal-label">Modelo</label>
      <input className="v-modal-input" value={veh.name} readOnly />
      <label className="v-modal-label">Placa</label>
      <input className="v-modal-input" value={veh.plate} readOnly />
      <label className="v-modal-label">Valor</label>
      <input
        className="v-modal-input"
        value={formatCurrency(veh.price * sellPercent, veh.paymentType)}
        readOnly
      />
      <div className="v-modal-description">
        <i className="fa-solid fa-triangle-exclamation" /> Esta ação é{" "}
        <b>irreversível</b>.
      </div>
    </Modal>
  );
}
