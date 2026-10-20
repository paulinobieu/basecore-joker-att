import React, { memo, useEffect, useMemo, useRef, useState } from "react";
import { create } from "zustand";
import { useShallow } from "zustand/react/shallow";
import { fetchNui } from "@app/utils/fetchNui";
import { isEnvBrowser } from "@app/utils/misc";
import { cn } from "@app/utils";
import { useMainStore } from "@app/stores/MainStore";
import { useVisibility } from "@app/stores/Visibility";
import { RARITY_MAP } from "@app/stores/constants";
import { useImageValidation } from "@app/hooks/useImageValidation";
import { SearchIcon } from "@views/components/SearchIcon";
import { SkinCard } from "@views/components/SkinCard";
import { SkinFallbackSVG } from "@views/components/SkinFallbackSVG";
import { DiamondIcon } from "@views/components/DiamondIcon";

// ── Types ──────────────────────────────────────────────────────────────────────

interface Skin {
	model_name: string;
	name: string;
	rarity: string;
	image: string;
	value?: number;
	quantity?: number;
}

interface ImprovementConfig {
	chanceExponent: number;
	minChance: number;
	minTargetMarkup: number | false;
	maxTargetMarkup: number | false;
	requirePlayerSkin?: boolean;
}

type ImprovementStatus = "improved" | "non-improved" | null;

interface ImprovementState {
	balance: number;
	playerSkins: Skin[];
	selectedPlayerSkins: Skin[];
	selectedServerSkin: Skin | null;
	serverSkins: Skin[];
	successChance: number;
	status: ImprovementStatus;
	playerInventoryFilter: string;
	serverInventoryFilter: string;
	config: ImprovementConfig;
	getData: () => Promise<void>;
	setBalance: (value: number) => Promise<void>;
	setSelectedPlayerSkins: (skins: Skin[]) => Promise<void>;
	setSelectedServerSkin: (skin: Skin | null) => Promise<void>;
	improve: () => Promise<void>;
	setPlayerInventoryFilter: (filter: string) => void;
	setServerInventoryFilter: (filter: string) => void;
}

// ── Store ──────────────────────────────────────────────────────────────────────

const initialState = {
	balance: 0,
	playerSkins: [] as Skin[],
	selectedPlayerSkins: [] as Skin[],
	selectedServerSkin: null as Skin | null,
	serverSkins: [] as Skin[],
	successChance: 0,
	status: null as ImprovementStatus,
	playerInventoryFilter: "",
	serverInventoryFilter: "",
	config: {
		chanceExponent: 1.5,
		minChance: 1,
		minTargetMarkup: false as number | false,
		maxTargetMarkup: false as number | false,
		requirePlayerSkin: true,
	},
};

const useImprovementStore = create<ImprovementState>()((set, get) => ({
	...initialState,

	async getData() {
		const data = await fetchNui({
			path: "get:improvement:data",
			mockData: {
				playerSkins: [
					{
						model_name: "weapon_ak47",
						name: "AK-47 | Redline",
						rarity: "raro",
						image:
							"https://steamcommunity-a.akamaihd.net/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpot7HxfDhjxszJemkV09-5lpKKqPrxN7LEmyVQ7MEpiLuSrYmnjVHj-UE6ZmD0dtWLMFhsZF7T-lC5xb_ug5C4ucyfwHI37CggsXzfzBbP_Xdmcj0",
					},
					{
						model_name: "weapon_m4a1_silencer",
						name: "M4A1-S | Hyper Beast",
						rarity: "epico",
						image:
							"https://steamcommunity-a.akamaihd.net/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpou-6kejhjxszFJTwW09-vloWZh8j1OO7GqWlD6sp9teTC84r2nVfi-EBpMD_0JoCVdVNrZVDY-1e-xuq518O8vebXiSw2",
					},
					{
						model_name: "weapon_awp",
						name: "AWP | Asiimov",
						rarity: "epico",
						image:
							"https://steamcommunity-a.akamaihd.net/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpot621FAR17PLfYQJS0YmfkbOZqv31IbnFl2pQ-sR_j-jE963y21Hj-kRkZWDzIY7GcVc4N1jCqFW5kO28gJe-vSCcwHU2HtGs_-g",
					},
					{
						model_name: "weapon_deagle",
						name: "Desert Eagle | Blaze",
						rarity: "comum",
						image:
							"https://steamcommunity-a.akamaihd.net/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgposr-3FAZh7PLZTjlH_9mkgL-KkurzOpfQhGwGupd1jrqTp9r2iw3i-BFsZmz2LdCRJg5qM1jZqAe9xLu-gJC9vcqanCIxvgSy",
					},
					{
						model_name: "weapon_knife_butterfly",
						name: "Butterfly Knife | Doppler",
						rarity: "lendario",
						image:
							"https://steamcommunity-a.akamaihd.net/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpovbSsLQJfwObaZzRB7c6OkL-Zk8j5NT_GmW5u5cB1g_zMyoD0mlHh_UZkZ272ItKQLABrNFzYq1C-xLvqhpbp75ia1zA97HRoqE2Y",
					},
				],
				serverSkins: [
					{
						model_name: "weapon_ak47",
						name: "AK-47 | Fire Serpent",
						rarity: "epico",
						image:
							"https://steamcommunity-a.akamaihd.net/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpot7HxfDhjxszJemkV09u5l5OHhOHLPr7Vn35cppd1hsTN_Iv9jFbs_UZtY2GhJo-VdgA_NVHQ-lm-x-i81MS_upLHwSEy6HRptH3X",
					},
					{
						model_name: "weapon_awp",
						name: "AWP | Dragon Lore",
						rarity: "epico",
						image:
							"https://steamcommunity-a.akamaihd.net/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpot621FAZh7PLfYQJE5du5m4m0kPrxN7LEqW9Y781lteXA54r2iVTj_BBlZGj3doSUeVA-ZV_T_VS5yO_ngZC4vPKmXwy",
					},
					{
						model_name: "weapon_m4a4",
						name: "M4A4 | Howl",
						rarity: "lendario",
						image:
							"https://steamcommunity-a.akamaihd.net/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpou-6kejhz2v_Nfz5H_uO1gb-Gw_alDL_Dll9u5cJ9gez--YD8j23h-Rc5MDj7Jo6TdwU9aA_S_gfrxum8jJe17JVZD8k",
					},
					{
						model_name: "weapon_knife_karambit",
						name: "Karambit | Fade",
						rarity: "lendario",
						image:
							"https://steamcommunity-a.akamaihd.net/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpovbSsLQJf2P3NfjpH6Na1gb-Gw_alIITCmyVQ7MEpiLuSrYmnjQfm-kRpZGylJ4GLJlJsZl7YqVO9xbvmgMC5tczJnCFr7CsusHzfzBJuEbLf",
					},
					{
						model_name: "weapon_glock",
						name: "Glock-18 | Fade",
						rarity: "comum",
						image:
							"https://steamcommunity-a.akamaihd.net/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgposbaqKAxf0Ob3djFH6eO7nYeDg7n4Nr_Yg2Yf6scg3LDHpd6m3A21-ENqZz_7ctKSewE6YFiD_Vm8xO28jsK97Z_PnCdk7EtisXHj_Q",
					},
				],
				config: {
					chanceExponent: 1.5,
					minChance: 1,
					minTargetMarkup: false,
					maxTargetMarkup: false,
				},
			},
		});

		if (data) set(data);
	},

	async setBalance(value) {
		if (value === 0) return set({ balance: 0 });

		const { selectedServerSkin, selectedPlayerSkins } = get();
		const chance = await fetchNui({
			path: "get:improvement:skinChance",
			payload: { balance: value, skin: selectedServerSkin, selectedPlayerSkins },
			mockData: 45,
		});

		if (chance == null || typeof chance !== "number") return;
		set({ balance: value, successChance: chance });
	},

	async setSelectedPlayerSkins(skins) {
		const { selectedServerSkin, balance } = get();

		if (skins.length === 0 && balance === 0) {
			return set({ successChance: 0, selectedPlayerSkins: [] });
		}

		const chance = await fetchNui({
			path: "get:improvement:skinChance",
			payload: { selectedPlayerSkins: skins, skin: selectedServerSkin, balance },
			mockData: 45,
		});

		if (chance == null || typeof chance !== "number") return;
		set({ selectedPlayerSkins: skins, successChance: chance });
	},

	async setSelectedServerSkin(skin) {
		if (!skin) return set({ selectedServerSkin: null });

		const { selectedPlayerSkins, balance } = get();
		const chance = await fetchNui({
			path: "get:improvement:skinChance",
			payload: { selectedPlayerSkins, skin, balance },
			mockData: 45,
		});

		if (chance == null || typeof chance !== "number") return;
		set({ selectedServerSkin: skin, successChance: chance });
	},

	async improve() {
		const { balance, selectedPlayerSkins, selectedServerSkin, config } = get();
		if (!selectedServerSkin) return;
		if (config.requirePlayerSkin !== false && selectedPlayerSkins.length === 0) return;

		const result = await fetchNui({
			path: "post:improvement:improve",
			payload: { balance, selectedServerSkin, selectedPlayerSkins },
			mockData: { success: true },
		});

		if (!result) return;

		set({ status: result.success ? "improved" : "non-improved" });

		const updatedPlayerSkins = result.playerSkins;

		setTimeout(() => {
			if (!isEnvBrowser()) get().getData();

			const resetState: Record<string, unknown> = {
				status: null,
				balance: 0,
				successChance: 0,
				selectedPlayerSkins: [],
				selectedServerSkin: null,
			};

			if (updatedPlayerSkins) {
				resetState.playerSkins = updatedPlayerSkins;
			}

			set(resetState as Partial<ImprovementState>);
		}, 6500);
	},

	setPlayerInventoryFilter(filter) {
		set({ playerInventoryFilter: filter });
	},

	setServerInventoryFilter(filter) {
		set({ serverInventoryFilter: filter });
	},
}));

