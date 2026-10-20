const COLORS = [
  "#000000", "#ffffff", "#f50202", "#f55f02", "#ffea00", "#a6ff00",
  "#33ff00", "#00ffc3", "#00aeff", "#0026ff", "#5100ff", "#8c00ff",
  "#d900ff", "#ff00ea", "#ff00a2", "#ffa1e1", "#2c0e3d", "#100e3d",
];

type DevScreen =
  | "dealership"
  | "garage"
  | "mechanic"
  | "invoices"
  | "stockManager"
  | "vehicleManager"
  | "garageManager"
  | "vehicleMenu"
  | "lockNotify"
  | "testDrive"
  | "clear";

function veh(
  index: string,
  name: string,
  category: string,
  cls: string,
  price: number,
  extra?: Record<string, any>
) {
  return {
    index,
    name,
    category,
    class: cls,
    paymentType: "primary",
    price,
    weights: { trunk: 45, gloves: 5 },
    ...extra,
  };
}

const HANDLING: Record<string, number[]> = {
  default: [167, 34, 92, 215],
};

function statsFor(index: string) {
  const seed = index.split("").reduce((value, char) => value + char.charCodeAt(0), 0);
  const base = HANDLING[index] || HANDLING.default;
  return {
    speed: base[0] + (seed % 90),
    acceleration: base[1] + (seed % 25),
    braking: base[2] + (seed % 30),
    traction: base[3] + (seed % 60),
  };
}

export const DEALER_MOCK = {
  categories: {
    car: "Veículos",
    motorcycle: "Motocicletas",
    vip: "VIPs",
    water: "Barcos",
  },
  vehicles: {
    car: [
      veh("sultan", "Sultan RS", "car", "Esportivo", 500000),
      veh("elegy2", "Elegy Retro", "car", "Esportivo", 420000),
      veh("comet2", "Comet", "car", "Esportivo", 680000),
      veh("banshee", "Banshee", "car", "Esportivo", 750000),
      veh("kuruma", "Kuruma", "car", "Sedan", 260000),
      veh("futo", "Futo", "car", "Compacto", 120000),
      veh("zentorno", "Zentorno", "car", "Super", 1850000),
      veh("t20", "T20", "car", "Super", 2400000),
    ],
    motorcycle: [
      veh("bati", "Bati 801", "motorcycle", "Esportiva", 180000),
      veh("hakuchou", "Hakuchou", "motorcycle", "Esportiva", 240000),
      veh("akuma", "Akuma", "motorcycle", "Street", 95000),
    ],
    vip: [
      veh("adder", "Adder", "vip", "Hyper", 1200, { paymentType: "secondary" }),
      veh("osiris", "Osiris", "vip", "Hyper", 950, { paymentType: "secondary" }),
    ],
    water: [
      veh("dinghy", "Dinghy", "water", "Barco", 150000),
      veh("marquis", "Marquis", "water", "Iate", 890000),
    ],
  },
  myVehicles: {
    ABC1D23: {
      index: "kuruma",
      name: "Kuruma",
      category: "car",
      class: "Sedan",
      price: 260000,
      paymentType: "primary",
      plate: "ABC1D23",
      tax: Math.floor(Date.now() / 1000) + 604800,
      expire_time: 0,
      trunk: 45,
    },
    XYZ9K01: {
      index: "futo",
      name: "Futo",
      category: "car",
      class: "Compacto",
      price: 120000,
      paymentType: "primary",
      plate: "XYZ9K01",
      tax: 0,
      expire_time: Math.floor(Date.now() / 1000) + 259200,
      trunk: 30,
    },
  },
  purchaseColorOptions: { primary: COLORS, secondary: COLORS },
  sellBackPercentFromPrice: 0.2,
  stock: {},
  testDrive: { payment: 200 },
  infiniteStock: true,
  balance: { money: 22000, gems: 22000 },
};

function ownedVehicle(
  plate: string,
  index: string,
  name: string,
  category: string,
  opts?: Record<string, any>
) {
  const seed = plate.charCodeAt(0) + plate.charCodeAt(3);
  return {
    plate,
    index,
    name,
    category,
    owner: 1,
    status: "GARAGE",
    trunk: 45,
    health: [1000, 700 + (seed % 300), 40 + (seed % 60)],
    tax: Math.floor(Date.now() / 1000) + 2592000,
    expire_time: 0,
    ...opts,
  };
}

