import { useState, useRef, useMemo, useEffect, useCallback } from "react";
import { useAppStore } from "@app/stores/store";
import { fetchNui, sendNui } from "@app/utils/nui";
import { formatCurrency, getRGBFromHex } from "@app/utils/format";
import { Modal } from "./Modal";
import { CustomSelect } from "./CustomSelect";

const excludedModsCategories: Record<number, boolean> = {
  11: true, 12: true, 13: true, 15: true, 16: true, 18: true, 23: true, 24: true,
};

const tunningsOpts: Record<string, { modId: number; name: string }> = {
  engine: { modId: 11, name: "Motor" },
  brakes: { modId: 12, name: "Freios" },
  transmission: { modId: 13, name: "Transmissão" },
  suspension: { modId: 15, name: "Suspensão" },
  armour: { modId: 16, name: "Blindagem" },
};

const tintNames: Record<number, string> = {
  0: "NENHUM", 1: "P.BLACK", 2: "D.SMOKE", 3: "L.SMOKE", 4: "STOCK", 5: "LIMO", 6: "GREEN",
};

const pCNames: Record<number, string> = {
  0: "AZ/BR", 1: "AM/PR", 2: "AM/AZ", 3: "AZ/BR2", 4: "AZ/BR3",
};

export function Mechanic() {
  const mechanicData = useAppStore((s) => s.mechanicData);
  const close = useAppStore((s) => s.close);
  const cartTotal = useAppStore((s) => s.mechanicCartTotal);

  const cooldownRef = useRef(false);
  const [currentCategory, setCurrentCategory] = useState("");
  const [confirmModal, setConfirmModal] = useState(false);
  const mechanicCooldownRef = useRef(false);

  if (!mechanicData) return null;

  const onlyPerf = mechanicData.onlyPerfTunnings;
  const disablePerf = mechanicData.disablePerfTunnings;

  // Build category list
  const categories = useMemo(() => {
    const cats: { id: string; name: string; img: string; isCustom: boolean }[] = [];
    const perfEntry = {
      id: "tunnings",
      name: "Performance",
      img: "img/mechanic/tunnings.svg",
      isCustom: true,
    };

    if (onlyPerf) return [perfEntry];

    if (!disablePerf) cats.push(perfEntry);

    cats.push(
      { id: "colors", name: "Pintura", img: "img/mechanic/colors.svg", isCustom: true },
      { id: "lights", name: "Luzes", img: "img/mechanic/lights.svg", isCustom: true },
      { id: "wheels", name: "Rodas", img: "img/mechanic/wheels.svg", isCustom: true },
      { id: "wheels-colors", name: "Cor das Rodas", img: "img/mechanic/wheels-colors.svg", isCustom: true },
      { id: "wtint", name: "Insufilmes", img: "img/mechanic/wtint.svg", isCustom: true },
      { id: "pcolor", name: "Cor da Placa", img: "img/mechanic/pcolor.svg", isCustom: true }
    );

    for (const catId in mechanicData.modList) {
      if (
        mechanicData.vehicleMods?.available?.[catId] > 0 &&
        !excludedModsCategories[Number(catId)]
      ) {
        cats.push({
          id: catId,
          name: mechanicData.modList[catId],
          img: `img/mechanic/${catId}.svg`,
          isCustom: false,
        });
      }
    }

    return cats;
  }, [mechanicData]);

  function selectCategory(catId: string, isCustom: boolean) {
    if (currentCategory === catId) return;
    if (cooldownRef.current) return;
    cooldownRef.current = true;
    setCurrentCategory(catId);
    setTimeout(() => (cooldownRef.current = false), 810);
  }

  function openConfirmModal() {
    if (mechanicCooldownRef.current) return;
    fetchNui({ action: "getCartTotal" }).then((r: any) => {
      if (r && typeof r.cart === "number") {
        useAppStore.getState().setMechanicCartTotal(r.cart);
        setConfirmModal(true);
      }
    });
  }

  function confirmPayment() {
    setConfirmModal(false);
    if (mechanicCooldownRef.current) return;
    mechanicCooldownRef.current = true;
    fetchNui({ action: "tryMechanicPayment" }).then((r: any) => {
      if (r?.success) {
        sendNui({ action: "close" });
        close();
      }
      setTimeout(() => (mechanicCooldownRef.current = false), 1250);
    });
  }

  return (
    <>
      <div className="mechanic-gradient" />
      <div id="right" />
      <div id="left">
        <div className="mechanic-tip">
          <div>
            <div className="key">G</div>
            <div className="tip">FIXAR / DESAFIXAR CÂMERA</div>
          </div>
          <div>
            <div className="key">A</div>
            <div className="key">D</div>
            <div className="tip">ROTACIONAR</div>
          </div>
        </div>
        <div id="mechanic-menu">
          <div className="menu">
            <div className="title">MECÂNICA</div>
            <div className="subtitle">PERSONALIZE O SEU VEÍCULO</div>
            <div id="categories">
              {categories.length === 0 ? (
                <div className="empty">
                  <i className="fa-solid fa-circle-xmark" /> Ops, parece que
                  este veículo não possuí nenhuma modificação disponível!
                </div>
              ) : (
                categories.map((cat) => (
                  <div
                    key={cat.id}
                    id={`mC-${cat.id}`}
                    className={`category${currentCategory === cat.id ? " active" : ""}`}
                    onClick={() => selectCategory(cat.id, cat.isCustom)}
                  >
                    <img
                      src={cat.img}
                      onError={(e) => (e.currentTarget.style.display = "none")}
                    />
                    <div>{cat.name}</div>
                  </div>
                ))
              )}
            </div>
            <div className="spacer-right" />
            <div className="cart">
              <div id="mechanic-total" className="total">
                {formatCurrency(cartTotal)}
              </div>
              <div className="button" onClick={openConfirmModal}>
                <i className="fa-solid fa-check" />
              </div>
            </div>
          </div>
        </div>
      </div>

      {currentCategory && (
        <MechanicCategoryPanel
          categoryId={currentCategory}
          mechanicData={mechanicData}
        />
      )}

      {confirmModal && (
        <Modal
          title="CONFIRMAÇÃO"
          icon="fa-solid fa-wrench"
          onConfirm={confirmPayment}
          onCancel={() => setConfirmModal(false)}
        >
          <div className="text">
            Deseja aplicar as modificações no veículo
            <br />
            por <b>{formatCurrency(cartTotal)}</b>?
          </div>
        </Modal>
      )}
    </>
  );
}