// ── SVG Icons ──────────────────────────────────────────────────────────────────

const InfoIcon = memo(() => (
	<svg
		width="1rem"
		height="1rem"
		viewBox="0 0 16 16"
		fill="none"
		xmlns="http://www.w3.org/2000/svg"
	>
		<path
			d="M8.4278 11.3278C8.5426 11.2126 8.6 11.07 8.6 10.9V8.5C8.6 8.33 8.5424 8.1876 8.4272 8.0728C8.312 7.958 8.1696 7.9004 8 7.9C7.8304 7.8996 7.688 7.9572 7.5728 8.0728C7.4576 8.1884 7.4 8.3308 7.4 8.5V10.9C7.4 11.07 7.4576 11.2126 7.5728 11.3278C7.688 11.443 7.8304 11.5004 8 11.5C8.1696 11.4996 8.3122 11.4426 8.4278 11.3278ZM8.4278 6.5272C8.5426 6.4124 8.6 6.27 8.6 6.1C8.6 5.93 8.5424 5.7876 8.4272 5.6728C8.312 5.558 8.1696 5.5004 8 5.5C7.8304 5.4996 7.688 5.5572 7.5728 5.6728C7.4576 5.7884 7.4 5.9308 7.4 6.1C7.4 6.2692 7.4576 6.4118 7.5728 6.5278C7.688 6.6438 7.8304 6.7012 8 6.7C8.1696 6.6988 8.3122 6.6412 8.4278 6.5272ZM8 14.5C7.17 14.5 6.39 14.3424 5.66 14.0272C4.93 13.712 4.295 13.2846 3.755 12.745C3.215 12.2054 2.7876 11.5704 2.4728 10.84C2.158 10.1096 2.0004 9.3296 2 8.5C1.9996 7.6704 2.1572 6.8904 2.4728 6.16C2.7884 5.4296 3.2158 4.7946 3.755 4.255C4.2942 3.7154 4.9292 3.288 5.66 2.9728C6.3908 2.6576 7.1708 2.5 8 2.5C8.8292 2.5 9.6092 2.6576 10.34 2.9728C11.0708 3.288 11.7058 3.7154 12.245 4.255C12.7842 4.7946 13.2118 5.4296 13.5278 6.16C13.8438 6.8904 14.0012 7.6704 14 8.5C13.9988 9.3296 13.8412 10.1096 13.5272 10.84C13.2132 11.5704 12.7858 12.2054 12.245 12.745C11.7042 13.2846 11.0692 13.7122 10.34 14.0278C9.6108 14.3434 8.8308 14.5008 8 14.5ZM8 13.3C9.34 13.3 10.475 12.835 11.405 11.905C12.335 10.975 12.8 9.84 12.8 8.5C12.8 7.16 12.335 6.025 11.405 5.095C10.475 4.165 9.34 3.7 8 3.7C6.66 3.7 5.525 4.165 4.595 5.095C3.665 6.025 3.2 7.16 3.2 8.5C3.2 9.84 3.665 10.975 4.595 11.905C5.525 12.835 6.66 13.3 8 13.3Z"
			fill="rgb(var(--primaryColor))"
		/>
	</svg>
));

const UpgradeIcon = memo(() => (
	<svg
		width="1.3125rem"
		height="1.3125rem"
		viewBox="0 0 21 21"
		fill="none"
		xmlns="http://www.w3.org/2000/svg"
	>
		<path
			d="M6.37882 9.564L7.01882 10.3983L10.9689 7.5363L14.92 10.3983L15.56 9.564L10.9689 6.234L6.37882 9.564ZM6.37882 12.6897L7.01882 13.524L10.9689 10.662L14.92 13.524L15.56 12.6897L10.9689 9.3597L6.37882 12.6897ZM11 1.5L3 6V15L11 19.5L19 15V6L11 1.5ZM17.9289 14.406L11 18.3057L4.07106 14.406V6.6057L11 2.6997L17.9289 6.6003V14.406Z"
			fill="rgb(var(--primaryColor))"
		/>
	</svg>
));

