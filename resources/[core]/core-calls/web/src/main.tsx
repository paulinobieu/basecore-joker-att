import { Router } from "@app/router/router";
import { isEnvBrowser } from "@app/utils/misc";
import React from "react";
import ReactDOM from "react-dom/client";
import { HashRouter } from "react-router-dom";

import "@views/styles/index.css";

if (isEnvBrowser()) {
	const body = document.getElementById("root");
	body!.style.backgroundImage =
		"linear-gradient(135deg, rgba(1,67,187,0.18) 0%, rgba(0,0,0,0.85) 60%)";
	body!.style.backgroundColor = "#0a0a0a";
	body!.style.backgroundSize = "cover";
	body!.style.backgroundRepeat = "no-repeat";
	body!.style.backgroundPosition = "center";
	body!.style.height = "100vh";
}

ReactDOM.createRoot(document.getElementById("root")!).render(
	<React.StrictMode>
		<HashRouter>
			<Router />
		</HashRouter>
	</React.StrictMode>,
);
