import { useState, useRef, useMemo } from "react";
import ReactDOM from "react-dom";
import { useAppStore } from "@app/stores/store";
import { fetchNui, sendNui } from "@app/utils/nui";
import { getVehicleImage, replaceMissingVehicleImage } from "@app/utils/format";
import { CustomSelect } from "./CustomSelect";

export function StockManager() {
  const managerData = useAppStore((s) => s.managerData);
  const close = useAppStore((s) => s.close);

  const [selectedCategory, setSelectedCategory] = useState("");
  const [stock, setStock] = useState<Record<string, number>>({});
  const saveCooldownRef = useRef(false);
  const [search, setSearch] = useState("");
  const searchTO = useRef<ReturnType<typeof setTimeout> | null>(null);
  const [debouncedSearch, setDebouncedSearch] = useState("");

  const container = document.getElementById("v-manager");

  const sortedCategories = useMemo(() => {
    if (!managerData) return [];
    const cats: [string, string][] = [];
    for (const catId in managerData.vehicles) {
      if (
        managerData.vehicles[catId] &&
        managerData.vehicles[catId].length > 0 &&
        managerData.categories[catId]
      ) {
        cats.push([catId, managerData.categories[catId]]);
      }
    }
    cats.sort((a, b) => a[1].localeCompare(b[1]));

    // Sort vehicles within each category
    for (const [catId] of cats) {
      managerData.vehicles[catId].sort((a: any, b: any) =>
        a.index.localeCompare(b.index)
      );
    }

    // Initialize stock from data
    const initialStock: Record<string, number> = {};
    for (const idx in managerData.stock) {
      initialStock[idx] = managerData.stock[idx];
    }
    setStock(initialStock);

    if (cats.length > 0 && !selectedCategory) {
      setSelectedCategory(cats[0][0]);
    }
    return cats;
  }, [managerData]);

  if (!managerData || !container) return null;

  const activeCat = selectedCategory || (sortedCategories[0]?.[0] ?? "");

  const categoryOptions = sortedCategories.map(([id, name]) => ({
    value: id,
    label: name,
  }));

  const vehicles = managerData.vehicles[activeCat] || [];

  function tryUpdateStock(index: string) {
    if (saveCooldownRef.current) return;
    const amount = stock[index] ?? 0;
    if (managerData.stock[index] !== undefined && managerData.stock[index] === amount) return;
    saveCooldownRef.current = true;

    fetchNui({ action: "tryUpdateDealerVehicleStock", index, amount }).then(
      (r: any) => {
        if (r?.success) {
          managerData.stock[index] = r.newStock;
          setStock((prev) => ({ ...prev, [index]: r.newStock }));
        } else {
          const s = managerData.stock[index] || 0;
          setStock((prev) => ({ ...prev, [index]: s }));
        }
        saveCooldownRef.current = false;
      }
    );
  }

  function handleSearch(value: string) {
    setSearch(value);
    if (searchTO.current) clearTimeout(searchTO.current);
    searchTO.current = setTimeout(() => {
      setDebouncedSearch(value.toLowerCase().trim());
    }, 500);
  }

  const filteredVehicles = vehicles.filter((v: any) => {
    if (!debouncedSearch) return true;
    return v.name.toLowerCase().includes(debouncedSearch);
  });

  return ReactDOM.createPortal(
    <div id="manager" className="core-manager core-manager--stock">
      <div className="panel-header">
        <div className="panel-title-group">
          <div className="title">GERENCIADOR DE ESTOQUE</div>
          <div className="subtitle">ATUALIZE A CONCESSIONÁRIA EM TEMPO REAL</div>
        </div>
        <div className="leave" onClick={close}>
          <i className="fa-solid fa-xmark" />
        </div>
      </div>
      <div className="panel-nav">
        <CustomSelect
          options={categoryOptions}
          selected={activeCat}
          onChange={setSelectedCategory}
        />
        <input
          id="manager-search"
          placeholder="Pesquisar..."
          value={search}
          onChange={(e) => handleSearch(e.target.value)}
        />
      </div>
      <div id="list">
        {filteredVehicles.length === 0 ? (
          <div className="empty">
            <i className="fa-solid fa-circle-xmark" /> Ops, parece que não temos
            nenhum veículo disponível nesta categoria!
          </div>
        ) : (
          filteredVehicles.map((veh: any) => (
            <div className="item" key={veh.index}>
              <div className="name">{veh.name}</div>
              <img
                src={getVehicleImage(veh.index)}
                onError={replaceMissingVehicleImage}
              />
              <div className="buttons">
                <input
                  value={stock[veh.index] ?? 0}
                  onChange={(e) => {
                    const val = e.target.value;
                    if (val === "" || !isNaN(Number(val))) {
                      setStock((prev) => ({
                        ...prev,
                        [veh.index]: val === "" ? 0 : parseInt(val),
                      }));
                    }
                  }}
                />
                <div className="save" onClick={() => tryUpdateStock(veh.index)}>
                  <i className="fa-solid fa-floppy-disk" />
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>,
    container
  );
}
