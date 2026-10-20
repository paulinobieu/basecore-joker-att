import { type ReactNode, useCallback, useEffect, useMemo, useState } from "react";
import { Outlet, useLocation, useNavigate } from "react-router-dom";
import { cn } from "@app/utils";
import { fetchNui } from "@app/utils/fetchNui";
import { useVisibility } from "@app/stores/Visibility";
import { useMainStore } from "@app/stores/MainStore";
import { useLayout } from "@app/hooks/useLayout";
import { useClickSound } from "@app/hooks/useClickSound";
import { ROUTES } from "@app/router/routes";
import { ErrorBoundary } from "@views/components/ErrorBoundary";
import { SquareDecoration } from "@views/components/SquareDecoration";
import { KeyLabel } from "@views/components/KeyLabel";
import { DiamondBadgeIcon } from "@views/components/icons/DiamondBadgeIcon";
import { PlusIcon } from "@views/components/icons/PlusIcon";
import { VoucherIcon } from "@views/components/icons/VoucherIcon";
import { CaixasIcon } from "@views/components/icons/CaixasIcon";
import { TrocaIcon } from "@views/components/icons/TrocaIcon";
import { InventarioIcon } from "@views/components/icons/InventarioIcon";
import { AprimoramentoIcon } from "@views/components/icons/AprimoramentoIcon";
import { RankingIcon } from "@views/components/icons/RankingIcon";

import avatarFallback from "@views/assets/images/avatar.png";
import logoDefault from "@views/assets/images/logo.png";
import uiCasesBg from "@views/assets/images/ui-cases-bg.png";

interface TabConfig {
	label: string;
	route: string;
	icon: ReactNode;
	disabled?: boolean;
	badge?: number;
}

const TABS: TabConfig[] = [
	{
		label: "Caixas",
		route: ROUTES.caixas,
		icon: <CaixasIcon />,
	},
	{
		label: "Inventário",
		route: ROUTES.inventario,
		icon: <InventarioIcon />,
	},
	{
		label: "Trocas",
		route: ROUTES.troca,
		icon: <TrocaIcon />,
	},
	{
		label: "Aprimoramento",
		route: ROUTES.aprimoramento,
		icon: <AprimoramentoIcon />,
	},
	{
		label: "Ranking",
		route: ROUTES.ranking,
		icon: <RankingIcon />,
	},
];

function formatNumber(value: number) {
	return value.toLocaleString("pt-BR");
}

