import React from "react";
import ReactDOM from "react-dom/client";
import { HashRouter } from "react-router-dom";
import { isEnvBrowser } from "@app/utils/misc";
import { applyColors } from "@app/utils/colors";
import { AppRouter } from "@app/router/router";
import "@views/styles/index.css";

applyColors({
	primaryColor: "0, 149, 243",
	secondaryColor: "229, 16, 127",
	thirdColor: "126, 54, 214",
});

if (isEnvBrowser()) {
	const root = document.getElementById("root");
	if (root) {
		root.style.backgroundImage = "url('https://i.imgur.com/3pzFKkZ.png')";
		root.style.backgroundSize = "cover";
		root.style.backgroundRepeat = "no-repeat";
		root.style.backgroundPosition = "center";
	}
}

ReactDOM.createRoot(document.getElementById("root")!).render(
	<React.StrictMode>
		<HashRouter>
			<AppRouter />
		</HashRouter>
	</React.StrictMode>,
);
