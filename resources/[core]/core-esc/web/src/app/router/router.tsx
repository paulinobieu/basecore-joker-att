import { Route, Routes, useNavigate } from "react-router-dom";

import { useVisibilityStore } from "@app/stores/Visibility";
import { lazyLoad } from "@app/utils/lazyLoad";
import { SpinLoader } from "@views/components/SpinLoader";
import { Layout } from "@views/layout";
import { Suspense, useEffect } from "react";
import { routes } from "./routes";

const { Home } = lazyLoad(() => import("../../views/pages/Home"));
const { Settings } = lazyLoad(() => import("../../views/pages/Settings"));
const { Shop } = lazyLoad(() => import("../../views/pages/Shop"));
const { Ranking } = lazyLoad(() => import("../../views/pages/Ranking"));

const DEFAULT_PAGE = "home";

export function Router() {
	const visible = useVisibilityStore((state) => state.visible);
	const navigate = useNavigate();

	// biome-ignore lint/correctness/useExhaustiveDependencies: <explanation>
	useEffect(() => {
		navigate(DEFAULT_PAGE, { replace: true });
	}, [visible]);

	return (
		<Suspense fallback={<SpinLoader />}>
			<Routes>
				<Route element={<Layout />} path="/">
					<Route element={<Home />} path={routes.home} />
					<Route element={<Settings />} path={routes.settings} />
					<Route element={<Shop />} path={routes.shop} />
					<Route element={<Ranking />} path={routes.ranking} />
				</Route>
			</Routes>
		</Suspense>
	);
}
