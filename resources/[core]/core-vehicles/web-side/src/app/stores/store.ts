import { create } from "zustand";

export type ViewType =
  | "none"
  | "dealership"
  | "garage"
  | "mechanic"
  | "invoices";

export type OverlayType = "none" | "stockManager" | "vehicleManager" | "garageManager";

export interface LockNotify {
  id: number;
  lockState: boolean;
  model: string;
}

interface AppStore {
  // View
  currentView: ViewType;
  overlayView: OverlayType;

  // Theme
  themeColor: string;
  themeRgb: string;

  // Dealership
  dealerData: any;
  dealerSelectedCategory: string;
  dealerPurchase: {
    veh: any;
    colors: [string, string];
    rentDays: number;
  } | null;

  // Garage
  garageData: any;
  garageSelectedPlate: string | null;

  // Mechanic
  mechanicData: any;
  mechanicSelectedCategory: string;
  mechanicCartTotal: number;

  // Invoices
  invoicesId: string;
  invoicesData: any;
  invoicesCurrentVehicle: string;

  // Stock Manager
  managerData: any;
  managerSelectedCategory: string;

  // Vehicle Manager
  vmanagerData: any;

  // Garage Manager
  gmanagerData: any;

  // Vehicle Menu
  vehicleMenuOpen: boolean;
  vehicleMenuKey: string;
  vehicleMenuBackSeats: boolean;
  vehicleMenuCurrentSeat: string;

  // Notifications
  lockNotifications: LockNotify[];
  testDrive: { model: string; seconds: number } | null;

  // Modal
  modalOpen: boolean;

  // Actions
  setTheme: (color: string) => void;
  openDealership: (data: any) => void;
  openGarage: (data: any) => void;
  openMechanic: (data: any) => void;
  openInvoices: (id: string, invoices: any, currentVehicle: string) => void;
  openStockManager: (data: any) => void;
  openVehicleManager: (data: any) => void;
  openGarageManager: (data: any) => void;
  setGarageManagerData: (data: any) => void;
  openVehicleMenu: (key: string, backSeats: boolean, currentSeat: string) => void;
  closeVehicleMenu: () => void;
  addLockNotify: (lockState: boolean, model: string) => void;
  removeLockNotify: (id: number) => void;
  setTestDrive: (data: { model: string; seconds: number } | null) => void;
  updateTestDriveTimer: (seconds: number) => void;
  setModalOpen: (open: boolean) => void;
  setDealerPurchase: (purchase: any) => void;
  setDealerSelectedCategory: (cat: string) => void;
  setGarageSelectedPlate: (plate: string | null) => void;
  setMechanicSelectedCategory: (cat: string) => void;
  setMechanicCartTotal: (total: number) => void;
  setManagerSelectedCategory: (cat: string) => void;
  removeVehicle: (plate: string) => void;
  updateVehicleTax: (plate: string, time: number) => void;
  close: () => void;
  closeOverlay: () => void;
}

let notifyIdCounter = 0;