export const GARAGE_MOCK = {
  type: "NORMAL",
  name: "Liberty Autos",
  myVehicles: {
    ABC1D23: ownedVehicle("ABC1D23", "sultan", "Sultan RS", "car"),
    DEF4G56: ownedVehicle("DEF4G56", "kuruma", "Kuruma", "car"),
    GHI7J89: ownedVehicle("GHI7J89", "futo", "Futo", "car", {
      tax: Math.floor(Date.now() / 1000) - 100,
      expired: true,
    }),
    JKL0M12: ownedVehicle("JKL0M12", "elegy2", "Elegy Retro", "car", {
      borrowedTo: "João Silva",
    }),
    MNO3P45: ownedVehicle("MNO3P45", "comet2", "Comet", "car"),
    PQR6S78: ownedVehicle("PQR6S78", "banshee", "Banshee", "car", {
      favorite: true,
    }),
    STU9V01: ownedVehicle("STU9V01", "zentorno", "Zentorno", "car"),
    VWX2Y34: ownedVehicle("VWX2Y34", "t20", "T20", "car"),
    YZA5B67: ownedVehicle("YZA5B67", "bati", "Bati 801", "motorcycle"),
    BCD8E90: ownedVehicle("BCD8E90", "akuma", "Akuma", "motorcycle"),
    EFG1H23: ownedVehicle("EFG1H23", "hakuchou", "Hakuchou", "motorcycle"),
    HIJ4K56: ownedVehicle("HIJ4K56", "phantom", "Phantom", "truck"),
    KLM7N89: ownedVehicle("KLM7N89", "packer", "Packer", "truck"),
  },
};

const MECHANIC_MOCK = {
  onlyPerfTunnings: false,
  disablePerfTunnings: false,
  modList: {
    0: "Aerofólios",
    1: "Para-choque dianteiro",
    2: "Para-choque traseiro",
    3: "Saias laterais",
    4: "Escapamentos",
    5: "Chassi",
    6: "Grades",
    7: "Capôs",
    8: "Para-lamas",
    10: "Tetos",
    11: "Motor",
    12: "Freios",
    13: "Transmissão",
    15: "Suspensão",
    16: "Blindagem",
  },
  vehicleMods: {
    available: {
      0: 6, 1: 5, 2: 5, 3: 4, 4: 7, 5: 3, 6: 5, 7: 6, 8: 4, 10: 3,
      11: 4, 12: 3, 13: 3, 15: 4, 16: 5,
      wheels: { VWT_SPORT: 12, VWT_TUNER: 10, VWT_HIGHEND: 8, VWT_MUSCLE: 9 },
    },
    current: {
      0: 1, 1: 0, 2: -1, 3: 1, 4: 2, 5: -1, 6: 0, 7: 2, 8: -1, 10: 0,
      11: 2, 12: 1, 13: 1, 15: 2, 16: 0,
    },
    colors: {
      type: "basic",
      primary: "#ca416b",
      secondary: "#16171a",
      smoke: "#f4f4f4",
    },
    lights: { neon: "#ca416b", xenon: "#ffffff" },
    wheels: { type: "VWT_SPORT", id: 3, custom: false },
    turbo: true,
    wtint: 3,
    pcolor: 0,
  },
};

const INVOICES_MOCK = {
  QWE4R56: [null, [null, "1199887766", "Sultan RS", 18500]],
  ABC1D23: [null, [null, "2199112233", "Banshee", 32750]],
  XYZ9K01: [null, [null, "3199776655", "Kuruma", 9200]],
};

const STOCK_MANAGER_MOCK = {
  categories: DEALER_MOCK.categories,
  vehicles: DEALER_MOCK.vehicles,
  stock: {
    sultan: 8, elegy2: 4, comet2: 2, banshee: 5, kuruma: 12, futo: 6,
    zentorno: 1, t20: 1, bati: 7, hakuchou: 3, akuma: 9, adder: 2,
    osiris: 2, dinghy: 3, marquis: 1,
  },
};

const VEHICLE_MANAGER_MOCK = {
  id: 42,
  vehicles: {
    DEV4M01: {
      index: "sultan",
      name: "Sultan RS",
      expire_time: 0,
      tax: Math.floor(Date.now() / 1000) + 604800,
    },
    DEV4M02: {
      index: "banshee",
      name: "Banshee",
      expire_time: Math.floor(Date.now() / 1000) + 1209600,
      tax: Math.floor(Date.now() / 1000) + 604800,
    },
    DEV4M03: {
      index: "bati",
      name: "Bati 801",
      expire_time: Math.floor(Date.now() / 1000) + 259200,
      tax: 0,
    },
  },
};

