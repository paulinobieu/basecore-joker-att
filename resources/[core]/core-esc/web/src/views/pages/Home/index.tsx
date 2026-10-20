import { useEscStore } from "@app/stores/Esc";
import { cn } from "@app/utils";
import { isEnvBrowser } from "@app/utils/misc";
import { useVisibilityStore } from "@app/stores/Visibility";
import { routes } from "@app/router/routes";
import { useNavigate, useLocation } from "react-router-dom";
import { useShallow } from "zustand/shallow";
import BoxBackground from "@views/assets/images/box-bg.png";
import OtimizationBackground from "@views/assets/images/otimization-background.png";
import MapImage from "@views/assets/images/map.webp";
import TrophyGif from "@views/assets/images/trophy.gif";
import SkinBackground from "@views/assets/images/skin-bg.png";
import { BattlePassCard } from "./BattlePassCard";
import {
	MapPinIcon,
	BoxNavIcon,
	DailyRewardIcon,
	ShopNavIcon,
	WeaponSkinsNavIcon,
	HomeNavIcon,
	UltraBoostNavIcon,
	WeaponSkinsCardIcon,
} from "./icons";

function MisteryBoxButton() {
	return (
		<button
			type="button"
			disabled
			className="flex h-[1.875rem] w-[13.125rem] cursor-not-allowed items-center justify-center rounded-[.1875rem] border border-white/20 border-solid bg-white/[.06] font-bold text-[.8125rem] text-white/50"
		>
			Em breve
		</button>
	);
}

function MisteryBoxCard() {
	return (
		<div
			style={{
				background: `url(${BoxBackground})`,
				backgroundSize: "cover",
				backgroundRepeat: "no-repeat",
			}}
			className="my-5 flex h-[17.5rem] w-[26.25rem] flex-col rounded-[1.25rem] border-solid p-[1.5625rem] outline outline-1 outline-white/25"
		>
			<h1 className="font-bold text-2xl">Caixas misteriosas</h1>
			<span className="mt-2 mb-auto w-[14.3125rem] text-sm">
				Abra caixas e descubra itens raros e{" "}
				<span className="font-semibold">surpresas exclusivas</span>.
			</span>
			<MisteryBoxButton />
		</div>
	);
}

function Divider() {
	return (
		<div
			className="h-[1.4375rem] w-[.0625rem]"
			style={{
				background:
					"linear-gradient(180deg, rgba(217, 217, 217, 0) 0%, rgba(217, 217, 217, 0.3) 50%, rgba(217, 217, 217, 0) 100%)",
			}}
		/>
	);
}

function MenuHeader() {
	const { links, openConfig, openMap } = useEscStore(
		useShallow((s) => ({
			links: s.links,
			openMap: s.openMap,
			openConfig: s.openConfig,
		})),
	);
	const fetchHideFrame = useVisibilityStore((s) => s.fetchHideFrame);
	return (
		<header className="flex h-[3.75rem] w-[48.75rem] items-center justify-center gap-[1.875rem] rounded-[.4375rem] bg-[#5E5E5E3D] bg-blend-screen">
			<span className="font-medium text-[1.0625rem]">Inicio</span>
			<Divider />
			<button
				className="font-medium text-[1.0625rem] transition-all duration-500 hover:scale-105 active:scale-100"
				type="button"
				onClick={openMap}
			>
				Mapa
			</button>
			<Divider />
			<button
				className="font-medium text-[1.0625rem] transition-all duration-500 hover:scale-105 active:scale-100"
				type="button"
				onClick={() => {
					if (isEnvBrowser()) return window.open(links.shop, "_blank");
					(window as any).invokeNative("openUrl", links.shop);
				}}
			>
				Loja
			</button>
			<Divider />
			<button
				className="font-medium text-[1.0625rem] transition-all duration-500 hover:scale-105 active:scale-100"
				type="button"
				onClick={openConfig}
			>
				Configurações
			</button>
			<Divider />
			<button
				className="font-medium text-[1.0625rem] transition-all duration-500 hover:scale-105 active:scale-100"
				type="button"
				onClick={fetchHideFrame}
			>
				Sair
			</button>
		</header>
	);
}

function MapCard() {
	const openMap = useEscStore((s) => s.openMap);
	return (
		<button
			type="button"
			className="my-5 flex h-[38.6rem] w-[48.75rem] items-center justify-center rounded-[1.25rem] border border-white/25 border-solid"
			style={{
				background:
					"radial-gradient(65.86% 65.86% at 50% 50%, rgba(0, 0, 0, 0) 48.87%, rgba(0, 0, 0, 0.45) 83.85%)",
			}}
			onClick={openMap}
		>
			<div className="absolute flex items-center justify-center transition-all duration-500 hover:scale-105 active:scale-100">
				<MapPinIcon />
			</div>
			<img
				src={MapImage}
				className="size-full rounded-[1.25rem] object-cover object-center"
				alt=""
			/>
		</button>
	);
}

