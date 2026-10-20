import { Router } from "@app/router/router";
import { debugData } from "@app/utils/debugData";
import { isEnvBrowser } from "@app/utils/misc";
import React from "react";
import ReactDOM from "react-dom/client";

import { HashRouter } from "react-router-dom";

import "@views/styles/index.css";

if (isEnvBrowser()) {
	const body = document.getElementById("root");

	body!.style.background = "#1a1a1f";
	body!.style.height = "100vh";

	debugData([
		{
			action: "openWeather",
			data: {
				weather: "CLEAR",
				hour: 13,
				minute: 16,
				themeColor: "#0143BB",
			},
		},
	]);
}

ReactDOM.createRoot(document.getElementById("root")!).render(
	<React.StrictMode>
		<HashRouter>
			<Router />
		</HashRouter>
	</React.StrictMode>,
);