const InventoryIcon = memo(() => (
	<svg
		width="1.3125rem"
		height="1.3125rem"
		viewBox="0 0 21 21"
		fill="none"
		xmlns="http://www.w3.org/2000/svg"
	>
		<path
			d="M18.0841 9.03239V15.8226C18.084 15.9255 18.0485 16.0253 17.9836 16.1051C17.9187 16.1849 17.8284 16.2399 17.7278 16.2607L10.4628 18.4777C10.4069 18.4978 10.3471 18.5044 10.2882 18.4971C10.2293 18.4899 10.1729 18.4689 10.1236 18.4358L3.40588 15.2959C3.32967 15.2613 3.26499 15.2055 3.21952 15.1351C3.17404 15.0647 3.14968 14.9827 3.14933 14.8988V7.59149L1.05896 3.99449C0.933538 3.78688 1.01715 3.51451 1.22524 3.38976C1.28493 3.35112 1.35383 3.32917 1.42483 3.32615C1.49582 3.32314 1.56632 3.33918 1.62906 3.37261L8.19948 6.29916L9.63708 6.02679L11.1155 2.76788C11.1992 2.56026 11.4548 2.4536 11.6619 2.51931L19.6699 4.7478C19.9018 4.81256 20.05 5.06112 19.9844 5.29254C19.9844 5.33349 19.9607 5.35729 19.9436 5.3992L18.0841 9.03239ZM10.5217 9.86759L15.8683 8.82477L9.91073 6.882L9.04228 7.04675L10.5217 9.86759ZM17.1748 9.47046L10.7298 10.7447V17.4701L17.1748 15.4855V9.47046ZM11.7693 3.47356L10.5454 6.14679L17.3886 8.38003L18.886 5.4592L11.7693 3.47356ZM9.82712 10.6618L4.05864 8.15528V14.6312L9.82616 17.3282L9.82712 10.6618ZM2.53742 4.7478L3.91042 7.11246L9.27412 9.45332L8.13391 7.26008L2.53742 4.7478Z"
			fill="rgb(var(--primaryColor))"
		/>
	</svg>
));

function WheelBorder() {
	return (
		<svg
			width="17.75rem"
			height="17.75rem"
			viewBox="0 0 284 284"
			fill="none"
			xmlns="http://www.w3.org/2000/svg"
			className="absolute"
		>
			<path
				d="M284 142C284 220.424 220.424 284 142 284C63.5756 284 0 220.424 0 142C0 63.5756 63.5756 0 142 0C220.424 0 284 63.5756 284 142ZM1.42 142C1.42 219.64 64.3598 282.58 142 282.58C219.64 282.58 282.58 219.64 282.58 142C282.58 64.3598 219.64 1.42 142 1.42C64.3598 1.42 1.42 64.3598 1.42 142Z"
				fill="#252525"
			/>
			<path
				d="M223.448 25.6804C198.884 8.48033 169.505 -0.501723 139.522 0.021627C109.539 0.544977 80.4913 10.5469 56.5423 28.5938L60.8151 34.2641C83.5667 17.1195 111.162 7.61773 139.646 7.12055C168.129 6.62337 196.039 15.1563 219.376 31.4964L223.448 25.6804Z"
				fill="#4D4D4D"
			/>
			<path
				d="M202.012 270.696C229.19 258.022 251.658 237.071 266.196 210.843C280.734 184.615 286.596 154.458 282.942 124.694L275.894 125.56C279.366 153.836 273.798 182.485 259.986 207.401C246.175 232.317 224.83 252.221 199.011 264.261L202.012 270.696Z"
				fill="#4D4D4D"
			/>
			<path
				d="M4.83854 178.752C12.5999 207.718 29.3319 233.483 52.6365 252.355C75.9412 271.226 104.622 282.236 134.568 283.805L134.94 276.715C106.491 275.224 79.2441 264.765 57.1047 246.837C34.9653 228.909 19.0699 204.432 11.6966 176.915L4.83854 178.752Z"
				fill="#4D4D4D"
			/>
		</svg>
	);
}

function SideBracket({ flipX }: { flipX?: boolean }) {
	return (
		<svg
			width="2.8125rem"
			height="5.0625rem"
			viewBox="0 0 45 81"
			fill="none"
			xmlns="http://www.w3.org/2000/svg"
			className={cn({ "-scale-x-100 ": flipX })}
		>
			<path
				d="M44.0098 61.3229L44.543 61.8619L44.6816 62.0026L44.543 62.1432L26.667 80.2057C26.4176 80.4577 26.0783 80.6002 25.7246 80.6002H0.200195V79.4381H25.7246C25.7709 79.4381 25.8163 79.4191 25.8496 79.3854L43.7256 61.3229L43.8672 61.1793L44.0098 61.3229ZM25.7246 0.199829C26.0783 0.199865 26.4176 0.342352 26.667 0.59436L44.543 18.6569L44.6816 18.7975L44.543 18.9381L44.0098 19.4772L43.8672 19.6207L43.7256 19.4772L25.8496 1.41467C25.8163 1.38098 25.7709 1.36195 25.7246 1.36194H0.200195V0.199829H25.7246Z"
				fill="#4D4D4D"
				stroke="#4D4D4D"
				strokeWidth="0.4"
			/>
		</svg>
	);
}

function TargetBracket({ flipX }: { flipX?: boolean }) {
	return (
		<svg
			width="1.0625rem"
			height="16.25rem"
			viewBox="0 0 17 260"
			fill="none"
			xmlns="http://www.w3.org/2000/svg"
			className={cn("absolute", { "-scale-x-100 right-0": flipX }, { "left-0": !flipX })}
		>
			<rect width="1" height="240" transform="translate(0.306641 9.79932)" fill="#252525" />
			<rect
				x="0.00585938"
				y="9.89941"
				width="14"
				height="1.00001"
				transform="rotate(-45 0.00585938 9.89941)"
				fill="#252525"
			/>
			<rect
				x="0.707031"
				y="248.999"
				width="14"
				height="1.00001"
				transform="rotate(45 0.707031 248.999)"
				fill="#252525"
			/>
			<path
				d="M10.703 101.043L14.703 98.0137C15.3616 97.5149 16.3066 97.9847 16.3066 98.8109V160.788C16.3066 161.614 15.3616 162.084 14.703 161.585L10.703 158.556C10.4533 158.367 10.3066 158.072 10.3066 157.759V101.84C10.3066 101.527 10.4533 101.232 10.703 101.043Z"
				fill="#4D4D4D"
			/>
		</svg>
	);
}

