import { useState } from "react";
import { useAppStore } from "@app/stores/store";

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

const SCREENS: Array<{
  id: DevScreen;
  label: string;
  short: string;
  icon: string;
}> = [
  { id: "dealership", label: "Concessionária", short: "CONCE", icon: "fa-solid fa-shop" },
  { id: "garage", label: "Garagem", short: "GARAGEM", icon: "fa-solid fa-warehouse" },
  { id: "mechanic", label: "Mecânica", short: "MECÂNICA", icon: "fa-solid fa-wrench" },
  { id: "invoices", label: "Pedidos da mecânica", short: "PEDIDOS", icon: "fa-solid fa-receipt" },
  { id: "stockManager", label: "Gerenciar estoque", short: "ESTOQUE", icon: "fa-solid fa-boxes-stacked" },
  { id: "vehicleManager", label: "Vehicle Manager", short: "VMANAGE", icon: "fa-solid fa-car-side" },
  { id: "garageManager", label: "Garage Manager", short: "GMANAGE", icon: "fa-solid fa-list-check" },
  { id: "vehicleMenu", label: "Menu do veículo", short: "V-MENU", icon: "fa-solid fa-gauge-high" },
];

function openDevScreen(screen: DevScreen) {
  (window as any).__coreVehiclesDev?.open(screen);
}

export function DevPanel() {
  const [collapsed, setCollapsed] = useState(false);
  const currentView = useAppStore((s) => s.currentView);
  const overlayView = useAppStore((s) => s.overlayView);
  const vehicleMenuOpen = useAppStore((s) => s.vehicleMenuOpen);
  const testDrive = useAppStore((s) => s.testDrive);

  const activeScreen =
    overlayView !== "none"
      ? overlayView
      : vehicleMenuOpen
        ? "vehicleMenu"
        : currentView;

  return (
    <aside className={`cv-dev-panel${collapsed ? " is-collapsed" : ""}`}>
      <button
        className="cv-dev-panel__toggle"
        type="button"
        title={collapsed ? "Abrir seletor de telas" : "Recolher seletor de telas"}
        onClick={() => setCollapsed((value) => !value)}
      >
        <span className="cv-dev-panel__mark">CV</span>
        {!collapsed && (
          <span className="cv-dev-panel__heading">
            <strong>ENV BROWSER</strong>
            <small>SELETOR DE TELAS</small>
          </span>
        )}
        <i className={`fa-solid fa-chevron-${collapsed ? "right" : "left"}`} />
      </button>

      {!collapsed && (
        <>
          <div className="cv-dev-panel__screens">
            {SCREENS.map((screen) => (
              <button
                key={screen.id}
                type="button"
                className={activeScreen === screen.id ? "is-active" : ""}
                title={screen.label}
                onClick={() => openDevScreen(screen.id)}
              >
                <i className={screen.icon} />
                <span>{screen.short}</span>
              </button>
            ))}
          </div>

          <div className="cv-dev-panel__tools">
            <button type="button" onClick={() => openDevScreen("lockNotify")}>
              <i className="fa-solid fa-lock" />
              <span>LOCK</span>
            </button>
            <button
              type="button"
              className={testDrive ? "is-active" : ""}
              onClick={() => openDevScreen("testDrive")}
            >
              <i className="fa-solid fa-stopwatch" />
              <span>TEST DRIVE</span>
            </button>
            <button type="button" className="is-clear" onClick={() => openDevScreen("clear")}>
              <i className="fa-solid fa-eye-slash" />
              <span>LIMPAR</span>
            </button>
          </div>
        </>
      )}
    </aside>
  );
}
