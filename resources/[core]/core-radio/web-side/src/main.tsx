import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { Radio } from "@views/pages/Radio";
import "@views/styles/index.css";

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <Radio />
  </StrictMode>,
);
