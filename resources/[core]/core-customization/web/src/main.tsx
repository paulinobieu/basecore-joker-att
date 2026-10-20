import { Router } from "@app/router/router";
import { isEnvBrowser } from "@app/utils/misc";
import "@views/styles/index.css";
import React from "react";
import ReactDOM from "react-dom/client";

import { HashRouter } from "react-router-dom";

if (isEnvBrowser()) {
	// Fundo so no navegador: in-game quem fica atras da NUI e a cena do
	// jogo. Este ramo nunca roda dentro do FiveM.
	//
	// Sem ele os paineis, que sao semitransparentes, ficam sobre branco
	// e todo o contraste do tema se perde.
	document.body.style.background =
		"url('https://cdn.europacity.com.br/background.jpg') center / cover no-repeat";
}

ReactDOM.createRoot(document.getElementById("root")!).render(
	<React.StrictMode>
		<HashRouter>
			<Router />
		</HashRouter>
	</React.StrictMode>,
);