export const useAppStore = create<AppStore>()((set, get) => ({
  currentView: "none",
  overlayView: "none",
  themeColor: "#0143bb",
  themeRgb: "1,67,187",
  dealerData: null,
  dealerSelectedCategory: "",
  dealerPurchase: null,
  garageData: null,
  garageSelectedPlate: null,
  mechanicData: null,
  mechanicSelectedCategory: "",
  mechanicCartTotal: 0,
  invoicesId: "",
  invoicesData: null,
  invoicesCurrentVehicle: "",
  managerData: null,
  managerSelectedCategory: "",
  vmanagerData: null,
  gmanagerData: null,
  vehicleMenuOpen: false,
  vehicleMenuKey: "m",
  vehicleMenuBackSeats: false,
  vehicleMenuCurrentSeat: "P1",
  lockNotifications: [],
  testDrive: null,
  modalOpen: false,

  setTheme: (color: string) => {
    const hex = color.replace("#", "");
    const r = parseInt(hex.substring(0, 2), 16);
    const g = parseInt(hex.substring(2, 4), 16);
    const b = parseInt(hex.substring(4, 6), 16);
    document.documentElement.style.setProperty("--theme", color);
    document.documentElement.style.setProperty("--theme-rgb", `${r},${g},${b}`);
    set({ themeColor: color, themeRgb: `${r},${g},${b}` });
  },

  openDealership: (data) =>
    set({
      currentView: "dealership",
      dealerData: data,
      dealerSelectedCategory: "",
      dealerPurchase: null,
    }),

  openGarage: (data) =>
    set({
      currentView: "garage",
      garageData: data,
      garageSelectedPlate: null,
    }),

  openMechanic: (data) =>
    set({
      currentView: "mechanic",
      mechanicData: data,
      mechanicSelectedCategory: "",
      mechanicCartTotal: 0,
    }),

  openInvoices: (id, invoices, currentVehicle) =>
    set({
      currentView: "invoices",
      invoicesId: id,
      invoicesData: invoices,
      invoicesCurrentVehicle: currentVehicle,
    }),

  openStockManager: (data) =>
    set({ overlayView: "stockManager", managerData: data, managerSelectedCategory: "" }),

  openVehicleManager: (data) =>
    set({ overlayView: "vehicleManager", vmanagerData: data }),

  openGarageManager: (data) =>
    set({ overlayView: "garageManager", gmanagerData: data }),

  setGarageManagerData: (data) =>
    set({ gmanagerData: data }),

  openVehicleMenu: (key, backSeats, currentSeat) =>
    set({
      vehicleMenuOpen: true,
      vehicleMenuKey: key.toLowerCase(),
      vehicleMenuBackSeats: backSeats,
      vehicleMenuCurrentSeat: currentSeat,
    }),

  closeVehicleMenu: () => set({ vehicleMenuOpen: false }),

  addLockNotify: (lockState, model) => {
    const id = ++notifyIdCounter;
    set((s) => ({
      lockNotifications: [...s.lockNotifications, { id, lockState, model }],
    }));
    setTimeout(() => get().removeLockNotify(id), 2300);
  },

  removeLockNotify: (id) =>
    set((s) => ({
      lockNotifications: s.lockNotifications.filter((n) => n.id !== id),
    })),

  setTestDrive: (data) => set({ testDrive: data }),

  updateTestDriveTimer: (seconds) =>
    set((s) =>
      s.testDrive ? { testDrive: { ...s.testDrive, seconds } } : {}
    ),

  setModalOpen: (open) => set({ modalOpen: open }),

  setDealerPurchase: (purchase) => set({ dealerPurchase: purchase }),
  setDealerSelectedCategory: (cat) => set({ dealerSelectedCategory: cat }),
  setGarageSelectedPlate: (plate) => set({ garageSelectedPlate: plate }),
  setMechanicSelectedCategory: (cat) => set({ mechanicSelectedCategory: cat }),
  setMechanicCartTotal: (total) => set({ mechanicCartTotal: total }),
  setManagerSelectedCategory: (cat) => set({ managerSelectedCategory: cat }),

  removeVehicle: (plate) =>
    set((s) => {
      const newState: any = {};
      if (s.garageData?.myVehicles?.[plate]) {
        newState.garageData = {
          ...s.garageData,
          myVehicles: { ...s.garageData.myVehicles, [plate]: null },
        };
      }
      if (s.dealerData?.myVehicles?.[plate]) {
        newState.dealerData = {
          ...s.dealerData,
          myVehicles: { ...s.dealerData.myVehicles, [plate]: null },
        };
      }
      return newState;
    }),

  updateVehicleTax: (plate, time) =>
    set((s) => {
      if (s.garageData?.myVehicles?.[plate]) {
        return {
          garageData: {
            ...s.garageData,
            myVehicles: {
              ...s.garageData.myVehicles,
              [plate]: { ...s.garageData.myVehicles[plate], tax: time },
            },
          },
        };
      }
      return {};
    }),

  close: () =>
    set({
      currentView: "none",
      overlayView: "none",
      dealerData: null,
      garageData: null,
      mechanicData: null,
      dealerPurchase: null,
      modalOpen: false,
    }),

  closeOverlay: () => set({ overlayView: "none" }),
}));
