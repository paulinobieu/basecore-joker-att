import { useScreenStore } from "@app/stores/Screen";
import { lazyLoad } from "@app/utils/lazyLoad";
import { NotFound } from "@views/components/NotFound";
import { SpinLoader } from "@views/components/SpinLoader";
import { Layout } from "@views/layout";
import { Suspense, useEffect } from "react";
import { Route, Routes, useNavigate } from "react-router-dom";
import { routes } from "./routes";

const { Clothes } = lazyLoad(() => import("../../views/pages/Clothes"));
const { Tattoos } = lazyLoad(() => import("../../views/pages/Tattoos"));

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
					<Route element={<Clothes />} path={routes.clothes} />
					<Route element={<Tattoos />} path={routes.tattoos} />
					<Route element={<NotFound />} path="*" />
				</Route>
			</Routes>
		</Suspense>
	);
}
