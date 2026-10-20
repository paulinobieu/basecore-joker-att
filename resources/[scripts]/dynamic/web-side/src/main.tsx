import { isEnvBrowser } from "@app/utils/misc";
import { Layout } from "@views/layout";
import React from "react";
import ReactDOM from "react-dom/client";

import "@views/styles/fonts/fontawesome/css/all.min.css";

if (isEnvBrowser()) {
    const body = document.getElementById("root");

    body!.style.backgroundImage =
        "url('https://cdn.europacity.com.br/background.jpg')";
    body!.style.backgroundSize = "cover";
    body!.style.backgroundRepeat = "no-repeat";
    body!.style.backgroundPosition = "center";
    body!.style.height = "100vh";
}

ReactDOM.createRoot(document.getElementById("root")!).render(
    <React.StrictMode>
        <Layout />
    </React.StrictMode>,
);