// --- Category detail panel ---
function MechanicCategoryPanel({
  categoryId,
  mechanicData,
}: {
  categoryId: string;
  mechanicData: any;
}) {
  const customCategories = [
    "colors", "lights", "wheels", "wheels-colors", "tunnings", "wtint", "pcolor",
  ];

  if (customCategories.includes(categoryId)) {
    switch (categoryId) {
      case "colors":
        return <ColorsPanel data={mechanicData} />;
      case "lights":
        return <LightsPanel data={mechanicData} />;
      case "wheels":
        return <WheelsPanel data={mechanicData} />;
      case "wheels-colors":
        return <WheelsColorsPanel data={mechanicData} />;
      case "tunnings":
        return <TunningsPanel data={mechanicData} />;
      case "wtint":
        return <WtintPanel data={mechanicData} />;
      case "pcolor":
        return <PcolorPanel data={mechanicData} />;
    }
  }

  return <ModCategoryPanel categoryId={categoryId} data={mechanicData} />;
}

// --- Generic mod category ---
function ModCategoryPanel({
  categoryId,
  data,
}: {
  categoryId: string;
  data: any;
}) {
  const cooldownRef = useRef(false);
  const categoryName = data.modList[categoryId];
  const [currentMod, setCurrentMod] = useState<number>(data.vehicleMods.current[categoryId]);
  const available = data.vehicleMods.available[categoryId];

  function changeMod(modId: number) {
    if (cooldownRef.current) return;
    cooldownRef.current = true;
    fetchNui({ action: "changeVehicleMod", modType: categoryId, modId }).then(
      (r: any) => {
        if (r) {
          data.vehicleMods.current[categoryId] = modId;
          setCurrentMod(modId);
        }
        setTimeout(() => (cooldownRef.current = false), 200);
      }
    );
  }

  const items = [];
  for (let i = -1; i < available; i++) {
    items.push(
      <div
        key={i}
        id={`mI-${i}`}
        className={`item${i === currentMod ? " selected" : ""}`}
        onClick={() => changeMod(i)}
      >
        <div className="id">{i >= 0 ? i : "/"}</div>
      </div>
    );
  }

  return (
    <div id="mechanic-category">
      <div className="menu">
        <div className="title">{categoryName}</div>
        <div id="items">{items}</div>
      </div>
    </div>
  );
}

