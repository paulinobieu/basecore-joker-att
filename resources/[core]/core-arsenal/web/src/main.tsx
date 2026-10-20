import { browserArsenal } from "@app/stores/Arsenal";
import { debugData } from "@app/utils/debugData";
import { isEnvBrowser } from "@app/utils/misc";
import { Layout } from "@views/layout";
import React from "react";
import ReactDOM from "react-dom/client";

import "@views/styles/index.css";

if (isEnvBrowser()) {
	const root = document.getElementById("root");

	if (root) {
		root.style.background =
			"radial-gradient(120% 120% at 20% 10%, #16181a 0%, #0b0c0d 60%, #050506 100%)";
	}

	// Mesma sequencia que o client dispara ao abrir o arsenal em jogo.
	debugData<unknown>([
		{ action: "setColor", payload: "220, 21, 83" },
		{ action: "setArsenal", payload: browserArsenal() },
		{ action: "setVisible", payload: true },
	]);
}

ReactDOM.createRoot(document.getElementById("root")!).render(
	<React.StrictMode>
		<Layout />
	</React.StrictMode>,
);
