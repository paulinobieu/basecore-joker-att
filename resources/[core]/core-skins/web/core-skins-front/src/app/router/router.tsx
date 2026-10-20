import { Suspense, useEffect } from "react";
import { Route, Routes, useNavigate } from "react-router-dom";
import { lazyLoad } from "@app/utils/lazyLoad";
import { useVisibility } from "@app/stores/Visibility";
import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { DEFAULT_ROUTE, ROUTES } from "@app/router/routes";
import { Layout } from "@views/layout";
import { SpinLoader } from "@views/components/SpinLoader";
import { NotFound } from "@views/components/NotFound";

const { Caixas } = lazyLoad(() => import("@views/pages/Caixas"));
const { Troca } = lazyLoad(() => import("@views/pages/Troca"));
const { Inventario } = lazyLoad(() => import("@views/pages/Inventario"));
const { Aprimoramento } = lazyLoad(() => import("@views/pages/Aprimoramento"));
const { Ranking } = lazyLoad(() => import("@views/pages/Ranking"));
const { AdminPanel } = lazyLoad(() => import("@views/pages/AdminPanel"));

export function AppRouter() {
	const visible = useVisibility((s) => s.visible);
	const admin = useVisibility((s) => s.admin);
	const setVisible = useVisibility((s) => s.setVisible);
	const setAdmin = useVisibility((s) => s.setAdmin);
	const navigate = useNavigate();

	useNuiMessage<boolean>("setVisible", setVisible);
	useNuiMessage<boolean>("setAdmin", setAdmin);

	useEffect(() => {
		if (visible) navigate(admin ? ROUTES.admin : DEFAULT_ROUTE, { replace: true });
	}, [visible, admin]);

	return (
		<Suspense fallback={<SpinLoader />}>
			<Routes>
				<Route element={<Layout />} path="/">
					<Route element={<Caixas />} path={ROUTES.caixas} />
					<Route element={<Troca />} path={ROUTES.troca} />
					<Route element={<Inventario />} path={ROUTES.inventario} />
					<Route element={<Aprimoramento />} path={ROUTES.aprimoramento} />
					<Route element={<Ranking />} path={ROUTES.ranking} />
					<Route path="*" element={<NotFound />} />
				</Route>
				<Route element={<AdminPanel />} path={ROUTES.admin} />
			</Routes>
		</Suspense>
	);
}