const TargetPlaceholderSVG = memo(() => (
	<svg
		width="12.75rem"
		height="6.3125rem"
		viewBox="0 0 204 101"
		fill="none"
		xmlns="http://www.w3.org/2000/svg"
	>
		<g clipPath="url(#clip0_6020_5124)">
			<mask
				id="mask0_6020_5124"
				style={{ maskType: "luminance" }}
				maskUnits="userSpaceOnUse"
				x="0"
				y="0"
				width="204"
				height="101"
			>
				<path d="M204 0H0V101H204V0Z" fill="white" />
			</mask>
			<g mask="url(#mask0_6020_5124)">
				<path
					d="M0 17.89C3.50252 16.1256 4.00746 16.0258 6.43599 16.5447C6.43599 13.3633 6.48408 10.1419 6.41996 6.92053C6.37587 4.68117 6.09936 2.44976 6.05929 0.210373C6.03123 -1.29852 7.16534 -2.05297 8.64407 -1.98511C9.54977 -1.94519 10.4915 -2.48408 11.3892 -2.42021C15.3085 -2.12881 15.9297 -1.18675 15.2724 2.72519C15.1402 3.51157 15.3245 4.45762 15.6611 5.19212C17.1319 8.40549 18.7069 11.567 20.2497 14.7484C21.6202 17.5706 21.7565 17.8141 24.9705 18.345C28.2085 18.8799 31.4946 19.1354 34.7567 19.5146C36.9087 19.7661 39.0888 20.3609 41.2088 20.1892C43.9098 19.9737 46.703 19.4747 49.1596 18.4169C50.2576 17.9459 50.7866 15.8661 51.3036 14.4211C52.5659 10.8844 53.175 10.7127 57.0383 11.3315C61.4745 12.038 65.9828 12.3055 70.4636 12.7166C72.2989 12.8842 74.0902 13.0998 75.7412 11.6588C76.3184 11.1558 77.7049 11.4592 78.7025 11.571C82.8786 12.026 87.054 12.4851 91.2097 13.0639C95.5543 13.6667 99.8619 14.5688 104.218 15.0039C106.021 15.1835 107.909 14.3133 109.772 14.2295C111.379 14.1536 112.926 13.1517 114.689 14.2095C115.511 14.7005 116.918 14.3812 118.024 14.2056C119.43 13.982 120.801 13.3154 121.911 14.8921C122.051 15.0918 122.845 14.8083 123.342 14.7844C124.312 14.7365 125.47 14.4132 125.374 16.1216C123.842 16.397 122.32 16.6685 120.797 16.9399C120.805 17.1156 120.809 17.2912 120.817 17.4668C121.747 17.5227 122.676 17.5786 123.735 17.6425C123.542 20.0096 125.478 19.6823 126.849 19.8898C131.513 20.6044 136.186 21.243 140.871 21.8298C144.79 22.3209 148.741 22.5843 152.649 23.1472C156.463 23.694 160.243 24.4844 164.038 25.179C164.154 25.1989 164.294 25.2867 164.362 25.3825C166.538 28.6239 170.894 30.1727 171.567 34.5956C171.616 34.9189 171.96 35.2941 172.269 35.4618C174.345 36.5834 176.445 37.6573 178.541 38.739C178.769 38.8588 179.082 39.0863 179.246 39.0185C183.393 37.1862 187.625 38.8508 191.809 38.755C194.887 38.6871 197.973 39.258 201.058 39.4216C203.15 39.5294 203.9 40.9864 203.924 42.5552C204.048 50.2394 203.98 57.9315 203.98 65.6716C200.598 67.811 197.777 65.9268 194.971 63.7755C190.086 60.0272 185.021 56.4905 180.312 52.5346C177.25 49.9639 173.567 48.7903 170.157 47.006C169.5 46.6627 168.654 46.6707 167.804 46.499C166.619 50.3591 166.831 54.0156 167.624 57.7718C168.446 61.6598 168.999 65.6159 169.476 69.5674C169.692 71.348 167.127 73.7989 165.328 73.7707C163.352 73.7392 161.376 73.5831 159.846 73.5037C158.383 66.6213 156.981 60.0192 155.578 53.4288C151.795 53.4288 148.352 53.4288 144.645 53.4288C143.667 54.4866 147.226 58.175 142.842 57.8557C140.81 64.0549 139.135 70.2901 136.719 76.2301C134.01 82.8882 130.435 89.1469 125.626 94.6199C124.841 95.5139 124.464 96.7514 123.767 97.7378C123.486 98.1326 122.853 98.5078 122.384 98.5039C120.933 98.492 119.194 99.079 118.284 97.3424C116.553 94.033 114.79 90.7282 113.271 87.3191C112.47 85.5188 112.161 83.5027 111.676 81.7582C122.452 70.8567 127.077 57.3208 129.144 42.2837C125.99 41.8646 122.909 41.2339 119.811 41.1261C118.072 41.0663 116.296 41.8606 114.541 42.2797C111.259 43.0621 108.354 42.4913 105.36 40.7469C103.26 39.5254 100.6 39.1542 98.1385 38.6791C92.0994 37.5136 85.9919 36.6713 79.9851 35.366C77.2476 34.7712 74.743 33.1665 72.0219 32.448C69.9503 31.9011 67.6984 32.0329 65.526 31.8532C60.7251 31.462 55.9282 31.0309 51.1273 30.7036C50.2977 30.6477 49.1997 30.0888 48.6466 31.5778C48.4944 31.9849 47.0036 31.977 46.1219 32.0089C45.3404 32.0368 44.547 31.8532 43.5892 31.7414C43.3608 29.8494 41.7658 29.9611 40.3191 29.8613C34.2518 29.4502 28.1845 29.0071 22.1132 28.6757C19.5645 28.536 17.0037 28.7316 14.4509 28.6199C13.425 28.576 12.4111 28.1329 11.4012 27.8375C10.2391 27.4942 9.08491 27.115 7.74239 26.6879C7.63822 26.3845 7.31761 25.8456 7.28958 25.2907C7.22147 23.8616 6.56022 23.4026 5.14158 23.4265C3.42238 23.4505 1.71118 23.207 0 23.0833C0 21.3508 0 19.6224 0 17.89ZM43.1524 26.7078C41.1126 26.5442 39.2732 26.4244 37.4378 26.2448C33.6427 25.8735 29.8556 25.4584 26.0605 25.0912C24.2973 24.9195 22.514 24.672 20.7546 24.7558C19.4843 24.8157 18.234 25.3705 17.1118 25.6659C17.9294 26.592 38.123 28.7117 42.7757 28.1408C42.8919 27.7017 43.0081 27.2586 43.1524 26.7078ZM72.1541 20.7401C67.3898 20.0974 62.7409 19.4548 58.0802 18.864C57.7356 18.82 57.1384 19.0515 57.0102 19.323C56.6095 20.1812 57.8037 21.8059 58.8216 21.9057C61.6268 22.1811 64.4641 22.2809 67.2292 22.7879C69.3409 23.1751 71.2447 23.7778 72.1541 20.7401ZM48.3701 28.9592C56.5894 29.6138 64.1194 30.2126 71.6494 30.8114C71.7376 30.5838 71.8258 30.3523 71.91 30.1248C71.4171 29.7735 70.9565 29.1708 70.4313 29.1069C67.5576 28.7476 64.6765 28.4203 61.7871 28.2726C57.7956 28.069 53.8002 28.0131 49.8007 27.9533C49.4882 27.9493 49.1676 28.3843 48.3701 28.9592ZM148.609 44.8345C148.484 47.0459 148.436 48.8742 148.26 50.6904C148.124 52.0995 148.773 52.9777 150.056 52.9857C151.386 52.9936 153.27 53.9278 153.767 51.5127C153.037 51.4409 152.324 51.369 151.855 51.3211C152.071 49.3851 152.275 47.5329 152.5 45.541C151.153 45.2935 150.083 45.1019 148.609 44.8345ZM10.9203 14.5728C12.6475 14.7444 14.2385 14.9041 15.8896 15.0718C15.0761 12.6408 13.8298 10.9363 10.9203 11.1958C10.9203 12.2576 10.9203 13.3473 10.9203 14.5728Z"
					fill="#272727"
				/>
			</g>
		</g>
		<defs>
			<clipPath id="clip0_6020_5124">
				<rect width="204" height="101" fill="white" />
			</clipPath>
		</defs>
	</svg>
));

