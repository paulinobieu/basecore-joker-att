import { Route, Routes, useNavigate } from "react-router-dom";

import { useVisibilityStore } from "@app/stores/Visibility";
import { lazyLoad } from "@app/utils/lazyLoad";
import { SpinLoader } from "@views/components/SpinLoader";
import { Layout } from "@views/layout";
import { Suspense, useEffect } from "react";
import { routes } from "./routes";

const { DoorsList } = lazyLoad(() => import("../../views/pages/DoorsList"));
const { DoorSettings } = lazyLoad(
	() => import("../../views/pages/DoorSettings"),
);

const DEFAULT_PAGE: keyof typeof routes = "home";

export function Router() {
	const visible = useVisibilityStore((state) => state.visible);
	const navigate = useNavigate();

	useEffect(() => {
		if (!visible) return;
		navigate(DEFAULT_PAGE, { replace: true });
	}, [visible]);

	return (
		<Suspense fallback={<SpinLoader />}>
			<Routes>
				<Route element={<Layout />} path="/">
					<Route element={<DoorsList />} path={routes.home} />
					<Route element={<DoorSettings />} path={routes.settings} />
				</Route>
			</Routes>
		</Suspense>
	);
}
