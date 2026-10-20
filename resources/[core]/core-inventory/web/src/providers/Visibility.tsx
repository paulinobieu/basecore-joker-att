import {
  useContainerInventory,
  useChestUpgrade,
  useGroundItem,
  useGroundSection,
  useInventory,
  useItem,
  useProfile,
  useTrade,
} from "@/stores/useNui";
import { useEffect, useRef, useState, type ReactNode } from "react";

import { AnimationProvider } from "./Animation";
import { Post } from "@/hooks/post";
import { isEnvBrowser } from "@/utils/misc";
import { useEventListener } from "@/hooks/listen";
import { useNuiEvent } from "@/hooks/observe";

function setAccentColor(value?: string) {
  const match = /^#?([\da-f]{6})$/i.exec(value ?? "");
  if (!match) return;

  const color = match[1];
  const red = Number.parseInt(color.slice(0, 2), 16);
  const green = Number.parseInt(color.slice(2, 4), 16);
  const blue = Number.parseInt(color.slice(4, 6), 16);

  document.documentElement.style.setProperty(
    "--main-color",
    `${red}, ${green}, ${blue}`,
  );
}

export const VisibilityProvider = ({ children }: { children: ReactNode }) => {
  const [visible, setVisible] = useState(isEnvBrowser());
  const setItem = useItem((state) => state.set);
  const setProfile = useProfile((state) => state.set);
  const setInventory = useInventory((state) => state.set);
  const setContainer = useContainerInventory((state) => state.set);
  const setGroundItems = useGroundItem((state) => state.set);
  const setGroundSection = useGroundSection((state) => state.set);
  const setChestUpgrade = useChestUpgrade((state) => state.set);
  const setTrade = useTrade((state) => state.set);
  const wasVisibleRef = useRef(visible);

  useNuiEvent("updateBackpack", setItem);
  useNuiEvent("setInventory", (inventory) => {
    setInventory(inventory);
    setAccentColor(inventory.accent);
  });
  useNuiEvent("setProfile", setProfile);
  useNuiEvent("setContainer", (container) => {
    if (container) {
      setGroundSection(null);
      setChestUpgrade(null);
      setTrade(null);
    }
    setContainer(container);
  });
  useNuiEvent("setGroundSection", (section) => {
    if (section) {
      setContainer(null);
      setTrade(null);
    }
    setChestUpgrade(null);
    setGroundSection(section);
  });
  useNuiEvent("setTrade", (session) => {
    if (session) {
      setContainer(null);
      setGroundSection(null);
      setChestUpgrade(null);
    }
    setTrade(session);
  });
  useNuiEvent("updateDrop", setGroundItems);
  useNuiEvent("setChestUpgrade", setChestUpgrade);
  useNuiEvent("setVisibility", setVisible);
  useEventListener<KeyboardEvent>("keydown", (event) => {
    if (visible && event.code === "Escape") {
      if (useChestUpgrade.getState().current) {
        setChestUpgrade(null);
        return;
      }
      setVisible(false);
    }
  });
  useEffect(() => {
    if (!visible) {
      setContainer(null);
      setGroundSection(null);
      setGroundItems({});
      setChestUpgrade(null);
      setTrade(null);
    }
    if (wasVisibleRef.current && !visible && !isEnvBrowser()) {
      Post.send("removeFocus", {});
    }
    wasVisibleRef.current = visible;
  }, [
    setChestUpgrade,
    setContainer,
    setGroundItems,
    setGroundSection,
    setTrade,
    visible,
  ]);

  return (
    <AnimationProvider show={visible}>
      <div className="inventory-viewport">{children}</div>
    </AnimationProvider>
  );
};