// ── Utilities ──────────────────────────────────────────────────────────────────

function easeOutQuart(t: number): number {
	return 1 - Math.pow(1 - t, 4);
}

// ── Components ─────────────────────────────────────────────────────────────────

function BalanceInput() {
	const { balance, setBalance } = useImprovementStore(
		useShallow((s) => ({ balance: s.balance, setBalance: s.setBalance })),
	);
	const skinsCoins = useMainStore((s) => s.skinsCoins);

	return (
		<div className="flex flex-col items-center">
			<div className="flex h-11 items-center justify-center rounded-[.4375rem] border border-white/[.16] border-solid p-[.1875rem]">
				<input
					placeholder="0"
					max={skinsCoins}
					min={0}
					type="range"
					className="flex h-full w-full items-center justify-center rounded-[.3125rem] border border-white/[.16] border-solid bg-transparent text-center font-semibold text-sm text-white outline-none transition-all duration-300 placeholder:text-[#adadad] focus:border-primaryColor"
					value={balance.toString().replace(/^0+/, "")}
					onChange={(e) => {
						if (e.target.value === "") return setBalance(0);
						const num = Number(e.target.value);
						if (Number.isNaN(num) || num <= 0) return;
						setBalance(num);
					}}
				/>
			</div>
			<span className="mt-2 font-semibold text-sm">
				{balance} SkinCoins
			</span>
		</div>
	);
}

function ImprovementWheel() {
	const { balance, selectedPlayerSkins, successChance, status } = useImprovementStore(
		useShallow((s) => ({
			balance: s.balance,
			successChance: s.successChance,
			selectedPlayerSkins: s.selectedPlayerSkins,
			status: s.status,
		})),
	);

	const [rotation, setRotation] = useState(0);
	const [showResult, setShowResult] = useState(false);
	const lastRotationRef = useRef(0);
	const animFrameRef = useRef<number | null>(null);

	useEffect(() => {
		if (status === null) {
			setShowResult(false);
			return;
		}

		if (animFrameRef.current !== null) cancelAnimationFrame(animFrameRef.current);
		setShowResult(false);

		const successArc = 360 * (successChance / 100);
		const fullSpins = 4 + Math.floor(Math.random() * 3);
		const padding = 12;

		let targetAngle: number;

		if (status === "improved") {
			const min = padding;
			const max = successArc - padding;
			targetAngle = max > min ? min + Math.random() * (max - min) : successArc / 2;
		} else {
			const min = successArc + padding;
			const max = 360 - padding;
			targetAngle = max > min ? min + Math.random() * (max - min) : successArc + (360 - successArc) / 2;
		}

		const normalizedLast = ((lastRotationRef.current % 360) + 360) % 360;
		let diff = targetAngle - normalizedLast;
		if (diff < 0) diff += 360;

		const totalRotation = fullSpins * 360 + diff;
		const startRotation = lastRotationRef.current;
		const duration = 5000;
		let startTime: number | null = null;

		function animate(timestamp: number) {
			if (!startTime) startTime = timestamp;

			const elapsed = timestamp - startTime;
			const progress = Math.min(elapsed / duration, 1);
			const currentRotation = startRotation + totalRotation * easeOutQuart(progress);

			setRotation(currentRotation);

			if (progress < 1) {
				animFrameRef.current = requestAnimationFrame(animate);
			} else {
				lastRotationRef.current = startRotation + totalRotation;
				animFrameRef.current = null;
				setShowResult(true);
			}
		}

		animFrameRef.current = requestAnimationFrame(animate);

		return () => {
			if (animFrameRef.current !== null) cancelAnimationFrame(animFrameRef.current);
		};
	}, [status]);

	const isFinished = showResult && status !== null;
	const isSuccess = status === "improved";

	return (
		<div className="flex items-center gap-6">
			<SideBracket />

			<div className="relative flex size-[17.75rem] items-center justify-center">
				<WheelBorder />

				{selectedPlayerSkins.length === 0 && balance <= 0 && (
					<div className="flex size-[13.125rem] flex-col items-center justify-center rounded-full border-2 border-primaryColor/40 border-solid bg-primaryColor/10">
						<UpgradeIcon />
						<span className="w-[10.625rem] text-center font-medium text-sm">
							Nenhum item selecionado para aprimorar.
						</span>
					</div>
				)}

				{(selectedPlayerSkins.length > 0 || balance > 0) && (
					<div className="relative flex size-[13.125rem] flex-col items-center justify-center rounded-full">
						{/* Rotating pointer */}
						<div
							className="absolute inset-0"
							style={{
								transform: `rotate(${rotation}deg)`,
								transformOrigin: "center center",
							}}
						>
							<div className="-translate-x-1/2 absolute top-0 left-1/2">
								<svg
									width=".875rem"
									height=".5rem"
									viewBox="0 0 14 8"
									fill="none"
									xmlns="http://www.w3.org/2000/svg"
								>
									<path
										d="M6.42417 7.78378C6.6801 8.07207 7.3199 8.07207 7.57583 7.78378L13.9099 0.648648C14.1659 0.36036 13.8459 0 13.3341 0H0.665899C0.154053 0 -0.16585 0.36036 0.0900729 0.648649L6.42417 7.78378Z"
										fill="rgb(var(--primaryColor))"
									/>
								</svg>
							</div>
						</div>

						{/* Circular progress ring */}
						<svg
							width="13.125rem"
							height="13.625rem"
							viewBox="0 0 210 218"
							fill="none"
							xmlns="http://www.w3.org/2000/svg"
							className="-rotate-90 absolute"
						>
							<rect
								x="0.5"
								y="8.5"
								width="209"
								height="209"
								rx="104.5"
								stroke="rgb(var(--primaryColor))"
							/>
							<path
								d="M189 113C189 124.031 186.827 134.954 182.606 145.145C178.384 155.337 172.197 164.597 164.397 172.397C156.597 180.197 147.337 186.384 137.145 190.606C126.954 194.827 116.031 197 105 197C93.969 197 83.0459 194.827 72.8546 190.606C62.6632 186.384 53.4031 180.197 45.603 172.397C37.8029 164.597 31.6155 155.337 27.3941 145.145C23.1727 134.954 21 124.031 21 113C21 101.969 23.1727 91.0459 27.3941 80.8546C31.6155 70.6632 37.8029 61.4031 45.603 53.603C53.4032 45.8029 62.6633 39.6155 72.8546 35.3941C83.046 31.1727 93.969 29 105 29C116.031 29 126.954 31.1727 137.145 35.3941C147.337 39.6155 156.597 45.8029 164.397 53.603C172.197 61.4032 178.384 70.6633 182.606 80.8546C186.827 91.046 189 101.969 189 113L189 113Z"
								stroke="rgb(var(--primaryColor))"
								strokeOpacity="0.14"
								strokeWidth="18"
							/>
							<path
								d="M189 113C189 124.031 186.827 134.954 182.606 145.145C178.384 155.337 172.197 164.597 164.397 172.397C156.597 180.197 147.337 186.384 137.145 190.606C126.954 194.827 116.031 197 105 197C93.969 197 83.0459 194.827 72.8546 190.606C62.6632 186.384 53.4031 180.197 45.603 172.397C37.8029 164.597 31.6155 155.337 27.3941 145.145C23.1727 134.954 21 124.031 21 113C21 101.969 23.1727 91.0459 27.3941 80.8546C31.6155 70.6632 37.8029 61.4031 45.603 53.603C53.4032 45.8029 62.6633 39.6155 72.8546 35.3941C83.046 31.1727 93.969 29 105 29C116.031 29 126.954 31.1727 137.145 35.3941C147.337 39.6155 156.597 45.8029 164.397 53.603C172.197 61.4032 178.384 70.6733 182.606 80.8546C186.827 91.046 189 101.969 189 113L189 113Z"
								stroke="rgb(var(--primaryColor))"
								strokeWidth="18"
								pathLength={100.01}
								strokeDasharray={100.01}
								strokeDashoffset={100 - successChance}
								className="transition-all duration-300"
							/>
							<defs>
								<filter
									id="filter0_d_683_3789"
									x="86"
									y="0"
									width="38"
									height="32"
									filterUnits="userSpaceOnUse"
									colorInterpolationFilters="sRGB"
								>
									<feFlood floodOpacity="0" result="BackgroundImageFix" />
									<feColorMatrix
										in="SourceAlpha"
										type="matrix"
										values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"
										result="hardAlpha"
									/>
									<feOffset dy="4" />
									<feGaussianBlur stdDeviation="6" />
									<feComposite in2="hardAlpha" operator="out" />
									<feColorMatrix
										type="matrix"
										values="0 0 0 0 0.960784 0 0 0 0 0.0470588 0 0 0 0 0.0470588 0 0 0 0.45 0"
									/>
									<feBlend
										mode="normal"
										in2="BackgroundImageFix"
										result="effect1_dropShadow_683_3789"
									/>
									<feBlend
										mode="normal"
										in="SourceGraphic"
										in2="effect1_dropShadow_683_3789"
										result="shape"
									/>
								</filter>
							</defs>
						</svg>

						{isFinished ? (
							<div className="z-10 flex flex-col items-center justify-center gap-2">
								<UpgradeIcon />
								<span className="w-[8.625rem] text-center font-[Montserrat] font-medium text-sm">
									{isSuccess
										? "Aprimoramento bem-sucedido!"
										: "Aprimoramento fracassado!"}
								</span>
							</div>
						) : (
							<div className="z-10 flex flex-col items-center justify-center gap-1">
								<h1 className="font-[Montserrat] font-semibold text-[#f2f2f2] text-[1.875rem]">
									{successChance.toFixed(2)}%
								</h1>
								<span className="text-[#adadad] text-[.6875rem]">
									Chance de sucesso
								</span>
							</div>
						)}
					</div>
				)}
			</div>

			<SideBracket flipX />
		</div>
	);
}