// --- Colors panel ---
function ColorsPanel({ data }: { data: any }) {
  const [colorType, setColorType] = useState(data.vehicleMods.colors.type);
  const primaryRef = useRef<HTMLDivElement>(null);
  const secondaryRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const W = (window as any).JSColor;
    if (!W) return;
    if (primaryRef.current) {
      new W(primaryRef.current, {
        valueElement: primaryRef.current,
        value: data.vehicleMods.colors.primary,
        onInput: function (this: any) {
          data.vehicleMods.colors.primary = this.toHEXString();
          sendNui({
            action: "changeVehicleColor",
            type: "primary",
            color: getRGBFromHex(this.toHEXString()),
          });
        },
      });
    }
    if (secondaryRef.current) {
      new W(secondaryRef.current, {
        valueElement: secondaryRef.current,
        value: data.vehicleMods.colors.secondary,
        onInput: function (this: any) {
          data.vehicleMods.colors.secondary = this.toHEXString();
          sendNui({
            action: "changeVehicleColor",
            type: "secondary",
            color: getRGBFromHex(this.toHEXString()),
          });
        },
      });
    }
  }, []);

  function changeColorType(type: string) {
    sendNui({ action: "changeVehicleColorType", type });
    setColorType(type);
    data.vehicleMods.colors.type = type;
  }

  function setExtraColour(type: string, action: string | boolean) {
    if (type === "chameleon") {
      if (action === "remove") {
        setColorType("basic");
        data.vehicleMods.colors.type = "basic";
      } else {
        setColorType("chameleon");
        data.vehicleMods.colors.type = "chameleon";
      }
    }
    sendNui({ action: "setVehicleExtraColour", type, _action: action });
  }

  const colorTypes = [
    { id: "basic", label: "BÁSICA" },
    { id: "chroma", label: "CROMADA" },
    { id: "opaque", label: "FOSCA" },
    { id: "metal", label: "METAL" },
  ];

  return (
    <div id="mechanic-category">
      <div className="menu">
        <div className="title">Tipo da Pintura</div>
        <div id="items">
          {colorTypes.map((ct) => (
            <div
              key={ct.id}
              id={`cT-${ct.id}`}
              className={`item${colorType === ct.id ? " selected" : ""}`}
              onClick={() => changeColorType(ct.id)}
            >
              <div className="id">
                <i className="fa-solid fa-brush" />
              </div>
              <div className="price">{ct.label}</div>
            </div>
          ))}
        </div>
        <div className="label" style={{ marginTop: 25 }}>
          Pintura Camaleão
        </div>
        <div className="index-colors">
          <div className="btn" onClick={() => setExtraColour("chameleon", false)}>
            <i className="fa-solid fa-arrow-left" />
          </div>
          <div className="btn remove" onClick={() => setExtraColour("chameleon", "remove")}>
            <i className="fa-solid fa-ban" />
          </div>
          <div className="btn" onClick={() => setExtraColour("chameleon", true)}>
            <i className="fa-solid fa-arrow-right" />
          </div>
        </div>
        <div className="label" style={{ marginTop: 25 }}>
          Perólado
        </div>
        <div className="index-colors">
          <div className="btn" onClick={() => setExtraColour("pearl", false)}>
            <i className="fa-solid fa-arrow-left" />
          </div>
          <div className="btn remove" onClick={() => setExtraColour("pearl", "remove")}>
            <i className="fa-solid fa-ban" />
          </div>
          <div className="btn" onClick={() => setExtraColour("pearl", true)}>
            <i className="fa-solid fa-arrow-right" />
          </div>
        </div>
        <div className="label" style={{ marginTop: 25 }}>
          Cor Primária
        </div>
        <div id="primary-picker" className="picker" ref={primaryRef} />
        <div className="label" style={{ marginTop: 25 }}>
          Cor Secundária
        </div>
        <div id="secondary-picker" className="picker" ref={secondaryRef} />
      </div>
    </div>
  );
}