function MenuNav() {
	const { pathname } = useLocation();
	const navigate = useNavigate();
	const { openMisteryBoxs, openUltraBoost, openDailyReward, openWeaponSkins } =
		useEscStore(
			useShallow((s) => ({
				openMisteryBoxs: s.openMisteryBoxs,
				openUltraBoost: s.openUltraBoost,
				openDailyReward: s.openDailyReward,
				openWeaponSkins: s.openWeaponSkins,
			})),
		);
	return (
		<div className="flex h-[3.125rem] w-[48.75rem] items-center justify-center gap-[1.875rem] rounded-[.4375rem] bg-[#5E5E5E3D]">
			<button
				type="button"
				className={cn(
					"bg-transparent outline-none transition-all duration-500 [&:hover>svg>path]:fill-primaryColor/50",
					pathname.includes(routes.home) && "[&>svg>path]:fill-primaryColor",
				)}
				onClick={() => navigate(routes.home)}
			>
				<HomeNavIcon />
			</button>
			<div
				className="h-[1.4375rem] w-[.0625rem]"
				style={{
					background:
						"linear-gradient(180deg, rgba(217, 217, 217, 0) 0%, rgba(217, 217, 217, 0.3) 50%, rgba(217, 217, 217, 0) 100%)",
				}}
			/>
			<button
				type="button"
				className={cn(
					"bg-transparent outline-none transition-all duration-500 [&:hover>svg>path]:fill-primaryColor/50",
				)}
				onClick={openMisteryBoxs}
			>
				<BoxNavIcon />
			</button>
			<div
				className="h-[1.4375rem] w-[.0625rem]"
				style={{
					background:
						"linear-gradient(180deg, rgba(217, 217, 217, 0) 0%, rgba(217, 217, 217, 0.3) 50%, rgba(217, 217, 217, 0) 100%)",
				}}
			/>
			<button
				type="button"
				className={cn(
					"bg-transparent outline-none transition-all duration-500 [&:hover>svg>path]:fill-primaryColor/50",
					pathname.includes(routes.shop) && "[&>svg>path]:fill-primaryColor",
				)}
				onClick={() => navigate(routes.shop)}
			>
				<ShopNavIcon />
			</button>
			<div
				className="h-[1.4375rem] w-[.0625rem]"
				style={{
					background:
						"linear-gradient(180deg, rgba(217, 217, 217, 0) 0%, rgba(217, 217, 217, 0.3) 50%, rgba(217, 217, 217, 0) 100%)",
				}}
			/>
			<button
				type="button"
				className={cn(
					"bg-transparent outline-none transition-all duration-500 [&:hover>svg>path]:fill-primaryColor/50",
				)}
				onClick={openUltraBoost}
			>
				<UltraBoostNavIcon />
			</button>
			<div
				className="h-[1.4375rem] w-[.0625rem]"
				style={{
					background:
						"linear-gradient(180deg, rgba(217, 217, 217, 0) 0%, rgba(217, 217, 217, 0.3) 50%, rgba(217, 217, 217, 0) 100%)",
				}}
			/>
			<button
				type="button"
				className={cn(
					"bg-transparent outline-none transition-all duration-500 [&:hover>svg>path]:fill-primaryColor/50",
				)}
				onClick={openDailyReward}
			>
				<DailyRewardIcon />
			</button>
			<div
				className="h-[1.4375rem] w-[.0625rem]"
				style={{
					background:
						"linear-gradient(180deg, rgba(217, 217, 217, 0) 0%, rgba(217, 217, 217, 0.3) 50%, rgba(217, 217, 217, 0) 100%)",
				}}
			/>
			<button
				type="button"
				className={cn(
					"bg-transparent outline-none transition-all duration-500 [&:hover>svg>path]:fill-primaryColor/50",
				)}
				onClick={openWeaponSkins}
			>
				<WeaponSkinsNavIcon />
			</button>
		</div>
	);
}

