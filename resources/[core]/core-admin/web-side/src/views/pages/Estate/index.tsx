import { Tabs } from "@views/components/Tabs";
import { Chests } from "@views/pages/Chests";
import { Properties } from "@views/pages/Properties";
import { useState } from "react";

const TABS = [
  { value: "properties", label: "Propriedades" },
  { value: "chests", label: "Baús" },
];

/**
 * Propriedades e baus dividem a mesma aba: o alternador vive na toolbar de
 * cada view, e cada uma continua dona do proprio estado e das proprias telas.
 */
export function Estate() {
  const [view, setView] = useState("properties");

  const switcher = (
    <Tabs fill={false} items={TABS} value={view} onChange={setView} />
  );

  return view === "chests" ? (
    <Chests switcher={switcher} />
  ) : (
    <Properties switcher={switcher} />
  );
}