// --- Lights panel ---
function LightsPanel({ data }: { data: any }) {
  const neonStatus = data.vehicleMods.lights?.neon ? true : false;
  const xenonStatus = data.vehicleMods.lights?.xenon ? true : false;

  const [neonChecked, setNeonChecked] = useState(neonStatus);
  const [xenonChecked, setXenonChecked] = useState(xenonStatus);

  const neonRef = useRef<HTMLDivElement>(null);
  const xenonRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const W = (window as any).JSColor;
    if (!W) return;
    const neonColor = neonStatus ? data.vehicleMods.lights.neon : "#ffffff";
    const xenonColor = xenonStatus ? data.vehicleMods.lights.xenon : "#ffffff";

    if (neonRef.current) {
      new W(neonRef.current, {
        valueElement: neonRef.current,
        value: neonColor,
        onInput: function (this: any) {
          if (data.vehicleMods.lights) data.vehicleMods.lights.neon = this.toHEXString();
          sendNui({
            action: "changeVehicleLightColor",
            type: "neon",
            color: getRGBFromHex(this.toHEXString()),
          });
        },
      });
    }
    if (xenonRef.current) {
      new W(xenonRef.current, {
        valueElement: xenonRef.current,
        value: xenonColor,
        onInput: function (this: any) {
          if (data.vehicleMods.lights) data.vehicleMods.lights.xenon = this.toHEXString();
          sendNui({
            action: "changeVehicleLightColor",
            type: "xenon",
            color: getRGBFromHex(this.toHEXString()),
          });
        },
      });
    }
  }, []);

  return (
    <div id="mechanic-category">
      <div className="menu">
        <div className="title">Xenon</div>
        <div className="switcher">
          Instalar
          <div style={{ marginLeft: "auto", marginTop: 5 }}>
            <input
              id="switch-xenon"
              className="switch switch--shadow"
              type="checkbox"
              checked={xenonChecked}
              onChange={(e) => {
                setXenonChecked(e.target.checked);
                sendNui({
                  action: "setVehicleLightStatus",
                  type: "xenon",
                  status: e.target.checked,
                });
              }}
            />
            <label htmlFor="switch-xenon" />
          </div>
        </div>
        <div id="xenon-picker" className="picker" style={{ marginTop: 10 }} ref={xenonRef} />
        <div className="label" style={{ marginTop: 25 }}>
          Neon
        </div>
        <div className="switcher">
          Instalar
          <div style={{ marginLeft: "auto", marginTop: 5 }}>
            <input
              id="switch-neon"
              className="switch switch--shadow"
              type="checkbox"
              checked={neonChecked}
              onChange={(e) => {
                setNeonChecked(e.target.checked);
                sendNui({
                  action: "setVehicleLightStatus",
                  type: "neon",
                  status: e.target.checked,
                });
              }}
            />
            <label htmlFor="switch-neon" />
          </div>
        </div>
        <div id="neon-picker" className="picker" style={{ marginTop: 10 }} ref={neonRef} />
      </div>
    </div>
  );
}

