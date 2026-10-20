import React, {
	useState,
	useEffect,
	useRef,
	useCallback,
	useMemo,
	useId,
} from "react";
import { fetchNui } from "@app/utils/fetchNui";
import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { useMainStore } from "@app/stores/MainStore";
import { useDataCache } from "@app/stores/DataCache";
import { RARITY_MAP } from "@app/stores/constants";
import { SearchIcon } from "@views/components/SearchIcon";
import { DiamondBadgeIcon } from "@views/components/icons/DiamondBadgeIcon";
import { DiamondIcon } from "@views/components/DiamondIcon";
import { SquareDecoration } from "@views/components/SquareDecoration";

import skinItemImage from "@views/assets/images/skin-item.png";
import tickSoundUrl from "@views/assets/sounds/tick.mp3";
import caseItemImage from "@views/assets/images/box.png";
import heroBannerImage from "@views/assets/images/banner.png";
import victorySoundUrl from "./assets/victory.mp3";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface CaseItem {
	id: string;
	name: string;
	price: number;
	originalPrice?: number;
	image: string;
	skinsCount?: number;
	badge?: "free" | "new";
	free?: boolean;
	availableIn?: number;
	cooldownSeconds?: number;
}

interface SkinItem {
	model_name: string;
	name: string;
	rarity: string;
	value: number;
	chance: number;
	image: string;
	durationDays?: number;
}

interface RouletteItem {
	id: number;
	name: string;
	rarity: string;
	chance: number;
	amount: number;
	image: string;
}

interface StripItem extends RouletteItem {}

interface LastWinItem {
	id?: string;
	name: string;
	player: string;
	image: string;
	rarity: string;
	source?: "improvement" | "case";
}

type RoulettePhase = "idle" | "spinning" | "result";

type SortOption = "Menor Preço" | "Maior Preço";

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const FONT = "Montserrat, sans-serif";

const SORT_OPTIONS: SortOption[] = ["Menor Preço", "Maior Preço"];

const ITEM_WIDTH = 227;
const STRIP_MULTIPLIER = 6;
const BASE_DURATION = 6000;
const MIN_FAST_FLOOR = 3000;
const MIN_FAST_DURATION = 4500;
const MAX_FAST_DURATION = 6500;
const REFERENCE_DISTANCE = 7200;
const DISTANCE_EXPONENT = 0.5;
const MAX_NORMAL_DURATION = 13500;
const DURATION_SCALE = 1.1;
const TICK_POOL_SIZE = 4;
const TICK_VOLUME = 0.15;

// Easing — single ease-out curve. Power 2.5 gives an instant burst at start
// (velocity = 2.5x average at t=0) and a long, continuous slowdown — the
// CSGO case opening feel.
const EASE_POWER = 2.5;
const HIGHLIGHT_START = 0.7;

const IDLE_ITEM_WIDTH = 226;

// ---------------------------------------------------------------------------
// WebAudio typings
// ---------------------------------------------------------------------------

declare global {
	interface Window {
		webkitAudioContext?: typeof AudioContext;
	}
}

// ---------------------------------------------------------------------------
// Utility functions
// ---------------------------------------------------------------------------

function easing(t: number): number {
	if (t >= 1) return 1;
	return 1 - (1 - t) ** EASE_POWER;
}

function formatCountdown(seconds: number): string {
	const h = Math.floor(seconds / 3600);
	const m = Math.floor((seconds % 3600) / 60);
	const s = seconds % 60;
	if (h > 0)
		return `${h}h ${String(m).padStart(2, "0")}m ${String(s).padStart(2, "0")}s`;
	if (m > 0) return `${m}m ${String(s).padStart(2, "0")}s`;
	return `${s}s`;
}

function getCaseCardBackground(badge?: string): string {
	if (badge === "free") {
		return "radial-gradient(86.16% 92.41% at 23.62% 1.53%, rgba(245, 189, 22, 0.16) 0%, rgba(245, 189, 22, 0.00) 86.08%), rgba(255, 255, 255, 0.03)";
	}
	if (badge === "new") {
		return "radial-gradient(64.13% 72.32% at 50.92% -0.76%, rgba(var(--primaryColor), 0.16) 0%, rgba(var(--primaryColor), 0.00) 86.08%), rgba(255, 255, 255, 0.03)";
	}
	return "radial-gradient(67.61% 67.66% at 53.67% -159.35%, rgba(255, 255, 255, 0.11) 0%, rgba(153, 153, 153, 0.00) 86.08%), rgba(255, 255, 255, 0.03)";
}

function shuffleByRarity<T extends { rarity: string }>(items: T[]): number[] {
	const count = items.length;
	if (count === 0) return [];

	const groups = new Map<string, number[]>();
	for (let i = 0; i < count; i++) {
		const r = items[i].rarity;
		const arr = groups.get(r) ?? [];
		arr.push(i);
		groups.set(r, arr);
	}

	for (const indices of groups.values()) {
		for (let i = indices.length - 1; i > 0; i--) {
			const j = Math.floor(Math.random() * (i + 1));
			[indices[i], indices[j]] = [indices[j], indices[i]];
		}
	}

	const keys = [...groups.keys()];
	for (let i = keys.length - 1; i > 0; i--) {
		const j = Math.floor(Math.random() * (i + 1));
		[keys[i], keys[j]] = [keys[j], keys[i]];
	}

	const orderedGroups = keys.map((k) => groups.get(k)!);
	const result: number[] = [];
	let remaining = count;

	while (remaining > 0) {
		for (const group of orderedGroups) {
			if (group.length) {
				result.push(group.pop()!);
				remaining--;
			}
		}
	}

	return result;
}

