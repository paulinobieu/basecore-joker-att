import { Navigate, Route, Routes, useNavigate } from "react-router-dom";

import { useVisibilityStore } from "@app/stores/Visibility";
import { lazyLoad } from "@app/utils/lazyLoad";
import { NotFound } from "@views/components/NotFound";
import { SpinLoader } from "@views/components/SpinLoader";
import { Layout } from "@views/layout";
import { BankLayout } from "@views/layout/BankLayout";
import { EntryLayout } from "@views/layout/EntryLayout";
import { Suspense, useEffect } from "react";
import { routes } from "./routes";

const { Accounts } = lazyLoad(() => import("../../views/pages/Accounts"));
const { Dashboard } = lazyLoad(() => import("../../views/pages/Dashboard"));
const { Pix } = lazyLoad(() => import("../../views/pages/Pix"));
const { Transfer } = lazyLoad(() => import("../../views/pages/Transfer"));
const { Statement } = lazyLoad(() => import("../../views/pages/Statement"));
const { Cryptos } = lazyLoad(() => import("../../views/pages/Cryptos"));
const { Investments } = lazyLoad(() => import("../../views/pages/Investments"));
const { Invoices } = lazyLoad(() => import("../../views/pages/Invoices"));
const { Fines } = lazyLoad(() => import("../../views/pages/Fines"));
const { Invites } = lazyLoad(() => import("../../views/pages/Invites"));

const DEFAULT_PAGE: keyof typeof routes = "accounts";

export function Router() {
	const visible = useVisibilityStore((state) => state.visible);
	const navigate = useNavigate();

	// O banco sempre abre na escolha de conta, nunca na última tela usada.
	// A dependência é só `visible`: o `navigate` do react-router é recriado a
	// cada troca de rota, e com ele na lista o efeito rodava de novo e jogava o
	// jogador de volta para a escolha de conta assim que ele entrava.
	// biome-ignore lint/correctness/useExhaustiveDependencies: só na abertura
	useEffect(() => {
		if (!visible) return;

		navigate(DEFAULT_PAGE, { replace: true });
	}, [visible]);

	return (
		<Suspense
			fallback={
				<div className="flex h-screen w-screen items-center justify-center">
					<SpinLoader />
				</div>
			}
		>
			<Routes>
				<Route element={<Layout />} path="/">
					<Route element={<Navigate replace to={routes.accounts} />} index />

					<Route element={<EntryLayout />}>
						<Route element={<Accounts />} path={routes.accounts} />
					</Route>

					<Route element={<BankLayout />}>
						<Route element={<Dashboard />} path={routes.dashboard} />
						<Route element={<Pix />} path={routes.pix} />
						<Route element={<Transfer />} path={routes.transfer} />
						<Route element={<Statement />} path={routes.statement} />
						<Route element={<Cryptos />} path={routes.cryptos} />
						<Route element={<Investments />} path={routes.investments} />
						<Route element={<Invoices />} path={routes.invoices} />
						<Route element={<Fines />} path={routes.fines} />
						<Route element={<Invites />} path={routes.invites} />
					</Route>

					<Route element={<NotFound />} path="*" />
				</Route>
			</Routes>
		</Suspense>
	);
}
