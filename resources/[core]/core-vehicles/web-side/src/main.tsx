import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import { isEnvBrowser } from "./app/utils/nui";
import "./styles/index.css";
import "./styles/dealership.css";
import "./styles/garage.css";
import "./styles/managers.css";
import "./styles/dev-panel.css";

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);

if (isEnvBrowser()) {
  import("./app/utils/dev-mock").then((m) => m.startDevMock());
}
