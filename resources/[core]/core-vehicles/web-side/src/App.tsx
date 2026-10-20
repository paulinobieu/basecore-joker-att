import { useEffect } from "react";
import { useAppStore } from "@app/stores/store";
import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { useClickSound } from "@app/hooks/useClickSound";
import { isEnvBrowser, sendNui } from "@app/utils/nui";
import { playSound } from "@app/utils/format";

import { Dealership } from "./components/Dealership";
import { Garage } from "./components/Garage";
import { Mechanic } from "./components/Mechanic";
import { MechanicInvoices } from "./components/MechanicInvoices";
import { StockManager } from "./components/StockManager";
import { VehicleManager } from "./components/VehicleManager";
import { GarageManager } from "./components/GarageManager";
import { VehicleMenu } from "./components/VehicleMenu";
import { Notifications } from "./components/Notifications";
import { DevPanel } from "./components/DevPanel";

export default function App() {
  const store = useAppStore();

  // Click sounds
  useClickSound();

  // --- NUI Message Handlers ---
  useNuiMessage("openDealership", (data: any) => {
    if (!data.data) return store.close();
    store.openDealership(data.data);
  });

  useNuiMessage("openStockManager", (data: any) => {
    if (!data.data) return store.close();
    store.openStockManager(data.data);
  });

  useNuiMessage("openCharacterVehManager", (data: any) => {
    if (!data.data) return store.close();
    store.openVehicleManager(data.data);
  });

  useNuiMessage("openGarageManager", (data: any) => {
    if (!data.data) return store.close();
    store.openGarageManager(data.data);
  });

  useNuiMessage("openGarage", (data: any) => {
    if (!data.data) return store.close();
    store.openGarage(data.data);
  });

  useNuiMessage("removeVehicle", (data: any) => {
    store.removeVehicle(data.plate);
  });

  useNuiMessage("updateVehicleTax", (data: any) => {
    store.updateVehicleTax(data.plate, data.time);
  });

  useNuiMessage("playLockSound", () => {
    playSound("lock.ogg", 0.35);
  });

  useNuiMessage("openMechanic", (data: any) => {
    if (!data.data) return store.close();
    store.openMechanic(data.data);
  });

  useNuiMessage("updateMechanicCart", (data: any) => {
    store.setMechanicCartTotal(data.total);
  });

  useNuiMessage("showMechanicInvoices", (data: any) => {
    if (!data.id || !data.invoices) return store.close();
    store.openInvoices(data.id, data.invoices, data.currentVehicle);
  });

  useNuiMessage("forceClose", () => {
    store.close();
  });

  useNuiMessage("showVehicleMenu", (data: any) => {
    store.openVehicleMenu(data.key, data.backSeats, data.currentSeat);
  });

  useNuiMessage("closeVehicleMenu", () => {
    store.closeVehicleMenu();
  });

  useNuiMessage("triggerLockNotify", (data: any) => {
    store.addLockNotify(data.lockState, data.model);
  });

  useNuiMessage("toggleTestDriveTimer", (data: any) => {
    if (data.model) {
      store.setTestDrive({ model: data.model, seconds: 0 });
    } else {
      store.setTestDrive(null);
    }
  });

  useNuiMessage("updateTestDriveTimer", (data: any) => {
    store.updateTestDriveTimer(data.seconds);
  });

  useNuiMessage("setTheme", (data: any) => {
    if (data.color) store.setTheme(data.color);
  });

  // Garage Manager - eventos de captura de coords
  useNuiMessage("gmCaptureMode", () => {
    // o lua já tira foco; só repassamos pro componente via window event
    window.dispatchEvent(new CustomEvent("gm:capture-mode"));
  });

  useNuiMessage("gmCaptureResult", (data: any) => {
    window.dispatchEvent(new CustomEvent("gm:capture-result", { detail: data.data ?? data }));
  });

  // --- Keyboard handlers ---
  useEffect(() => {
    function handleKeyDown(e: KeyboardEvent) {
      const key = e.key.toLowerCase();

      if (key === "tab") {
        e.preventDefault();
        return;
      }

      if (key === "escape") {
        if (store.modalOpen) {
          store.setModalOpen(false);
          return;
        }
        handleClose();
        return;
      }

      if (store.currentView === "mechanic" && key === "g") {
        sendNui({ action: "toggleFocus" });
        return;
      }

      if (!store.modalOpen) {
        let rotate: boolean | null = null;
        if (key === "a") rotate = false;
        else if (key === "d") rotate = true;
        if (rotate !== null) {
          sendNui({ action: "rotateModelViewer", side: rotate });
        }
      }
    }

    function handleKeyUp(e: KeyboardEvent) {
      const key = e.key.toLowerCase();
      if (key === store.vehicleMenuKey && store.vehicleMenuOpen) {
        closeVMenu();
      }
    }

    window.addEventListener("keydown", handleKeyDown);
    window.addEventListener("keyup", handleKeyUp);
    return () => {
      window.removeEventListener("keydown", handleKeyDown);
      window.removeEventListener("keyup", handleKeyUp);
    };
  });

  function handleClose() {
    sendNui({ action: "close" });
    store.close();
  }

  function closeVMenu() {
    store.closeVehicleMenu();
    sendNui({ action: "remove-focus" });
  }

  // Notify server that interface is loaded
  useEffect(() => {
    sendNui({ action: "interface-loaded" });
  }, []);

  // --- Render ---
  const currentView = store.currentView;
  const overlayView = store.overlayView;

  return (
    <>
      {currentView === "dealership" && <Dealership />}
      {currentView === "garage" && <Garage />}
      {currentView === "mechanic" && <Mechanic />}
      {currentView === "invoices" && <MechanicInvoices />}

      {overlayView === "stockManager" && <StockManager />}
      {overlayView === "vehicleManager" && <VehicleManager />}
      {overlayView === "garageManager" && <GarageManager />}

      <VehicleMenu />
      <Notifications />
      {isEnvBrowser() && <DevPanel />}
    </>
  );
}
