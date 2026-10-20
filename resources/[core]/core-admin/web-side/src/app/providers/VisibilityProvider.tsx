import React, {
  Context,
  createContext,
  useContext,
  useEffect,
  useState,
} from "react";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { fetchNui } from "../utils/fetchNui";
import { isEnvBrowser } from "../utils/misc";
import { ThemeColors, applyThemeColors } from "../utils/theme";

const VisibilityCtx = createContext<VisibilityProviderValue | null>(null);

interface VisibilityProviderValue {
  setVisible: (visible: boolean) => void;
  visible: boolean;
  hideFrame: () => void;
  refreshData: () => void;
}

export const VisibilityProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [visible, setVisible] = useState(isEnvBrowser());

  useNuiEvent<boolean>("setVisible", setVisible);
  useNuiEvent<ThemeColors>("setColors", applyThemeColors);

  const refreshData = () => {
    fetchNui("getNotifications");
    fetchNui("getOnlinePlayers");
    fetchNui("getServerData");
    fetchNui("getChatMessages");
    fetchNui("getUserInfo");
  };

  const hideFrame = () => {
    if (isEnvBrowser()) {
      setVisible(false);
      return;
    }
    fetchNui("hideFrame");
  };

  useEffect(() => {
    if (!visible) return;
    if (isEnvBrowser()) return;

    refreshData();

    const keyHandler = (e: KeyboardEvent) => {
      if (e.code === "Escape") hideFrame();
    };

    window.addEventListener("keydown", keyHandler);
    return () => window.removeEventListener("keydown", keyHandler);
  }, [visible]);

  return (
    <VisibilityCtx.Provider
      value={{
        visible,
        setVisible,
        hideFrame,
        refreshData,
      }}
    >
      {children}
    </VisibilityCtx.Provider>
  );
};

export const useVisibility = () =>
  useContext<VisibilityProviderValue>(
    VisibilityCtx as Context<VisibilityProviderValue>
  );