// --- Wheels panel ---
function WheelsPanel({ data }: { data: any }) {
  const availableWheels = data.vehicleMods.available.wheels || {};
  const currentWheel = data.vehicleMods.wheels || {};

  const [wheelCategory, setWheelCategory] = useState(currentWheel.type || "");
  const [customTyres, setCustomTyres] = useState(!!currentWheel.custom);

  const categoryOptions = useMemo(() => {
    return Object.keys(availableWheels).map((c) => ({
      value: c,
      label: c.replace("VWT_", "").toLowerCase().replace(/^\w/, (ch: string) => ch.toUpperCase()),
    }));
  }, [availableWheels]);

  const wheelItems = useMemo(() => {
    if (!wheelCategory || !availableWheels[wheelCategory]) return [];
    const count = availableWheels[wheelCategory];
    const items = [];
    for (let w = -1; w < count; w++) {
      items.push(w);
    }
    return items;
  }, [wheelCategory, availableWheels]);

  useEffect(() => {
    if (!wheelCategory && categoryOptions.length > 0 && currentWheel.type) {
      setWheelCategory(currentWheel.type);
    }
  }, []);

  function changeWheel(type: string, id: number) {
    sendNui({ action: "changeVehicleWheel", type, id });
    data.vehicleMods.wheels.type = type;
    data.vehicleMods.wheels.id = id;
  }

  return (
    <div id="mechanic-category">
      <div className="menu">
        <div className="title">Rodas</div>
        <CustomSelect
          options={categoryOptions}
          selected={wheelCategory}
          onChange={(v) => setWheelCategory(v)}
        />
        <div className="wheels" id="items" style={{ marginTop: 10 }}>
          {wheelItems.map((w) => (
            <div
              key={`${wheelCategory}-${w}`}
              id={`vW-${wheelCategory}-${w}`}
              className={`item${
                currentWheel.type === wheelCategory &&
                currentWheel.id === w
                  ? " selected"
                  : ""
              }`}
              onClick={() => changeWheel(wheelCategory, w)}
            >
              <div className="id">{w}</div>
            </div>
          ))}
        </div>
        <div className="switcher">
          Atomic - Custom
          <div style={{ marginLeft: "auto", marginTop: 5 }}>
            <input
              id="switch-customTyres"
              className="switch switch--shadow"
              type="checkbox"
              checked={customTyres}
              onChange={(e) => {
                setCustomTyres(e.target.checked);
                sendNui({
                  action: "setVehicleCustomTyresEnabled",
                  status: e.target.checked,
                });
              }}
            />
            <label htmlFor="switch-customTyres" />
          </div>
        </div>
      </div>
    </div>
  );
}

// --- Wheels Colors panel ---
function WheelsColorsPanel({ data }: { data: any }) {
  const smokeRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const W = (window as any).JSColor;
    if (!W || !smokeRef.current) return;
    new W(smokeRef.current, {
      valueElement: smokeRef.current,
      value: data.vehicleMods.colors.smoke || "#ffffff",
      onInput: function (this: any) {
        data.vehicleMods.colors.smoke = this.toHEXString();
        sendNui({
          action: "changeVehicleColor",
          type: "smoke",
          color: getRGBFromHex(this.toHEXString()),
        });
      },
    });
  }, []);

  function setExtraColour(type: string, action: string | boolean) {
    sendNui({ action: "setVehicleExtraColour", type, _action: action });
  }

  return (
    <div id="mechanic-category">
      <div className="menu">
        <div className="title">Cor do Aro</div>
        <div className="index-colors">
          <div className="btn" onClick={() => setExtraColour("wheel", false)}>
            <i className="fa-solid fa-arrow-left" />
          </div>
          <div className="btn remove" onClick={() => setExtraColour("wheel", "remove")}>
            <i className="fa-solid fa-ban" />
          </div>
          <div className="btn" onClick={() => setExtraColour("wheel", true)}>
            <i className="fa-solid fa-arrow-right" />
          </div>
        </div>
        <div className="label" style={{ marginTop: 25 }}>
          Cor da Fumaça
        </div>
        <div id="smoke-picker" className="picker" ref={smokeRef} />
      </div>
    </div>
  );
}

