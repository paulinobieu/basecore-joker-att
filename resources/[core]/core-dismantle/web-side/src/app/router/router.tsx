import { Route, Routes } from "react-router-dom";
import { Layout } from "@views/layout";

export function Router() {
	return (
		<Routes>
			<Route element={<Layout />} path="*" />
		</Routes>
	);
}
