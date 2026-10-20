import { useVisibilityStore } from "@app/stores/Visibility";
import { ErrorBoundary } from "@views/components/ErrorBoundary";
import { SpinLoader } from "@views/components/SpinLoader";
import { Layout } from "@views/layout";
import { Totem } from "@views/pages/Totem";
import { Suspense, useEffect } from "react";
import { Navigate, Route, Routes, useNavigate } from "react-router-dom";
import { routes } from "./routes";

export function Router() {
	const visible = useVisibilityStore((state) => state.visible);
	const navigate = useNavigate();

	useEffect(() => {
		if (visible) navigate(routes.totem, { replace: true });
	}, [navigate, visible]);

	return (
		<ErrorBoundary>
			<Suspense fallback={<SpinLoader />}>
				<Routes>
					<Route element={<Layout />} path="/">
						<Route element={<Totem />} path={routes.totem} />
						<Route element={<Navigate replace to={routes.totem} />} path="*" />
					</Route>
				</Routes>
			</Suspense>
		</ErrorBoundary>
	);
}
