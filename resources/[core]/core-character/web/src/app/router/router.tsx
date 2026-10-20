import { useScreenStore } from "@app/stores/Screen";
import { lazyLoad } from "@app/utils/lazyLoad";
import { NotFound } from "@views/components/NotFound";
import { SpinLoader } from "@views/components/SpinLoader";
import { Layout } from "@views/layout";
import { Suspense, useEffect } from "react";
import { Route, Routes, useNavigate } from "react-router-dom";
import { routes } from "./routes";

const { Character } = lazyLoad(() => import("../../views/pages/Character"));
const { BarberShop } = lazyLoad(() => import("../../views/pages/BarberShop"));
const { Select } = lazyLoad(() => import("../../views/pages/Select"));
const { SelectSpawn } = lazyLoad(() => import("../../views/pages/SelectSpawn"));

export function Router() {
	const screen = useScreenStore((state) => state.screen);
	const navigate = useNavigate();

	// biome-ignore lint/correctness/useExhaustiveDependencies: <explanation>
	useEffect(() => {
		if (!screen) return;

		navigate(routes[screen], { replace: true });
	}, [screen]);

	return (
		<Suspense fallback={<SpinLoader />}>
			<Routes>
				<Route element={<Layout />} path="/">
					<Route element={<Character />} path={routes.character} />
					<Route element={<BarberShop />} path={routes.barber} />
					<Route element={<Select />} path={routes.select} />
					<Route element={<SelectSpawn />} path={routes.spawn} />
					<Route element={<NotFound />} path="*" />
				</Route>
			</Routes>
		</Suspense>
	);
}
