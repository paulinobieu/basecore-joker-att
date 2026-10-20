import { navigation } from "@app/router/routes";
import { Sidebar } from "@views/components/Sidebar";
import { useMemo } from "react";
import { Outlet, useLocation } from "react-router-dom";

/** Painel principal: navegação à esquerda, identidade da página no topo. */
export function BankLayout() {
	const { pathname } = useLocation();

	const entry = useMemo(
		() => navigation.find((item) => pathname.endsWith(item.route)),
		[pathname],
	);

	return (
		<div className="bank-shell flex h-[50rem] w-[90rem] rounded-[.625rem] bg-[#111114F5] outline outline-[#14141769] outline-[.5625rem]">
			<Sidebar />

			<div className="flex h-full w-[calc(100%-6.125rem)] flex-col">
				<header className="flex h-[4.75rem] w-full flex-shrink-0 flex-col justify-center border-[#D9D9D91A] border-b border-solid px-[1.25rem]">
					<h1 className="font-black text-[1.0625rem] text-ink uppercase leading-tight">
						{entry?.label ?? "Banco"}
					</h1>
					<span className="font-semibold text-[.6875rem] text-ink-ghost">
						{entry?.subtitle ?? "Core Network"}
					</span>
				</header>

				<main className="flex h-[calc(100%-4.75rem)] w-full">
					<Outlet />
				</main>
			</div>
		</div>
	);
}