export function Layout() {
	const visible = useVisibility((s) => s.visible);
	const previewMode = useVisibility((s) => s.previewMode);
	const navigate = useNavigate();
	const location = useLocation();
	const store = useMainStore();
	const [logo, setLogo] = useState(logoDefault);
	const [skinCoinsShopUrl, setSkinCoinsShopUrl] = useState<string | null>(null);

	const tabs = useMemo(
		() =>
			TABS.filter(
				(tab) => tab.route !== ROUTES.aprimoramento || store.improvementEnabled !== false,
			),
		[store.improvementEnabled],
	);

	useLayout();
	useClickSound();

	useEffect(() => {
		if (!visible) return;

		fetchNui({
			path: "get:playerData",
			mockData: {
				name: "Bieu do Grau",
				skinsCoins: 8000,
				vouchers: 786,
				avatar: null,
				id: 4964,
				durations: [
					{ id: "7d", label: "7 Dias", days: 7, price: 5000 },
					{ id: "30d", label: "30 Dias", days: 30, price: 15000 },
					{ id: "perm", label: "Permanente", days: 0, price: null },
				],
			},
		}).then((data: any) => {
			if (data?.name) store.setPlayerData(data);
		});

		fetchNui({ path: "get:logo", mockData: null }).then((data: any) => {
			if (data) setLogo(data);
		});

		fetchNui({ path: "get:skinCoinsShopUrl", mockData: "https://loja.americagg.com.br/" }).then(
			(data: any) => {
				setSkinCoinsShopUrl(data && data.length > 0 ? data : null);
			},
		);
	}, [visible]);

	const activeIndex = tabs.findIndex((tab) => location.pathname.includes(tab.route));

	const goToPrev = useCallback(() => {
		let idx = activeIndex <= 0 ? tabs.length - 1 : activeIndex - 1;
		while (tabs[idx].disabled && idx !== activeIndex) {
			idx = idx <= 0 ? tabs.length - 1 : idx - 1;
		}
		if (!tabs[idx].disabled) navigate(tabs[idx].route);
	}, [activeIndex, navigate, tabs]);

	const goToNext = useCallback(() => {
		let idx = activeIndex >= tabs.length - 1 ? 0 : activeIndex + 1;
		while (tabs[idx].disabled && idx !== activeIndex) {
			idx = idx >= tabs.length - 1 ? 0 : idx + 1;
		}
		if (!tabs[idx].disabled) navigate(tabs[idx].route);
	}, [activeIndex, navigate, tabs]);

	useEffect(() => {
		const handler = (e: KeyboardEvent) => {
			const tag = (document.activeElement?.tagName ?? "").toLowerCase();
			if (tag === "input" || tag === "textarea" || tag === "select") return;
			if (document.querySelector("[data-modal-open]")) return;
			if (document.querySelector("[data-spinning]")) return;
			if (e.key.toLowerCase() === "q") goToPrev();
			if (e.key.toLowerCase() === "e") goToNext();
		};
		window.addEventListener("keydown", handler);
		return () => window.removeEventListener("keydown", handler);
	}, [goToPrev, goToNext]);

	return (
		<div
			className={cn(
				"fixed inset-0 z-[2] flex h-screen w-screen flex-col overflow-hidden transition-opacity duration-500",
				visible ? "opacity-100" : "pointer-events-none opacity-0",
			)}
		>
			<div
				style={{
					background: `linear-gradient(108deg, rgba(var(--primaryColor), 0) 52.97%, rgba(var(--primaryColor), 0.06) 107.13%), linear-gradient(109deg, rgba(var(--primaryColor), 0.07) 6.6%, rgba(var(--primaryColor), 0) 38.84%), url(${uiCasesBg}) center / cover no-repeat, linear-gradient(0deg, rgba(5, 5, 5, 0.94) 0%, rgba(5, 5, 5, 0.94) 100%), rgba(40, 40, 40, 0.70)`,
				}}
				className={cn(
					"absolute inset-0 flex flex-col transition-opacity duration-500",
					previewMode ? "pointer-events-none opacity-0" : "opacity-100",
				)}
			>
				{/* Corner decorations */}
				<SquareDecoration className="-translate-x-[61.5%] -rotate-[30deg] pointer-events-none absolute bottom-0 left-0 w-[15vw] translate-y-[20%]" />
				<SquareDecoration className="-translate-y-[40%] pointer-events-none absolute top-0 right-0 w-[15vw] translate-x-[60%] rotate-[90deg]" />
				<SquareDecoration className="pointer-events-none absolute right-0 bottom-0 w-[15vw] translate-x-[17%] translate-y-[61.5%] rotate-[90deg]" />

				{/* Header */}
				<header
					style={{
						backgroundImage: `linear-gradient(109deg, rgba(var(--primaryColor), 0.10) 0%, rgba(var(--primaryColor), 0) 35%), linear-gradient(rgba(8,8,8,0.4), rgba(8,8,8,0.4))`,
					}}
					className="relative z-[1] flex h-[5rem] w-full shrink-0 items-center justify-between border-b border-b-white/[.10] bg-center bg-cover bg-no-repeat px-[5%]"
				>
					<div className="flex items-center gap-[2.5rem]">
						<img src={logo} alt="" className="h-[5rem] w-[6.6875rem] object-contain" />
						<button type="button" onClick={goToPrev}>
							<KeyLabel label="Q" />
						</button>
						<nav className="flex items-center">
							{tabs.map((tab) => {
								const isActive = location.pathname.includes(tab.route);
								return (
									<button
										key={tab.route}
										type="button"
										disabled={tab.disabled}
										onClick={() => !tab.disabled && navigate(tab.route)}
										className={cn(
											"relative flex h-[5rem] items-center gap-[0.5rem] overflow-hidden px-[1rem] py-[0.625rem] font-medium text-[0.9375rem] tracking-[-0.04em] transition",
											tab.disabled && "cursor-not-allowed opacity-30",
											!tab.disabled && !isActive && "text-white/60 hover:text-white",
											!tab.disabled && isActive && "text-white",
										)}
									>
										{isActive && (
											<>
												<div
													style={{
														background:
															"linear-gradient(to right, transparent, rgb(var(--primaryColor)), transparent)",
													}}
													className="pointer-events-none absolute bottom-0 left-0 h-[1px] w-full"
												/>
												<div
													style={{
														background:
															"radial-gradient(ellipse at center, rgba(var(--primaryColor), 0.8), transparent 70%)",
													}}
													className="-translate-x-1/2 pointer-events-none absolute bottom-0 left-1/2 h-[2.8125rem] w-full translate-y-[40%] opacity-40 blur-md"
												/>
											</>
										)}
										{tab.icon}
										{tab.label}
										{tab.badge && !isActive && (
											<div className="absolute top-[0.5rem] right-[0.125rem] flex h-[1rem] w-[1.3125rem] items-center justify-center rounded-[0.125rem] border-[0.7px] border-primaryColor/60 bg-primaryColor">
												<span className="text-center font-bold text-[0.75rem] text-white leading-none tracking-[-0.04em]">
													{tab.badge}
												</span>
											</div>
										)}
									</button>
								);
							})}
						</nav>
						<button type="button" onClick={goToNext}>
							<KeyLabel label="E" />
						</button>
					</div>

					<div className="flex items-center gap-[1.25rem]">
						{/* SkinCoins */}
						<div className="flex items-center gap-[0.5rem]">
							<DiamondBadgeIcon />
							<span className="font-medium text-[0.8125rem] text-white tracking-[-0.04em]">
								{formatNumber(store.skinsCoins)} SkinCoins
							</span>
							{skinCoinsShopUrl ? (
								<button
									type="button"
									className="transition hover:opacity-80"
									onClick={() =>
										(window as any).invokeNative?.("openUrl", skinCoinsShopUrl)
									}
								>
									<PlusIcon />
								</button>
							) : null}
						</div>

						{/* Voucher */}
						<div className="group relative">
							<div className="rounded-[0.25rem] border-[0.7px] border-white/[.16] p-[0.125rem]">
								<div className="flex h-[1.875rem] w-[9.125rem] items-center gap-[0.5rem] rounded-[0.1875rem] border-[0.7px] border-white/[.06] bg-[#080808]/[.38] px-[0.5rem]">
									<VoucherIcon />
									<span className="font-medium text-[0.75rem] text-white tracking-[-0.04em]">
										Voucher
									</span>
									<span className="ml-auto font-medium text-[#ADADAD] text-[0.75rem] tracking-[-0.04em]">
										{formatNumber(store.vouchers)}
									</span>
								</div>
							</div>
							<div className="-translate-x-1/2 pointer-events-none absolute top-full left-1/2 mt-[0.5rem] flex h-[3.875rem] w-[20rem] items-center rounded-[0.25rem] bg-[#050505] px-[1rem] opacity-0 transition-opacity group-hover:pointer-events-auto group-hover:opacity-100">
								<span className="font-normal text-[#ADADAD] text-[0.75rem] leading-relaxed tracking-[-0.04em]">
									Troque seus vouchers por itens exclusivos dentro do jogo. Resgate
									recompensas especiais.
								</span>
							</div>
						</div>

						{/* User info */}
						<div className="flex items-center gap-[0.75rem]">
							<div className="flex flex-col items-end">
								<span className="font-normal text-[#ADADAD] text-[0.6875rem] tracking-[-0.04em]">
									Conectado como:
								</span>
								<span className="font-medium text-[0.9375rem] text-white tracking-[-0.04em]">
									{store.name}
								</span>
							</div>
							<img
								src={store.avatar || avatarFallback}
								alt=""
								className="h-[2.75rem] w-[2.75rem] rounded-full border-2 border-primaryColor object-cover"
							/>
						</div>
					</div>
				</header>

				{/* Main content */}
				<main className="h-[calc(100%-5rem)] w-full px-[5%] pt-[1rem]">
					<ErrorBoundary>
						<Outlet />
					</ErrorBoundary>
				</main>
			</div>
		</div>
	);
}