// --- Tunnings panel ---
function TunningsPanel({ data }: { data: any }) {
  const [turbo, setTurbo] = useState(!!data.vehicleMods.turbo);

  function setModFromSlider(catId: number, catInd: string, modId: number) {
    fetchNui({ action: "changeVehicleMod", modType: catId, modId }).then(
      (r: any) => {
        data.vehicleMods.current[catId] = modId;
      }
    );
  }

  const sliders = Object.entries(tunningsOpts)
    .filter(([, tn]) => {
      const max = (data.vehicleMods.available[tn.modId] || 0) - 1;
      return max > 0;
    })
    .map(([opt, tn]) => {
      const min = -1;
      const current = data.vehicleMods.current[tn.modId] ?? -1;
      const max = data.vehicleMods.available[tn.modId] - 1;
      return { opt, tn, min, current, max };
    });

  return (
    <div id="mechanic-category">
      <div className="menu">
        <div className="title">Performance</div>
        <div className="switcher">
          Turbo
          <div style={{ marginLeft: "auto", marginTop: 5 }}>
            <input
              id="switch-turbo"
              className="switch switch--shadow"
              type="checkbox"
              checked={turbo}
              onChange={(e) => {
                setTurbo(e.target.checked);
                sendNui({
                  action: "setVehicleTurboEnabled",
                  status: e.target.checked,
                });
              }}
            />
            <label htmlFor="switch-turbo" />
          </div>
        </div>
        {sliders.map(({ opt, tn, min, current, max }) => (
          <TunningSlider
            key={opt}
            opt={opt}
            name={tn.name}
            modId={tn.modId}
            min={min}
            max={max}
            initial={current}
            onChange={(val) => setModFromSlider(tn.modId, opt, val)}
          />
        ))}
      </div>
    </div>
  );
}

function TunningSlider({
  opt,
  name,
  modId,
  min,
  max,
  initial,
  onChange,
}: {
  opt: string;
  name: string;
  modId: number;
  min: number;
  max: number;
  initial: number;
  onChange: (val: number) => void;
}) {
  const [value, setValue] = useState(initial);

  return (
    <div className="menu-range">
      <div className="info">
        <div className="key">{name}</div>
        <div className="value">
          ( <span id={`t-${opt}`}>{value}</span> / {max} )
        </div>
      </div>
      <div>
        <input
          id={`v-${opt}`}
          type="range"
          min={min}
          max={max}
          step={1}
          value={value}
          onChange={(e) => {
            const v = parseInt(e.target.value);
            setValue(v);
            onChange(v);
          }}
          style={{
            backgroundSize: `${((value - min) * 100) / (max - min)}% 100%`,
          }}
        />
      </div>
    </div>
  );
}

// --- Window tint panel ---
function WtintPanel({ data }: { data: any }) {
  const [selected, setSelected] = useState(data.vehicleMods.wtint ?? 0);

  function setTint(id: number) {
    sendNui({ action: "setVehicleWindowTint", id });
    data.vehicleMods.wtint = id;
    setSelected(id);
  }

  return (
    <div id="mechanic-category">
      <div className="menu">
        <div className="title">Insufilmes</div>
        <div id="items">
          {[0, 1, 2, 3, 4, 5, 6].map((w) => (
            <div
              key={w}
              id={`wT-${w}`}
              className={`item${selected === w ? " selected" : ""}`}
              onClick={() => setTint(w)}
            >
              <div className="id">
                <i className="fa-solid fa-toilet-paper-blank" />
              </div>
              <div className="price">{tintNames[w]}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// --- Plate color panel ---
function PcolorPanel({ data }: { data: any }) {
  const [selected, setSelected] = useState(data.vehicleMods.pcolor ?? 0);

  function setColor(id: number) {
    sendNui({ action: "setVehiclePlateColor", id });
    data.vehicleMods.pcolor = id;
    setSelected(id);
  }

  return (
    <div id="mechanic-category">
      <div className="menu">
        <div className="title">Cor da Placa</div>
        <div id="items">
          {[0, 1, 2, 3, 4].map((p) => (
            <div
              key={p}
              id={`pC-${p}`}
              className={`item${selected === p ? " selected" : ""}`}
              onClick={() => setColor(p)}
            >
              <div className="id">
                <i className="fa-solid fa-rectangle-wide" />
              </div>
              <div className="price">{pCNames[p]}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