function ImproveButton() {
	const improve = useImprovementStore((s) => s.improve);

	return (
		<button
			type="button"
			className={cn(
				"group relative mt-6 flex h-8 w-[8.75rem] items-center justify-center gap-2 rounded-[.3125rem] bg-[#D3D3D326] outline outline-1 outline-white/10 outline-offset-2 transition-all duration-300 [&:hover>.coin>path]:stroke-white",
			)}
			onClick={improve}
		>
			<div
				className={cn(
					"absolute size-full rounded-[.3125rem] border border-primaryColor border-solid opacity-0 transition-all duration-300 group-hover:opacity-100",
				)}
				style={{
					background:
						"linear-gradient(134.74deg, rgb(var(--primaryColor)) -47.65%, rgba(var(--primaryColor), 0.5) 122.65%)",
				}}
			/>
			<span
				className={cn(
					"duraiton-300 relative z-10 font-semibold text-[#adadad] text-[.8125rem] transition-all group-hover:text-white ",
				)}
			>
				Aprimorar
			</span>
		</button>
	);
}

// ── Player Inventory ───────────────────────────────────────────────────────────

function PlayerInventorySearch() {
	const { playerInventoryFilter, setPlayerInventoryFilter } = useImprovementStore(
		useShallow((s) => ({
			playerInventoryFilter: s.playerInventoryFilter,
			setPlayerInventoryFilter: s.setPlayerInventoryFilter,
		})),
	);

	return (
		<div className="grid h-[2.125rem] w-full place-items-center rounded-md border border-white/[.16] border-solid p-0.5">
			<div className="flex size-full items-center justify-between rounded-[.25rem] border border-white/[.06] border-solid bg-[#080808]/[.38] px-2">
				<input
					placeholder="Procurar..."
					className="w-[calc(100%-.5rem-.875rem)] bg-transparent text-white text-xs outline-none placeholder:text-[#adadad]"
					value={playerInventoryFilter}
					onChange={(e) => setPlayerInventoryFilter(e.target.value)}
				/>
				<SearchIcon />
			</div>
		</div>
	);
}

function PlayerInventoryHeader() {
	return (
		<header className="flex min-h-[3rem] w-full items-center justify-center rounded-[.4375rem] border border-white/[.16] border-solid p-[.1875rem]">
			<div className="flex size-full items-center gap-2 rounded-[.3125rem] border border-white/[.06] border-solid bg-white/[.08] px-2 font-semibold text-sm">
				<InventoryIcon />
				Meu inventário
			</div>
		</header>
	);
}

