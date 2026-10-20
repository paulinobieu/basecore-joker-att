import { useState, useRef, useMemo } from "react";
import ReactDOM from "react-dom";
import { useAppStore } from "@app/stores/store";
import { fetchNui, sendNui } from "@app/utils/nui";
import {
  getVehicleImage,
  replaceMissingVehicleImage,
  formatDateFromTime,
  formatCurrency,
} from "@app/utils/format";
import { Modal } from "./Modal";

export function VehicleManager() {
  const vmanagerData = useAppStore((s) => s.vmanagerData);
  const close = useAppStore((s) => s.close);

  const cooldownRef = useRef(false);
  const [search, setSearch] = useState("");
  const searchTO = useRef<ReturnType<typeof setTimeout> | null>(null);
  const [debouncedSearch, setDebouncedSearch] = useState("");
  const [rentDays, setRentDays] = useState(0);

  // Modal state
  const [modal, setModal] = useState<null | {
    type: "remove" | "renew" | "add" | "removeAll";
    plate?: string;
  }>(null);

  const container = document.getElementById("v-manager");

  const sortedVehicles = useMemo(() => {
    if (!vmanagerData?.vehicles) return [];
    const arr: any[] = [];
    for (const plate in vmanagerData.vehicles) {
      const v = vmanagerData.vehicles[plate];
      if (v) {
        v.plate = plate;
        arr.push(v);
      }
    }
    arr.sort((a, b) => a.index.localeCompare(b.index));
    return arr;
  }, [vmanagerData]);

  if (!vmanagerData || !container) return null;

  function handleSearch(value: string) {
    setSearch(value);
    if (searchTO.current) clearTimeout(searchTO.current);
    searchTO.current = setTimeout(() => {
      setDebouncedSearch(value.toLowerCase().trim());
    }, 500);
  }

  const filtered = sortedVehicles.filter((v) => {
    if (!debouncedSearch) return true;
    const text = `${v.name} ${v.plate} ${v.index}`.toLowerCase();
    return text.includes(debouncedSearch);
  });

  function cvmTryRemove(plate: string) {
    if (cooldownRef.current) return;
    cooldownRef.current = true;
    fetchNui({ action: "cvmTryRemove", plate }).then((r: any) => {
      if (r?.success) {
        vmanagerData.vehicles[plate] = null;
        useAppStore.getState().openVehicleManager({ ...vmanagerData });
      }
      setTimeout(() => (cooldownRef.current = false), 800);
    });
    setModal(null);
  }

  function cvmTryFind(plate: string) {
    if (cooldownRef.current) return;
    cooldownRef.current = true;
    fetchNui({ action: "cvmTryFind", plate }).then((r: any) => {
      if (r?.success) {
        sendNui({ action: "close" });
        close();
      }
      setTimeout(() => (cooldownRef.current = false), 800);
    });
  }

  function cvmTryRenew(plate: string) {
    if (cooldownRef.current) return;
    cooldownRef.current = true;
    fetchNui({ action: "cvmTryRenew", plate, days: rentDays }).then(
      (r: any) => {
        if (r?.success && r.newTime) {
          vmanagerData.vehicles[plate].expire_time = r.newTime;
          useAppStore.getState().openVehicleManager({ ...vmanagerData });
        }
        setTimeout(() => (cooldownRef.current = false), 500);
      }
    );
    setModal(null);
  }

  function cvmTryRemoveAll() {
    if (cooldownRef.current) return;
    cooldownRef.current = true;
    fetchNui({ action: "cvmTryRemoveAll", id: vmanagerData.id }).then((r: any) => {
      if (r?.success) {
        vmanagerData.vehicles = {};
        useAppStore.getState().openVehicleManager({ ...vmanagerData });
      }
      setTimeout(() => (cooldownRef.current = false), 800);
    });
    setModal(null);
  }

  function cvmTryAdd(model: string, plate: string, days: number) {
    if (cooldownRef.current) return;
    cooldownRef.current = true;
    fetchNui({
      action: "cvmTryAdd",
      id: vmanagerData.id,
      model,
      days,
      plate,
    }).then((r: any) => {
      if (r?.success) {
        if (!vmanagerData.vehicles) vmanagerData.vehicles = {};
        vmanagerData.vehicles[r.plate] = r.nvdata;
        useAppStore.getState().openVehicleManager({ ...vmanagerData });
      }
      setTimeout(() => (cooldownRef.current = false), 800);
    });
    setModal(null);
  }

  return ReactDOM.createPortal(
    <>
      <div id="manager" className="char core-manager core-manager--vehicles">
        <div className="panel-header">
          <div className="panel-title-group">
            <div className="title">GERENCIADOR DE VEÍCULOS</div>
            <div className="subtitle">PERSONAGEM #{vmanagerData.id}</div>
          </div>
          <div className="leave" onClick={close}>
            <i className="fa-solid fa-xmark" />
          </div>
        </div>
        <div className="panel-nav">
          <div
            className="new"
            onClick={() => {
              setRentDays(0);
              setModal({ type: "add" });
            }}
          >
            ADICIONAR VEÍCULO
          </div>
          {sortedVehicles.length > 0 && (
            <div
              className="new"
              style={{ background: "rgba(255,90,90,0.15)", color: "#ff5a5a", border: "1px solid rgba(255,90,90,0.3)" }}
              onClick={() => setModal({ type: "removeAll" })}
            >
              REMOVER TODOS
            </div>
          )}
          <input
            id="vmanager-search"
            placeholder="Pesquisar..."
            value={search}
            onChange={(e) => handleSearch(e.target.value)}
          />
        </div>
        <div id="list" className="char">
          {filtered.map((veh) => {
            const hasDuration =
              veh.expire_time && veh.expire_time > 0;
            const durationText = hasDuration
              ? `EXPIRA EM - ${formatDateFromTime(veh.expire_time * 1000)}`
              : "PERMANENTE";
            return (
              <div className="cveh" key={veh.plate} id={`cveh-${veh.plate}`}>
                <img
                  src={getVehicleImage(veh.index)}
                  onError={replaceMissingVehicleImage}
                />
                <div className="infos">
                  <div className="info">- {veh.name}</div>
                  <div className="info">- {veh.plate}</div>
                  <div className="info">- {durationText}</div>
                </div>
                <div className="buttons">
                  <div
                    className="button remove"
                    onClick={() => setModal({ type: "remove", plate: veh.plate })}
                  >
                    REMOVER
                  </div>
                  <div
                    className="button find"
                    onClick={() => cvmTryFind(veh.plate)}
                  >
                    LOCALIZAR
                  </div>
                  {hasDuration && (
                    <div
                      className="button renew"
                      onClick={() => {
                        setRentDays(1);
                        setModal({ type: "renew", plate: veh.plate });
                      }}
                    >
                      RENOVAR
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {modal?.type === "remove" && modal.plate && (
        <RemoveModal
          plate={modal.plate}
          vehicle={vmanagerData.vehicles[modal.plate]}
          id={vmanagerData.id}
          onConfirm={() => cvmTryRemove(modal.plate!)}
          onCancel={() => setModal(null)}
        />
      )}
      {modal?.type === "renew" && modal.plate && (
        <RenewModal
          vehicle={vmanagerData.vehicles[modal.plate]}
          rentDays={rentDays}
          setRentDays={setRentDays}
          onConfirm={() => cvmTryRenew(modal.plate!)}
          onCancel={() => setModal(null)}
        />
      )}
      {modal?.type === "add" && (
        <AddModal
          id={vmanagerData.id}
          rentDays={rentDays}
          setRentDays={setRentDays}
          onConfirm={cvmTryAdd}
          onCancel={() => setModal(null)}
        />
      )}
      {modal?.type === "removeAll" && (
        <RemoveAllModal
          id={vmanagerData.id}
          count={sortedVehicles.length}
          onConfirm={cvmTryRemoveAll}
          onCancel={() => setModal(null)}
        />
      )}
    </>,
    container
  );
}

function RemoveAllModal({
  id,
  count,
  onConfirm,
  onCancel,
}: {
  id: string;
  count: number;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  return (
    <Modal
      title="REMOVER TODOS OS VEÍCULOS"
      icon="fa-solid fa-trash-can"
      onConfirm={onConfirm}
      onCancel={onCancel}
    >
      <div className="text">
        Deseja realmente remover <b>todos os {count} veículos</b> do personagem{" "}
        <b>#{id}</b>?
        <br />
        <b>Atenção:</b> esta ação é <b>irreversível</b> e remove tanto carros
        permanentes quanto aluguéis.
      </div>
    </Modal>
  );
}

function RemoveModal({
  plate,
  vehicle,
  id,
  onConfirm,
  onCancel,
}: {
  plate: string;
  vehicle: any;
  id: string;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  return (
    <Modal
      title="CONFIRMAÇÃO"
      icon="fa-solid fa-trash"
      onConfirm={onConfirm}
      onCancel={onCancel}
    >
      <div className="text">
        Deseja realmente remover o veículo{" "}
        <b>
          {vehicle?.index} ({plate})
        </b>{" "}
        do personagem <b>#{id}</b>?
        <br />
        <b>Atenção:</b> esta ação é <b>irreversível</b>!
      </div>
    </Modal>
  );
}

function RenewModal({
  vehicle,
  rentDays,
  setRentDays,
  onConfirm,
  onCancel,
}: {
  vehicle: any;
  rentDays: number;
  setRentDays: (d: number) => void;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  return (
    <Modal
      title="DURAÇÃO DO VEÍCULO"
      icon="fa-solid fa-clock-rotate-left"
      onConfirm={onConfirm}
      onCancel={onCancel}
    >
      <div className="text">Modelo</div>
      <input value={vehicle?.index || ""} readOnly />
      <div className="text">Placa</div>
      <input value={vehicle?.plate || ""} readOnly />
      <center>
        <div className="text" style={{ marginTop: 12 }}>
          Quantidade de dias
        </div>
        <div className="modal-range">
          <input readOnly value={rentDays} />
          <input
            type="range"
            min={1}
            max={30}
            step={1}
            value={rentDays}
            onChange={(e) => setRentDays(parseInt(e.target.value))}
            style={{
              backgroundSize: `${((rentDays - 1) * 100) / 29}% 100%`,
            }}
          />
        </div>
      </center>
    </Modal>
  );
}

function AddModal({
  id,
  rentDays,
  setRentDays,
  onConfirm,
  onCancel,
}: {
  id: string;
  rentDays: number;
  setRentDays: (d: number) => void;
  onConfirm: (model: string, plate: string, days: number) => void;
  onCancel: () => void;
}) {
  const [model, setModel] = useState("");
  const [plate, setPlate] = useState("");

  return (
    <Modal
      title={`ADICIONAR VEÍCULO PARA O ID #${id}`}
      icon="fa-solid fa-plus"
      onConfirm={() => onConfirm(model, plate, rentDays)}
      onCancel={onCancel}
    >
      <div className="text">Modelo do Veículo</div>
      <input
        placeholder="Insira.."
        value={model}
        onChange={(e) => setModel(e.target.value)}
      />
      <div className="text">
        Placa customizada
        <br />
        <span className="modal-text-tip">
          [ VAZIO = GERAR AUTOMATICAMENTE ]
          <br />[ SOMENTE VEÍCULOS PERMANENTES ]
        </span>
      </div>
      <input
        placeholder="(Opcional)"
        value={plate}
        onChange={(e) => setPlate(e.target.value)}
      />
      <center>
        <div className="text" style={{ marginTop: 12 }}>
          Quantidade de dias
          <br />
          <span className="modal-text-tip">[ 0 = PERMANENTE ]</span>
        </div>
        <div className="modal-range">
          <input readOnly value={rentDays} />
          <input
            type="range"
            min={0}
            max={30}
            step={1}
            value={rentDays}
            onChange={(e) => setRentDays(parseInt(e.target.value))}
            style={{
              backgroundSize: `${(rentDays * 100) / 30}% 100%`,
            }}
          />
        </div>
      </center>
    </Modal>
  );
}
