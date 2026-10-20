import React from "react";
import ReactDOM from "react-dom/client";
import { HashRouter } from "react-router-dom";
import { VisibilityProvider } from "@app/providers/VisibilityProvider";
import { Router } from "@app/router/router";
import { isEnvBrowser } from "@app/utils/misc";
import "@views/styles/index.css";

if (isEnvBrowser()) {
  const root = document.getElementById("root");
  if (root) {
    root.style.background =
      "radial-gradient(120% 120% at 20% 10%, #23202b 0%, #0b0b0d 60%, #050506 100%)";
  }
}

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <HashRouter>
      <VisibilityProvider>
        <Router />
      </VisibilityProvider>
    </HashRouter>
  </React.StrictMode>
);