function PlayerSkinCard({ image, model_name, name, rarity, quantity, value }: Skin) {
	const { selectedSkins, setSelectedSkins } = useImprovementStore(
		useShallow((s) => ({
			selectedSkins: s.selectedPlayerSkins,
			setSelectedSkins: s.setSelectedPlayerSkins,
		})),
	);

	const rarityData = RARITY_MAP[rarity] || RARITY_MAP.comum;
	const color = `rgb(${rarityData.rgb})`;
	const isSelected = selectedSkins.some((s) => s.model_name === model_name);
	const { isImageValid } = useImageValidation(image);

	return (
		<button
			type="button"
			className="group relative flex h-[11.25rem] w-[11.0625rem] cursor-pointer flex-col items-center overflow-hidden rounded-[.375rem] transition-all duration-300"
			style={{
				background: `linear-gradient(180deg, rgba(${rarityData.rgb}, 0.24) -17.86%, rgba(${rarityData.rgb}, 0) 53.57%), rgba(12, 12, 12, 0.24)`,
				border: `.125rem solid ${isSelected ? "rgb(var(--primaryColor))" : color}`,
			}}
			onClick={() => {
				if (isSelected) {
					return setSelectedSkins(selectedSkins.filter((s) => s.model_name !== model_name));
				}
				setSelectedSkins([...selectedSkins, { image, model_name, name, rarity, value }]);
			}}
		>
			{quantity != null && quantity > 1 && (
				<div
					className="absolute left-[.5rem] top-[.5rem] z-10 flex h-[1.375rem] items-center justify-center rounded-[.25rem] px-[.375rem]"
					style={{
						background: "rgba(0, 0, 0, 0.60)",
						border: "0.7px solid rgba(255, 255, 255, 0.20)",
					}}
				>
					<span
						className="font-bold text-[.6875rem] tracking-[-0.0275rem] text-white/80"
						style={{ fontFamily: "Montserrat, sans-serif" }}
					>
						x{quantity}
					</span>
				</div>
			)}

			<svg
				width="1.25rem"
				height="1.25rem"
				viewBox="0 0 20 20"
				fill="none"
				xmlns="http://www.w3.org/2000/svg"
				className={cn(
					"transiton-all absolute top-3 right-3 scale-0 opacity-0 duration-300",
					{ "scale-100 opacity-100": isSelected },
				)}
			>
				<path
					fillRule="evenodd"
					clipRule="evenodd"
					d="M10 17.5C10.9849 17.5 11.9602 17.306 12.8701 16.9291C13.7801 16.5522 14.6069 15.9997 15.3033 15.3033C15.9997 14.6069 16.5522 13.7801 16.9291 12.8701C17.306 11.9602 17.5 10.9849 17.5 10C17.5 9.01509 17.306 8.03982 16.9291 7.12987C16.5522 6.21993 15.9997 5.39314 15.3033 4.6967C14.6069 4.00026 13.7801 3.44781 12.8701 3.0709C11.9602 2.69399 10.9849 2.5 10 2.5C8.01088 2.5 6.10322 3.29018 4.6967 4.6967C3.29018 6.10322 2.5 8.01088 2.5 10C2.5 11.9891 3.29018 13.8968 4.6967 15.3033C6.10322 16.7098 8.01088 17.5 10 17.5ZM9.80667 13.0333L13.9733 8.03333L12.6933 6.96667L9.11 11.2658L7.25583 9.41083L6.0775 10.5892L8.5775 13.0892L9.2225 13.7342L9.80667 13.0333Z"
					fill="rgb(var(--primaryColor))"
				/>
			</svg>

			<div className="relative flex h-[7.5rem] w-full items-center justify-center py-[.5rem]">
				<div className="scale-[1.3]">
					<DiamondIcon color={color} />
				</div>
				{!isImageValid && <SkinFallbackSVG fill={color} />}
				{isImageValid && (
					<img
						src={image}
						alt={name}
						className="absolute max-h-[6.25rem] w-[85%] object-contain transition-transform group-hover:scale-105"
						onError={(e) => {
							(e.target as HTMLImageElement).src = image;
						}}
					/>
				)}
			</div>

			<div className="flex flex-col items-center gap-[.125rem] pb-[.625rem]">
				<span
					className="w-full px-[.25rem] text-center font-semibold text-[#F2F2F2] text-sm tracking-[-0.04rem]"
					style={{ fontFamily: "Montserrat, sans-serif" }}
				>
					{name}
				</span>
			</div>
		</button>
	);
}

function PlayerSkinsList() {
	const { filter, skins } = useImprovementStore(
		useShallow((s) => ({
			skins: s.playerSkins,
			filter: s.playerInventoryFilter,
		})),
	);

	return (
		<div className="scrollbar-hide flex min-h-0 flex-1 w-full flex-wrap content-start gap-2 overflow-auto pb-4">
			{skins?.length > 0 &&
				skins
					.filter((s) => s.name.toLocaleLowerCase().includes(filter.toLocaleLowerCase()))
					.map((skin) => <PlayerSkinCard key={skin.model_name} {...skin} />)}
		</div>
	);
}

function PlayerInventory() {
	return (
		<div className="flex h-full w-[calc(50%-26.25rem/2)] flex-col gap-2">
			<PlayerInventoryHeader />
			<div className="flex min-h-0 w-full flex-1 flex-col gap-4 rounded-md border border-white/[.16] border-solid p-4 pb-0">
				<PlayerInventorySearch />
				<PlayerSkinsList />
			</div>
		</div>
	);
}

// ── Target Display ─────────────────────────────────────────────────────────────

function TargetDisplay() {
	const { selectedServerSkin } = useImprovementStore(
		useShallow((s) => ({ selectedServerSkin: s.selectedServerSkin })),
	);

	return (
		<div className="relative flex h-[18.75rem] w-[19.125rem] flex-col items-center justify-center">
			<TargetBracket />

			{!selectedServerSkin && (
				<>
					<TargetPlaceholderSVG />
					<h1 className="font-semibold text-sm">Selecione itens</h1>
					<span className="text-[#ADADAD] text-xs">
						Escolha itens que deseja receber
					</span>
				</>
			)}

			{selectedServerSkin && <SkinCard {...selectedServerSkin} />}

			<TargetBracket flipX />
		</div>
	);
}

// ── Server Inventory ───────────────────────────────────────────────────────────

function ServerInventorySearch() {
	const { serverInventoryFilter, setServerInventoryFilter } = useImprovementStore(
		useShallow((s) => ({
			serverInventoryFilter: s.serverInventoryFilter,
			setServerInventoryFilter: s.setServerInventoryFilter,
		})),
	);

	return (
		<div className="grid h-[2.125rem] w-full place-items-center rounded-md border border-white/[.16] border-solid p-0.5">
			<div className="flex size-full items-center justify-between rounded-[.25rem] border border-white/[.06] border-solid bg-[#080808]/[.38] px-2">
				<input
					placeholder="Procurar..."
					className="w-[calc(100%-.5rem-.875rem)] bg-transparent text-white text-xs outline-none placeholder:text-[#adadad]"
					value={serverInventoryFilter}
					onChange={(e) => setServerInventoryFilter(e.target.value)}
				/>
				<SearchIcon />
			</div>
		</div>
	);
}

function ServerInventoryHeader() {
	return (
		<header className="flex min-h-[3rem] w-full items-center justify-center rounded-[.4375rem] border border-white/[.16] border-solid p-[.1875rem]">
			<div className="flex size-full h-full min-h-full w-full items-center gap-2 rounded-[.3125rem] border border-white/[.06] border-solid bg-white/[.08] px-2 font-semibold text-sm">
				<UpgradeIcon />
				Item a receber
			</div>
		</header>
	);
}