function buildStrip(
	items: RouletteItem[],
	winnerIndex: number,
): { stripItems: StripItem[]; winnerSlot: number } {
	const count = items.length;
	const totalSlots = count * STRIP_MULTIPLIER;
	const winnerSlot = Math.floor(totalSlots * 0.72);

	const shuffledIndices = shuffleByRarity(items);
	const strip: StripItem[] = [];

	for (let i = 0; i < totalSlots; i++) {
		const idx = shuffledIndices[i % count];
		strip.push({ ...items[idx], id: i + 1 });
	}

	strip[winnerSlot] = { ...items[winnerIndex], id: winnerSlot + 1 };

	return { stripItems: strip, winnerSlot };
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

const MOCK_CASES: CaseItem[] = [
	{ id: "diaria", name: "Caixa Diária", price: 0, image: caseItemImage, skinsCount: 30, badge: "free", free: true, availableIn: 0, cooldownSeconds: 86400 },
	{ id: "padrao", name: "Caixa Padrão", price: 100, image: caseItemImage, skinsCount: 71, badge: "new" },
	{ id: "pistola", name: "Caixa Pistola", price: 150, image: caseItemImage, skinsCount: 18, badge: "new" },
	{ id: "rifle", name: "Caixa Rifle", price: 200, image: caseItemImage, skinsCount: 44, badge: "new" },
	{ id: "sniper", name: "Caixa Sniper", price: 200, image: caseItemImage, skinsCount: 9, badge: "new" },
	{ id: "premium", name: "Caixa Premium", price: 500, image: caseItemImage, skinsCount: 71, badge: "new" },
	{ id: "suprema", name: "Caixa Suprema", price: 1000, image: caseItemImage, skinsCount: 40, badge: "new" },
];

const MOCK_LAST_WINS: LastWinItem[] = [
	{ name: "SIG BLUE", player: "Bieu do Grau #114245", image: skinItemImage, rarity: "comum" },
	{ name: "SIG BLUE", player: "Bieu do Grau #114245", image: skinItemImage, rarity: "raro" },
	{ name: "SIG BLUE", player: "Bieu do Grau #114245", image: skinItemImage, rarity: "epico" },
	{ name: "SIG BLUE", player: "Bieu do Grau #114245", image: skinItemImage, rarity: "lendario" },
	{ name: "SIG BLUE", player: "Bieu do Grau #114245", image: skinItemImage, rarity: "comum" },
	{ name: "SIG BLUE", player: "Bieu do Grau #114245", image: skinItemImage, rarity: "raro" },
	{ name: "SIG BLUE", player: "Bieu do Grau #114245", image: skinItemImage, rarity: "epico" },
	{ name: "SIG BLUE", player: "Bieu do Grau #114245", image: skinItemImage, rarity: "lendario" },
	{ name: "SIG BLUE", player: "Bieu do Grau #114245", image: skinItemImage, rarity: "comum" },
	{ name: "SIG BLUE", player: "Bieu do Grau #114245", image: skinItemImage, rarity: "raro" },
];

// ---------------------------------------------------------------------------
// Small icon / badge components
// ---------------------------------------------------------------------------

function FreeBadge() {
	return (
		<div
			className="absolute left-[19px] top-[-12px] z-10 flex h-[26px] items-center justify-center rounded-[4px] p-[3px] transition-transform duration-300 group-hover:rotate-[-6deg]"
			style={{ border: "0.7px solid #F5BD16" }}
		>
			<div
				className="flex items-center justify-center gap-[5px] self-stretch rounded-[3px] px-[6px]"
				style={{
					border: "0.7px solid #F5BD16",
					background:
						"linear-gradient(135deg, #F5BD16 -47.65%, rgba(245, 189, 22, 0.90) 122.65%)",
				}}
			>
				<svg width="15" height="15" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg">
					<g clipPath="url(#clip0_gratis)">
						<path d="M7.875 0L1.5 3.75V11.25L7.875 15L14.25 11.25V3.75L7.875 0ZM13.4003 10.752L7.875 14.0025L2.34975 10.7513V4.2525L7.875 1.002L13.4003 4.25325V10.752Z" fill="black" />
						<path d="M10.5 5.8785L9.97125 5.25L7.233 8.505L5.77875 6.765L5.25 7.3935L7.233 9.75L10.5 5.8785Z" fill="black" />
					</g>
					<defs>
						<clipPath id="clip0_gratis">
							<rect width="15" height="15" fill="white" />
						</clipPath>
					</defs>
				</svg>
				<span
					className="text-center font-bold text-[12px] uppercase tracking-[-0.48px] text-[#0C0C0C]"
					style={{ fontFamily: FONT }}
				>
					GRÁTIS
				</span>
			</div>
		</div>
	);
}

function NewBadge() {
	return (
		<div
			className="absolute left-1/2 -translate-x-1/2 top-[-12px] z-10 flex h-[24px] items-center justify-center rounded-[4px] p-[3px] transition-transform duration-300 group-hover:rotate-[-6deg]"
			style={{ border: "0.7px solid rgb(var(--primaryColor))" }}
		>
			<div
				className="flex items-center justify-center gap-[3px] self-stretch rounded-[3px] px-[8px]"
				style={{
					border: "0.7px solid rgba(var(--primaryColor), 0.60)",
					background:
						"linear-gradient(135deg, rgb(var(--primaryColor)) -47.65%, rgba(var(--primaryColor), 0.50) 122.65%)",
				}}
			>
				<span
					className="text-center font-bold text-[11px] uppercase tracking-[-0.44px] text-white"
					style={{ fontFamily: FONT }}
				>
					NOVO
				</span>
			</div>
		</div>
	);
}

function PrimaryDot() {
	return (
		<div
			className="h-[4px] w-[4px] rounded-full bg-primaryColor"
			style={{
				filter:
					"drop-shadow(0 0 4px rgb(var(--primaryColor))) drop-shadow(0 0 10px rgb(var(--primaryColor)))",
			}}
		/>
	);
}

function ChevronDownIcon() {
	return (
		<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 12 12" fill="none">
			<path
				d="M5.72853 7.96497L1.74603 3.78522C1.67954 3.71548 1.64246 3.62283 1.64246 3.52647C1.64246 3.43012 1.67954 3.33747 1.74603 3.26772L1.75053 3.26322C1.78276 3.2293 1.82155 3.20228 1.86455 3.18382C1.90755 3.16536 1.95386 3.15584 2.00065 3.15584C2.04745 3.15584 2.09375 3.16536 2.13675 3.18382C2.17975 3.20228 2.21855 3.2293 2.25078 3.26322L6.00078 7.19922L9.74928 3.26322C9.78151 3.2293 9.8203 3.20228 9.8633 3.18382C9.9063 3.16536 9.95261 3.15584 9.9994 3.15584C10.0462 3.15584 10.0925 3.16536 10.1355 3.18382C10.1785 3.20228 10.2173 3.2293 10.2495 3.26322L10.254 3.26772C10.3205 3.33747 10.3576 3.43012 10.3576 3.52647C10.3576 3.62283 10.3205 3.71548 10.254 3.78522L6.27153 7.96497C6.2365 8.00173 6.19438 8.031 6.14771 8.05099C6.10104 8.07099 6.0508 8.0813 6.00003 8.0813C5.94925 8.0813 5.89901 8.07099 5.85234 8.05099C5.80567 8.031 5.76355 8.00173 5.72853 7.96497Z"
				fill="#CCCCCC"
			/>
		</svg>
	);
}

function CatalogIcon() {
	const id = useId();
	const color = "rgb(var(--primaryColor))";

	return (
		<svg
			width="73"
			height="73"
			viewBox="0 0 73 73"
			fill="none"
			xmlns="http://www.w3.org/2000/svg"
			style={{
				filter:
					"drop-shadow(0 0 3px rgba(var(--primaryColor), 0.3)) drop-shadow(0 0 11px rgba(var(--primaryColor), 0.9))",
			}}
		>
			<path
				d="M31.6815 13.5809C34.1223 11.1402 38.0787 11.1402 40.5194 13.5809L58.62 31.6815C61.0608 34.1223 61.0608 38.0786 58.62 40.5194L40.5194 58.62C38.0787 61.0607 34.1223 61.0607 31.6815 58.62L13.581 40.5194C11.1402 38.0786 11.1402 34.1223 13.581 31.6815L31.6815 13.5809Z"
				stroke={color}
				strokeWidth="1.5"
				shapeRendering="crispEdges"
			/>
			<g filter={`url(#filter1_${id})`}>
				<path
					d="M33.2721 15.9289C34.8342 14.3668 37.3668 14.3668 38.9289 15.9289L56.2721 33.272C57.8342 34.8341 57.8342 37.3668 56.2721 38.9289L38.9289 56.272C37.3668 57.8341 34.8342 57.8341 33.2721 56.272L15.9289 38.9289C14.3668 37.3668 14.3668 34.8341 15.9289 33.272L33.2721 15.9289Z"
					fill={`url(#paint0_${id})`}
					fillOpacity="0.7"
					shapeRendering="crispEdges"
				/>
				<path
					d="M33.2721 15.9289C34.8342 14.3668 37.3668 14.3668 38.9289 15.9289L56.2721 33.272C57.8342 34.8341 57.8342 37.3668 56.2721 38.9289L38.9289 56.272C37.3668 57.8341 34.8342 57.8341 33.2721 56.272L15.9289 38.9289C14.3668 37.3668 14.3668 34.8341 15.9289 33.272L33.2721 15.9289Z"
					fill={`url(#paint1_${id})`}
					shapeRendering="crispEdges"
				/>
				<path
					d="M33.5194 16.1766C34.9449 14.7512 37.2561 14.7512 38.6815 16.1766L56.0243 33.5194C57.4497 34.9448 57.4497 37.2561 56.0243 38.6815L38.6815 56.0243C37.2561 57.4497 34.9449 57.4497 33.5194 56.0243L16.1767 38.6815C14.7513 37.2561 14.7513 34.9448 16.1767 33.5194L33.5194 16.1766Z"
					stroke={color}
					strokeOpacity="0.6"
					strokeWidth="0.7"
					shapeRendering="crispEdges"
				/>
			</g>
			<g clipPath={`url(#clip0_${id})`}>
				<path
					d="M27.694 39.0242C27.694 37.7303 27.6886 36.4364 27.6993 35.1478C27.6993 34.9539 27.6407 34.8649 27.4488 34.8282C27.241 34.7863 27.0385 34.7235 26.836 34.6606C26.367 34.5192 26.1059 34.1682 26.1006 33.6863C26.0953 32.8481 26.0953 32.01 26.1006 31.1719C26.1006 30.6637 26.3777 30.318 26.8786 30.1818C27.9125 29.8989 28.9357 29.6161 29.9642 29.3542C30.2093 29.2913 30.2839 29.1813 30.2999 28.9508C30.3425 28.3746 30.4171 27.8036 30.4598 27.2274C30.5237 26.3369 31.451 25.7659 32.3036 26.3159C33.0817 26.8188 33.9023 27.2536 34.7017 27.725C34.8562 27.8141 34.9948 27.8246 35.1707 27.8088C35.6023 27.7722 36.0393 27.7827 36.4763 27.7879C36.8387 27.7931 37.201 27.8298 37.5634 27.835C37.6434 27.835 37.734 27.7931 37.8032 27.7512C38.6399 27.2693 39.4819 26.8083 40.2972 26.295C41.1073 25.7816 42.0239 26.3212 42.0985 27.2117C42.1571 27.8717 42.221 28.5317 42.301 29.1918C42.3116 29.2756 42.4075 29.3908 42.4875 29.417C43.3028 29.6632 44.1182 29.8937 44.9389 30.1294C44.9655 30.1347 44.9921 30.1451 45.0188 30.1451C45.8555 30.2656 46.0953 30.5328 46.0953 31.3657C46.0953 32.1252 46.0953 32.8848 46.0953 33.6444C46.0953 34.1734 45.8341 34.5087 45.3172 34.6658C45.0561 34.7444 44.6884 34.7549 44.5605 34.9278C44.4219 35.1163 44.5019 35.4621 44.5019 35.7397C44.5019 38.0917 44.5019 40.4385 44.5019 42.7905C44.5019 43.4034 44.2781 43.7073 43.6865 43.8854C41.3524 44.5925 39.0183 45.2945 36.6895 46.0016C36.3058 46.1169 35.9221 46.1221 35.5384 46.0069C33.1723 45.2945 30.8062 44.5768 28.4347 43.8592C27.9444 43.7125 27.694 43.372 27.694 42.8639C27.694 41.591 27.694 40.3076 27.694 39.0242ZM43.4787 35.2001C43.3934 35.2159 43.3295 35.2263 43.2762 35.2421C41.0913 35.8497 38.9063 36.4574 36.7161 37.0546C36.5243 37.1069 36.5189 37.2065 36.5189 37.3584C36.5243 38.757 36.5189 40.1504 36.5189 41.5491C36.5189 41.9629 36.3484 42.1619 36.002 42.1567C35.6663 42.1515 35.4957 41.9576 35.4957 41.5595C35.4957 40.9205 35.4957 40.2866 35.4957 39.6475C35.4957 38.7937 35.4957 37.9398 35.4957 37.0598C33.2469 36.4364 31.0033 35.813 28.7331 35.1844C28.7331 35.3049 28.7331 35.3887 28.7331 35.4725C28.7331 37.856 28.7385 40.2395 28.7278 42.6229C28.7278 42.8482 28.8078 42.9163 29.0049 42.9791C31.2485 43.6496 33.4813 44.3359 35.7249 44.9959C35.954 45.064 36.2418 45.0692 36.471 45.0011C38.7252 44.3359 40.9687 43.6496 43.2176 42.9791C43.4201 42.9163 43.4893 42.8377 43.4893 42.6229C43.4787 40.2395 43.484 37.856 43.484 35.4725C43.4787 35.3887 43.4787 35.2997 43.4787 35.2001ZM45.0508 31.1928C44.9282 31.2242 44.8269 31.2504 44.7257 31.2766C42.0292 32.0362 39.338 32.801 36.6468 33.5658C36.2951 33.6653 35.954 33.6758 35.597 33.5763C33.1829 32.89 30.7742 32.2091 28.3601 31.5281C27.9604 31.4128 27.5608 31.3081 27.1291 31.1876C27.1291 31.3028 27.1291 31.3919 27.1291 31.4757C27.1291 32.12 27.1398 32.7696 27.1238 33.4139C27.1184 33.6286 27.1824 33.7125 27.3955 33.7701C29.9109 34.4563 32.4262 35.132 34.9255 35.8654C35.7355 36.1064 36.471 36.1012 37.2757 35.8654C39.775 35.132 42.2903 34.4563 44.8056 33.7701C44.9975 33.7177 45.0774 33.6444 45.0721 33.4348C45.0561 32.7696 45.0668 32.1095 45.0668 31.4443C45.0668 31.3657 45.0561 31.2923 45.0508 31.1928ZM29.0369 30.6533C29.2181 30.7109 29.3193 30.7423 29.4206 30.7737C31.5096 31.3657 33.5986 31.9524 35.6823 32.5548C35.9647 32.6386 36.2312 32.6386 36.5136 32.5548C38.5973 31.9576 40.6916 31.3657 42.7753 30.7737C42.8605 30.7476 42.9458 30.7161 43.1003 30.6637C42.7806 30.5747 42.5461 30.4961 42.3063 30.4437C42.2423 30.428 42.1464 30.4542 42.1038 30.4961C41.864 30.7266 41.5815 30.7947 41.2565 30.7947C37.9205 30.7895 34.5791 30.7895 31.2431 30.7947C30.8967 30.7947 30.625 30.6795 30.4011 30.4228C30.3585 30.3756 30.2519 30.339 30.188 30.3494C29.8256 30.4333 29.4686 30.538 29.0369 30.6533ZM38.2882 29.768C39.322 29.768 40.3026 29.768 41.3151 29.768C41.2085 28.8722 41.1819 27.9869 41.022 27.0702C40.0947 27.6098 39.2421 28.1022 38.3894 28.6051C38.3415 28.6313 38.2935 28.6941 38.2882 28.7413C38.2828 29.0765 38.2882 29.417 38.2882 29.768ZM31.2538 29.768C32.2716 29.768 33.2575 29.768 34.2754 29.768C34.2754 29.4484 34.286 29.1446 34.2701 28.846C34.2647 28.7465 34.1901 28.6208 34.1102 28.5684C33.3854 28.1336 32.65 27.7093 31.9199 27.285C31.8187 27.2221 31.7121 27.1698 31.5256 27.0702C31.4297 27.9974 31.3444 28.8722 31.2538 29.768ZM35.3252 29.7627C35.9807 29.7627 36.6095 29.7627 37.233 29.7627C37.233 29.438 37.233 29.1289 37.233 28.8198C36.5882 28.8198 35.9594 28.8198 35.3252 28.8198C35.3252 29.1446 35.3252 29.4432 35.3252 29.7627Z"
					fill="white"
				/>
			</g>
			<defs>
				<filter
					id={`filter1_${id}`}
					x="3.35736"
					y="3.35732"
					width="65.4863"
					height="65.4863"
					filterUnits="userSpaceOnUse"
					colorInterpolationFilters="sRGB"
				>
					<feFlood floodOpacity="0" result="BackgroundImageFix" />
					<feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha" />
					<feOffset />
					<feGaussianBlur stdDeviation="5.7" />
					<feComposite in2="hardAlpha" operator="out" />
					<feColorMatrix type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.3 0" />
					<feBlend mode="normal" in2="BackgroundImageFix" result="effect1" />
					<feBlend mode="normal" in="SourceGraphic" in2="effect1" result="shape" />
				</filter>
				<linearGradient id={`paint0_${id}`} x1="36.1005" y1="13.1005" x2="36.1005" y2="59.1005" gradientUnits="userSpaceOnUse">
					<stop stopColor="#363636" />
					<stop offset="1" stopColor="#1D1D1D" />
				</linearGradient>
				<linearGradient id={`paint1_${id}`} x1="37.3783" y1="-6.0662" x2="86.5727" y2="61.0171" gradientUnits="userSpaceOnUse">
					<stop stopColor={color} />
					<stop offset="0.7" stopColor={color} stopOpacity="0" />
				</linearGradient>
				<clipPath id={`clip0_${id}`}>
					<rect width="20" height="20" fill="white" transform="translate(26.1005 26.1005)" />
				</clipPath>
			</defs>
		</svg>
	);
}

function BoxIcon({ color }: { color: string }) {
	return (
		<svg width="17" height="15" viewBox="0 0 17 15" fill="none" xmlns="http://www.w3.org/2000/svg">
			<path
				d="M15.2858 6.12411V12.4899C15.2857 12.5864 15.254 12.68 15.1959 12.7548C15.1378 12.8296 15.057 12.8811 14.9669 12.9006L8.4667 14.9791C8.4167 14.9979 8.36321 15.0041 8.3105 14.9973C8.2578 14.9905 8.20735 14.9708 8.16319 14.9398L2.15263 11.9962C2.08445 11.9637 2.02657 11.9114 1.98588 11.8454C1.9452 11.7794 1.9234 11.7025 1.92309 11.6239V4.77327L0.0527542 1.40109C-0.0594657 1.20645 0.0153476 0.951105 0.201531 0.834146C0.25494 0.797929 0.316588 0.777344 0.380107 0.774519C0.443626 0.771694 0.506711 0.78673 0.562845 0.818075L6.44164 3.56171L7.72791 3.30637L9.05075 0.251133C9.12556 0.0564983 9.35425 -0.0434976 9.53959 0.0181071L16.7047 2.10731C16.9121 2.16802 17.0447 2.40105 16.9861 2.618C16.9861 2.65639 16.9648 2.67871 16.9495 2.718L15.2858 6.12411ZM8.5194 6.90712L13.3032 5.92948L7.97276 4.10812L7.19572 4.26258L8.5194 6.90712ZM14.4722 6.53481L8.70559 7.7294V14.0345L14.4722 12.1739V6.53481ZM9.63565 0.912714L8.54066 3.41886L14.6634 5.51253L16.0033 2.77425L9.63565 0.912714ZM7.89794 7.65173L2.73668 5.30182V11.373L7.89709 13.9015L7.89794 7.65173ZM1.37559 2.10731L2.60406 4.32418L7.40316 6.51874L6.38298 4.46257L1.37559 2.10731Z"
				fill={color}
			/>
		</svg>
	);
}

function StarIcon({ color }: { color: string }) {
	return (
		<svg width="17" height="17" viewBox="0 0 17 17" fill="none" xmlns="http://www.w3.org/2000/svg">
			<path
				d="M8.5 1L10.85 5.8L16 6.55L12.25 10.2L13.2 15.35L8.5 12.85L3.8 15.35L4.75 10.2L1 6.55L6.15 5.8L8.5 1Z"
				fill={color}
			/>
		</svg>
	);
}

function PlayerIcon() {
	return (
		<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 15 15" fill="none">
			<path
				d="M7.49235 12.9991C6.43311 13.0003 5.37358 13.0003 4.31378 12.9991C3.67368 12.9974 3.16598 12.6144 3.03611 12.0304C2.96021 11.6896 3.01418 11.3532 3.10358 11.0204C3.45525 9.69068 4.65365 8.76587 6.06541 8.74654C7.03442 8.73425 8.00511 8.73161 8.97411 8.74654C10.5335 8.76938 11.8347 9.95768 11.9865 11.4648C12.0253 11.8424 11.9908 12.1999 11.742 12.5117C11.6285 12.662 11.4838 12.7835 11.3188 12.8672C11.1537 12.9509 10.9726 12.9945 10.789 12.9947C9.69011 13.0035 8.5887 12.9974 7.49067 12.9974C7.49179 12.9974 7.49235 12.998 7.49235 12.9991ZM7.50585 12.3246H10.6954C11.0757 12.3246 11.3195 12.0875 11.3077 11.7168C11.3036 11.566 11.2853 11.416 11.2528 11.2689C11.0024 10.1772 10.0595 9.42545 8.90665 9.41578C7.97053 9.40437 7.03442 9.41315 6.09577 9.41578C5.98726 9.41696 5.87987 9.42427 5.77361 9.43774C4.64015 9.57826 3.73862 10.5567 3.69561 11.6703C3.68043 12.0655 3.95536 12.3351 4.35089 12.3308C5.4017 12.3158 6.45335 12.3246 7.50585 12.3246ZM4.84762 5.57512C4.85099 4.15232 6.04686 2.99301 7.50838 3.00003C8.97243 3.00618 10.1556 4.15408 10.1573 5.57336C10.1599 6.9944 8.96821 8.15459 7.50416 8.15459C6.04011 8.15635 4.8493 6.99615 4.8493 5.57512M7.50079 3.67279C6.41962 3.67454 5.54169 4.53085 5.54422 5.57863C5.54591 6.62816 6.42636 7.48447 7.505 7.48447C8.5887 7.48447 9.47337 6.62377 9.46831 5.57072C9.46241 4.52031 8.5828 3.67103 7.50079 3.67279Z"
				fill="#7A7A7A"
			/>
		</svg>
	);
}

function SideBorder({ side }: { side: "left" | "right" }) {
	return (
		<div
			className={`pointer-events-none absolute inset-y-0 z-20 flex items-center ${
				side === "left" ? "-left-[40px]" : "-right-[40px] scale-x-[-1]"
			}`}
		>
			<svg
				width="11"
				height="100%"
				viewBox="0 0 11 144"
				preserveAspectRatio="none"
				fill="none"
				xmlns="http://www.w3.org/2000/svg"
			>
				<rect width="1" height="124" transform="translate(0.307114 9.7995)" fill="rgb(var(--primaryColor))" />
				<rect x="0.0071106" y="9.89948" width="14" height="1.00001" transform="rotate(-45 0.0071106 9.89948)" fill="rgb(var(--primaryColor))" />
				<rect x="0.707108" y="133" width="14" height="1.00001" transform="rotate(45 0.707108 133)" fill="rgb(var(--primaryColor))" />
			</svg>
		</div>
	);
}

// ---------------------------------------------------------------------------
// CaseCard
// ---------------------------------------------------------------------------

function CaseCard({ item, onClick }: { item: CaseItem; onClick?: () => void }) {
	const [countdown, setCountdown] = useState(item.availableIn ?? 0);

	useEffect(() => {
		setCountdown(item.availableIn ?? 0);
	}, [item.availableIn]);

	useEffect(() => {
		if (!item.free || countdown <= 0) return;
		const timer = setInterval(() => {
			setCountdown((prev) => {
				if (prev <= 1) {
					clearInterval(timer);
					return 0;
				}
				return prev - 1;
			});
		}, 1000);
		return () => clearInterval(timer);
	}, [item.free, countdown > 0]);

	const isLocked = item.free && countdown > 0;

	return (
		<div
			className={`group relative flex items-center justify-center rounded-[10px] border-[0.7px] border-white/[.14] p-[4px] transition-colors ${
				isLocked
					? "cursor-not-allowed opacity-60"
					: "cursor-pointer hover:border-primaryColor"
			}`}
			onClick={isLocked ? undefined : onClick}
		>
			{item.badge === "new" && <NewBadge />}
			{item.badge === "free" && <FreeBadge />}

			<div
				className="relative flex flex-1 flex-col items-center self-stretch overflow-hidden rounded-[7px]"
				style={{ background: getCaseCardBackground(item.badge) }}
			>
				<div className="relative flex h-[140px] items-end justify-center self-stretch mt-[16px]">
					<SquareDecoration className="absolute inset-[-15%] h-[130%] w-[130%]" />
					<img
						src={item.image}
						alt={item.name}
						className="relative z-10 w-[65%] object-contain transition-transform group-hover:scale-105"
					/>
				</div>

				<div className="flex flex-col items-start justify-center gap-[5px] self-stretch p-[16px]">
					<span
						className="self-stretch font-semibold text-[19px] tracking-[-0.76px] text-[#F2F2F2] truncate"
						style={{ fontFamily: FONT }}
					>
						{item.name}
					</span>

					{isLocked ? (
						<span
							className="text-center font-normal text-[14px] tracking-[-0.56px] text-[#F5BD16]"
							style={{ fontFamily: FONT }}
						>
							{formatCountdown(countdown)}
						</span>
					) : item.free ? (
						<span
							className="text-center font-semibold text-[14px] tracking-[-0.56px] text-[#F5BD16]"
							style={{ fontFamily: FONT }}
						>
							DISPONÍVEL
						</span>
					) : (
						<div className="flex items-center gap-[6px]">
							{item.originalPrice ? (
								<>
									<div className="flex items-center gap-[4px] opacity-50 line-through">
										<DiamondBadgeIcon />
										<span
											className="font-normal text-[14px] tracking-[-0.56px] text-[#ADADAD]"
											style={{ fontFamily: FONT }}
										>
											{item.originalPrice.toLocaleString("pt-BR")}
										</span>
									</div>
									<span
										className="text-center font-normal text-[15px] tracking-[-0.6px] text-[#ADADAD]"
										style={{ fontFamily: FONT }}
									>
										{item.price.toLocaleString("pt-BR")}
									</span>
								</>
							) : (
								<>
									<DiamondBadgeIcon />
									<span
										className="text-center font-normal text-[15px] tracking-[-0.6px] text-[#ADADAD]"
										style={{ fontFamily: FONT }}
									>
										{item.price.toLocaleString("pt-BR")}
									</span>
								</>
							)}
						</div>
					)}
				</div>
			</div>
		</div>
	);
}

// ---------------------------------------------------------------------------
// SortDropdown
// ---------------------------------------------------------------------------

function SortDropdown({
	value,
	onChange,
}: {
	value: SortOption;
	onChange: (v: SortOption) => void;
}) {
	const [open, setOpen] = useState(false);
	const ref = useRef<HTMLDivElement>(null);

	useEffect(() => {
		if (!open) return;
		const handler = (e: MouseEvent) => {
			if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
		};
		document.addEventListener("mousedown", handler);
		return () => document.removeEventListener("mousedown", handler);
	}, [open]);

	return (
		<div className="relative" ref={ref}>
			<button
				type="button"
				className="h-[34px] w-[190px] cursor-pointer rounded-[6px] border-[0.7px] border-white/[.16] p-[2px] transition-colors hover:border-white/[.25]"
				onClick={() => setOpen(!open)}
			>
				<div
					className="flex h-full items-center justify-center gap-[3px] self-stretch rounded-[4px] border-[0.7px] border-white/[.06] px-[8px] transition-colors hover:bg-white/[.12]"
					style={{ background: "rgba(255, 255, 255, 0.08)" }}
				>
					<span
						className="flex-1 text-left font-medium text-[12px] tracking-[-0.48px] text-[#F2F2F2]/80"
						style={{ fontFamily: FONT }}
					>
						{value}
					</span>
					<ChevronDownIcon />
				</div>
			</button>

			{open && (
				<div
					className="absolute left-0 top-[calc(100%+4px)] z-50 flex w-full flex-col items-start gap-[2px] self-stretch rounded-[7px] border-[0.7px] border-white/10 p-[3px]"
					style={{
						background: "rgba(8, 8, 8, 0.90)",
						boxShadow: "0 0 10px 0 rgba(0, 0, 0, 0.20)",
					}}
				>
					<div className="flex flex-col items-start gap-[2px] self-stretch">
						{SORT_OPTIONS.map((option) => {
							const isActive = option === value;
							return (
								<button
									key={option}
									type="button"
									className={`flex h-[30px] cursor-pointer items-start gap-[8px] self-stretch rounded-[5px] px-[8px] py-[8px] pl-[11px] transition-colors hover:bg-white/[.10] ${
										isActive ? "border-[0.8px] border-[#595B5E]/30" : ""
									}`}
									style={
										isActive
											? { background: "rgba(255, 255, 255, 0.13)" }
											: undefined
									}
									onClick={() => {
										onChange(option);
										setOpen(false);
									}}
								>
									<span
										className={`font-medium text-[12px] tracking-[-0.48px] ${
											isActive ? "text-[#F2F2F2]" : "text-[#BFBFBF]"
										}`}
										style={{
											fontFamily: FONT,
											textShadow: "0 0 10px rgba(0, 0, 0, 0.20)",
										}}
									>
										{option}
									</span>
								</button>
							);
						})}
					</div>
				</div>
			)}
		</div>
	);
}

// ---------------------------------------------------------------------------
// GemsFilterCheckbox
// ---------------------------------------------------------------------------

function GemsFilterCheckbox({
	active,
	onChange,
}: {
	active: boolean;
	onChange: (v: boolean) => void;
}) {
	return (
		<button
			type="button"
			className="flex cursor-pointer items-center gap-[12px] self-stretch"
			onClick={() => onChange(!active)}
		>
			<div
				className="flex h-[20px] w-[20px] items-center justify-center gap-[10px] rounded-[5px] border-[0.8px] p-[3px]"
				style={{ borderColor: "rgb(var(--primaryColor))" }}
			>
				<div
					className="h-[12px] w-[12px] shrink-0 rounded-[3px] transition-opacity"
					style={{
						background: active ? "rgb(var(--primaryColor))" : "transparent",
						opacity: active ? 1 : 0,
					}}
				/>
			</div>
			<span
				className="font-medium text-[15px] tracking-[-0.6px] text-[#F2F2F2]"
				style={{ fontFamily: FONT }}
			>
				SkinCoins suficientes
			</span>
		</button>
	);
}

// ---------------------------------------------------------------------------
// CaseCatalogHeader
// ---------------------------------------------------------------------------

function CaseCatalogHeader({
	sort,
	onSortChange,
	search,
	onSearchChange,
	skinsCoinsFilter,
	onSkinsCoinsFilterChange,
}: {
	sort: SortOption;
	onSortChange: (v: SortOption) => void;
	search: string;
	onSearchChange: (v: string) => void;
	skinsCoinsFilter: boolean;
	onSkinsCoinsFilterChange: (v: boolean) => void;
}) {
	return (
		<div className="mt-[16px] flex items-center gap-[12px] self-stretch">
			<div className="flex items-center gap-[4px]">
				<CatalogIcon />
				<span
					className="font-semibold text-[19px] tracking-[-0.95px] text-white"
					style={{
						fontFamily: FONT,
						textShadow: "0 0 18px rgba(255, 255, 255, 0.35)",
					}}
				>
					Catálogo
				</span>
			</div>

			<div className="ml-auto flex items-center gap-[16px]">
				<div className="flex items-center gap-[8px]">
					<span
						className="font-medium text-[13px] tracking-[-0.52px] text-[#BFBFBF]/80"
						style={{ fontFamily: FONT }}
					>
						Ordenar por:
					</span>
					<SortDropdown value={sort} onChange={onSortChange} />
				</div>

				<div className="h-[34px] w-[300px] rounded-[6px] border-[0.7px] border-white/[.16] p-[2px] transition-colors hover:border-white/[.25]">
					<div className="flex h-full items-center gap-[8px] rounded-[4px] border-[0.7px] border-white/[.06] bg-[#080808]/[.38] px-[8px] transition-colors hover:bg-[#080808]/[.50]">
						<input
							type="text"
							value={search}
							onChange={(e) => onSearchChange(e.target.value)}
							placeholder="Pesquisar item..."
							className="flex-1 bg-transparent text-[12px] tracking-[-0.48px] text-[#ADADAD] placeholder-[#ADADAD] outline-none"
							style={{ fontFamily: FONT }}
						/>
						<SearchIcon />
					</div>
				</div>

				<GemsFilterCheckbox active={skinsCoinsFilter} onChange={onSkinsCoinsFilterChange} />
			</div>
		</div>
	);
}

// ---------------------------------------------------------------------------
// Roulette strip item
// ---------------------------------------------------------------------------

function RouletteStripItem({ item }: { item: RouletteItem }) {
	const rarityData = RARITY_MAP[item.rarity] || RARITY_MAP.comum;
	const color = `rgb(${rarityData.rgb})`;

	return (
		<div
			className="flex h-[240px] w-[226px] shrink-0 flex-col items-center"
			style={{
				background: `linear-gradient(180deg, rgba(${rarityData.rgb}, 0.32) -17.86%, rgba(${rarityData.rgb}, 0) 53.57%), rgba(12, 12, 12, 0.24)`,
				boxShadow: `inset 0 -2px 0 0 rgba(0, 0, 0, 0.6), inset 0 -2px 0 0 ${color}`,
			}}
		>
			<div className="h-[1px] w-full self-stretch" style={{ background: color }} />
			<div className="flex items-center justify-end self-stretch p-[8px]">
				<span
					className="text-right font-medium text-[14px] tracking-[-0.65px] text-white"
					style={{ fontFamily: FONT }}
				>
					{item.chance}%
				</span>
			</div>
			<div className="relative flex flex-1 items-center justify-center self-stretch py-[4px]">
				<div className="scale-[1.3]">
					<DiamondIcon color={color} />
				</div>
				<img
					src={item.image}
					alt={item.name}
					className="absolute max-h-[120px] w-[75%] object-contain"
					loading="lazy"
					decoding="async"
				/>
			</div>
			<div className="flex flex-col items-center justify-end gap-[3px] self-stretch px-0 py-[8px]">
				<span
					className="text-center font-semibold text-[16px] tracking-[-0.64px] text-[#F2F2F2] w-full truncate px-[8px]"
					style={{ fontFamily: FONT }}
				>
					{item.name}
				</span>
				<span
					className="text-center font-normal text-[13px] tracking-[-0.52px] text-[#ADADAD]"
					style={{ fontFamily: FONT }}
				>
					{rarityData.label}
				</span>
			</div>
		</div>
	);
}

// ---------------------------------------------------------------------------
// Roulette indicator (center line)
// ---------------------------------------------------------------------------

function RouletteIndicator() {
	return (
		<div className="pointer-events-none absolute inset-0 left-1/2 z-10 flex w-[2px] -translate-x-1/2 flex-col items-center">
			<svg width="16" height="10" viewBox="0 0 16 10" fill="none" className="shrink-0">
				<path d="M8 10L0 0H16L8 10Z" fill="rgb(var(--primaryColor))" />
			</svg>
			<div
				className="flex-1 w-[3px]"
				style={{
					background: "rgb(var(--primaryColor))",
					boxShadow:
						"0 0 20px rgba(var(--primaryColor), 0.7), 0 0 40px rgba(var(--primaryColor), 0.3), 0 0 6px rgba(var(--primaryColor), 0.5)",
				}}
			/>
			<svg width="16" height="10" viewBox="0 0 16 10" fill="none" className="shrink-0">
				<path d="M8 0L16 10H0L8 0Z" fill="rgb(var(--primaryColor))" />
			</svg>
		</div>
	);
}

// ---------------------------------------------------------------------------
// Idle carousel (when not spinning)
// ---------------------------------------------------------------------------

function IdleCarousel({ items }: { items: RouletteItem[] }) {
	const totalWidth = items.length * IDLE_ITEM_WIDTH;
	const duration = items.length * 3;
	const tripled = useMemo(() => [...items, ...items, ...items], [items]);

	if (items.length === 0) return null;

	return (
		<div className="relative w-full overflow-hidden rounded-[8px]">
			<style>{`
				@keyframes idle-scroll {
					0% { transform: translateX(0); }
					100% { transform: translateX(-${totalWidth}px); }
				}
			`}</style>
			<div
				className="flex"
				style={{
					animation: `idle-scroll ${duration}s linear infinite`,
					width: `${totalWidth * 3}px`,
				}}
			>
				{tripled.map((item, i) => (
					<div
						key={`idle-${i}`}
						className={`shrink-0 ${
							i % items.length < items.length - 1
								? "border-r border-[#3A3A3A]/50"
								: ""
						}`}
					>
						<RouletteStripItem item={item} />
					</div>
				))}
			</div>
		</div>
	);
}

// ---------------------------------------------------------------------------
// Roulette viewport
// ---------------------------------------------------------------------------

function RouletteViewport({
	phase,
	stripItems,
	defaultItems,
	stripRef,
	viewportRef,
}: {
	phase: RoulettePhase;
	stripItems: StripItem[];
	defaultItems: RouletteItem[];
	stripRef: React.RefObject<HTMLDivElement | null>;
	viewportRef: React.RefObject<HTMLDivElement | null>;
}) {
	return (
		<div
			className="relative flex shrink-0 flex-col items-end justify-center gap-[10px] py-[16px]"
			style={{
				borderTop: "0.7px solid rgba(255, 255, 255, 0.00)",
				borderBottom: "0.7px solid rgba(255, 255, 255, 0.00)",
				background:
					"linear-gradient(270deg, rgba(255, 255, 255, 0.00) -1.83%, rgba(255, 255, 255, 0.06) 50%, rgba(255, 255, 255, 0.00) 101.83%)",
			}}
		>
			{(phase === "spinning" || phase === "result") && <RouletteIndicator />}

			{phase === "idle" ? (
				<IdleCarousel items={defaultItems} />
			) : (
				<div
					className="relative w-full rounded-[8px]"
					ref={viewportRef}
					style={{
						clipPath:
							phase === "result"
								? "inset(-30px 0)"
								: "inset(-16px 0)",
					}}
				>
					<div
						ref={stripRef}
						className="flex will-change-transform"
						style={{ transform: "translateX(0px)" }}
					>
						{stripItems.map((item, i) => (
							<div
								key={`${item.id}-${i}`}
								className="shrink-0 transition-[transform,filter] duration-150 ease-out border-r border-[#3A3A3A]/50"
								style={{ width: "227px" }}
							>
								<RouletteStripItem item={item} />
							</div>
						))}
					</div>
				</div>
			)}
		</div>
	);
}

// ---------------------------------------------------------------------------
// useRoulette hook
// ---------------------------------------------------------------------------

function useRoulette({
	items,
	soundEnabled,
	fastMode,
}: {
	items: RouletteItem[];
	soundEnabled: boolean;
	fastMode: boolean;
}) {
	const [phase, setPhase] = useState<RoulettePhase>("idle");
	const [stripItems, setStripItems] = useState<StripItem[]>([]);
	const [winningItem, setWinningItem] = useState<RouletteItem | null>(null);

	const stripRef = useRef<HTMLDivElement>(null);
	const viewportRef = useRef<HTMLDivElement>(null);

	const viewportWidthRef = useRef(0);
	const rafRef = useRef(0);
	const startTimeRef = useRef(0);
	const lastTickSlotRef = useRef(-1);
	const tickPoolRef = useRef<HTMLAudioElement[]>([]);
	const tickPoolIndexRef = useRef(0);
	const audioContextRef = useRef<AudioContext | null>(null);
	const tickBufferRef = useRef<AudioBuffer | null>(null);
	const soundEnabledRef = useRef(soundEnabled);
	const victoryAudioRef = useRef<HTMLAudioElement | null>(null);

	const targetOffsetRef = useRef(0);
	const durationRef = useRef(BASE_DURATION);
	const winnerSlotRef = useRef(0);
	const readyToSpinRef = useRef(false);
	const isFastRef = useRef(false);

	const highlightedSlotRef = useRef(-999);
	const lastTickTimeRef = useRef(0);

	soundEnabledRef.current = soundEnabled;

	// Initialize audio
	useEffect(() => {
		tickPoolRef.current = Array.from({ length: TICK_POOL_SIZE }, () => {
			const audio = new Audio(tickSoundUrl);
			audio.volume = TICK_VOLUME;
			return audio;
		});

		victoryAudioRef.current = new Audio(victorySoundUrl);
		victoryAudioRef.current.volume = 0.4;

		const AudioCtx = window.AudioContext ?? window.webkitAudioContext;
		let ctx: AudioContext | null = null;

		if (AudioCtx) {
			ctx = new AudioCtx();
			audioContextRef.current = ctx;
			fetch(tickSoundUrl)
				.then((r) => r.arrayBuffer())
				.then((buf) => ctx!.decodeAudioData(buf))
				.then((decoded) => {
					tickBufferRef.current = decoded;
				})
				.catch(() => {});
		}

		return () => {
			for (const a of tickPoolRef.current) a.pause();
			victoryAudioRef.current?.pause();
			audioContextRef.current = null;
			tickBufferRef.current = null;
			ctx?.close();
		};
	}, []);

	const playTick = useCallback(() => {
		if (!soundEnabledRef.current) return;

		const ctx = audioContextRef.current;
		const buffer = tickBufferRef.current;

		if (ctx && buffer) {
			if (ctx.state === "suspended") ctx.resume();
			const source = ctx.createBufferSource();
			const gain = ctx.createGain();
			gain.gain.value = TICK_VOLUME;
			source.buffer = buffer;
			source.connect(gain);
			gain.connect(ctx.destination);
			source.start();
			return;
		}

		const audio = tickPoolRef.current[tickPoolIndexRef.current % TICK_POOL_SIZE];
		if (audio) {
			audio.currentTime = 0;
			audio.play().catch(() => {});
			tickPoolIndexRef.current++;
		}
	}, []);

	const highlightNearItems = useCallback((position: number) => {
		const strip = stripRef.current;
		if (!strip) return;
		const children = strip.children;
		const count = children.length;
		if (count === 0) return;

		const currentSlot = Math.min(
			Math.max(0, Math.floor(position / ITEM_WIDTH)),
			count - 1,
		);
		if (currentSlot === highlightedSlotRef.current) return;

		const prev = highlightedSlotRef.current;
		if (prev >= 0 && prev < count) {
			for (
				let k = Math.max(0, prev - 1);
				k <= Math.min(count - 1, prev + 1);
				k++
			) {
				const el = children[k] as HTMLElement;
				el.style.transform = "";
				el.style.zIndex = "";
			}
		}

		highlightedSlotRef.current = currentSlot;

		for (
			let k = Math.max(0, currentSlot - 1);
			k <= Math.min(count - 1, currentSlot + 1);
			k++
		) {
			const el = children[k] as HTMLElement;
			if (k === currentSlot) {
				el.style.transform = "scale(1.12)";
				el.style.zIndex = "5";
			}
		}
	}, []);

	const clearItemStyles = useCallback(() => {
		if (!stripRef.current) return;
		const children = stripRef.current.children;
		for (let i = 0; i < children.length; i++) {
			const el = children[i] as HTMLElement;
			el.style.transform = "";
			el.style.zIndex = "";
			el.style.filter = "";
			el.style.opacity = "";
			el.style.transition = "";
			el.style.outline = "";
			el.style.outlineOffset = "";
			el.style.borderRadius = "";
			el.style.overflow = "";
		}
	}, []);

	const animateFrame = useCallback(
		(timestamp: number) => {
			if (!startTimeRef.current) startTimeRef.current = timestamp;

			const elapsed = timestamp - startTimeRef.current;
			const duration = durationRef.current;
			const progress = Math.min(elapsed / duration, 1);
			const offset = -easing(progress) * targetOffsetRef.current;

			if (stripRef.current) {
				stripRef.current.style.transform = `translateX(${offset}px)`;
			}

			const vpWidth = viewportWidthRef.current;
			const position = Math.abs(offset) + vpWidth / 2;
			const currentSlot = Math.floor(position / ITEM_WIDTH);

			if (currentSlot !== lastTickSlotRef.current) {
				lastTickSlotRef.current = currentSlot;
				const tickInterval = progress < 0.4 ? 55 : 0;

				if (
					tickInterval === 0 ||
					timestamp - lastTickTimeRef.current >= tickInterval
				) {
					playTick();
					lastTickTimeRef.current = timestamp;
				}
			}

			if (progress >= HIGHLIGHT_START) {
				highlightNearItems(position);
			}

			if (progress < 1) {
				rafRef.current = requestAnimationFrame(animateFrame);
			} else {
				// Animation complete
				clearItemStyles();

				if (stripRef.current) {
					const children = stripRef.current.children;
					const childCount = children.length;
					const winner = winnerSlotRef.current;
					const vpW =
						viewportRef.current?.getBoundingClientRect().width ?? 0;
					const radius = Math.max(4, Math.ceil(vpW / ITEM_WIDTH / 2) + 2);
					const start = Math.max(0, winner - radius);
					const end = Math.min(childCount - 1, winner + radius);

					for (let i = start; i <= end; i++) {
						const el = children[i] as HTMLElement;
						if (i === winner) {
							el.style.transform = "scale(1.15)";
							el.style.zIndex = "5";
							el.style.opacity = "1";
							el.style.outline =
								"1px solid rgba(255, 255, 255, 0.10)";
							el.style.outlineOffset = "4px";
							el.style.borderRadius = "8px";
							el.style.overflow = "hidden";
							el.style.transition =
								"transform 0.4s ease, opacity 0.4s ease";
						} else {
							el.style.transform = "scale(0.95)";
							el.style.opacity = "0.45";
							el.style.transition =
								"transform 0.4s ease, opacity 0.4s ease";
						}
					}
				}

				setPhase("result");

				if (soundEnabledRef.current && victoryAudioRef.current) {
					victoryAudioRef.current.currentTime = 0;
					victoryAudioRef.current.play().catch(() => {});
				}
			}
		},
		[playTick, highlightNearItems, clearItemStyles],
	);

	// Start animation when phase changes to spinning
	useEffect(() => {
		if (phase !== "spinning" || !readyToSpinRef.current) return;
		readyToSpinRef.current = false;

		const vpWidth =
			viewportRef.current?.getBoundingClientRect().width ?? 0;
		viewportWidthRef.current = vpWidth;

		const targetOffset = Math.max(
			0,
			winnerSlotRef.current * ITEM_WIDTH + ITEM_WIDTH / 2 - vpWidth / 2,
		);
		targetOffsetRef.current = targetOffset;

		const distanceRatio = Math.max(targetOffset / REFERENCE_DISTANCE, 0.35);

		if (isFastRef.current) {
			const raw = Math.min(
				MAX_FAST_DURATION,
				Math.max(MIN_FAST_FLOOR, MIN_FAST_DURATION * distanceRatio ** DISTANCE_EXPONENT),
			);
			durationRef.current = Math.round(raw * DURATION_SCALE);
		} else {
			const raw = Math.min(
				MAX_NORMAL_DURATION,
				Math.max(
					BASE_DURATION,
					BASE_DURATION * distanceRatio ** DISTANCE_EXPONENT,
				),
			);
			durationRef.current = Math.round(raw * DURATION_SCALE);
		}

		startTimeRef.current = 0;
		lastTickSlotRef.current = -1;
		lastTickTimeRef.current = 0;
		highlightedSlotRef.current = -999;

		if (stripRef.current) {
			stripRef.current.style.transform = "translateX(0px)";
		}

		requestAnimationFrame(() => {
			rafRef.current = requestAnimationFrame(animateFrame);
		});
	}, [phase, animateFrame]);

	const startSpin = useCallback(
		(winnerIndex: number) => {
			const { stripItems: strip, winnerSlot } = buildStrip(
				items,
				winnerIndex,
			);
			setStripItems(strip);
			setWinningItem(items[winnerIndex]);
			winnerSlotRef.current = winnerSlot;
			isFastRef.current = fastMode;
			readyToSpinRef.current = true;
			setPhase("spinning");
		},
		[items, fastMode],
	);

	const reset = useCallback(() => {
		cancelAnimationFrame(rafRef.current);
		highlightedSlotRef.current = -999;
		clearItemStyles();
		if (victoryAudioRef.current) {
			victoryAudioRef.current.pause();
			victoryAudioRef.current.currentTime = 0;
		}
		setPhase("idle");
		setWinningItem(null);
		setStripItems([]);
		if (stripRef.current) {
			stripRef.current.style.transform = "translateX(0px)";
		}
	}, [clearItemStyles]);

	useEffect(() => () => cancelAnimationFrame(rafRef.current), []);

	return {
		phase,
		stripItems,
		winningItem,
		stripRef,
		viewportRef,
		startSpin,
		reset,
	};
}

// ---------------------------------------------------------------------------
// CaseContentCard (skins inside a case)
// ---------------------------------------------------------------------------

function CaseContentCard({ item }: { item: SkinItem }) {
	const rarityData = RARITY_MAP[item.rarity] || RARITY_MAP.comum;
	const color = `rgb(${rarityData.rgb})`;
	const image = item.image || skinItemImage;

	return (
		<div
			className="group flex w-full flex-col items-center transition-all duration-300"
			style={{
				background: `linear-gradient(180deg, rgba(${rarityData.rgb}, 0.32) -17.86%, rgba(${rarityData.rgb}, 0) 53.57%), rgba(12, 12, 12, 0.24)`,
				boxShadow: `inset 0 -2px 0 0 rgba(0, 0, 0, 0.6), inset 0 -2px 0 0 ${color}`,
			}}
		>
			<div className="h-[1px] w-full self-stretch" style={{ background: color }} />
			<div className="flex items-center justify-between self-stretch p-[8px]">
				<BoxIcon color={color} />
				<span
					className="text-right font-medium text-[12px] tracking-[-0.65px] text-white"
					style={{ fontFamily: FONT }}
				>
					{item.chance}%
				</span>
			</div>
			<div className="relative flex h-[120px] items-center justify-center self-stretch py-[4px]">
				<DiamondIcon color={color} />
				<img
					src={image}
					alt={item.name}
					className="absolute max-h-[100px] w-[85%] object-contain transition-transform duration-300 group-hover:-translate-y-[4px] group-hover:scale-105"
					onError={(e) => {
						(e.target as HTMLImageElement).src = skinItemImage;
					}}
				/>
			</div>
			<div className="flex flex-col items-center justify-end gap-[3px] self-stretch px-0 py-[8px]">
				<span
					className="text-center font-semibold text-[16px] tracking-[-0.64px] text-[#F2F2F2] w-full truncate px-[4px]"
					style={{ fontFamily: FONT }}
				>
					{item.name}
				</span>
				<span
					className="text-center font-normal text-[12px] tracking-[-1px] text-[#7A7A7A]"
					style={{ fontFamily: FONT }}
				>
					{rarityData.label}
				</span>
				{typeof item.durationDays === "number" && item.durationDays > 0 && (
					<span
						className="rounded-[3px] px-[7px] py-[1px] font-bold text-[10px] uppercase tracking-[-0.2px]"
						style={{
							fontFamily: FONT,
							color: "#FFC65C",
							background: "rgba(255, 198, 92, 0.12)",
							border: "0.7px solid rgba(255, 198, 92, 0.5)",
						}}
					>
						{`⏳ ${item.durationDays} ${item.durationDays === 1 ? "dia" : "dias"}`}
					</span>
				)}
			</div>
		</div>
	);
}

// ---------------------------------------------------------------------------
// CaseOpener (opening a specific case)
// ---------------------------------------------------------------------------

function CaseOpener({
	box,
	onBack,
	onSkinsCoinsUpdate,
}: {
	box: CaseItem;
	onBack: () => void;
	onSkinsCoinsUpdate?: (skinsCoins: number) => void;
}) {
	const [skins, setSkins] = useState<SkinItem[]>([]);
	const [soundEnabled, setSoundEnabled] = useState(true);
	const [fastMode, setFastMode] = useState(false);
	const [opening, setOpening] = useState(false);
	const [ready, setReady] = useState(false);
	const [cooldown, setCooldown] = useState(box.free ? box.availableIn ?? 0 : 0);
	const [wonDurationDays, setWonDurationDays] = useState<number | null>(null);

	const isLocked = box.free && cooldown > 0;

	// Cooldown timer for free cases
	useEffect(() => {
		if (!box.free || cooldown <= 0) return;
		const timer = setInterval(() => {
			setCooldown((prev) => {
				if (prev <= 1) {
					clearInterval(timer);
					return 0;
				}
				return prev - 1;
			});
		}, 1000);
		return () => clearInterval(timer);
	}, [box.free, cooldown > 0]);

	// Fetch case contents
	const fetchContents = useCallback(async () => {
		const data = await fetchNui<SkinItem[]>({
			path: "get:caseContents",
			payload: { caseId: box.id },
			mockData: [
				{ model_name: "mock_1",  name: "AK Cinza Urbano",       rarity: "comum",    value: 80,   chance: 12, image: skinItemImage },
				{ model_name: "mock_2",  name: "M4 Areia",              rarity: "comum",    value: 95,   chance: 11, image: skinItemImage },
				{ model_name: "mock_3",  name: "Glock Sombra",          rarity: "comum",    value: 110,  chance: 10, image: skinItemImage },
				{ model_name: "mock_4",  name: "Desert Eagle Black",    rarity: "comum",    value: 130,  chance: 10, image: skinItemImage },
				{ model_name: "mock_5",  name: "MP5 Floresta",          rarity: "comum",    value: 150,  chance: 9,  image: skinItemImage },
				{ model_name: "mock_6",  name: "AWP Marítima",          rarity: "comum",    value: 180,  chance: 8,  image: skinItemImage },
				{ model_name: "mock_7",  name: "AK Vermelha Linha",     rarity: "raro",     value: 320,  chance: 7,  image: skinItemImage },
				{ model_name: "mock_8",  name: "M4 Neon Azul",          rarity: "raro",     value: 380,  chance: 6,  image: skinItemImage },
				{ model_name: "mock_9",  name: "Scar Tigre",            rarity: "raro",     value: 420,  chance: 5,  image: skinItemImage },
				{ model_name: "mock_10", name: "Deagle Cromada",        rarity: "raro",     value: 480,  chance: 5,  image: skinItemImage },
				{ model_name: "mock_11", name: "AK Dragão Roxo",        rarity: "epico",    value: 680,  chance: 4,  image: skinItemImage },
				{ model_name: "mock_12", name: "AWP Aurora",            rarity: "epico",    value: 750,  chance: 4,  image: skinItemImage },
				{ model_name: "mock_13", name: "M4 Cyberpunk",          rarity: "epico",    value: 820,  chance: 4,  image: skinItemImage },
				{ model_name: "mock_14", name: "AK Fênix Dourada",      rarity: "lendario", value: 1100, chance: 3,  image: skinItemImage },
				{ model_name: "mock_15", name: "AWP Dragon Lore Lendária", rarity: "lendario", value: 1500, chance: 2,  image: skinItemImage },
			],
		});
		if (data) setSkins([...data].sort((a, b) => b.value - a.value));
	}, [box.id]);

	useEffect(() => {
		fetchContents().then(() => setReady(true));
	}, [fetchContents]);

	// Map skins to roulette items
	const rouletteItems: RouletteItem[] = skins.map((skin, i) => ({
		id: i + 1,
		name: skin.name,
		rarity: skin.rarity,
		chance: skin.chance,
		amount: 0,
		image: skin.image || skinItemImage,
	}));

	const { phase, stripItems, stripRef, viewportRef, startSpin, reset } =
		useRoulette({ items: rouletteItems, soundEnabled, fastMode });

	// Open case handler
	const handleOpen = async () => {
		if (phase !== "idle" || opening || rouletteItems.length === 0 || isLocked) return;
		setOpening(true);

		const result = await fetchNui<{
			skin: {
				model_name: string;
				name: string;
				rarity: string;
				value: number;
				image: string;
				durationDays?: number;
			};
			skinsCoins: number;
		}>({
			path: "post:openCase",
			payload: { caseId: box.id },
			mockData: {
				skin: {
					model_name: skins[0]?.model_name || "mock",
					name: skins[0]?.name || "Mock",
					rarity: "raro",
					value: 350,
					image: skinItemImage,
					durationDays: skins[0]?.durationDays,
				},
				skinsCoins: 7900,
			},
		});

		if (!result || !result.skin) {
			setOpening(false);
			return;
		}

		if (result.skinsCoins !== undefined && onSkinsCoinsUpdate) {
			onSkinsCoinsUpdate(result.skinsCoins);
		}

		const winnerIdx = skins.findIndex(
			(s) => s.model_name === result.skin.model_name,
		);
		setWonDurationDays(
			typeof result.skin.durationDays === "number" && result.skin.durationDays > 0
				? result.skin.durationDays
				: null,
		);
		startSpin(winnerIdx >= 0 ? winnerIdx : 0);
		setOpening(false);

		if (box.free) setCooldown(box.cooldownSeconds ?? 86400);
	};

	const handleReset = () => {
		setWonDurationDays(null);
		reset();
	};

	return (
		<div
			className="flex h-full w-full flex-col"
			{...(phase === "spinning" ? { "data-spinning": true } : {})}
		>
			{/* Header */}
			<div
				className="relative flex min-h-[64px] shrink-0 items-center justify-center py-[16px] transition-all duration-300 ease-out"
				style={{
					opacity: ready ? 1 : 0,
					transform: ready ? "translateY(0)" : "translateY(-12px)",
				}}
			>
				<button
					type="button"
					onClick={onBack}
					className="absolute left-0 cursor-pointer rounded-[4px] border-[0.7px] border-white/[.16] p-[3px] transition-colors hover:border-white/[.25]"
				>
					<div className="flex h-[26px] w-[26px] items-center justify-center rounded-[3px] border-[0.7px] border-white/[.06] bg-[#080808]/[.38] transition-colors hover:bg-[#080808]/[.55]">
						<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
							<path d="M14 7L9 12L14 17" stroke="#ADADAD" strokeLinecap="round" strokeLinejoin="round" />
						</svg>
					</div>
				</button>

				<div className="flex items-center gap-[24px]">
					<PrimaryDot />
					<span
						className="font-semibold text-[15px] tracking-[-0.05em] text-white"
						style={{ fontFamily: FONT }}
					>
						{box.name}
					</span>

					{box.free ? (
						<span
							className="font-semibold text-[14px] tracking-[-0.56px] text-[#F5BD16]"
							style={{ fontFamily: FONT }}
						>
							GRÁTIS
						</span>
					) : (
						<div className="flex items-center gap-[6px]">
							{box.originalPrice ? (
								<>
									<div className="flex items-center gap-[4px] opacity-50 line-through">
										<DiamondBadgeIcon />
										<span
											className="font-medium text-[14px] tracking-[-0.05em] text-white"
											style={{ fontFamily: FONT }}
										>
											{box.originalPrice.toLocaleString("pt-BR")}
										</span>
									</div>
									<span
										className="font-medium text-[15px] tracking-[-0.05em] text-white"
										style={{ fontFamily: FONT }}
									>
										{box.price.toLocaleString("pt-BR")}
									</span>
								</>
							) : (
								<>
									<DiamondBadgeIcon />
									<span
										className="font-medium text-[15px] tracking-[-0.05em] text-white"
										style={{ fontFamily: FONT }}
									>
										{box.price.toLocaleString("pt-BR")}
									</span>
								</>
							)}
						</div>
					)}
					<PrimaryDot />
				</div>
			</div>

			{/* Roulette strip */}
			<div
				className="transition-all duration-500 ease-out"
				style={{
					opacity: ready ? 1 : 0,
					transform: ready ? "translateY(0) scale(1)" : "translateY(16px) scale(0.98)",
					transitionDelay: "0.1s",
				}}
			>
				<RouletteViewport
					phase={phase}
					stripItems={stripItems}
					defaultItems={rouletteItems.slice(0, 9)}
					stripRef={stripRef}
					viewportRef={viewportRef}
				/>
			</div>

			{/* Action bar */}
			<div
				className="relative flex shrink-0 items-center justify-center py-[16px] transition-all duration-[400ms] ease-out"
				style={{
					opacity: ready ? 1 : 0,
					transform: ready ? "translateY(0)" : "translateY(12px)",
					transitionDelay: "0.18s",
				}}
			>
				{phase === "result" && wonDurationDays && (
					<span
						className="absolute right-0 rounded-[4px] px-[9px] py-[3px] font-bold text-[11px] uppercase tracking-[-0.2px]"
						style={{
							fontFamily: FONT,
							color: "#FFC65C",
							background: "rgba(255, 198, 92, 0.12)",
							border: "0.7px solid rgba(255, 198, 92, 0.5)",
						}}
					>
						{`⏳ Expira em ${wonDurationDays} ${wonDurationDays === 1 ? "dia" : "dias"}`}
					</span>
				)}
				{phase === "spinning" ? (
					<span
						className="font-medium text-[15px] tracking-[-0.6px]"
						style={{ fontFamily: FONT, color: "rgb(var(--primaryColor))" }}
					>
						Abrindo caixa...
					</span>
				) : isLocked ? (
					<span
						className="font-medium text-[14px] tracking-[-0.56px] text-[#F5BD16]"
						style={{ fontFamily: FONT }}
					>
						Disponível em {formatCountdown(cooldown)}
					</span>
				) : (
					<button
						type="button"
						onClick={phase === "result" ? handleReset : handleOpen}
						disabled={opening}
						className="flex h-[38px] cursor-pointer items-center justify-center rounded-[6px] p-[3px] transition-colors hover:opacity-90 disabled:opacity-50 disabled:cursor-not-allowed"
						style={{ border: "0.7px solid rgb(var(--primaryColor))" }}
					>
						<div
							className={`flex items-center justify-center gap-[8px] self-stretch rounded-[5px] ${
								phase === "result" ? "px-[40px]" : "px-[16px]"
							}`}
							style={{
								border: "0.7px solid rgba(var(--primaryColor), 0.60)",
								background:
									"linear-gradient(135deg, rgb(var(--primaryColor)) -47.65%, rgba(var(--primaryColor), 0.50) 122.65%)",
							}}
						>
							{phase === "result" ? (
								<>
									<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 12 12" fill="none">
										<g clipPath="url(#clip0_1_4386)">
											<path
												d="M12.0001 4.5H7.50011L9.18236 2.81775C8.33261 1.968 7.20236 1.5 6.00011 1.5C4.79786 1.5 3.66836 1.968 2.81786 2.81775C1.96811 3.6675 1.50011 4.79775 1.50011 6C1.50011 7.20225 1.96811 8.33175 2.81786 9.18225C3.23478 9.60143 3.73073 9.93374 4.27697 10.1599C4.8232 10.3861 5.40889 10.5017 6.00011 10.5C6.64189 10.502 7.27659 10.3658 7.86103 10.1006C8.44547 9.83545 8.96596 9.44753 9.38711 8.96325L10.5159 9.951C9.72328 10.857 8.67652 11.5036 7.5116 11.8069C6.34669 12.1102 5.11749 12.056 3.98375 11.6515C2.85001 11.247 1.86416 10.5108 1.1543 9.53867C0.444447 8.56651 0.043417 7.40331 0.00332928 6.20024C-0.0367584 4.99717 0.28595 3.80985 0.929515 2.7926C1.57308 1.77534 2.50775 0.975175 3.61204 0.496094C4.71634 0.0170143 5.93921 -0.118831 7.12172 0.106213C8.30424 0.331257 9.39173 0.906784 10.2429 1.758L12.0001 0V4.5Z"
												fill="#F2F2F2"
											/>
										</g>
										<defs>
											<clipPath id="clip0_1_4386">
												<rect width="12" height="12" fill="white" />
											</clipPath>
										</defs>
									</svg>
									<span
										className="text-center font-semibold text-[14px] tracking-[-0.56px] text-[#F2F2F2]"
										style={{ fontFamily: FONT }}
									>
										Abrir novamente
									</span>
								</>
							) : (
								<>
									<span
										className="text-center font-semibold text-[14px] tracking-[-0.56px] text-[#F2F2F2]"
										style={{ fontFamily: FONT }}
									>
										{box.free ? "Abrir Grátis" : "Abrir"}
									</span>
									{!box.free && (
										<div className="flex items-center gap-[5px]">
											{box.originalPrice ? (
												<>
													<div
														className="flex items-center gap-[3px] opacity-50 line-through"
														style={{ filter: "brightness(0) invert(1)" }}
													>
														<div className="flex h-[18px] w-[18px] items-center justify-center">
															<DiamondBadgeIcon />
														</div>
														<span
															className="font-medium text-[13px] tracking-[-0.52px] text-white"
															style={{ fontFamily: FONT }}
														>
															{box.originalPrice.toLocaleString("pt-BR")}
														</span>
													</div>
													<span
														className="font-medium text-[14px] tracking-[-0.56px] text-white"
														style={{ fontFamily: FONT }}
													>
														{box.price.toLocaleString("pt-BR")}
													</span>
												</>
											) : (
												<>
													<div
														className="flex h-[18px] w-[18px] items-center justify-center"
														style={{ filter: "brightness(0) invert(1)" }}
													>
														<DiamondBadgeIcon />
													</div>
													<span
														className="font-medium text-[14px] tracking-[-0.56px] text-white"
														style={{ fontFamily: FONT }}
													>
														{box.price.toLocaleString("pt-BR")}
													</span>
												</>
											)}
										</div>
									)}
								</>
							)}
						</div>
					</button>
				)}

				{/* Sound & fast mode toggles */}
				<div className="absolute right-0 flex items-center gap-[6px]">
					<button
						type="button"
						onClick={() => setSoundEnabled(!soundEnabled)}
						className={`aspect-square h-[38px] w-[38px] shrink-0 cursor-pointer p-[3px] transition-colors ${
							soundEnabled
								? "rounded-[6px]"
								: "rounded-[7px] border-[0.7px] border-white/[.16] hover:border-white/[.25]"
						}`}
						style={
							soundEnabled
								? { border: "0.7px solid rgb(var(--primaryColor))" }
								: undefined
						}
					>
						<div
							className={`flex h-full w-full items-center justify-center rounded-[5px] transition-colors ${
								soundEnabled
									? ""
									: "border-[0.7px] border-white/[.06] bg-[#080808]/[.38] hover:bg-[#080808]/[.55]"
							}`}
							style={
								soundEnabled
									? {
											border: "0.7px solid rgba(var(--primaryColor), 0.60)",
											background:
												"linear-gradient(135deg, rgb(var(--primaryColor)) -47.65%, rgba(var(--primaryColor), 0.50) 122.65%)",
										}
									: undefined
							}
						>
							{soundEnabled ? (
								<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20" fill="none">
									<path fillRule="evenodd" clipRule="evenodd" d="M8.10938 3.13899C9.07939 2.12938 10.6504 2.90224 10.6504 4.20247V15.7972C10.6504 17.1078 9.05886 17.8758 8.0957 16.847C8.09187 16.8429 8.08772 16.8385 8.08398 16.8343L5.60156 14.0365C5.5862 14.0199 5.56749 14.0065 5.54688 13.9974L5.48047 13.9837H2.5C1.65706 13.9835 1.01676 13.2793 1.0166 12.4661V7.53352C1.0166 6.7206 1.65735 6.0171 2.5 6.01692H5.48633C5.50872 6.01681 5.53119 6.0121 5.55176 6.00325C5.57138 5.99474 5.58851 5.98136 5.60352 5.96614L8.09082 3.15852C8.0966 3.152 8.10334 3.14527 8.10938 3.13899ZM9.13672 3.98567C9.1149 3.98964 9.08386 4.00096 9.04688 4.03938L6.56445 6.84309C6.55946 6.84873 6.55402 6.85519 6.54883 6.86067C6.41254 7.00403 6.24802 7.11822 6.06641 7.19661C5.88477 7.27493 5.68901 7.31596 5.49121 7.31672H2.5C2.42284 7.31693 2.31738 7.39008 2.31738 7.53352V12.4661C2.31753 12.6106 2.42329 12.6827 2.5 12.6829H5.48438C5.68538 12.6836 5.88426 12.7262 6.06836 12.807C6.20645 12.8675 6.33441 12.949 6.44727 13.0482L6.55566 13.1536L6.56445 13.1634L9.04492 15.9583C9.08216 15.9981 9.11385 16.0098 9.13574 16.014C9.16131 16.0188 9.19351 16.0166 9.22754 16.0023C9.29225 15.9748 9.35059 15.9113 9.35059 15.7972V4.20247C9.35057 4.08957 9.29292 4.0263 9.22852 3.99836C9.19462 3.98374 9.16224 3.98112 9.13672 3.98567Z" fill="white" />
									<path d="M13.5 7.5C14.3 8.3 14.75 9.4 14.75 10.5C14.75 11.6 14.3 12.7 13.5 13.5" stroke="white" strokeWidth="1.3" strokeLinecap="round" />
									<path d="M16 5.5C17.3 6.8 18 8.6 18 10.5C18 12.4 17.3 14.2 16 15.5" stroke="white" strokeWidth="1.3" strokeLinecap="round" />
								</svg>
							) : (
								<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20" fill="none">
									<path fillRule="evenodd" clipRule="evenodd" d="M8.10938 3.13899C9.07939 2.12938 10.6504 2.90224 10.6504 4.20247V15.7972C10.6504 17.1078 9.05886 17.8758 8.0957 16.847C8.09187 16.8429 8.08772 16.8385 8.08398 16.8343L5.60156 14.0365C5.5862 14.0199 5.56749 14.0065 5.54688 13.9974L5.48047 13.9837H2.5C1.65706 13.9835 1.01676 13.2793 1.0166 12.4661V7.53352C1.0166 6.7206 1.65735 6.0171 2.5 6.01692H5.48633C5.50872 6.01681 5.53119 6.0121 5.55176 6.00325C5.57138 5.99474 5.58851 5.98136 5.60352 5.96614L8.09082 3.15852C8.0966 3.152 8.10334 3.14527 8.10938 3.13899ZM9.13672 3.98567C9.1149 3.98964 9.08386 4.00096 9.04688 4.03938L6.56445 6.84309C6.55946 6.84873 6.55402 6.85519 6.54883 6.86067C6.41254 7.00403 6.24802 7.11822 6.06641 7.19661C5.88477 7.27493 5.68901 7.31596 5.49121 7.31672H2.5C2.42284 7.31693 2.31738 7.39008 2.31738 7.53352V12.4661C2.31753 12.6106 2.42329 12.6827 2.5 12.6829H5.48438C5.68538 12.6836 5.88426 12.7262 6.06836 12.807C6.20645 12.8675 6.33441 12.949 6.44727 13.0482L6.55566 13.1536L6.56445 13.1634L9.04492 15.9583C9.08216 15.9981 9.11385 16.0098 9.13574 16.014C9.16131 16.0188 9.19351 16.0166 9.22754 16.0023C9.29225 15.9748 9.35059 15.9113 9.35059 15.7972V4.20247C9.35057 4.08957 9.29292 4.0263 9.22852 3.99836C9.19462 3.98374 9.16224 3.98112 9.13672 3.98567Z" fill="#ADADAD" />
									<path d="M17.874 7.04036C18.1278 6.7867 18.5392 6.78673 18.793 7.04036C19.0466 7.29416 19.0466 7.70549 18.793 7.9593L16.752 9.99934L18.793 12.0404C19.0466 12.2942 19.0466 12.7055 18.793 12.9593C18.5392 13.2131 18.1279 13.213 17.874 12.9593L15.833 10.9183L13.793 12.9593C13.5392 13.2131 13.1279 13.213 12.874 12.9593C12.6204 12.7054 12.6202 12.2941 12.874 12.0404L14.9141 9.99934L12.874 7.9593C12.6204 7.70545 12.6202 7.29414 12.874 7.04036C13.1278 6.7867 13.5392 6.78673 13.793 7.04036L15.833 9.0804L17.874 7.04036Z" fill="#ADADAD" />
								</svg>
							)}
						</div>
					</button>

					<button
						type="button"
						onClick={() => setFastMode(!fastMode)}
						className={`aspect-square h-[38px] w-[38px] shrink-0 cursor-pointer p-[3px] transition-colors ${
							fastMode
								? "rounded-[6px]"
								: "rounded-[7px] border-[0.7px] border-white/[.16] hover:border-white/[.25]"
						}`}
						style={
							fastMode
								? { border: "0.7px solid rgb(var(--primaryColor))" }
								: undefined
						}
					>
						<div
							className={`flex h-full w-full items-center justify-center rounded-[5px] transition-colors ${
								fastMode
									? ""
									: "border-[0.7px] border-white/[.06] bg-[#080808]/[.38] hover:bg-[#080808]/[.55]"
							}`}
							style={
								fastMode
									? {
											border: "0.7px solid rgba(var(--primaryColor), 0.60)",
											background:
												"linear-gradient(135deg, rgb(var(--primaryColor)) -47.65%, rgba(var(--primaryColor), 0.50) 122.65%)",
										}
									: undefined
							}
						>
							<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20" fill="none">
								<path
									fillRule="evenodd"
									clipRule="evenodd"
									d="M12.3895 0.650394C12.4881 0.650098 12.5856 0.67067 12.6756 0.710941C12.7431 0.741164 12.8057 0.781454 12.8602 0.831058L12.9119 0.883792L12.9578 0.941409C12.9865 0.981612 13.0105 1.02496 13.0301 1.07032L13.0555 1.13868L13.074 1.21094C13.0883 1.28315 13.0909 1.3573 13.0818 1.43067C13.0804 1.44202 13.079 1.45359 13.077 1.46485L11.9686 7.52539H16.2498C16.4809 7.52539 16.6911 7.65782 16.7908 7.86621C16.8903 8.07474 16.8618 8.32222 16.7166 8.50196L8.1502 19.0898L8.14923 19.0889C8.08701 19.1667 8.00994 19.2315 7.92071 19.2764C7.8245 19.3247 7.71782 19.3485 7.61017 19.3486C7.50941 19.3487 7.40957 19.3285 7.31817 19.2861C7.22638 19.2435 7.14503 19.181 7.07989 19.1035C7.01476 19.0261 6.96747 18.9347 6.94122 18.8369C6.91507 18.7393 6.91097 18.6366 6.92852 18.5371V18.5342L8.03106 12.4746H3.74981C3.51878 12.4746 3.30848 12.3422 3.2088 12.1338C3.10931 11.9253 3.13791 11.6778 3.28302 11.498L11.8484 0.912113C11.9099 0.834767 11.9869 0.771756 12.075 0.726566L12.1492 0.693363C12.2255 0.664958 12.3076 0.650769 12.3895 0.650394ZM5.00665 11.2754H8.74981C8.92769 11.2754 9.09675 11.3537 9.21075 11.4902C9.32475 11.6268 9.3715 11.8074 9.33966 11.9824L8.46368 16.7939L14.993 8.72461H11.2498C11.0718 8.72459 10.9029 8.64549 10.7889 8.50879C10.6752 8.37222 10.6281 8.19242 10.66 8.01758L11.5399 3.19922L5.00665 11.2754Z"
									fill={fastMode ? "white" : "#ADADAD"}
								/>
							</svg>
						</div>
					</button>
				</div>
			</div>

			{/* Skins in case label */}
			<div
				className="flex shrink-0 items-center justify-center gap-[12px] py-[16px] transition-opacity duration-[400ms] ease-out"
				style={{ opacity: ready ? 1 : 0, transitionDelay: "0.25s" }}
			>
				<PrimaryDot />
				<span
					className="font-semibold text-[15px] tracking-[-0.05em] text-white"
					style={{ fontFamily: FONT }}
				>
					Skins nesta caixa
				</span>
				<PrimaryDot />
			</div>

			{/* Skins grid */}
			<div
				className="scrollbar-custom flex-1 overflow-y-auto pr-[10px] transition-all duration-[450ms] ease-out"
				style={{
					opacity: ready ? 1 : 0,
					transform: ready ? "translateY(0)" : "translateY(16px)",
					transitionDelay: "0.3s",
				}}
			>
				<div className="grid grid-cols-[repeat(auto-fill,minmax(190px,1fr))] gap-[8px] pb-[16px]">
					{skins.map((skin) => (
						<div
							key={skin.model_name}
							className="overflow-hidden rounded-[8px] border border-transparent transition-colors duration-300"
							style={{ borderColor: "transparent" }}
							onMouseEnter={(e) => {
								const rgb =
									RARITY_MAP[skin.rarity]?.rgb || RARITY_MAP.comum.rgb;
								e.currentTarget.style.borderColor = `rgba(${rgb}, 0.4)`;
							}}
							onMouseLeave={(e) => {
								e.currentTarget.style.borderColor = "transparent";
							}}
						>
							<CaseContentCard item={skin} />
						</div>
					))}
				</div>
			</div>
		</div>
	);
}

// ---------------------------------------------------------------------------
// LastWinCard
// ---------------------------------------------------------------------------

function LastWinCard({
	item,
	isLast,
}: {
	item: LastWinItem;
	isLast: boolean;
}) {
	const rarityRgb = (RARITY_MAP[item.rarity] ?? RARITY_MAP.comum).rgb;
	const color = `rgb(${rarityRgb})`;

	return (
		<div
			className={`flex w-[190px] shrink-0 flex-col items-center self-stretch ${
				isLast ? "" : "border-r border-[#3A3A3A]/50"
			}`}
			style={{
				background: `linear-gradient(180deg, rgba(${rarityRgb}, 0.32) -17.86%, rgba(${rarityRgb}, 0) 53.57%), rgba(12, 12, 12, 0.24)`,
				boxShadow: `inset 0 -2px 0 0 rgba(0, 0, 0, 0.6), inset 0 -2px 0 0 ${color}`,
			}}
		>
			<div className="h-[1px] w-full self-stretch" style={{ background: color }} />
			<div className="relative z-10 flex flex-col items-start gap-[10px] self-stretch p-[8px]">
				{item.source === "improvement" ? (
					<StarIcon color={color} />
				) : (
					<BoxIcon color={color} />
				)}
			</div>
			<div className="relative flex items-center justify-center self-stretch py-[4px]">
				<DiamondIcon color={color} />
				<img
					src={item.image}
					alt={item.name}
					className="absolute w-[95%] object-contain"
					onError={(e) => {
						const target = e.currentTarget;
						target.src = skinItemImage;
						target.onerror = null;
					}}
				/>
			</div>
			<div className="relative z-10 flex flex-col items-center justify-end gap-[3px] self-stretch px-0 py-[8px]">
				<span
					className="text-center font-bold text-[13px] tracking-[-0.04em] text-[#F2F2F2] w-full truncate px-[8px]"
					style={{ fontFamily: FONT }}
				>
					{item.name}
				</span>
				<div className="flex items-center gap-[4px]">
					<PlayerIcon />
					<span
						className="font-normal text-[12px] tracking-[-0.65px] text-[#7A7A7A]"
						style={{ fontFamily: FONT }}
					>
						{item.player}
					</span>
				</div>
			</div>
		</div>
	);
}

// ---------------------------------------------------------------------------
// LastWins
// ---------------------------------------------------------------------------

function LastWins() {
	const [wins, setWins] = useState<LastWinItem[]>([]);
	const scrollRef = useRef<HTMLDivElement>(null);

	const fetchLastWins = useCallback(async () => {
		const data = await fetchNui<LastWinItem[]>({
			path: "get:lastWins",
			mockData: MOCK_LAST_WINS,
		});
		if (data) setWins(data.map((w) => ({ ...w, image: w.image || skinItemImage })));
	}, []);

	useEffect(() => {
		fetchLastWins();
	}, [fetchLastWins]);

	useNuiMessage<LastWinItem>("newWin", (item) => {
		if (!item) return;
		setWins((prev) => {
			if (item.id && prev.some((w) => w.id === item.id)) return prev;
			return [{ ...item, image: item.image || skinItemImage }, ...prev].slice(0, 20);
		});
		if (scrollRef.current) scrollRef.current.scrollLeft = 0;
	});

	if (wins.length === 0) return null;

	return (
		<div className="shrink-0">
			<div className="flex items-center justify-center gap-[12px] py-[16px]">
				<PrimaryDot />
				<span
					className="font-semibold text-[15px] tracking-[-0.05em] text-white"
					style={{ fontFamily: FONT }}
				>
					Últimos ganhos
				</span>
				<PrimaryDot />
			</div>

			<div className="relative">
				<SideBorder side="left" />
				<SideBorder side="right" />
				<div
					ref={scrollRef}
					className="scrollbar-hide flex overflow-hidden rounded-[8px]"
					style={{ cursor: "grab" }}
				>
					{wins.map((item, i) => (
						<LastWinCard
							key={item.id ?? `${item.name}-${item.player}-${i}`}
							item={item}
							isLast={i === wins.length - 1}
						/>
					))}
				</div>
			</div>
		</div>
	);
}

// ---------------------------------------------------------------------------
// Caixas (main page export)
// ---------------------------------------------------------------------------

export function Caixas() {
	const [cases, setCases] = useState<CaseItem[]>([]);
	const skinsCoins = useMainStore((s) => s.skinsCoins);
	const setSkinsCoins = useMainStore((s) => s.setSkinsCoins);

	const [selectedCase, setSelectedCase] = useState<CaseItem | null>(null);
	const [sort, setSort] = useState<SortOption>("Menor Preço");
	const [search, setSearch] = useState("");
	const [skinsCoinsFilter, setSkinsCoinsFilter] = useState(false);
	const [ready, setReady] = useState(false);
	const [loading, setLoading] = useState(true);
	const [bannerUrl, setBannerUrl] = useState(heroBannerImage);

	const cache = useDataCache();

	const loadCases = useCallback(
		async (forceRefresh?: boolean) => {
			if (!forceRefresh) {
				const cached = cache.get("cases", 5000) as CaseItem[] | null;
				if (cached) {
					setCases(cached);
					setLoading(false);
					return;
				}
			}

			setLoading(true);
			const data = await fetchNui<CaseItem[]>({
				path: "get:cases",
				mockData: MOCK_CASES,
			});

			if (data) {
				const normalized = data.map((c) => ({
					...c,
					image: c.image || caseItemImage,
				}));
				setCases(normalized);
				cache.set("cases", normalized);
			}
			setLoading(false);
		},
		[cache],
	);

	useEffect(() => {
		loadCases().then(() => setReady(true));
		fetchNui<string | null>({ path: "get:banner", mockData: null }).then(
			(url) => {
				if (url) setBannerUrl(url);
			},
		);
	}, [loadCases]);

	const filteredCases = useMemo(() => {
		let result = [...cases];

		if (search.trim()) {
			const q = search.toLowerCase().trim();
			result = result.filter((c) => c.name.toLowerCase().includes(q));
		}

		if (skinsCoinsFilter) {
			result = result.filter((c) => c.price <= skinsCoins);
		}

		switch (sort) {
			case "Menor Preço":
				result.sort((a, b) => a.price - b.price);
				break;
			case "Maior Preço":
				result.sort((a, b) => b.price - a.price);
				break;
		}

		return result;
	}, [cases, sort, search, skinsCoinsFilter, skinsCoins]);

	if (selectedCase) {
		return (
			<CaseOpener
				box={selectedCase}
				onBack={() => {
					setSelectedCase(null);
					loadCases(true);
				}}
				onSkinsCoinsUpdate={(c) => setSkinsCoins(c)}
			/>
		);
	}

	if (loading && cases.length === 0) {
		return (
			<div className="flex h-full w-full items-center justify-center">
				<span
					className="text-[14px] text-[#7A7A7A]"
					style={{ fontFamily: FONT }}
				>
					Carregando caixas...
				</span>
			</div>
		);
	}

	return (
		<div className="flex h-full w-full flex-col">
			<div
				className="transition-all duration-300 ease-out"
				style={{
					opacity: ready ? 1 : 0,
					transform: ready ? "translateY(0)" : "translateY(-12px)",
				}}
			>
				<LastWins />
			</div>

			<div className="scrollbar-custom flex min-h-0 flex-1 flex-col overflow-x-hidden overflow-y-auto pr-[10px] mt-[16px]">
				<div
					className="h-[176px] shrink-0 self-stretch rounded-[8px] border border-white/10 transition-all duration-500 ease-out"
					style={{
						background: `url(${bannerUrl}) 50% / cover no-repeat`,
						opacity: ready ? 1 : 0,
						transform: ready ? "scale(1)" : "scale(0.97)",
						transitionDelay: "0.08s",
					}}
				/>

				<div
					className="transition-all duration-[400ms] ease-out"
					style={{
						opacity: ready ? 1 : 0,
						transform: ready ? "translateY(0)" : "translateY(12px)",
						transitionDelay: "0.15s",
					}}
				>
					<CaseCatalogHeader
						sort={sort}
						onSortChange={setSort}
						search={search}
						onSearchChange={setSearch}
						skinsCoinsFilter={skinsCoinsFilter}
						onSkinsCoinsFilterChange={setSkinsCoinsFilter}
					/>
				</div>

				<div className="mt-[16px] grid grid-cols-[repeat(auto-fill,minmax(220px,1fr))] gap-[10px] pb-[24px]">
					{filteredCases.map((caseItem, i) => (
						<div
							key={caseItem.id}
							className="transition-all duration-[450ms] ease-out"
							style={{
								opacity: ready ? 1 : 0,
								transform: ready
									? "translateY(0) scale(1)"
									: "translateY(20px) scale(0.95)",
								transitionDelay: `${0.2 + i * 0.03}s`,
							}}
						>
							<CaseCard
								item={caseItem}
								onClick={() => setSelectedCase(caseItem)}
							/>
						</div>
					))}
				</div>
			</div>
		</div>
	);
}