const GARAGES_MOCK = [
  {
    id: 1,
    name: "Garagem Central",
    type: "NORMAL",
    permission: null,
    payment: 0,
    open: { x: 215.45, y: -810.12, z: 30.73, h: 157.0 },
    spawns: [
      { x: 229.21, y: -800.12, z: 30.57, h: 157.2 },
      { x: 232.36, y: -807.42, z: 30.49, h: 159.8 },
    ],
    blip: { enabled: true, icon: 357, color: 0, size: 0.5 },
  },
  {
    id: 2,
    name: "Heliponto Hospital",
    type: "AIR",
    permission: "Paramedic",
    payment: 0,
    open: { x: 351.74, y: -587.82, z: 74.16, h: 72.0 },
    spawns: [{ x: 351.83, y: -588.11, z: 74.16, h: 72.4 }],
    blip: { enabled: false, icon: 357, color: 0, size: 0.5 },
  },
  {
    id: 3,
    name: "Polícia — Viaturas",
    type: "SERVICE",
    permission: "Police",
    payment: 0,
    open: { x: 454.21, y: -1017.43, z: 28.42, h: 90.0 },
    spawns: [{ x: 438.56, y: -1018.11, z: 27.75, h: 91.2 }],
    vehicles: { police: 0, police2: 0, police3: 0 },
    blip: { enabled: false, icon: 357, color: 0, size: 0.5 },
  },
  {
    id: 4,
    name: "Marina Del Perro",
    type: "WATER",
    permission: null,
    payment: 250,
    open: { x: -802.13, y: -1504.73, z: 1.6, h: 110.0 },
    spawns: [{ x: -797.45, y: -1502.14, z: 0.12, h: 112.5 }],
    blip: { enabled: true, icon: 357, color: 0, size: 0.5 },
  },
];

const VEHICLE_CATALOG_MOCK = [
  { spawn: "sultan", name: "Sultan RS", category: "car", paymentType: "primary", price: 500000, class: "Esportivo", mode: "", outDealership: false, weights: { trunk: 45, gloves: 5 } },
  { spawn: "banshee", name: "Banshee", category: "car", paymentType: "primary", price: 750000, class: "Esportivo", mode: "", outDealership: false, weights: { trunk: 35, gloves: 5 } },
  { spawn: "kuruma", name: "Kuruma", category: "car", paymentType: "primary", price: 260000, class: "Sedan", mode: "", outDealership: false, weights: { trunk: 45, gloves: 5 } },
  { spawn: "bati", name: "Bati 801", category: "motorcycle", paymentType: "primary", price: 180000, class: "Esportiva", mode: "", outDealership: false, weights: { trunk: 10, gloves: 0 } },
  { spawn: "adder", name: "Adder", category: "vip", paymentType: "secondary", price: 1200, class: "Hyper", mode: "", outDealership: false, weights: { trunk: 30, gloves: 5 } },
  { spawn: "phantom", name: "Phantom", category: "truck", paymentType: "primary", price: 950000, class: "Caminhão", mode: "", outDealership: true, weights: { trunk: 100, gloves: 10 } },
];

function clone<T>(value: T): T {
  return JSON.parse(JSON.stringify(value));
}

function post(action: string, payload: Record<string, any> = {}) {
  window.postMessage({ action, ...payload }, "*");
}

function clearInterfaces() {
  post("forceClose");
  post("closeVehicleMenu");
  post("toggleTestDriveTimer");
}

