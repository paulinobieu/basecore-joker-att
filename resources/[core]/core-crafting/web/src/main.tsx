import { isEnvBrowser } from "@app/utils/misc";
import { Notifys } from "@views/components/Notifys";
import { Layout } from "@views/layout";
import React from "react";
import ReactDOM from "react-dom/client";

import "@views/styles/index.css";

if (isEnvBrowser()) {
	const root = document.getElementById("root");

	if (root) {
		root.style.background =
			"radial-gradient(120% 120% at 20% 10%, #241016 0%, #0b0b0d 60%, #050506 100%)";
	}
}

ReactDOM.createRoot(document.getElementById("root")!).render(
	<React.StrictMode>
		<Layout />
		<Notifys />
	</React.StrictMode>,
);
