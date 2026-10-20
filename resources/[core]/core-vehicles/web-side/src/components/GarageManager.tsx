import { memo, useEffect, useMemo, useRef, useState } from "react";
import ReactDOM from "react-dom";
import { useAppStore } from "@app/stores/store";
import { fetchNui } from "@app/utils/nui";
import { CustomSelect } from "./CustomSelect";

type GarageType = "NORMAL" | "AIR" | "WATER" | "SERVICE";

interface Coords { x: number; y: number; z: number; h: number; }

interface Garage {
  id: number;
  name: string;
  type: GarageType;
  permission: string | null;
  payment: number;
  open: Coords | null;
  spawns: Coords[];
  vehicles?: Record<string, number> | null;
  blip?: { enabled?: boolean; icon?: number; color?: number; size?: number } | null;
}

interface Vehicle {
  spawn: string;
  name?: string;
  category?: string;
  paymentType?: string;
  price?: number;
  class?: string;
  mode?: string;
  outDealership?: boolean;
  weights?: { trunk?: number; gloves?: number };
}

const TYPE_META: Record<GarageType, { label: string; icon: string; color: string; bg: string }> = {
  NORMAL:  { label: "Normal",   icon: "fa-solid fa-car",    color: "#3C8EDC", bg: "rgba(60,142,220,0.15)" },
  AIR:     { label: "Aérea",    icon: "fa-solid fa-plane",  color: "#9B6BFF", bg: "rgba(155,107,255,0.15)" },
  WATER:   { label: "Aquática", icon: "fa-solid fa-anchor", color: "#10B981", bg: "rgba(16,185,129,0.15)"  },
  SERVICE: { label: "Serviço",  icon: "fa-solid fa-wrench", color: "#F3A623", bg: "rgba(243,166,35,0.15)"  },
};

const TYPES_LIST: { value: GarageType; description: string }[] = [
  { value: "NORMAL",  description: "Carros, motos, caminhões — veículos do personagem" },
  { value: "AIR",     description: "Helicópteros e aviões do personagem" },
  { value: "WATER",   description: "Barcos e jet skis do personagem" },
  { value: "SERVICE", description: "Lista fixa de veículos disponíveis (serviço/profissão)" },
];

function fmtCoords(c: Coords | null) {
  if (!c) return "—";
  return `${c.x.toFixed(1)}, ${c.y.toFixed(1)}, ${c.z.toFixed(1)}`;
}