function resolveHash(): DevScreen {
  const hash = window.location.hash.replace(/^#/, "").toLowerCase();
  const aliases: Record<string, DevScreen> = {
    conce: "dealership",
    concessionaria: "dealership",
    dealership: "dealership",
    garage: "garage",
    garagem: "garage",
    mechanic: "mechanic",
    mecanica: "mechanic",
    invoices: "invoices",
    pedidos: "invoices",
    stock: "stockManager",
    stockmanager: "stockManager",
    vmanage: "vehicleManager",
    vehiclemanager: "vehicleManager",
    gmanage: "garageManager",
    garagemanager: "garageManager",
    menu: "vehicleMenu",
    vehiclemenu: "vehicleMenu",
  };
  return aliases[hash] || "dealership";
}

function setHash(screen: DevScreen) {
  const next = screen === "clear" ? window.location.pathname + window.location.search : `#${screen}`;
  window.history.replaceState(null, "", next);
}

function openDevScreen(screen: DevScreen, updateHash = true) {
  if (screen === "lockNotify") {
    post("triggerLockNotify", { lockState: true, model: "Banshee" });
    return;
  }

  if (screen === "testDrive") {
    post("toggleTestDriveTimer", { model: "Banshee" });
    post("updateTestDriveTimer", { seconds: 42 });
    return;
  }

  clearInterfaces();
  post("setTheme", { color: "#ca416b" });

  switch (screen) {
    case "dealership":
      post("openDealership", { data: clone(DEALER_MOCK) });
      break;
    case "garage":
      post("openGarage", { data: clone(GARAGE_MOCK) });
      break;
    case "mechanic":
      post("openMechanic", { data: clone(MECHANIC_MOCK) });
      break;
    case "invoices":
      post("showMechanicInvoices", {
        id: "mechanic-dev",
        invoices: clone(INVOICES_MOCK),
        currentVehicle: "ABC1D23",
      });
      break;
    case "stockManager":
      post("openStockManager", { data: clone(STOCK_MANAGER_MOCK) });
      break;
    case "vehicleManager":
      post("openCharacterVehManager", { data: clone(VEHICLE_MANAGER_MOCK) });
      break;
    case "garageManager":
      post("openGarageManager", { data: { garages: clone(GARAGES_MOCK) } });
      break;
    case "vehicleMenu":
      post("showVehicleMenu", { key: "m", backSeats: true, currentSeat: "P1" });
      break;
    case "clear":
      break;
  }

  if (updateHash) setHash(screen);
}

export function startDevMock() {
  document.body.style.background =
    "radial-gradient(circle at 50% 55%, #4a5158 0%, #23272c 45%, #101215 100%)";

  (window as any).__devNui = (payload: any) => {
    switch (payload?.action) {
      case "dealerSelectedVehicle":
        return Promise.resolve({
          success: true,
          stats: payload.index ? statsFor(String(payload.index)) : null,
        });
      case "setVehicleFavorite":
        return Promise.resolve({ success: true, favorite: Boolean(payload.favorite) });
      case "trackVehicle":
      case "tryMechanicPayment":
      case "tryApplyMechanicInvoice":
      case "gmClose":
      case "gmCreate":
      case "gmUpdate":
      case "gmDelete":
      case "gmTeleport":
      case "vrSave":
      case "vrDelete":
      case "cvmTryRemove":
      case "cvmTryFind":
      case "cvmTryRemoveAll":
        return Promise.resolve({ success: true });
      case "changeVehicleMod":
        return Promise.resolve(true);
      case "getCartTotal":
        return Promise.resolve({ cart: 18650 });
      case "tryCallMechanicInvoice":
        return Promise.resolve({ success: true, remove: false });
      case "tryUpdateDealerVehicleStock":
        return Promise.resolve({ success: true, newStock: Number(payload.amount) || 0 });
      case "gmGetGarages":
        return Promise.resolve({ success: true, garages: clone(GARAGES_MOCK) });
      case "vrGetList":
        return Promise.resolve({
          success: true,
          vehicles: clone(VEHICLE_CATALOG_MOCK),
          categories: clone(DEALER_MOCK.categories),
        });
      case "cvmTryRenew":
        return Promise.resolve({
          success: true,
          newTime: Math.floor(Date.now() / 1000) + Math.max(1, Number(payload.days)) * 86400,
        });
      case "cvmTryAdd":
        return Promise.resolve({
          success: true,
          plate: payload.plate || "DEV4NEW",
          nvdata: {
            index: payload.model || "sultan",
            name: payload.model || "Sultan RS",
            expire_time: payload.days > 0
              ? Math.floor(Date.now() / 1000) + Number(payload.days) * 86400
              : 0,
          },
        });
      default:
        console.debug("[dev-mock] fetchNui:", payload);
        return Promise.resolve({ success: false });
    }
  };

  (window as any).__coreVehiclesDev = { open: openDevScreen };
  (window as any).GARAGE_LOGO_URL =
    "https://r2.fivemanage.com/K2s8y13QwgWTCBacvtcbY/HUD_MADRID.gif";

  setTimeout(() => openDevScreen(resolveHash(), false), 120);

  window.addEventListener("hashchange", () => {
    openDevScreen(resolveHash(), false);
  });
}
