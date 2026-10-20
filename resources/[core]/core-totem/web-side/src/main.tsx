import { Router } from "@app/router/router";
import { isEnvBrowser } from "@app/utils/misc";
import React from "react";
import ReactDOM from "react-dom/client";
import { HashRouter } from "react-router-dom";

if (isEnvBrowser()) {
	document.documentElement.classList.add("browser-preview");
}

ReactDOM.createRoot(document.getElementById("root")!).render(
	<React.StrictMode>
		<HashRouter>
			<Router />
		</HashRouter>
	</React.StrictMode>,
);