export function GarageManager() {
  const gmanagerData = useAppStore((s) => s.gmanagerData);
  const setData = useAppStore((s) => s.setGarageManagerData);
  const close = useAppStore((s) => s.close);

  const container = document.getElementById("g-manager");
  const cooldownRef = useRef(false);

  const [search, setSearch] = useState("");
  const [editor, setEditor] = useState<null | { mode: "create" | "edit"; id?: number }>(null);

  // form state
  const [formName, setFormName]       = useState("");
  const [formType, setFormType]       = useState<GarageType>("NORMAL");
  const [formPerm, setFormPerm]       = useState("");
  const [formPayment, setFormPayment] = useState<number>(0);
  const [formOpen, setFormOpen]       = useState<Coords | null>(null);
  const [formSpawns, setFormSpawns]   = useState<Coords[]>([]);
  const [formVehicles, setFormVehicles] = useState<{ spawn: string; price: number }[]>([]);
  const [vSpawnInput, setVSpawnInput] = useState("");
  const [vPriceInput, setVPriceInput] = useState<number>(0);
  const [capturing, setCapturing]     = useState<null | "open" | "spawn">(null);
  const [formBlipEnabled, setFormBlipEnabled] = useState<boolean>(true);

  // ---- TAB + VEHICLES ----
  const [activeTab, setActiveTab] = useState<"garages" | "vehicles">("garages");
  const [vehicles, setVehicles]   = useState<Vehicle[]>([]);
  const [vehCategories, setVehCategories] = useState<Record<string, string>>({});
  const [vehSearch, setVehSearch] = useState("");
  const [debouncedVehSearch, setDebouncedVehSearch] = useState("");
  const vehSearchTO = useRef<ReturnType<typeof setTimeout> | null>(null);
  const [vehCategory, setVehCategory] = useState<string>("car");
  const [vehVisibleCount, setVehVisibleCount] = useState(20);
  const VEH_PAGE_SIZE = 20;
  const [vehEditor, setVehEditor] = useState<null | { mode: "create" | "edit"; original?: Vehicle }>(null);
  // veh form fields
  const [vfSpawn, setVfSpawn]               = useState("");
  const [vfName, setVfName]                 = useState("");
  const [vfCategory, setVfCategory]         = useState("car");
  const [vfPaymentType, setVfPaymentType]   = useState("primary");
  const [vfPrice, setVfPrice]               = useState<number>(0);
  const [vfClass, setVfClass]               = useState("");
  const [vfMode, setVfMode]                 = useState("");
  const [vfOutDealership, setVfOutDealership] = useState(false);
  const [vfWeightTrunk, setVfWeightTrunk]   = useState<number>(5);
  const [vfWeightGloves, setVfWeightGloves] = useState<number>(5);

  const showGarageForm = editor !== null;
  const showVehicleForm = vehEditor !== null;
  const showForm = showGarageForm || showVehicleForm;

  // Refresh garages on mount
  useEffect(() => {
    fetchNui<{ success?: boolean; garages?: Garage[] }>({ action: "gmGetGarages" }).then((r) => {
      if (r?.garages) setData({ garages: r.garages });
    });
    loadVehicles();
  }, []);

  function loadVehicles() {
    fetchNui<{ success?: boolean; vehicles?: Vehicle[]; categories?: Record<string,string> }>({ action: "vrGetList" })
      .then((r) => {
        if (r?.vehicles) setVehicles(r.vehicles);
        if (r?.categories) setVehCategories(r.categories);
      });
  }

  function resetVehForm() {
    setVfSpawn("");
    setVfName("");
    setVfCategory("car");
    setVfPaymentType("primary");
    setVfPrice(0);
    setVfClass("");
    setVfMode("");
    setVfOutDealership(false);
    setVfWeightTrunk(5);
    setVfWeightGloves(5);
  }

  function openVehCreate() {
    resetVehForm();
    setVehEditor({ mode: "create" });
  }

  function openVehEdit(v: Vehicle) {
    setVfSpawn(v.spawn);
    setVfName(v.name || "");
    setVfCategory(v.category || "car");
    setVfPaymentType(v.paymentType || "primary");
    setVfPrice(Number(v.price) || 0);
    setVfClass(v.class || "");
    setVfMode(v.mode || "");
    setVfOutDealership(!!v.outDealership);
    setVfWeightTrunk(Number(v.weights?.trunk ?? 5));
    setVfWeightGloves(Number(v.weights?.gloves ?? 5));
    setVehEditor({ mode: "edit", original: v });
  }

  function saveVehicle() {
    if (cooldownRef.current) return;
    cooldownRef.current = true;
    fetchNui<{ success?: boolean; message?: string }>({
      action: "vrSave",
      data: {
        spawn: vfSpawn.trim().toLowerCase(),
        name: vfName.trim(),
        category: vfCategory,
        paymentType: vfPaymentType,
        price: Number(vfPrice) || 0,
        class: vfClass.trim(),
        mode: vfMode.trim(),
        outDealership: vfOutDealership,
        weightTrunk: Number(vfWeightTrunk) || 0,
        weightGloves: Number(vfWeightGloves) || 0,
      },
    }).then((r) => {
      if (r?.success) { setVehEditor(null); resetVehForm(); loadVehicles(); }
      setTimeout(() => (cooldownRef.current = false), 500);
    });
  }

  function deleteVehicle(v: Vehicle) {
    if (cooldownRef.current) return;
    cooldownRef.current = true;
    fetchNui<{ success?: boolean }>({ action: "vrDelete", spawn: v.spawn }).then((r) => {
      if (r?.success) loadVehicles();
      setTimeout(() => (cooldownRef.current = false), 500);
    });
  }

  function handleVehSearch(value: string) {
    setVehSearch(value);
    if (vehSearchTO.current) clearTimeout(vehSearchTO.current);
    vehSearchTO.current = setTimeout(() => {
      setDebouncedVehSearch(value.trim().toLowerCase());
    }, 350);
  }

  // Pré-agrupa por categoria uma única vez (recalcula só quando lista muda)
  const vehiclesByCategory = useMemo(() => {
    const map: Record<string, Vehicle[]> = {};
    for (const v of vehicles) {
      const cat = v.category || "_";
      if (!map[cat]) map[cat] = [];
      map[cat].push(v);
    }
    return map;
  }, [vehicles]);

  const filteredVehicles = useMemo(() => {
    const list = vehiclesByCategory[vehCategory] || [];
    const q = debouncedVehSearch;
    if (!q) return list;
    return list.filter((v) =>
      v.spawn.toLowerCase().includes(q) ||
      (v.name || "").toLowerCase().includes(q) ||
      (v.class || "").toLowerCase().includes(q)
    );
  }, [vehiclesByCategory, vehCategory, debouncedVehSearch]);

  // Reseta paginação quando os filtros mudam
  useEffect(() => {
    setVehVisibleCount(VEH_PAGE_SIZE);
  }, [vehCategory, debouncedVehSearch]);

  const visibleVehicles = useMemo(
    () => filteredVehicles.slice(0, vehVisibleCount),
    [filteredVehicles, vehVisibleCount]
  );

  const vehCategoryOptions = useMemo(() => {
    return Object.entries(vehCategories)
      .map(([value, label]) => ({
        value,
        label: `${label} (${(vehiclesByCategory[value] || []).length})`,
      }))
      .sort((a, b) => a.label.localeCompare(b.label));
  }, [vehCategories, vehiclesByCategory]);

  // captura de coords resultado
  useEffect(() => {
    const onRes = (e: any) => {
      const detail = e.detail || {};
      if (!detail.success || !detail.coords) { setCapturing(null); return; }
      if (capturing === "open") setFormOpen(detail.coords);
      else if (capturing === "spawn") setFormSpawns((prev) => [...prev, detail.coords]);
      setCapturing(null);
    };
    window.addEventListener("gm:capture-result", onRes);
    return () => window.removeEventListener("gm:capture-result", onRes);
  }, [capturing]);

  // Durante a captura, esconde o painel pra o admin ver o mundo
  useEffect(() => {
    const gm = document.getElementById("g-manager");
    if (capturing) {
      if (gm) { gm.style.opacity = "0"; gm.style.pointerEvents = "none"; }
    } else {
      if (gm) { gm.style.opacity = ""; gm.style.pointerEvents = ""; }
    }
    return () => {
      if (gm) { gm.style.opacity = ""; gm.style.pointerEvents = ""; }
    };
  }, [capturing]);

  const garages: Garage[] = useMemo(() => {
    return (gmanagerData?.garages || []) as Garage[];
  }, [gmanagerData]);

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return garages;
    return garages.filter(g =>
      g.name.toLowerCase().includes(q) ||
      g.type.toLowerCase().includes(q) ||
      (g.permission || "").toLowerCase().includes(q)
    );
  }, [garages, search]);

  if (!container) return null;

  function refreshFromServer() {
    fetchNui<{ success?: boolean; garages?: Garage[] }>({ action: "gmGetGarages" }).then((r) => {
      if (r?.garages) setData({ garages: r.garages });
    });
  }

  function handleClose() {
    if (cooldownRef.current) return;
    cooldownRef.current = true;
    fetchNui({ action: "gmClose" }).finally(() => {
      close();
      setTimeout(() => (cooldownRef.current = false), 500);
    });
  }

  function resetForm() {
    setFormName("");
    setFormType("NORMAL");
    setFormPerm("");
    setFormPayment(0);
    setFormOpen(null);
    setFormSpawns([]);
    setFormVehicles([]);
    setVSpawnInput("");
    setVPriceInput(0);
    setCapturing(null);
    setFormBlipEnabled(true);
  }

  function openCreate() {
    resetForm();
    setEditor({ mode: "create" });
  }

  function openEdit(g: Garage) {
    setFormName(g.name);
    setFormType(g.type);
    setFormPerm(g.permission || "");
    setFormPayment(g.payment || 0);
    setFormOpen(g.open);
    setFormSpawns(g.spawns || []);
    setFormVehicles(
      g.vehicles && typeof g.vehicles === "object"
        ? Object.entries(g.vehicles).map(([spawn, price]) => ({ spawn, price: Number(price) || 0 }))
        : []
    );
    setVSpawnInput("");
    setVPriceInput(0);
    setCapturing(null);
    setFormBlipEnabled(g.blip?.enabled !== false);
    setEditor({ mode: "edit", id: g.id });
  }

  function captureCoords(target: "open" | "spawn") {
    setCapturing(target);
    fetchNui({ action: "gmStartCapture", label: target === "open" ? "do blip" : "do spawn" });
  }

  function addVehicle() {
    const spawn = vSpawnInput.trim().toLowerCase();
    if (!spawn) return;
    if (formVehicles.some(v => v.spawn === spawn)) return;
    setFormVehicles((prev) => [...prev, { spawn, price: Number(vPriceInput) || 0 }]);
    setVSpawnInput("");
    setVPriceInput(0);
  }

  function removeVehicle(spawn: string) {
    setFormVehicles((prev) => prev.filter(v => v.spawn !== spawn));
  }

  const requiresVehicles = formType === "SERVICE";
  const canSave =
    formName.trim() !== "" &&
    formOpen !== null &&
    formSpawns.length > 0 &&
    (!requiresVehicles || formVehicles.length > 0);

  function save() {
    if (!canSave || !editor) return;
    if (cooldownRef.current) return;
    cooldownRef.current = true;

    const vehiclesMap = formVehicles.reduce<Record<string, number>>((acc, v) => {
      acc[v.spawn] = v.price; return acc;
    }, {});

    const payload: any = {
      name: formName.trim(),
      type: formType,
      permission: formPerm.trim(),
      payment: Number(formPayment) || 0,
      open: formOpen,
      spawns: formSpawns,
      vehicles: requiresVehicles ? vehiclesMap : null,
      blip: { enabled: formBlipEnabled, icon: 357, color: 0, size: 0.5 },
      marker: { icon: 36, color: [255,255,255,255], size: 0.8 },
    };

    const isEdit = editor.mode === "edit" && editor.id;
    if (isEdit) payload.id = editor.id;

    fetchNui<{ success?: boolean; message?: string }>({
      action: isEdit ? "gmUpdate" : "gmCreate",
      data: payload,
    }).then((r) => {
      if (r?.success) {
        setEditor(null);
        resetForm();
        refreshFromServer();
      }
      setTimeout(() => (cooldownRef.current = false), 500);
    });
  }

  function confirmDelete(g: Garage) {
    if (cooldownRef.current) return;
    cooldownRef.current = true;
    fetchNui<{ success?: boolean }>({ action: "gmDelete", id: g.id }).then((r) => {
      if (r?.success) refreshFromServer();
      setTimeout(() => (cooldownRef.current = false), 500);
    });
  }

  function teleport(g: Garage) {
    if (cooldownRef.current) return;
    cooldownRef.current = true;
    fetchNui<{ success?: boolean }>({ action: "gmTeleport", id: g.id }).then(() => {
      setTimeout(() => (cooldownRef.current = false), 500);
    });
  }

  function removeSpawn(idx: number) {
    setFormSpawns(prev => prev.filter((_, i) => i !== idx));
  }

  function handleFormBack() {
    if (showGarageForm) { setEditor(null); resetForm(); }
    else if (showVehicleForm) { setVehEditor(null); resetVehForm(); }
  }

  function handleFormConfirm() {
    if (showGarageForm) save();
    else if (showVehicleForm) saveVehicle();
  }

  const formTitle = showGarageForm
    ? (editor!.mode === "edit" ? "EDITAR GARAGEM" : "NOVA GARAGEM")
    : showVehicleForm
      ? (vehEditor!.mode === "edit" ? "EDITAR VEÍCULO" : "NOVO VEÍCULO")
      : "";

  const formSubtitle = showGarageForm
    ? "PREENCHA OS DADOS DA GARAGEM"
    : showVehicleForm
      ? "PREENCHA OS DADOS DO VEÍCULO"
      : "";

  const formConfirmLabel = showGarageForm
    ? (editor!.mode === "edit" ? "SALVAR" : "CRIAR")
    : showVehicleForm
      ? (vehEditor!.mode === "edit" ? "SALVAR" : "CADASTRAR")
      : "";

  const vehFormValid = vfSpawn.trim() !== "" && vfName.trim() !== "";
  const formConfirmDisabled = showGarageForm ? !canSave : showVehicleForm ? !vehFormValid : false;

  return ReactDOM.createPortal(
    <div id="manager" className="char core-manager core-manager--garages">
      <div className="panel-header">
        {showForm ? (
          <div style={{ display: "flex", alignItems: "center", gap: 14, minWidth: 0 }}>
            <div
              className="leave"
              onClick={handleFormBack}
              title="Voltar"
              style={{ position: "static", fontSize: 16 }}
            >
              <i className="fa-solid fa-arrow-left" />
            </div>
            <div className="panel-title-group">
              <div className="title">{formTitle}</div>
              <div className="subtitle">{formSubtitle}</div>
            </div>
          </div>
        ) : (
          <>
            <div className="panel-title-group">
              <div className="title">GERENCIADOR CORE</div>
              <div className="subtitle">
                {activeTab === "garages"
                  ? `${garages.length} GARAGEM(NS) CADASTRADA(S)`
                  : `${vehicles.length} VEÍCULO(S) NO SERVIDOR`}
              </div>
            </div>
            <div className="leave" onClick={handleClose}>
              <i className="fa-solid fa-xmark" />
            </div>
          </>
        )}
      </div>

      {!showForm && (<>
        {/* tabs */}
        <div className="core-manager__tabs" style={{ display: "flex", gap: 4, padding: "0 16px", marginTop: 8, borderBottom: "1px solid rgba(255,255,255,0.06)" }}>
          {[
            { key: "garages",  label: "GARAGENS",  icon: "fa-solid fa-warehouse" },
            { key: "vehicles", label: "VEÍCULOS",  icon: "fa-solid fa-car" },
          ].map((t) => {
            const active = activeTab === t.key;
            return (
              <div
                key={t.key}
                className={active ? "is-active" : ""}
                onClick={() => setActiveTab(t.key as any)}
                style={{
                  padding: "10px 18px", cursor: "pointer",
                  borderBottom: `2px solid ${active ? "#3C8EDC" : "transparent"}`,
                  color: active ? "#fff" : "rgba(255,255,255,0.5)",
                  fontWeight: 700, fontSize: 12, letterSpacing: 0.5,
                  transition: "all .15s",
                }}
              >
                <i className={t.icon} />&nbsp; {t.label}
              </div>
            );
          })}
        </div>

        {activeTab === "garages" && (<>
        <div className="panel-nav">
          <div className="new" onClick={openCreate}>
            <i className="fa-solid fa-plus" /> CRIAR GARAGEM
          </div>
          <input
            id="gmanager-search"
            placeholder="Pesquisar por nome, tipo ou permissão..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>

        <div id="list" className="char">
          {filtered.length === 0 && (
            <div className="gm-empty" style={{
              display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center",
              padding: "3rem 2rem", color: "rgba(255,255,255,.4)", textAlign: "center", gap: 12
            }}>
              <i className={garages.length === 0 ? "fa-solid fa-warehouse" : "fa-solid fa-magnifying-glass"}
                 style={{ fontSize: 48, opacity: 0.5 }} />
              <div style={{ fontSize: 14, fontWeight: 600, letterSpacing: 0.5 }}>
                {garages.length === 0 ? "NENHUMA GARAGEM CADASTRADA" : "NENHUM RESULTADO"}
              </div>
              <div style={{ fontSize: 12, opacity: 0.7 }}>
                {garages.length === 0
                  ? "Clique em CRIAR GARAGEM para adicionar a primeira."
                  : `Não encontramos garagens para "${search}".`}
              </div>
            </div>
          )}

          {filtered.map((g) => {
            const meta = TYPE_META[g.type] || TYPE_META.NORMAL;
            return (
              <div
                key={g.id}
                id={`gveh-${g.id}`}
                className="gm-garage-row"
                style={{
                  display: "flex", alignItems: "center", gap: 14,
                  padding: 12, borderRadius: 8,
                  background: "rgba(255,255,255,0.02)",
                  border: "1px solid rgba(255,255,255,0.05)",
                  marginBottom: 8, transition: "border-color .15s",
                }}
                onMouseEnter={(e) => (e.currentTarget.style.borderColor = `${meta.color}55`)}
                onMouseLeave={(e) => (e.currentTarget.style.borderColor = "rgba(255,255,255,0.05)")}
              >
                {/* type icon */}
                <div
                  className="gm-garage-row__icon"
                  style={{
                    width: 52, height: 52, borderRadius: 10, display: "flex",
                    alignItems: "center", justifyContent: "center",
                    color: meta.color, background: meta.bg, fontSize: 22, flexShrink: 0,
                    border: `1px solid ${meta.color}33`,
                  }}
                >
                  <i className={meta.icon} />
                </div>

                {/* info column */}
                <div style={{ flex: 1, minWidth: 0, display: "flex", flexDirection: "column", gap: 6 }}>
                  <div style={{ display: "flex", alignItems: "center", gap: 8, flexWrap: "wrap" }}>
                    <span style={{ color: "#fff", fontWeight: 700, fontSize: 14, letterSpacing: 0.3 }}>
                      {g.name}
                    </span>
                    <span
                      className="gm-type-badge"
                      style={{
                        display: "inline-flex", alignItems: "center", gap: 4,
                        padding: "2px 8px", borderRadius: 999,
                        background: meta.bg, color: meta.color,
                        fontSize: 10, fontWeight: 700, letterSpacing: 0.5, textTransform: "uppercase",
                      }}
                    >
                      <i className={meta.icon} style={{ fontSize: 9 }} />
                      {meta.label}
                    </span>
                  </div>
                  <div style={{
                    display: "flex", gap: 12, flexWrap: "wrap",
                    fontSize: 11, color: "rgba(255,255,255,.55)",
                  }}>
                    <span><i className="fa-solid fa-location-dot" />&nbsp; {fmtCoords(g.open)}</span>
                    <span><i className="fa-solid fa-square-parking" />&nbsp; {g.spawns.length} spawn(s)</span>
                    {g.payment > 0 && <span><i className="fa-solid fa-coins" />&nbsp; ${g.payment}</span>}
                    {g.permission && <span><i className="fa-solid fa-key" />&nbsp; {g.permission}</span>}
                  </div>
                </div>

                {/* action icons */}
                <div style={{ display: "flex", gap: 4, flexShrink: 0 }}>
                  <IconButton title="Teleportar" icon="fa-solid fa-location-arrow" color="#3C8EDC" onClick={() => teleport(g)} />
                  <IconButton title="Editar"     icon="fa-solid fa-pen"           color="#F3A623" onClick={() => openEdit(g)} />
                  <IconButton title="Remover"    icon="fa-solid fa-trash"          color="#ff5a5a" onClick={() => confirmDelete(g)} />
                </div>
              </div>
            );
          })}
        </div>
        </>)}

        {activeTab === "vehicles" && (<>
        <div className="panel-nav">
          <div className="new" onClick={openVehCreate}>
            <i className="fa-solid fa-plus" /> CADASTRAR VEÍCULO
          </div>
          <div style={{ flex: "0 0 200px" }}>
            <CustomSelect
              selected={vehCategory}
              onChange={setVehCategory}
              options={vehCategoryOptions}
            />
          </div>
          <input
            placeholder="Pesquisar por spawn, nome ou classe..."
            value={vehSearch}
            onChange={(e) => handleVehSearch(e.target.value)}
          />
        </div>

        <div id="list" className="char">
          {filteredVehicles.length === 0 && (
            <div className="gm-empty" style={{
              display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center",
              padding: "3rem 2rem", color: "rgba(255,255,255,.4)", textAlign: "center", gap: 12
            }}>
              <i className="fa-solid fa-car-side" style={{ fontSize: 48, opacity: 0.5 }} />
              <div style={{ fontSize: 14, fontWeight: 600, letterSpacing: 0.5 }}>
                {vehicles.length === 0 ? "CARREGANDO VEÍCULOS..." : "NENHUM RESULTADO"}
              </div>
              {vehicles.length > 0 && vehSearch && (
                <div style={{ fontSize: 12, opacity: 0.7 }}>
                  Não encontramos veículos para "{vehSearch}".
                </div>
              )}
            </div>
          )}

          {visibleVehicles.map((v) => (
            <VehicleRow
              key={v.spawn}
              v={v}
              catLabel={vehCategories[v.category || ""] || v.category || "—"}
              onEdit={openVehEdit}
              onDelete={deleteVehicle}
            />
          ))}

          {filteredVehicles.length > visibleVehicles.length && (
            <div
              className="core-manager__load-more"
              onClick={() => setVehVisibleCount((c) => c + VEH_PAGE_SIZE)}
              style={{
                margin: "8px 0", padding: "10px 14px", borderRadius: 6, cursor: "pointer",
                background: "rgba(60,142,220,0.08)", border: "1px solid rgba(60,142,220,0.25)",
                color: "#3C8EDC", fontSize: 12, fontWeight: 700, letterSpacing: 0.5,
                display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
                transition: "all .15s",
              }}
              onMouseEnter={(e) => { e.currentTarget.style.background = "rgba(60,142,220,0.15)"; }}
              onMouseLeave={(e) => { e.currentTarget.style.background = "rgba(60,142,220,0.08)"; }}
            >
              <i className="fa-solid fa-chevron-down" />
              VER MAIS — exibindo {visibleVehicles.length} de {filteredVehicles.length}
            </div>
          )}
        </div>
        </>)}
      </>)}

      {showGarageForm && (
        <div className="char gm-form-page">
          <div>
            <div className="text">Nome</div>
            <input
              placeholder="Ex.: Garagem Centro"
              value={formName}
              onChange={(e) => setFormName(e.target.value)}
            />
          </div>

          <div style={{ marginTop: 12 }}>
            <div className="text">Tipo</div>
            <CustomSelect
              selected={formType}
              onChange={(v) => setFormType(v as GarageType)}
              options={TYPES_LIST.map((t) => ({
                value: t.value,
                label: TYPE_META[t.value].label,
              }))}
            />
          </div>

          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12, marginTop: 12 }}>
            <div>
              <div className="text">Permissão (opcional)</div>
              <input
                placeholder="ex.: policia.acesso"
                value={formPerm}
                onChange={(e) => setFormPerm(e.target.value)}
              />
            </div>
            <div>
              <div className="text">Taxa de saída</div>
              <input
                type="number"
                min={0}
                value={formPayment}
                onChange={(e) => setFormPayment(Number(e.target.value))}
              />
            </div>
          </div>

          <div className="gm-form-section" style={{ marginTop: 16, padding: 12, background: "rgba(255,255,255,0.02)", border: "1px solid rgba(255,255,255,0.05)", borderRadius: 6 }}>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 8 }}>
              <span style={{ fontSize: 12, color: "rgba(255,255,255,0.7)", fontWeight: 600, textTransform: "uppercase", letterSpacing: 0.5 }}>
                <i className="fa-solid fa-location-dot" />&nbsp; Posição do blip
              </span>
              {formOpen && (
                <span style={{ fontSize: 11, color: "#10B981" }}>
                  <i className="fa-solid fa-circle-check" />&nbsp; capturado
                </span>
              )}
            </div>
            <div
              className="gm-form-action"
              onClick={() => !capturing && captureCoords("open")}
              style={{
                padding: "10px 12px", borderRadius: 4,
                background: formOpen ? "rgba(16,185,129,0.08)" : "rgba(60,142,220,0.1)",
                border: `1px solid ${formOpen ? "rgba(16,185,129,0.3)" : "rgba(60,142,220,0.3)"}`,
                color: formOpen ? "#fff" : "#3C8EDC",
                cursor: capturing ? "wait" : "pointer",
                opacity: capturing ? 0.5 : 1, fontSize: 13, fontWeight: 600,
                display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
                transition: "all .15s",
              }}
            >
              <i className={formOpen ? "fa-solid fa-rotate" : "fa-solid fa-location-crosshairs"} />
              {formOpen ? fmtCoords(formOpen) : "CAPTURAR MINHA POSIÇÃO"}
            </div>

            <div style={{ marginTop: 10, display: "flex", alignItems: "center", gap: 8 }}>
              <input
                id="gm-blip-visible"
                type="checkbox"
                checked={formBlipEnabled}
                onChange={(e) => setFormBlipEnabled(e.target.checked)}
                style={{ width: 16, height: 16, cursor: "pointer" }}
              />
              <label htmlFor="gm-blip-visible" style={{ fontSize: 12, color: "rgba(255,255,255,0.8)", cursor: "pointer" }}>
                Mostrar o blip no mapa do GTA (M)
              </label>
            </div>
          </div>

          <div className="gm-form-section" style={{ marginTop: 12, padding: 12, background: "rgba(255,255,255,0.02)", border: "1px solid rgba(255,255,255,0.05)", borderRadius: 6 }}>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 8 }}>
              <span style={{ fontSize: 12, color: "rgba(255,255,255,0.7)", fontWeight: 600, textTransform: "uppercase", letterSpacing: 0.5 }}>
                <i className="fa-solid fa-square-parking" />&nbsp; Spawns dos veículos
              </span>
              <span style={{ fontSize: 11, color: formSpawns.length > 0 ? "#10B981" : "rgba(255,255,255,0.4)" }}>
                {formSpawns.length > 0 && <i className="fa-solid fa-circle-check" />}&nbsp;
                {formSpawns.length} adicionado(s)
              </span>
            </div>
            <div
              className="gm-form-action"
              onClick={() => !capturing && captureCoords("spawn")}
              style={{
                padding: "10px 12px", borderRadius: 4,
                background: "rgba(243,166,35,0.1)", border: "1px solid rgba(243,166,35,0.3)",
                color: "#F3A623", cursor: capturing ? "wait" : "pointer",
                opacity: capturing ? 0.5 : 1, fontSize: 13, fontWeight: 600,
                display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
                transition: "all .15s",
              }}
            >
              <i className="fa-solid fa-plus" />
              ADICIONAR SPAWN DA MINHA POSIÇÃO
            </div>
            {formSpawns.length > 0 && (
              <div style={{ marginTop: 8, maxHeight: 110, overflowY: "auto", display: "flex", flexDirection: "column", gap: 4 }}>
                {formSpawns.map((s, i) => (
                  <div key={i} style={{
                    display: "flex", justifyContent: "space-between", alignItems: "center",
                    padding: "4px 4px 4px 10px", fontSize: 11, color: "rgba(255,255,255,.7)",
                    background: "rgba(255,255,255,0.02)", borderRadius: 4,
                  }}>
                    <span><b style={{ color: "rgba(255,255,255,0.9)" }}>#{i + 1}</b> — {fmtCoords(s)}</span>
                    <button
                      type="button"
                      onClick={() => removeSpawn(i)}
                      title="Remover spawn"
                      style={{
                        width: 26, height: 26, borderRadius: 4, padding: 0,
                        background: "rgba(255,90,90,0.1)", border: "1px solid rgba(255,90,90,0.25)",
                        color: "#ff8585", cursor: "pointer",
                        display: "flex", alignItems: "center", justifyContent: "center",
                        fontSize: 11, transition: "all .15s",
                      }}
                      onMouseEnter={(e) => { e.currentTarget.style.background = "rgba(255,90,90,0.2)"; e.currentTarget.style.color = "#ff5a5a"; }}
                      onMouseLeave={(e) => { e.currentTarget.style.background = "rgba(255,90,90,0.1)"; e.currentTarget.style.color = "#ff8585"; }}
                    >
                      <i className="fa-solid fa-xmark" />
                    </button>
                  </div>
                ))}
              </div>
            )}
          </div>

          {capturing && (
            <div className="gm-form-warning" style={{ marginTop: 10, padding: 10, background: "rgba(255,200,0,.1)", border: "1px solid rgba(255,200,0,.3)", borderRadius: 4, fontSize: 12, color: "#ffd969", display: "flex", alignItems: "center", gap: 8 }}>
              <i className="fa-solid fa-circle-exclamation" />
              <span>Painel oculto — vá até a posição e pressione <b>E</b> no jogo (BACKSPACE cancela).</span>
            </div>
          )}

          {formType === "SERVICE" && (
            <>
              <div className="text" style={{ marginTop: 12 }}>
                Veículos disponíveis ({formVehicles.length})
              </div>
              <div style={{ display: "flex", gap: 6, alignItems: "stretch" }}>
                <input
                  placeholder="spawn (ex.: dinghy)"
                  value={vSpawnInput}
                  onChange={(e) => setVSpawnInput(e.target.value)}
                  onKeyDown={(e) => { if (e.key === "Enter") { e.preventDefault(); addVehicle(); } }}
                  style={{ flex: 1 }}
                />
                <input
                  type="number"
                  min={0}
                  placeholder="preço"
                  value={vPriceInput}
                  onChange={(e) => setVPriceInput(Number(e.target.value))}
                  onKeyDown={(e) => { if (e.key === "Enter") { e.preventDefault(); addVehicle(); } }}
                  style={{ width: 100 }}
                />
                <button
                  className="gm-form-add"
                  type="button"
                  onClick={addVehicle}
                  title="Adicionar veículo"
                  style={{
                    width: 44, height: 40, flexShrink: 0,
                    background: "rgba(60,142,220,0.12)",
                    border: "1px solid rgba(60,142,220,0.35)",
                    borderRadius: 6, color: "#3C8EDC", cursor: "pointer",
                    display: "flex", alignItems: "center", justifyContent: "center",
                    padding: 0, fontSize: 13, transition: "all .15s",
                  }}
                  onMouseEnter={(e) => { e.currentTarget.style.background = "rgba(60,142,220,0.22)"; }}
                  onMouseLeave={(e) => { e.currentTarget.style.background = "rgba(60,142,220,0.12)"; }}
                >
                  <i className="fa-solid fa-plus" />
                </button>
              </div>
              {formVehicles.length > 0 && (
                <div style={{ marginTop: 6, maxHeight: 110, overflowY: "auto", display: "flex", flexDirection: "column", gap: 4 }}>
                  {formVehicles.map((v) => (
                    <div key={v.spawn} style={{
                      display: "flex", justifyContent: "space-between", alignItems: "center",
                      padding: "4px 4px 4px 10px", fontSize: 11, color: "rgba(255,255,255,.7)",
                      background: "rgba(255,255,255,0.02)", borderRadius: 4,
                    }}>
                      <span><b style={{ color: "rgba(255,255,255,0.9)" }}>{v.spawn}</b>{v.price > 0 ? ` — $${v.price}` : " — grátis"}</span>
                      <button
                        type="button"
                        onClick={() => removeVehicle(v.spawn)}
                        title="Remover veículo"
                        style={{
                          width: 26, height: 26, borderRadius: 4, padding: 0,
                          background: "rgba(255,90,90,0.1)", border: "1px solid rgba(255,90,90,0.25)",
                          color: "#ff8585", cursor: "pointer",
                          display: "flex", alignItems: "center", justifyContent: "center",
                          fontSize: 11, transition: "all .15s",
                        }}
                        onMouseEnter={(e) => { e.currentTarget.style.background = "rgba(255,90,90,0.2)"; e.currentTarget.style.color = "#ff5a5a"; }}
                        onMouseLeave={(e) => { e.currentTarget.style.background = "rgba(255,90,90,0.1)"; e.currentTarget.style.color = "#ff8585"; }}
                      >
                        <i className="fa-solid fa-xmark" />
                      </button>
                    </div>
                  ))}
                </div>
              )}
              {formVehicles.length === 0 && (
                <div style={{ marginTop: 6, fontSize: 12, color: "#ffd969" }}>
                  <i className="fa-solid fa-circle-exclamation" />&nbsp;
                  Adicione pelo menos 1 veículo para a garagem funcionar
                </div>
              )}
            </>
          )}

          {!canSave && (
            <div style={{ marginTop: 12, fontSize: 12, color: "rgba(255,255,255,.5)" }}>
              {formName.trim() === "" && <div>• Nome obrigatório</div>}
              {!formOpen && <div>• Capture a posição do blip</div>}
              {formSpawns.length === 0 && <div>• Adicione pelo menos 1 spawn</div>}
              {requiresVehicles && formVehicles.length === 0 && <div>• Adicione pelo menos 1 veículo</div>}
            </div>
          )}
        </div>
      )}

      {showVehicleForm && (
        <div className="char gm-form-page">
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
            <div>
              <div className="text">Spawn (model)</div>
              <input
                placeholder="ex.: adder"
                value={vfSpawn}
                onChange={(e) => setVfSpawn(e.target.value)}
                disabled={vehEditor!.mode === "edit"}
                style={vehEditor!.mode === "edit" ? { opacity: 0.6, cursor: "not-allowed" } : undefined}
              />
            </div>
            <div>
              <div className="text">Nome de exibição</div>
              <input
                placeholder="ex.: Adder"
                value={vfName}
                onChange={(e) => setVfName(e.target.value)}
              />
            </div>
          </div>

          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12, marginTop: 8 }}>
            <div>
              <div className="text">Categoria</div>
              <CustomSelect
                selected={vfCategory}
                onChange={setVfCategory}
                options={Object.entries(vehCategories).map(([value, label]) => ({ value, label }))}
              />
            </div>
            <div>
              <div className="text">Tipo de pagamento</div>
              <CustomSelect
                selected={vfPaymentType}
                onChange={setVfPaymentType}
                options={[
                  { value: "primary",   label: "Primário ($)" },
                  { value: "secondary", label: "Secundário (gemas)" },
                ]}
              />
            </div>
          </div>

          <div style={{ marginTop: 8 }}>
            <div>
              <div className="text">
                {vfPaymentType === "secondary"
                  ? "Preço em gemas"
                  : "Preço em dinheiro"}
              </div>
              <input type="number" min={0} value={vfPrice} onChange={(e) => setVfPrice(Number(e.target.value))} />
            </div>
          </div>

          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12, marginTop: 8 }}>
            <div>
              <div className="text">Classe (subcategoria livre)</div>
              <input placeholder="ex.: Clássicos" value={vfClass} onChange={(e) => setVfClass(e.target.value)} />
            </div>
            <div>
              <div className="text">Mode (opcional)</div>
              <input placeholder="ex.: Work, Bikes, Rental" value={vfMode} onChange={(e) => setVfMode(e.target.value)} />
            </div>
          </div>

          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12, marginTop: 8 }}>
            <div>
              <div className="text">Peso porta-malas</div>
              <input type="number" min={0} value={vfWeightTrunk} onChange={(e) => setVfWeightTrunk(Number(e.target.value))} />
            </div>
            <div>
              <div className="text">Peso porta-luvas</div>
              <input type="number" min={0} value={vfWeightGloves} onChange={(e) => setVfWeightGloves(Number(e.target.value))} />
            </div>
          </div>

          <div style={{ marginTop: 12, display: "flex", alignItems: "center", gap: 8 }}>
            <input
              id="vf-outdealership"
              type="checkbox"
              checked={vfOutDealership}
              onChange={(e) => setVfOutDealership(e.target.checked)}
              style={{ width: 16, height: 16, cursor: "pointer" }}
            />
            <label htmlFor="vf-outdealership" style={{ fontSize: 12, color: "rgba(255,255,255,0.8)", cursor: "pointer" }}>
              Ocultar da concessionária (não fica disponível para compra)
            </label>
          </div>

          {!vehFormValid && (
            <div style={{ marginTop: 12, fontSize: 12, color: "rgba(255,255,255,.5)" }}>
              {vfSpawn.trim() === "" && <div>• Spawn obrigatório</div>}
              {vfName.trim() === "" && <div>• Nome obrigatório</div>}
            </div>
          )}
        </div>
      )}

      {showForm && (
        <div
          className="v-modal-actions"
          style={{
            padding: "12px 20px",
            borderTop: "1px solid rgba(255,255,255,0.06)",
            flexShrink: 0,
          }}
        >
          <button type="button" className="v-modal-btn-cancel" onClick={handleFormBack}>
            CANCELAR
          </button>
          <button
            type="button"
            className="v-modal-btn-confirm"
            onClick={handleFormConfirm}
            disabled={formConfirmDisabled}
            style={formConfirmDisabled ? { opacity: 0.5, cursor: "not-allowed" } : undefined}
          >
            {formConfirmLabel}
          </button>
        </div>
      )}
    </div>,
    container
  );
}

