import { Router } from "@app/router/router";
import { isEnvBrowser } from "@app/utils/misc";
import React from "react";
import ReactDOM from "react-dom/client";

import { HashRouter } from "react-router-dom";

if (isEnvBrowser()) {
	const root = document.getElementById("root");

	root!.style.backgroundColor = "#1c1c1f";
	root!.style.height = "100vh";
}

ReactDOM.createRoot(document.getElementById("root")!).render(
	<React.StrictMode>
		<HashRouter>
			<Router />
		</HashRouter>
	</React.StrictMode>,
);