function ServerSkinCard({ image, model_name, name, rarity }: Skin) {
	const { selectedServerSkin, setSelectedServerSkin } = useImprovementStore(
		useShallow((s) => ({
			selectedServerSkin: s.selectedServerSkin,
			setSelectedServerSkin: s.setSelectedServerSkin,
		})),
	);

	const rarityData = RARITY_MAP[rarity] || RARITY_MAP.comum;
	const color = `rgb(${rarityData.rgb})`;

	const isSelected = useMemo(
		() => model_name === selectedServerSkin?.model_name,
		[model_name, selectedServerSkin],
	);

	const { isImageValid } = useImageValidation(image);

	return (
		<button
			type="button"
			className="group relative flex h-[11.25rem] w-[11.0625rem] cursor-pointer flex-col items-center overflow-hidden rounded-[.375rem] transition-all duration-300"
			style={{
				background: `linear-gradient(180deg, rgba(${rarityData.rgb}, 0.24) -17.86%, rgba(${rarityData.rgb}, 0) 53.57%), rgba(12, 12, 12, 0.24)`,
				border: `.125rem solid ${isSelected ? "rgb(var(--primaryColor))" : color}`,
			}}
			onClick={() => {
				if (isSelected) return setSelectedServerSkin(null);
				setSelectedServerSkin({ image, model_name, name, rarity });
			}}
		>
			<svg
				width="1.25rem"
				height="1.25rem"
				viewBox="0 0 20 20"
				fill="none"
				xmlns="http://www.w3.org/2000/svg"
				className={cn(
					"transiton-all absolute top-3 right-3 scale-0 opacity-0 duration-300",
					{ "scale-100 opacity-100": isSelected },
				)}
			>
				<path
					fillRule="evenodd"
					clipRule="evenodd"
					d="M10 17.5C10.9849 17.5 11.9602 17.306 12.8701 16.9291C13.7801 16.5522 14.6069 15.9997 15.3033 15.3033C15.9997 14.6069 16.5522 13.7801 16.9291 12.8701C17.306 11.9602 17.5 10.9849 17.5 10C17.5 9.01509 17.306 8.03982 16.9291 7.12987C16.5522 6.21993 15.9997 5.39314 15.3033 4.6967C14.6069 4.00026 13.7801 3.44781 12.8701 3.0709C11.9602 2.69399 10.9849 2.5 10 2.5C8.01088 2.5 6.10322 3.29018 4.6967 4.6967C3.29018 6.10322 2.5 8.01088 2.5 10C2.5 11.9891 3.29018 13.8968 4.6967 15.3033C6.10322 16.7098 8.01088 17.5 10 17.5ZM9.80667 13.0333L13.9733 8.03333L12.6933 6.96667L9.11 11.2658L7.25583 9.41083L6.0775 10.5892L8.5775 13.0892L9.2225 13.7342L9.80667 13.0333Z"
					fill="rgb(var(--primaryColor))"
				/>
			</svg>

			<div className="relative flex h-[7.5rem] w-full items-center justify-center py-[.5rem]">
				<div className="scale-[1.3]">
					<DiamondIcon color={color} />
				</div>
				{!isImageValid && <SkinFallbackSVG fill={color} />}
				{isImageValid && (
					<img
						src={image}
						alt={name}
						className="absolute max-h-[6.25rem] w-[85%] object-contain transition-transform group-hover:scale-105"
						onError={(e) => {
							(e.target as HTMLImageElement).src = image;
						}}
					/>
				)}
			</div>

			<div className="flex flex-col items-center gap-[.125rem] pb-[.625rem]">
				<span
					className="w-full px-[.25rem] text-center font-semibold text-[#F2F2F2] text-sm tracking-[-0.04rem]"
					style={{ fontFamily: "Montserrat, sans-serif" }}
				>
					{name}
				</span>
			</div>
		</button>
	);
}

function ServerSkinsList() {
	const { filter, skins, selectedPlayerSkins, balance, config } = useImprovementStore(
		useShallow((s) => ({
			skins: s.serverSkins,
			filter: s.serverInventoryFilter,
			selectedPlayerSkins: s.selectedPlayerSkins,
			balance: s.balance,
			config: s.config,
		})),
	);

	const totalValue = useMemo(() => {
		let total = balance;
		for (const skin of selectedPlayerSkins) {
			total += skin.value ?? 0;
		}
		return total;
	}, [selectedPlayerSkins, balance]);

	const minMarkup = config?.minTargetMarkup;
	const maxMarkup = config?.maxTargetMarkup;
	const minValue = minMarkup !== false ? totalValue * (minMarkup ?? 1.25) : null;
	const maxValue = maxMarkup !== false ? totalValue * (maxMarkup ?? 1.2) : null;

	const filteredSkins = useMemo(
		() =>
			skins?.filter(
				(skin) =>
					!(
						!skin.name.toLocaleLowerCase().includes(filter.toLocaleLowerCase()) ||
						(totalValue > 0 && minValue !== null && (skin.value ?? 0) < minValue) ||
						(totalValue > 0 && maxValue !== null && (skin.value ?? 0) > maxValue)
					),
			) ?? [],
		[skins, filter, totalValue, minValue, maxValue],
	);

	return (
		<div className="scrollbar-hide flex min-h-0 flex-1 w-full flex-wrap content-start gap-2 overflow-auto pb-4">
			{filteredSkins.map((skin) => (
				<ServerSkinCard key={skin.model_name} {...skin} />
			))}
		</div>
	);
}

function ServerInventory() {
	return (
		<div className="flex h-full w-[calc(50%-26.25rem/2)] flex-col gap-2">
			<ServerInventoryHeader />
			<div className="flex min-h-0 w-full flex-1 flex-col gap-4 rounded-md border border-white/[.16] border-solid p-4 pb-0">
				<ServerInventorySearch />
				<ServerSkinsList />
			</div>
		</div>
	);
}

// ── Main Page ──────────────────────────────────────────────────────────────────

export function Aprimoramento() {
	const visible = useVisibility((s) => s.visible);
	const getData = useImprovementStore((s) => s.getData);
	const selectedServerSkin = useImprovementStore((s) => s.selectedServerSkin);

	useEffect(() => {
		if (visible) getData();
	}, [visible, getData]);

	const rarityColor = `rgb(${(RARITY_MAP[selectedServerSkin?.rarity as string] || RARITY_MAP.comum).rgb})`;

	return (
		<div className="flex h-full w-full flex-col items-center">
			<div className="mb-4 flex min-h-0 w-full flex-1 items-start justify-center gap-[1.75rem]">
				<PlayerInventory />

				<div className="flex flex-col items-center gap-4">
					<header className="mb-4 flex items-center gap-1.5 font-semibold text-[.8125rem] text-primaryColor">
						<InfoIcon />
						Como funciona?
					</header>

					<BalanceInput />
					<ImprovementWheel />

					{/* Down-arrow bracket (rotated SideBracket SVG) */}
					<svg
						width="2.8125rem"
						height="5.0625rem"
						viewBox="0 0 45 81"
						fill="none"
						xmlns="http://www.w3.org/2000/svg"
						className="rotate-90"
					>
						<path
							d="M44.0098 61.3229L44.543 61.8619L44.6816 62.0026L44.543 62.1432L26.667 80.2057C26.4176 80.4577 26.0783 80.6002 25.7246 80.6002H0.200195V79.4381H25.7246C25.7709 79.4381 25.8163 79.4191 25.8496 79.3854L43.7256 61.3229L43.8672 61.1793L44.0098 61.3229ZM25.7246 0.199829C26.0783 0.199865 26.4176 0.342352 26.667 0.59436L44.543 18.6569L44.6816 18.7975L44.543 18.9381L44.0098 19.4772L43.8672 19.6207L43.7256 19.4772L25.8496 1.41467C25.8163 1.38098 25.7709 1.36195 25.7246 1.36194H0.200195V0.199829H25.7246Z"
							fill={rarityColor || "#4d4d4d"}
							stroke={rarityColor || "#4d4d4d"}
							className="transition-all duration-300"
							strokeWidth="0.4"
						/>
					</svg>

					<TargetDisplay />
					<ImproveButton />
				</div>

				<ServerInventory />
			</div>
		</div>
	);
}