interface IconButtonProps {
  title: string;
  icon: string;
  color: string;
  onClick: () => void;
}

interface VehicleRowProps {
  v: Vehicle;
  catLabel: string;
  onEdit: (v: Vehicle) => void;
  onDelete: (v: Vehicle) => void;
}

const VehicleRow = memo(function VehicleRow({ v, catLabel, onEdit, onDelete }: VehicleRowProps) {
  return (
    <div
      className="gm-vehicle-row"
      style={{
        display: "flex", alignItems: "center", gap: 14,
        padding: 10, borderRadius: 8,
        background: "rgba(255,255,255,0.02)",
        border: "1px solid rgba(255,255,255,0.05)",
        marginBottom: 6,
      }}
    >
      <div className="gm-vehicle-row__icon" style={{
        width: 44, height: 44, borderRadius: 8, flexShrink: 0,
        display: "flex", alignItems: "center", justifyContent: "center",
        background: "rgba(60,142,220,0.12)", color: "#3C8EDC", fontSize: 18,
        border: "1px solid rgba(60,142,220,0.25)",
      }}>
        <i className="fa-solid fa-car" />
      </div>

      <div style={{ flex: 1, minWidth: 0, display: "flex", flexDirection: "column", gap: 4 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8, flexWrap: "wrap" }}>
          <span style={{ color: "#fff", fontWeight: 700, fontSize: 13 }}>
            {v.name || v.spawn}
          </span>
          <span style={{
            fontSize: 10, color: "rgba(255,255,255,0.4)", fontFamily: "monospace",
            background: "rgba(255,255,255,0.04)", padding: "1px 6px", borderRadius: 3,
          }}>
            {v.spawn}
          </span>
        </div>
        <div style={{ display: "flex", gap: 10, flexWrap: "wrap", fontSize: 11, color: "rgba(255,255,255,.5)" }}>
          <span><i className="fa-solid fa-tag" />&nbsp; {catLabel}</span>
          {typeof v.price === "number" && (
            <span>
              <i className={v.paymentType === "secondary" ? "fa-regular fa-gem" : "fa-solid fa-dollar-sign"} />
              &nbsp; {v.price.toLocaleString()}
            </span>
          )}
          {v.class && <span><i className="fa-solid fa-layer-group" />&nbsp; {v.class}</span>}
          {v.mode && <span><i className="fa-solid fa-shapes" />&nbsp; {v.mode}</span>}
          {v.outDealership && <span style={{ color: "#F3A623" }}><i className="fa-solid fa-eye-slash" />&nbsp; oculto da loja</span>}
        </div>
      </div>

      <div style={{ display: "flex", gap: 4, flexShrink: 0 }}>
        <IconButton title="Editar" icon="fa-solid fa-pen" color="#F3A623" onClick={() => onEdit(v)} />
        <IconButton title="Remover" icon="fa-solid fa-trash" color="#ff5a5a" onClick={() => onDelete(v)} />
      </div>
    </div>
  );
});

function IconButton({ title, icon, color, onClick }: IconButtonProps) {
  const [hover, setHover] = useState(false);
  return (
    <button
      className="gm-icon-button"
      type="button"
      title={title}
      onClick={onClick}
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => setHover(false)}
      style={{
        width: 36, height: 36, border: "1px solid rgba(255,255,255,0.06)",
        borderRadius: 6, background: hover ? `${color}22` : "rgba(255,255,255,0.02)",
        color: hover ? color : "rgba(255,255,255,0.5)",
        display: "flex", alignItems: "center", justifyContent: "center",
        cursor: "pointer", transition: "all .15s", padding: 0, fontSize: 13,
      }}
    >
      <i className={icon} />
    </button>
  );
}