function OtimizationCard() {
	const { otimization, toggleOtimization } = useEscStore(
		useShallow((s) => ({
			otimization: s.otimization,
			toggleOtimization: s.toggleOtimization,
		})),
	);
	return (
		<div
			className="flex h-[23.5rem] w-[14.375rem] flex-col items-center rounded-[1.25rem] border border-white/25 border-solid p-[0.875rem] px-[1.5625rem]"
			style={{
				background: `url(${OtimizationBackground})`,
				backgroundSize: "cover",
				backgroundRepeat: "no-repeat",
			}}
		>
			<WeaponSkinsCardIcon />
			<h1 className="mt-5 font-bold text-[1.4375rem]">Otimização</h1>
			<span className="mt-2 text-wrap text-center text-sm text-white/80">
				Ative o <span className="font-semibold">modo turbo</span> e otimize o
				seu jogo.
			</span>
			<div className="mt-auto flex w-full items-center justify-between font-bold text-[.9375rem]">
				{otimization ? "Ativado" : "Desativado"}
				<button
					type="button"
					className={cn(
						"relative h-[1.5rem] w-[3.3125rem] rounded-[.3125rem] border border-white/30 border-solid p-1 transition-all duration-500 hover:border-white/40 ",
						otimization &&
							"[&>.coloredBackground]:opacity-50 [&>.customBackground]:opacity-100",
					)}
					style={{
						background:
							"linear-gradient(180deg, rgba(255, 255, 255, 0) 1.34%, rgba(255, 255, 255, 0.08) 59.6%)",
					}}
					onClick={toggleOtimization}
				>
					<div
						className={cn(
							"absolute top-[.1875rem] left-[.1875rem] z-10 size-4 rounded-[.25rem] border border-white/5 border-solid bg-white/30 transition-all duration-500",
							otimization &&
								"-translate-x-[calc(100%+.1875rem)] left-[calc(100%)] border-white bg-white/70",
						)}
					/>
					<div
						className="customBackground absolute top-0 left-0 z-0 size-full rounded-[.3125rem] opacity-0 bg-blend-screen transition-all duration-500"
						style={{
							background:
								"linear-gradient(90deg, rgb(var(--primaryColor)) -37.37%, rgb(var(--secondaryColor)) 144.95%),radial-gradient(70.52% 166.67% at 71.91% -48.48%, rgb(var(--thirdyColor)) 33.32%, rgba(148, 146, 251, 0) 100%)",
						}}
					/>
				</button>
			</div>
		</div>
	);
}

function RankingCard() {
	return (
		<div
			className="relative flex h-[10.4375rem] w-[26.25rem] flex-col items-center justify-center overflow-hidden rounded-[.625rem] border border-[#FFAC26] border-solid bg-blend-multiply"
			style={{
				background:
					"linear-gradient(180deg, rgba(255, 255, 255, 0) 1.34%, rgba(255, 255, 255, 0.16) 59.6%),linear-gradient(0deg, rgba(221, 221, 221, 0.08), rgba(221, 221, 221, 0.08)),linear-gradient(0deg, rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)),linear-gradient(84.99deg, rgba(255, 172, 38, 0) 29.99%, rgba(255, 172, 38, 0.3) 101.25%),linear-gradient(244.93deg, rgba(255, 172, 38, 0) 69.34%, rgba(255, 172, 38, 0.2) 142.93%)",
			}}
		>
			<h1 className="relative z-10 mb-[.3125rem] font-semibold text-xl">
				Você está entre os melhores?
			</h1>
			<span className="relative z-10 mb-[2.375rem] text-[.8125rem]">
				Descubra sua posição e{" "}
				<span className="font-semibold">desafie os melhores.</span>
			</span>
			<button
				type="button"
				disabled
				className="relative z-10 flex h-[1.875rem] w-[9.75rem] cursor-not-allowed items-center justify-center rounded-[.1875rem] border border-white/20 border-solid bg-white/[.06] font-bold text-[.8125rem] text-white/50"
			>
				Em breve
			</button>
			<img
				src={TrophyGif}
				className="-translate-x-[52%] absolute left-full z-0 size-[19.4375rem] object-cover"
				alt="trophy gif"
			/>
		</div>
	);
}

function WeaponSkinsCard() {
	const openWeaponSkins = useEscStore((s) => s.openWeaponSkins);
	return (
		<div
			style={{
				background: `url(${SkinBackground})`,
				backgroundSize: "cover",
				backgroundRepeat: "no-repeat",
			}}
			className="flex h-[17.5rem] w-[26.25rem] flex-col justify-between rounded-[1.25rem] border border-white/25 border-solid p-[1.5625rem]"
		>
			<h1 className="font-bold text-2xl">Skins de Armas</h1>
			<button
				type="button"
				style={{
					background:
						"linear-gradient(90deg, #C8FF49 -37.37%, #A0CC3A 144.95%),radial-gradient(70.52% 166.67% at 71.91% -48.48%, #C8FF49 33.32%, rgba(200, 255, 73, 0) 100%)",
				}}
				className="flex h-[1.875rem] w-[14.375rem] items-center justify-center self-center rounded-[.25rem] border border-white/30 border-solid font-bold text-[#1d1d1d]/90 text-[.8125rem] bg-blend-screen transition-all duration-500 will-change-contents hover:scale-105 hover:text-[#1d1d1d] active:scale-100"
				onClick={openWeaponSkins}
			>
				Abrir skins de armas
			</button>
		</div>
	);
}

function Home() {
	return (
		<div className="flex h-full w-full justify-center">
			<div className="flex flex-col gap-[.9375rem]">
				<BattlePassCard />
				<OtimizationCard />
			</div>
			<div className="mr-5 ml-5 flex flex-col">
				<MenuHeader />
				<MapCard />
				<MenuNav />
			</div>
			<div className="flex flex-col">
				<WeaponSkinsCard />
				<MisteryBoxCard />
				<RankingCard />
			</div>
		</div>
	);
}

export { Home };
