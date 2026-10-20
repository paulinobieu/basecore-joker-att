import React, { useState, useEffect, useMemo, memo } from "react";
import { create } from "zustand";
import { useShallow } from "zustand/react/shallow";
import { fetchNui } from "@app/utils/fetchNui";
import { cn } from "@app/utils";
import { formatDateTime } from "@app/utils/misc";
import { hexToRgba } from "@app/utils/colors";
import { useMainStore } from "@app/stores/MainStore";
import { useVisibility } from "@app/stores/Visibility";
import { RARITY_MAP } from "@app/stores/constants";
import { useImageValidation } from "@app/hooks/useImageValidation";
import { SearchIcon } from "@views/components/SearchIcon";
import { SkinCard } from "@views/components/SkinCard";
import { SkinFallbackSVG } from "@views/components/SkinFallbackSVG";
import { DiamondIcon } from "@views/components/DiamondIcon";
import fallbackAvatar from "@views/assets/images/fallback-avatar.png";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface Player {
	id: number;
	name: string;
	avatar?: string;
}

interface SkinItem {
	id: string;
	name: string;
	image: string;
	rarity: string;
	vouchersRequired: number;
	selected?: boolean;
}

interface Trade {
	id: string;
	proposer: Player;
	timestamp: number;
	status: "accepted" | "declined" | "pending";
	proposerItems: SkinItem[];
	otherPlayerItems: SkinItem[];
	otherPlayer?: Player;
}

interface NewTradeData {
	player: SkinItem[];
	otherPlayerItems: SkinItem[];
	otherPlayer: Player;
	playerData: Player;
	selectingSkin: "player" | "otherPlayer";
}

type TradesFilter = "all" | "pending" | "declined" | "accepted";

interface TradeStoreState {
	newTrade: NewTradeData | null;
	selectedTrade: Trade | null;
	trades: Trade[];
	players: Player[];
	tradesFilter: TradesFilter;
	newTradesFilter: string;
	getTradesData: () => Promise<void>;
	getPlayersById: (id: number) => Promise<void>;
	acceptTrade: () => Promise<void>;
	declineTrade: () => Promise<void>;
	getPlayerData: (id: number) => Promise<void>;
	sendTrade: () => Promise<void>;
	setNewTrade: (trade: NewTradeData | null) => void;
	setSelectedTrade: (trade: Trade | null) => void;
	setTradesFilter: (filter: TradesFilter) => void;
	setNewTradesFilter: (filter: string) => void;
	resetStore: () => void;
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const statusColors: Record<Trade["status"], string> = {
	accepted: "#6FAF19",
	declined: "#F50C0C",
	pending: "#CB942B",
};

const initialState = {
	newTrade: null as NewTradeData | null,
	selectedTrade: null as Trade | null,
	trades: [] as Trade[],
	players: [] as Player[],
	tradesFilter: "all" as TradesFilter,
	newTradesFilter: "",
};

// ---------------------------------------------------------------------------
// Store
// ---------------------------------------------------------------------------

const useTradeStore = create<TradeStoreState>()((set, get) => ({
	...initialState,

	async getTradesData() {
		const mockTrades: Trade[] = [
			{
				id: "trade-001",
				proposer: { id: 4964, name: "Miguel Facca", avatar: "" },
				timestamp: Date.now() - 3e5,
				status: "pending",
				proposerItems: [
					{ id: "skin-001", name: "AK-47 | Redline", image: "", rarity: "comum", vouchersRequired: 3 },
					{ id: "skin-002", name: "M4A4 | Howl", image: "", rarity: "raro", vouchersRequired: 10 },
				],
				otherPlayerItems: [
					{ id: "skin-003", name: "AWP | Asiimov", image: "", rarity: "comum", vouchersRequired: 5 },
				],
				otherPlayer: { name: "Diogo Muniz", id: 1, avatar: "" },
			},
			{
				id: "trade-002",
				proposer: { id: 2, name: "Xlucazz Nunes" },
				timestamp: Date.now() - 18e5,
				status: "accepted",
				proposerItems: [
					{ id: "skin-004", name: "Glock-18 | Fade", image: "", rarity: "epico", vouchersRequired: 4 },
				],
				otherPlayerItems: [
					{ id: "skin-005", name: "USP-S | Kill Confirmed", image: "", rarity: "comum", vouchersRequired: 6 },
					{ id: "skin-006", name: "Desert Eagle | Blaze", image: "", rarity: "epico", vouchersRequired: 4 },
				],
			},
			{
				id: "trade-003",
				proposer: { id: 3, name: "Diogo Muniz" },
				timestamp: Date.now() - 36e5,
				status: "declined",
				proposerItems: [
					{ id: "skin-007", name: "M4A1-S | Hyper Beast", image: "", rarity: "comum", vouchersRequired: 5 },
					{ id: "skin-008", name: "AUG | Chameleon", image: "", rarity: "Mil-Spec", vouchersRequired: 1 },
				],
				otherPlayerItems: [
					{ id: "skin-009", name: "Karambit | Doppler", image: "", rarity: "comum", vouchersRequired: 15 },
				],
			},
			{
				id: "trade-004",
				proposer: { id: 4, name: "Carlos Souza" },
				timestamp: Date.now() - 54e5,
				status: "pending",
				proposerItems: [
					{ id: "skin-010", name: "AWP | Dragon Lore", image: "", rarity: "comum", vouchersRequired: 20 },
				],
				otherPlayerItems: [
					{ id: "skin-011", name: "AK-47 | Fire Serpent", image: "", rarity: "comum", vouchersRequired: 12 },
					{ id: "skin-012", name: "M4A4 | Poseidon", image: "", rarity: "epico", vouchersRequired: 4 },
				],
			},
			{
				id: "trade-005",
				proposer: { id: 5, name: "Fernanda Lima" },
				timestamp: Date.now() - 72e5,
				status: "accepted",
				proposerItems: [
					{ id: "skin-013", name: "P250 | Mehndi", image: "", rarity: "Mil-Spec", vouchersRequired: 1 },
					{ id: "skin-014", name: "Tec-9 | Fuel Injector", image: "", rarity: "raro", vouchersRequired: 2 },
					{ id: "skin-015", name: "CZ75-Auto | Xiangliu", image: "", rarity: "epico", vouchersRequired: 3 },
				],
				otherPlayerItems: [
					{ id: "skin-016", name: "Five-SeveN | Hyper Beast", image: "", rarity: "comum", vouchersRequired: 5 },
				],
			},
			{
				id: "trade-006",
				proposer: { id: 6, name: "Ricardo Alves" },
				timestamp: Date.now() - 108e5,
				status: "declined",
				proposerItems: [
					{ id: "skin-017", name: "Butterfly Knife | Fade", image: "", rarity: "comum", vouchersRequired: 18 },
				],
				otherPlayerItems: [
					{ id: "skin-018", name: "AWP | Wildfire", image: "", rarity: "comum", vouchersRequired: 8 },
					{ id: "skin-019", name: "SSG 08 | Blood in the Water", image: "", rarity: "comum", vouchersRequired: 6 },
				],
			},
			{
				id: "trade-007",
				proposer: { id: 7, name: "Beatriz Costa" },
				timestamp: Date.now() - 144e5,
				status: "pending",
				proposerItems: [
					{ id: "skin-020", name: "SG 553 | Cyrex", image: "", rarity: "epico", vouchersRequired: 3 },
					{ id: "skin-021", name: "FAMAS | Mecha Industries", image: "", rarity: "epico", vouchersRequired: 2 },
				],
				otherPlayerItems: [
					{ id: "skin-022", name: "Galil AR | Chatterbox", image: "", rarity: "epico", vouchersRequired: 3 },
					{ id: "skin-023", name: "AK-47 | Neon Rider", image: "", rarity: "comum", vouchersRequired: 6 },
				],
			},
			{
				id: "trade-008",
				proposer: { id: 8, name: "Lucas Oliveira" },
				timestamp: Date.now() - 18e6,
				status: "accepted",
				proposerItems: [
					{ id: "skin-024", name: "M9 Bayonet | Marble Fade", image: "", rarity: "comum", vouchersRequired: 14 },
				],
				otherPlayerItems: [
					{ id: "skin-025", name: "Karambit | Tiger Tooth", image: "", rarity: "comum", vouchersRequired: 13 },
				],
			},
			{
				id: "trade-009",
				proposer: { id: 9, name: "Ana Paula" },
				timestamp: Date.now() - 216e5,
				status: "pending",
				proposerItems: [
					{ id: "skin-026", name: "MP9 | Hypnotic", image: "", rarity: "epico", vouchersRequired: 3 },
					{ id: "skin-027", name: "MAC-10 | Neon Rider", image: "", rarity: "raro", vouchersRequired: 2 },
				],
				otherPlayerItems: [
					{ id: "skin-028", name: "UMP-45 | Primal Saber", image: "", rarity: "epico", vouchersRequired: 3 },
				],
			},
			{
				id: "trade-010",
				proposer: { id: 10, name: "Rodrigo Martins" },
				timestamp: Date.now() - 252e5,
				status: "declined",
				proposerItems: [
					{ id: "skin-029", name: "Negev | Loudmouth", image: "", rarity: "epico", vouchersRequired: 3 },
					{ id: "skin-030", name: "M249 | Aztec", image: "", rarity: "Mil-Spec", vouchersRequired: 1 },
				],
				otherPlayerItems: [
					{ id: "skin-031", name: "AWP | Neo-Noir", image: "", rarity: "comum", vouchersRequired: 7 },
				],
			},
			{
				id: "trade-011",
				proposer: { id: 11, name: "Juliana Ramos" },
				timestamp: Date.now() - 288e5,
				status: "accepted",
				proposerItems: [
					{ id: "skin-032", name: "Flip Knife | Crimson Web", image: "", rarity: "comum", vouchersRequired: 10 },
				],
				otherPlayerItems: [
					{ id: "skin-033", name: "Gut Knife | Doppler", image: "", rarity: "comum", vouchersRequired: 9 },
					{ id: "skin-034", name: "Shadow Daggers | Freehand", image: "", rarity: "epico", vouchersRequired: 3 },
				],
			},
			{
				id: "trade-012",
				proposer: { id: 12, name: "Pedro Henrique" },
				timestamp: Date.now() - 324e5,
				status: "pending",
				proposerItems: [
					{ id: "skin-035", name: "AK-47 | Asiimov", image: "", rarity: "comum", vouchersRequired: 7 },
					{ id: "skin-036", name: "M4A1-S | Master Piece", image: "", rarity: "comum", vouchersRequired: 8 },
				],
				otherPlayerItems: [
					{ id: "skin-037", name: "AWP | Medusa", image: "", rarity: "comum", vouchersRequired: 15 },
				],
			},
			{
				id: "trade-013",
				proposer: { id: 13, name: "Camila Ferreira" },
				timestamp: Date.now() - 36e6,
				status: "declined",
				proposerItems: [
					{ id: "skin-038", name: "Deagle | Conspiracy", image: "", rarity: "epico", vouchersRequired: 3 },
				],
				otherPlayerItems: [
					{ id: "skin-039", name: "Deagle | Printstream", image: "", rarity: "epico", vouchersRequired: 5 },
					{ id: "skin-040", name: "Deagle | Golden Koi", image: "", rarity: "epico", vouchersRequired: 3 },
				],
			},
			{
				id: "trade-014",
				proposer: { id: 14, name: "Thiago Barbosa" },
				timestamp: Date.now() - 396e5,
				status: "accepted",
				proposerItems: [
					{ id: "skin-041", name: "SCAR-20 | Bloodsport", image: "", rarity: "comum", vouchersRequired: 6 },
					{ id: "skin-042", name: "G3SG1 | Hunter", image: "", rarity: "epico", vouchersRequired: 3 },
				],
				otherPlayerItems: [
					{ id: "skin-043", name: "SSG 08 | Death Strike", image: "", rarity: "comum", vouchersRequired: 5 },
					{ id: "skin-044", name: "SCAR-20 | Crimson Web", image: "", rarity: "epico", vouchersRequired: 4 },
				],
			},
			{
				id: "trade-015",
				proposer: { id: 15, name: "Isabela Nascimento" },
				timestamp: Date.now() - 432e5,
				status: "pending",
				proposerItems: [
					{ id: "skin-045", name: "Bowie Knife | Slaughter", image: "", rarity: "comum", vouchersRequired: 11 },
				],
				otherPlayerItems: [
					{ id: "skin-046", name: "Falchion Knife | Doppler", image: "", rarity: "comum", vouchersRequired: 10 },
					{ id: "skin-047", name: "Ursus Knife | Tiger Tooth", image: "", rarity: "comum", vouchersRequired: 12 },
				],
			},
			{
				id: "trade-016",
				proposer: { id: 16, name: "Gabriel Lopes" },
				timestamp: Date.now() - 468e5,
				status: "declined",
				proposerItems: [
					{ id: "skin-048", name: "PP-Bizon | High Roller", image: "", rarity: "epico", vouchersRequired: 3 },
					{ id: "skin-049", name: "P90 | Asiimov", image: "", rarity: "comum", vouchersRequired: 5 },
				],
				otherPlayerItems: [
					{ id: "skin-050", name: "MP5-SD | Phosphor", image: "", rarity: "epico", vouchersRequired: 3 },
					{ id: "skin-051", name: "MP7 | Bloodsport", image: "", rarity: "comum", vouchersRequired: 6 },
				],
			},
			{
				id: "trade-017",
				proposer: { id: 17, name: "Mariana Vieira" },
				timestamp: Date.now() - 504e5,
				status: "accepted",
				proposerItems: [
					{ id: "skin-052", name: "XM1014 | Black Tie", image: "", rarity: "epico", vouchersRequired: 3 },
					{ id: "skin-053", name: "Nova | Hyper Beast", image: "", rarity: "comum", vouchersRequired: 5 },
					{ id: "skin-054", name: "MAG-7 | Bulldozer", image: "", rarity: "epico", vouchersRequired: 2 },
				],
				otherPlayerItems: [
					{ id: "skin-055", name: "Sawed-Off | The Kraken", image: "", rarity: "epico", vouchersRequired: 3 },
				],
			},
			{
				id: "trade-018",
				proposer: { id: 18, name: "Felipe Castro" },
				timestamp: Date.now() - 54e6,
				status: "pending",
				proposerItems: [
					{ id: "skin-056", name: "Talon Knife | Marble Fade", image: "", rarity: "comum", vouchersRequired: 16 },
				],
				otherPlayerItems: [
					{ id: "skin-057", name: "Stiletto Knife | Fade", image: "", rarity: "comum", vouchersRequired: 14 },
					{ id: "skin-058", name: "Navaja Knife | Doppler", image: "", rarity: "comum", vouchersRequired: 8 },
				],
			},
			{
				id: "trade-019",
				proposer: { id: 19, name: "Larissa Campos" },
				timestamp: Date.now() - 576e5,
				status: "declined",
				proposerItems: [
					{ id: "skin-059", name: "AK-47 | Vulcan", image: "", rarity: "comum", vouchersRequired: 8 },
					{ id: "skin-060", name: "AK-47 | Aquamarine Revenge", image: "", rarity: "comum", vouchersRequired: 6 },
				],
				otherPlayerItems: [
					{ id: "skin-061", name: "M4A4 | The Emperor", image: "", rarity: "comum", vouchersRequired: 7 },
				],
			},
			{
				id: "trade-020",
				proposer: { id: 20, name: "Bruno Teixeira" },
				timestamp: Date.now() - 612e5,
				status: "accepted",
				proposerItems: [
					{ id: "skin-062", name: "Huntsman Knife | Lore", image: "", rarity: "comum", vouchersRequired: 13 },
				],
				otherPlayerItems: [
					{ id: "skin-063", name: "Classic Knife | Crimson Web", image: "", rarity: "comum", vouchersRequired: 11 },
					{ id: "skin-064", name: "Paracord Knife | Slaughter", image: "", rarity: "comum", vouchersRequired: 9 },
				],
			},
		].map((t) => ({
			...t,
			proposer: { ...t.proposer, avatar: "https://github.com/miguel-facca.png" },
			otherPlayer: {
				id: Math.round(Math.random() * 1e5),
				name: "Proposer",
				avatar: "",
			},
		}));

		const data = await fetchNui<Trade[]>({
			path: "get:trades:list",
			mockData: mockTrades,
		});

		if (data) {
			set({ trades: data });
		}
	},

	async getPlayersById(id) {
		const mockPlayers: Player[] = [
			{ id, avatar: "https://github.com/miguel-facca.png", name: "Miguel Facca" },
			{ id: id + 100, avatar: "https://github.com/xlucazzz.png", name: "Xlucazz Nunes" },
			{ id: id + 1000, avatar: "", name: "Diogo Muniz" },
		];

		const data = await fetchNui<Player[]>({
			path: "get:trades:playersById",
			payload: { id },
			mockData: mockPlayers,
		});

		if (data) {
			set({ players: data });
		}
	},

	async acceptTrade() {
		const { newTrade, selectedTrade } = get();

		const payload = newTrade
			? { newTrade }
			: selectedTrade
				? { newTrade: { tradeId: selectedTrade.id, playerData: selectedTrade.proposer } }
				: null;

		if (!payload) return;

		const result = await fetchNui<{ success: boolean; vouchers: number }>({
			path: "post:trades:acceptTrade",
			payload,
			mockData: { success: true, vouchers: 0 },
		});

		if (result) {
			if (typeof result === "object" && typeof result.vouchers === "number") {
				useMainStore.getState().setVouchers(result.vouchers);
			}
			set({ newTrade: null, selectedTrade: null });
			get().getTradesData();
		}
	},

	async declineTrade() {
		const { newTrade, selectedTrade } = get();

		const payload = newTrade
			? { newTrade }
			: selectedTrade
				? { newTrade: { tradeId: selectedTrade.id, playerData: selectedTrade.proposer } }
				: null;

		if (!payload) return;

		const result = await fetchNui<{ success: boolean; vouchers: number }>({
			path: "post:trades:declineTrade",
			payload,
			mockData: { success: true, vouchers: 0 },
		});

		if (result) {
			if (typeof result === "object" && typeof result.vouchers === "number") {
				useMainStore.getState().setVouchers(result.vouchers);
			}
			set({ newTrade: null, selectedTrade: null });
			get().getTradesData();
		}
	},

	async getPlayerData(id) {
		const mockData = {
			player: [
				{ id: "skin-001", name: "AK-47 | Redline", image: "", rarity: "comum", vouchersRequired: 3, selected: false },
				{ id: "skin-002", name: "M4A4 | Howl", image: "", rarity: "raro", vouchersRequired: 10, selected: false },
				{ id: "skin-002", name: "M4A4 | Howl", image: "", rarity: "raro", vouchersRequired: 10, selected: false },
				{ id: "skin-002", name: "M4A4 | Howl", image: "", rarity: "raro", vouchersRequired: 10, selected: false },
				{ id: "skin-002", name: "M4A4 | Howl", image: "", rarity: "raro", vouchersRequired: 10, selected: false },
				{ id: "skin-002", name: "M4A4 | Howl", image: "", rarity: "raro", vouchersRequired: 10, selected: false },
				{ id: "skin-002", name: "M4A4 | Howl", image: "", rarity: "raro", vouchersRequired: 10, selected: false },
				{ id: "skin-002", name: "M4A4 | Howl", image: "", rarity: "raro", vouchersRequired: 10, selected: false },
				{ id: "skin-002", name: "M4A4 | Howl", image: "", rarity: "raro", vouchersRequired: 10, selected: false },
				{ id: "skin-002", name: "M4A4 | Howl", image: "", rarity: "raro", vouchersRequired: 10, selected: false },
				{ id: "skin-002", name: "M4A4 | Howl", image: "", rarity: "raro", vouchersRequired: 10, selected: false },
				{ id: "skin-002", name: "M4A4 | Howl", image: "", rarity: "raro", vouchersRequired: 10, selected: false },
			],
			otherPlayerItems: [
				{ id: "skin-001", name: "AK-47 | Redline", image: "", rarity: "comum", vouchersRequired: 3, selected: false },
				{ id: "skin-002", name: "M4A4 | Howl", image: "", rarity: "raro", vouchersRequired: 10, selected: false },
			],
			otherPlayer: { name: "Diogo Muniz", id, avatar: "" },
			playerData: { name: "Miguel Facca", id: 4964, avatar: "" },
		};

		const data = await fetchNui<typeof mockData>({
			path: "get:playersData",
			payload: { id },
			mockData,
		});

		if (data) {
			set({ newTrade: { ...data, selectingSkin: "player" } });
		}
	},

	async sendTrade() {
		const { newTrade } = get();

		const result = await fetchNui<{ success: boolean; vouchers: number }>({
			path: "post:trades:sendTrade",
			payload: { newTrade },
			mockData: { success: true, vouchers: 0 },
		});

		if (result) {
			if (typeof result === "object" && typeof result.vouchers === "number") {
				useMainStore.getState().setVouchers(result.vouchers);
			}
			get().getTradesData();
			set({ newTrade: null });
		}
	},

	setNewTrade(trade) {
		set({ newTrade: trade });
	},

	setSelectedTrade(trade) {
		set({ selectedTrade: trade });
	},

	setTradesFilter(filter) {
		set({ tradesFilter: filter });
	},

	setNewTradesFilter(filter) {
		set({ newTradesFilter: filter });
	},

	resetStore() {
		set(initialState);
	},
}));

// ---------------------------------------------------------------------------
// SVG Icons
// ---------------------------------------------------------------------------

const TradeIcon = memo(() => (
	<svg width="3.5rem" height="3.5rem" viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
		<path
			d="M23.5811 5.48047C26.0218 3.03974 29.9782 3.03974 32.4189 5.48047L50.5195 23.5811C52.9603 26.0218 52.9603 29.9782 50.5195 32.4189L32.4189 50.5195C29.9782 52.9603 26.0218 52.9603 23.5811 50.5195L5.48047 32.4189C3.03974 29.9782 3.03974 26.0218 5.48047 23.5811L23.5811 5.48047Z"
			stroke="rgb(var(--primaryColor))"
			strokeWidth="1.5"
		/>
		<path
			d="M25.1716 7.82843C26.7337 6.26633 29.2663 6.26633 30.8284 7.82843L48.1716 25.1716C49.7337 26.7337 49.7337 29.2663 48.1716 30.8284L30.8284 48.1716C29.2663 49.7337 26.7337 49.7337 25.1716 48.1716L7.82843 30.8284C6.26633 29.2663 6.26633 26.7337 7.82843 25.1716L25.1716 7.82843Z"
			fill="url(#paint0_linear_693_3789)"
			fillOpacity="0.7"
		/>
		<path
			d="M25.1716 7.82843C26.7337 6.26633 29.2663 6.26633 30.8284 7.82843L48.1716 25.1716C49.7337 26.7337 49.7337 29.2663 48.1716 30.8284L30.8284 48.1716C29.2663 49.7337 26.7337 49.7337 25.1716 48.1716L7.82843 30.8284C6.26633 29.2663 6.26633 26.7337 7.82843 25.1716L25.1716 7.82843Z"
			fill="url(#paint1_linear_693_3789)"
		/>
		<path
			d="M25.4189 8.07617C26.8444 6.65076 29.1556 6.65076 30.5811 8.07617L47.9238 25.4189C49.3492 26.8444 49.3492 29.1556 47.9238 30.5811L30.5811 47.9238C29.1556 49.3492 26.8444 49.3492 25.4189 47.9238L8.07617 30.5811C6.65076 29.1556 6.65076 26.8444 8.07617 25.4189L25.4189 8.07617Z"
			stroke="rgb(var(--primaryColor))"
			strokeOpacity="0.6"
			strokeWidth="0.7"
		/>
		<path
			d="M20 23.5925L28.5004 18.6858L37.0009 23.5925V33.4077L28.5004 38.3144L20 33.4077V23.5925Z"
			stroke="white"
			strokeWidth="1.18696"
		/>
		<mask id="mask0_693_3789" style={{ maskType: "luminance" }} maskUnits="userSpaceOnUse" x="23" y="24" width="11" height="9">
			<path d="M23.9062 24.563H33.7489V32.438H23.9072L23.9062 24.563Z" fill="white" />
		</mask>
		<g mask="url(#mask0_693_3789)">
			<path
				d="M25.1956 28.5667H23.9082V25.8431H29.6741V24.563C30.5771 25.2021 31.4545 25.8276 32.352 26.4649L29.6796 28.364V27.0949H25.1956V28.5667ZM27.9932 32.438C27.0792 31.7897 26.2009 31.1625 25.3088 30.5297C26.2009 29.8979 27.0792 29.2734 27.9758 28.6324V29.8924H32.4534V28.4316H33.7499V31.1433H27.9932V32.438Z"
				fill="white"
			/>
		</g>
		<defs>
			<linearGradient id="paint0_linear_693_3789" x1="28" y1="5" x2="28" y2="51" gradientUnits="userSpaceOnUse">
				<stop stopColor="#363636" />
				<stop offset="1" stopColor="#1D1D1D" />
			</linearGradient>
			<linearGradient id="paint1_linear_693_3789" x1="29.2778" y1="-14.1667" x2="78.4722" y2="52.9167" gradientUnits="userSpaceOnUse">
				<stop stopColor="rgb(var(--primaryColor))" />
				<stop offset="0.7" stopColor="rgb(var(--primaryColor))" stopOpacity="0" />
			</linearGradient>
		</defs>
	</svg>
));

const ArrowIcon = memo(() => (
	<svg width="1.5rem" height="1.5rem" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
		<path d="M13.75 6.75L19.25 12L13.75 17.25" stroke="rgb(var(--primaryColor))" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
		<path d="M19 12H4.75" stroke="rgb(var(--primaryColor))" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
	</svg>
));

const VoucherIcon = memo(() => (
	<svg width="1rem" height="1rem" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
		<g clipPath="url(#clip0_6020_4854)">
			<path
				d="M1.9128 11.8641C1.6456 11.5953 1.3816 11.3321 1.1184 11.0665L0.3624 10.3105C-0.1208 9.82571 -0.1208 9.16411 0.3624 8.68171L8.6816 0.361705C9.1616 -0.118295 9.8224 -0.121495 10.3032 0.357705C10.8048 0.855305 11.3016 1.35611 11.8024 1.85531C11.8456 1.89771 11.8504 1.92651 11.82 1.98331C11.3768 2.76971 11.6224 3.7337 12.3976 4.1809C12.9168 4.4825 13.4552 4.4825 13.9864 4.1985C14.0736 4.1521 14.1144 4.1649 14.1784 4.2289C14.6688 4.72491 15.1648 5.21451 15.6568 5.71051C16.0304 6.08811 16.1096 6.6209 15.8488 7.05611C15.7936 7.1472 15.7272 7.23105 15.6512 7.30571L7.3056 15.6497C6.8384 16.1169 6.168 16.1153 5.7008 15.6489C5.20213 15.1492 4.7024 14.65 4.2016 14.1513C4.152 14.1033 4.1504 14.0697 4.1824 14.0089C4.7104 13.0305 4.1664 11.8561 3.0864 11.6433C2.70675 11.5663 2.31202 11.6318 1.9776 11.8273C1.96213 11.8369 1.9408 11.8494 1.9136 11.8649M0.8088 9.54491C0.8144 9.55371 0.8176 9.56091 0.8248 9.56811C1.2048 9.94731 1.5824 10.3289 1.9656 10.7049C1.9872 10.7265 2.0352 10.7321 2.0672 10.7265C2.8856 10.5713 3.6392 10.7193 4.2912 11.2401C5.1512 11.9257 5.4704 12.8297 5.2864 13.9137C5.2736 13.9809 5.2808 14.0273 5.3328 14.0777C5.57813 14.3182 5.82187 14.5609 6.064 14.8057C6.1936 14.9385 6.32 15.0737 6.4376 15.1945L12.3008 9.33611L11.7392 8.78011L12.4896 8.02811C12.6752 8.21691 12.8656 8.40971 13.0408 8.58571C13.7565 7.87317 14.4736 7.16037 15.192 6.44731C15.1904 6.44251 15.1861 6.43664 15.1792 6.42971C14.8065 6.05549 14.4329 5.68215 14.0584 5.30971C14.0368 5.28891 13.9888 5.2777 13.9584 5.28571C13.6304 5.35451 13.2992 5.36891 12.9672 5.3193C12.5999 5.26496 12.2478 5.13565 11.9326 4.93942C11.6174 4.74318 11.346 4.48421 11.1351 4.17861C10.9243 3.87301 10.7786 3.52731 10.707 3.163C10.6355 2.79868 10.6396 2.42355 10.7192 2.06091C10.732 2.00411 10.7232 1.96811 10.6824 1.92731C10.4413 1.68997 10.2024 1.45051 9.9656 1.20891C9.828 1.06971 9.6944 0.927305 9.572 0.799305L7.3984 2.95931C7.5784 3.1353 7.7608 3.3137 7.928 3.47931C7.6752 3.7329 7.4288 3.9785 7.1672 4.24251C6.9976 4.0681 6.8192 3.88811 6.6472 3.70811L0.8088 9.54491Z"
				fill="rgb(var(--primaryColor))"
			/>
			<path
				d="M3.58789 8.75602L6.68869 5.65842L7.38229 6.35522L4.28229 9.45122L3.58789 8.75602ZM8.15989 7.13602C8.38949 7.36962 8.62549 7.60642 8.85109 7.83442L5.75509 10.9304L5.05989 10.2352C6.09189 9.20322 7.12629 8.16802 8.15989 7.13602ZM10.3431 9.31762L7.24869 12.4096L6.54469 11.7072L9.63909 8.61362L10.3431 9.31762ZM11.5383 7.26162L10.8455 7.96082L9.78789 6.89842L10.4887 6.20242C10.8295 6.54882 11.1855 6.90642 11.5383 7.26162ZM8.01909 5.14162L8.72309 4.43762C9.07669 4.79202 9.43269 5.15042 9.78629 5.50322L9.08389 6.20562L8.01909 5.14162Z"
				fill="rgb(var(--primaryColor))"
			/>
		</g>
		<defs>
			<clipPath id="clip0_6020_4854">
				<rect width="16" height="16" fill="white" />
			</clipPath>
		</defs>
	</svg>
));

const BackArrowIcon = memo(() => (
	<svg width=".375rem" height=".6875rem" viewBox="0 0 6 11" fill="none" xmlns="http://www.w3.org/2000/svg">
		<path d="M5.5 0.500001L0.5 5.5L5.5 10.5" stroke="#ADADAD" strokeLinecap="round" strokeLinejoin="round" />
	</svg>
));

// ---------------------------------------------------------------------------
// Sub-components
// ---------------------------------------------------------------------------

function TradeHeader() {
	const { newTrade, selectedTrade } = useTradeStore(
		useShallow((s) => ({ newTrade: s.newTrade, selectedTrade: s.selectedTrade })),
	);

	return (
		<header className="mb-6 flex w-full items-center gap-2.5 font-semibold text-[1.1875rem]">
			<TradeIcon />
			{!selectedTrade && !newTrade && "Sistema de trocas"}
			{!selectedTrade && newTrade && "Nova troca"}
			{selectedTrade && !newTrade && "Visualizar proposta"}
		</header>
	);
}

// ---- Home View ----

function PlayerItem({ avatar, id, name }: Player) {
	const { imageUrl, isImageValid } = useImageValidation(avatar ?? "");
	const getPlayerData = useTradeStore((s) => s.getPlayerData);

	return (
		<button
			type="button"
			className="flex min-h-[3.75rem] w-full items-center rounded-[.3125rem] border border-white/[.06] border-solid bg-white/[.08] px-2 transition-all duration-300 hover:border-white/25 hover:bg-white/15"
			onClick={() => getPlayerData(id)}
		>
			<img
				src={isImageValid ? imageUrl : fallbackAvatar}
				className="mr-4 size-[2.875rem] rounded-full border border-primaryColor border-solid"
				alt=""
			/>
			<div className="flex items-center gap-2 font-medium text-[.9375rem]">
				{name}
				<div className="flex h-6 w-fit items-center justify-center rounded-[.3125rem] border border-white/[.06] border-solid bg-white/20 px-2 font-semibold text-[.8125rem] text-white/80">
					{id}
				</div>
			</div>
		</button>
	);
}

function PlayerSearch() {
	const [searchId, setSearchId] = useState(0);
	const { players, getPlayersById } = useTradeStore(
		useShallow((s) => ({ players: s.players, getPlayersById: s.getPlayersById })),
	);

	return (
		<div className="flex h-full w-1/2 flex-col gap-4">
			<header className="flex min-h-[3rem] w-full items-center justify-center rounded-[.4375rem] border border-white/[.16] border-solid p-[.1875rem]">
				<div className="flex size-full items-center gap-2 rounded-[.3125rem] border border-white/[.06] border-solid bg-white/[.08] px-2 font-semibold text-sm">
					Buscar jogador
				</div>
			</header>

			<span className="text-[#adadad] text-xs">
				Pesquise um jogador para convida-lo ao sistema de trocas.
			</span>

			<div className="grid h-[2.125rem] w-full place-items-center rounded-md border border-white/[.16] border-solid p-0.5">
				<div className="flex size-full items-center justify-between rounded-[.25rem] border border-white/[.06] border-solid bg-[#080808]/[.38] px-2">
					<input
						placeholder="Procure ID do jogador"
						className="w-[calc(100%-.5rem-.875rem)] bg-transparent text-white text-xs outline-none placeholder:text-[#adadad]"
						value={searchId.toString().replace(/^0+/, "")}
						onChange={(e) => {
							if (e.target.value === "") return setSearchId(0);
							const num = Number(e.target.value);
							if (Number.isNaN(num) || num <= 0) return;
							setSearchId(num);
						}}
					/>
					<button
						type="button"
						className="bg-transparent outline-none"
						onClick={() => {
							if (searchId <= 0) return;
							getPlayersById(searchId).then(() => setSearchId(0));
						}}
					>
						<SearchIcon />
					</button>
				</div>
			</div>

			<div
				className={cn(
					"hideScroll relative flex h-[calc(100%-1rem*3-3.375rem-2.125rem-.9375rem)] w-full flex-col gap-2 overflow-auto rounded-md border border-white/[.16] border-solid p-4 pb-0",
				)}
			>
				{players.length <= 0 && (
					<div className="-translate-y-1/2 -translate-x-1/2 absolute top-1/2 left-1/2 flex w-fit items-center gap-2 text-[#7A7A7ACC] text-xs">
						<SearchIcon />
						Procure um jogador para realizar uma troca.
					</div>
				)}
				{players?.length > 0 && players.map((p) => <PlayerItem key={p.id} {...p} />)}
			</div>
		</div>
	);
}

function FilterButton({ filter, label }: { filter: TradesFilter; label: string }) {
	const { tradesFilter, setTradesFilter } = useTradeStore(
		useShallow((s) => ({ tradesFilter: s.tradesFilter, setTradesFilter: s.setTradesFilter })),
	);
	const isActive = useMemo(() => tradesFilter === filter, [tradesFilter, filter]);

	return (
		<button
			type="button"
			onClick={() => setTradesFilter(filter)}
			className={cn(
				"group h-[2.125rem] rounded-md border border-white/[.16] border-solid p-[.125rem] transition-all duration-300 hover:border-primaryColor",
				{ "border-primaryColor": isActive },
			)}
		>
			<div
				className={cn(
					"relative flex size-full items-center justify-center rounded-[.25rem] border border-white/[.06] border-solid bg-white/[.08] px-4 text-white/80 group-hover:border-transparent ",
					{ "border-transparent bg-transparent": isActive },
				)}
			>
				<div
					className={cn(
						"absolute inset-0 rounded-[.25rem] border border-primaryColor/60 border-solid opacity-0 transition-all duration-300 group-hover:opacity-100",
						{ "opacity-100": isActive },
					)}
					style={{
						background:
							"linear-gradient(134.74deg, rgb(var(--primaryColor)) -47.65%, rgba(var(--primaryColor), 0.5) 122.65%)",
					}}
				/>
				<span
					className={cn(
						"relative z-10 font-semibold text-[.8125rem] transition-all duration-300 group-hover:text-white",
						{ "text-white": isActive },
					)}
				>
					{label}
				</span>
			</div>
		</button>
	);
}

function TradeRow({
	id,
	otherPlayerItems,
	proposer,
	proposerItems,
	status,
	timestamp,
	otherPlayer,
}: Trade) {
	const { setSelectedTrade } = useTradeStore(
		useShallow((s) => ({ setSelectedTrade: s.setSelectedTrade })),
	);

	return (
		<button
			type="button"
			className="group flex min-h-12 w-full items-center justify-center rounded-lg border border-white/[.16] border-solid p-[.1875rem] transition-all duration-300 hover:border-white/20"
			onClick={() =>
				setSelectedTrade({ id, otherPlayerItems, proposer, proposerItems, status, timestamp, otherPlayer })
			}
		>
			<div className="flex size-full items-center rounded-[.3125rem] border border-white/[.06] border-solid bg-white/[.08] px-2 transition-all duration-300 group-hover:bg-white/10">
				<div className="flex flex-1 items-center font-semibold text-[.8125rem]">
					{proposer.name} #{proposer.id}
				</div>
				<div className="flex flex-1 items-center justify-center font-semibold text-[.8125rem]">
					{formatDateTime(timestamp)}
				</div>
				<div className="flex flex-1 items-center justify-center font-semibold text-[.8125rem]">
					<div
						className="flex h-[1.625rem] items-center justify-center rounded-[.25rem] border border-solid px-2.5"
						style={{
							borderColor: hexToRgba(statusColors[status], 0.32),
							backgroundColor: hexToRgba(statusColors[status], 0.24),
							color: statusColors[status],
						}}
					>
						{status === "accepted" && "Aceita"}
						{status === "declined" && "Recusada"}
						{status === "pending" && "Pendente"}
					</div>
				</div>
				<div className="flex flex-1 items-center justify-center gap-[.3125rem]">
					<span className="font-bold text-[.8125rem] text-primaryColor underline">Abrir proposta</span>
					<ArrowIcon />
				</div>
			</div>
		</button>
	);
}

function TradesList() {
	const { filter, trades } = useTradeStore(
		useShallow((s) => ({ filter: s.tradesFilter, trades: s.trades })),
	);

	return (
		<div className=" relative flex h-full w-1/2 flex-col gap-6 rounded-md border border-white/[.16] border-solid p-4 pb-0">
			<header className="flex items-center gap-2 font-semibold text-base">
				<div
					className="size-1 rounded-full bg-primaryColor"
					style={{
						boxShadow:
							"0rem 0rem .25rem 0rem rgb(var(--primaryColor)),0rem 0rem .625rem 0rem rgb(var(--primaryColor))",
					}}
				/>
				Propostas de troca
			</header>

			<div className="flex items-center gap-2">
				<FilterButton filter="all" label="Todas" />
				<FilterButton filter="pending" label="Pendentes" />
				<FilterButton filter="declined" label="Recusadas" />
				<FilterButton filter="accepted" label="Aceitas" />
			</div>

			<div className="scrollbar-hide flex h-[calc(100%-1.5rem*2-2.125rem-1.25rem)] w-full flex-col gap-2 overflow-auto">
				{trades?.length > 0 &&
					trades
						.filter((t) => (filter === "all" ? true : t.status === filter))
						.map((t) => <TradeRow key={t.id} {...t} />)}
			</div>
		</div>
	);
}

function HomeView() {
	return (
		<div className="flex h-[88%] w-full items-center gap-7">
			<PlayerSearch />
			<TradesList />
		</div>
	);
}

// ---- New Trade View ----

function VoucherBadge({ items }: { items: SkinItem[] }) {
	return (
		<div className="ml-auto flex h-[2.375rem] items-center justify-center rounded-md border border-primaryColor border-solid p-[.1875rem]">
			<div
				className="flex size-full items-center rounded-[.3125rem] border border-primaryColor/60 border-solid px-2"
				style={{
					background:
						"linear-gradient(134.74deg, rgba(var(--primaryColor), 0.3) -47.65%, rgba(var(--primaryColor), 0.15) 122.65%)",
				}}
			>
				<VoucherIcon />
				<span className="mr-4 ml-2 font-semibold text-[#f2f2f2] text-[.8125rem]">
					Voucher necessário:
				</span>
				<h1 className="font-medium text-[.8125rem] text-white/50">
					{items.reduce((acc, item) => acc + item.vouchersRequired, 0)}
				</h1>
			</div>
		</div>
	);
}

function TradeSkinCard({ image, model_name, name, rarity }: SkinItem & { model_name?: string }) {
	const rarityData = RARITY_MAP[rarity] || RARITY_MAP.comum;
	const color = `rgb(${rarityData.rgb})`;
	const { isImageValid } = useImageValidation(image);

	return (
		<div
			className="group relative flex h-[10.625rem] w-[8.75rem] flex-col items-center overflow-hidden rounded-[.375rem] transition-all duration-300"
			style={{
				background: `linear-gradient(180deg, rgba(${rarityData.rgb}, 0.24) -17.86%, rgba(${rarityData.rgb}, 0) 53.57%), rgba(12, 12, 12, 0.24)`,
				border: `.125rem solid ${color}`,
			}}
		>
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
		</div>
	);
}

function TradeItemsSection({
	items,
	otherPlayer,
	proposer,
	title,
}: {
	items: SkinItem[];
	otherPlayer?: Player;
	proposer?: Player;
	title: string;
}) {
	const { imageUrl, isImageValid } = useImageValidation(proposer?.avatar || "");

	return (
		<div className="flex h-[21.5625rem] w-full flex-col gap-2.5 rounded-md border border-white/[.16] border-solid p-6">
			<header className="flex items-center gap-2 font-semibold text-[.9375rem]">
				<div
					className="size-1 rounded-full bg-primaryColor"
					style={{
						boxShadow:
							"0rem 0rem .25rem 0rem rgba(var(--primaryColor), 1),0rem 0rem .625rem 0rem rgba(var(--primaryColor), 1)",
					}}
				/>
				{title}
			</header>

			<div className="flex items-center">
				<img
					src={isImageValid ? imageUrl : fallbackAvatar}
					alt=""
					className="size-[2.875rem] rounded-full border border-primaryColor border-solid object-cover"
				/>
				<div className="ml-4 flex flex-col items-start">
					<span className="font-semibold text-[.9375rem]">
						{proposer?.name} #{proposer?.id}
					</span>
					<span className="text-xs">
						Itens que você irá enviar para{" "}
						<span className="font-bold">
							{otherPlayer?.name} #{otherPlayer?.id}
						</span>
					</span>
				</div>
				<VoucherBadge items={items} />
			</div>

			<div className="scrollbar-hide mt-2.5 flex h-flex-1 w-full flex-wrap content-start gap-3 overflow-auto">
				{items.map((item) => (
					<TradeSkinCard key={item.id} {...item} model_name={item.name} />
				))}
			</div>
		</div>
	);
}

function NewTradeOffer() {
	const { newTrade, sendTrade } = useTradeStore(
		useShallow((s) => ({ newTrade: s.newTrade, sendTrade: s.sendTrade })),
	);

	return (
		<div className="flex h-full w-1/2 flex-col rounded-md border border-white/[.16] border-solid p-4">
			{newTrade && (
				<TradeItemsSection
					items={newTrade.player.filter((i) => i.selected)}
					proposer={newTrade.playerData}
					otherPlayer={newTrade.otherPlayer}
					title="Suas ofertas"
				/>
			)}

			<div className="my-8 h-[.0625rem] w-full bg-[#d9d9d9]/10" />

			{newTrade && (
				<TradeItemsSection
					items={newTrade.otherPlayerItems.filter((i) => i.selected)}
					proposer={newTrade.otherPlayer}
					otherPlayer={newTrade.playerData}
					title="Ofertas do jogador"
				/>
			)}

			<button
				type="button"
				className="mt-[2.1875rem] flex h-[2.375rem] w-full items-center justify-center rounded-lg border border-primaryColor border-solid p-[.1875rem]"
				onClick={sendTrade}
			>
				<div
					className="flex size-full items-center justify-center rounded-md border border-primaryColor/60 border-solid font-semibold text-sm"
					style={{
						background:
							"linear-gradient(134.74deg, rgb(var(--primaryColor)) -47.65%, rgba(var(--primaryColor), 0.5) 122.65%)",
					}}
				>
					Enviar proposta de troca
				</div>
			</button>
		</div>
	);
}

function InventoryTabs() {
	const { newTrade, setNewTrade } = useTradeStore(
		useShallow((s) => ({ newTrade: s.newTrade, setNewTrade: s.setNewTrade })),
	);

	return (
		<header className="flex h-[2.9375rem] w-full items-center justify-center rounded-lg border border-white/[.16] border-solid p-[.1875rem]">
			<div className="flex size-full items-center gap-2 rounded-lg border border-white/10 border-solid p-1">
				<button
					type="button"
					className="group relative flex min-h-[2.0625rem] w-1/2 items-center justify-center "
					onClick={() => {
						if (newTrade) setNewTrade({ ...newTrade, selectingSkin: "player" });
					}}
				>
					<div
						className={cn(
							"absolute inset-0 rounded-md border border-primaryColor/60 border-solid opacity-0 transition-all duration-300 group-hover:opacity-75",
							{ "opacity-100": newTrade?.selectingSkin === "player" },
						)}
						style={{
							background:
								"linear-gradient(134.74deg, rgb(var(--primaryColor)) -47.65%, rgba(var(--primaryColor), 0.5) 122.65%)",
						}}
					/>
					<span
						className={cn(
							"relative z-10 font-semibold text-[#adadad] text-sm transition-all duration-300 group-hover:text-white",
							{ "text-white": newTrade?.selectingSkin === "player" },
						)}
					>
						Meu Inventário
					</span>
				</button>

				<button
					type="button"
					className="group relative flex min-h-[2.0625rem] w-1/2 items-center justify-center "
					onClick={() => {
						if (newTrade) setNewTrade({ ...newTrade, selectingSkin: "otherPlayer" });
					}}
				>
					<div
						className={cn(
							"absolute inset-0 rounded-md border border-primaryColor/60 border-solid opacity-0 transition-all duration-300 group-hover:opacity-75",
							{ "opacity-100": newTrade?.selectingSkin === "otherPlayer" },
						)}
						style={{
							background:
								"linear-gradient(134.74deg, rgb(var(--primaryColor)) -47.65%, rgba(var(--primaryColor), 0.5) 122.65%)",
						}}
					/>
					<span
						className={cn(
							"relative z-10 font-semibold text-[#adadad] text-sm transition-all duration-300 group-hover:text-white",
							{ "text-white": newTrade?.selectingSkin === "otherPlayer" },
						)}
					>
						Inventário de {newTrade?.otherPlayer.name} #{newTrade?.otherPlayer.id}
					</span>
				</button>
			</div>
		</header>
	);
}

function SelectableSkinCard({
	image,
	name,
	rarity,
	selected,
	vouchersRequired,
	id,
}: SkinItem) {
	const { newTrade, setNewTrade } = useTradeStore(
		useShallow((s) => ({ newTrade: s.newTrade, setNewTrade: s.setNewTrade })),
	);

	const rarityData = RARITY_MAP[rarity] || RARITY_MAP.comum;
	const color = `rgb(${rarityData.rgb})`;
	const { isImageValid } = useImageValidation(image);

	const handleClick = () => {
		if (!newTrade) return;
		const key = newTrade.selectingSkin === "player" ? "player" : "otherPlayerItems";
		setNewTrade({
			...newTrade,
			[key]: newTrade[key].map((item) =>
				item.id === id ? { ...item, selected: !item.selected } : item,
			),
		});
	};

	return (
		<button
			type="button"
			className="group relative flex h-[11.25rem] w-[9.1875rem] cursor-pointer flex-col items-center overflow-hidden rounded-[.375rem] transition-all duration-300"
			style={{
				background: `linear-gradient(180deg, rgba(${rarityData.rgb}, 0.24) -17.86%, rgba(${rarityData.rgb}, 0) 53.57%), rgba(12, 12, 12, 0.24)`,
				border: `.125rem solid ${selected ? "rgb(var(--primaryColor))" : color}`,
			}}
			onClick={handleClick}
		>
			<svg
				width="1.25rem"
				height="1.25rem"
				viewBox="0 0 20 20"
				fill="none"
				xmlns="http://www.w3.org/2000/svg"
				className={cn("transiton-all absolute top-3 right-3 scale-0 opacity-0 duration-300", {
					"scale-100 opacity-100": selected,
				})}
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

function SelectItemsPanel() {
	const { newTrade, newTradesFilter, setNewTradesFilter, setNewTrade } = useTradeStore(
		useShallow((s) => ({
			newTrade: s.newTrade,
			newTradesFilter: s.newTradesFilter,
			setNewTradesFilter: s.setNewTradesFilter,
			setNewTrade: s.setNewTrade,
		})),
	);

	const activeItems = newTrade
		? newTrade[newTrade.selectingSkin === "player" ? "player" : "otherPlayerItems"]
		: [];

	return (
		<div className="flex h-full w-1/2 flex-col gap-4">
			<InventoryTabs />

			<div className="flex w-full flex-1 flex-col gap-3 rounded-md border border-white/[.16] border-solid p-4">
				<div className="flex min-h-10 w-full items-center justify-center rounded-md border border-white/[.16] border-solid p-[.1875rem]">
					<div className="flex size-full items-center rounded-[.3125rem] border border-white/[.06] border-solid bg-white/[.08] p-1.5">
						<button
							type="button"
							className="grid size-8 place-items-center rounded-[.3125rem] border border-white/[.16] border-solid p-0.5"
							onClick={() => setNewTrade(null)}
						>
							<div className="grid size-full place-items-center rounded-[.1875rem] border border-white/[.06] border-solid bg-[#080808]/[.38]">
								<BackArrowIcon />
							</div>
						</button>
						<span className="ml-4 font-semibold text-[#f2f2f2] text-base">
							Selecione os itens
						</span>
					</div>
				</div>

				<div className="grid h-[2.125rem] w-full place-items-center rounded-md border border-white/[.16] border-solid p-0.5">
					<div className="flex size-full items-center justify-between rounded-[.25rem] border border-white/[.06] border-solid bg-[#080808]/[.38] px-2">
						<input
							placeholder="Procurar..."
							className="w-[calc(100%-.5rem-.875rem)] bg-transparent text-white text-xs outline-none placeholder:text-[#adadad]"
							value={newTradesFilter}
							onChange={(e) => setNewTradesFilter(e.target.value)}
						/>
						<SearchIcon />
					</div>
				</div>

				<div className="scrollbar-hide flex h-[84%] w-full flex-wrap content-start gap-1.5 gap-y-2 overflow-auto">
					{activeItems
						.filter((i) => i.name.toLocaleLowerCase().includes(newTradesFilter.toLocaleLowerCase()))
						.map((item) => (
							<SelectableSkinCard key={item.id} {...item} />
						))}
				</div>
			</div>
		</div>
	);
}

function NewTradeView() {
	return (
		<div className="flex h-[87.5%] w-full items-center gap-8">
			<SelectItemsPanel />
			<NewTradeOffer />
		</div>
	);
}

// ---- Detail View ----

function DetailHeader() {
	const { selectedTrade, acceptTrade, declineTrade, setSelectedTrade } = useTradeStore(
		useShallow((s) => ({
			selectedTrade: s.selectedTrade,
			acceptTrade: s.acceptTrade,
			declineTrade: s.declineTrade,
			setSelectedTrade: s.setSelectedTrade,
		})),
	);
	const myId = useMainStore((s) => s.id);

	const isReceivedTrade = selectedTrade && selectedTrade.proposer.id !== myId;

	return (
		<header className="flex w-full items-center">
			<div
				className={cn(
					"flex min-h-10 w-full items-center justify-center rounded-md border border-white/[.16] border-solid p-[.1875rem]",
					{ "w-[calc(100%-1rem-8.8125rem*2-.5rem)]": isReceivedTrade },
				)}
			>
				<div className="flex size-full items-center rounded-[.3125rem] border border-white/[.06] border-solid bg-white/[.08] p-1.5">
					<button
						type="button"
						className="grid size-[1.625rem] place-items-center rounded-[.3125rem] border border-white/[.16] border-solid p-0.5"
						onClick={() => setSelectedTrade(null)}
					>
						<div className="grid size-full place-items-center rounded-[.1875rem] border border-white/[.06] border-solid bg-[#080808]/[.38]">
							<BackArrowIcon />
						</div>
					</button>
					<span className="ml-4 font-semibold text-[#f2f2f2] text-sm">
						Proposta {isReceivedTrade ? "recebida" : "enviada"}
					</span>
				</div>
			</div>

			{isReceivedTrade && (
				<>
					<button
						type="button"
						className="mr-2 ml-4 grid h-11 min-h-11 w-[8.8125rem] place-items-center rounded-md border border-[#6FAF19] border-solid p-[.1875rem] transition-all duration-300 hover:brightness-75"
						onClick={acceptTrade}
					>
						<div
							style={{
								background:
									"linear-gradient(134.74deg, rgba(111, 175, 25, 0.564706) -47.65%, rgba(111, 175, 25, 0.5) 122.65%)",
							}}
							className="grid size-full place-items-center rounded-[.3125rem] border border-[#6FAF1999] border-solid font-semibold text-[#f2f2f2] text-sm"
						>
							Aceitar troca
						</div>
					</button>
					<button
						type="button"
						className="grid h-11 min-h-11 w-[8.8125rem] place-items-center rounded-md border border-[#F50C0C] border-solid p-[.1875rem] transition-all duration-300 hover:brightness-75"
						onClick={declineTrade}
					>
						<div
							style={{
								background:
									"linear-gradient(134.74deg, rgba(245, 12, 12, 0.564706) -47.65%, rgba(245, 12, 12, 0.5) 122.65%)",
							}}
							className="grid size-full place-items-center rounded-[.3125rem] border border-[#F50C0C99] border-solid font-semibold text-[#f2f2f2] text-sm"
						>
							Recusar troca
						</div>
					</button>
				</>
			)}
		</header>
	);
}

function DetailItemsSection({
	items,
	otherPlayer,
	proposer,
	title,
}: {
	items: SkinItem[];
	otherPlayer?: Player;
	proposer?: Player;
	title: string;
}) {
	const { imageUrl, isImageValid } = useImageValidation(proposer?.avatar || "");

	return (
		<div className="flex h-full w-1/2 flex-col gap-2.5 rounded-md border border-white/[.16] border-solid p-6">
			<header className="flex items-center gap-2 font-semibold text-[.9375rem]">
				<div
					className="size-1 rounded-full bg-primaryColor"
					style={{
						boxShadow:
							"0rem 0rem .25rem 0rem rgba(var(--primaryColor), 1),0rem 0rem .625rem 0rem rgba(var(--primaryColor), 1)",
					}}
				/>
				{title}
			</header>

			<div className="flex items-center">
				<img
					src={isImageValid ? imageUrl : fallbackAvatar}
					alt=""
					className="size-[2.875rem] rounded-full border border-primaryColor border-solid object-cover"
				/>
				<div className="ml-4 flex flex-col items-start">
					<span className="font-semibold text-[.9375rem]">
						{proposer?.name} #{proposer?.id}
					</span>
					<span className="text-xs">
						Itens que você irá enviar para{" "}
						<span className="font-bold">
							{otherPlayer?.name} #{otherPlayer?.id}
						</span>
					</span>
				</div>
				<VoucherBadge items={items} />
			</div>

			<div className="scrollbar-hide mt-2.5 flex h-[calc(100%-2.875rem-1.25rem-1.125rem)] w-full flex-wrap content-start gap-3 overflow-auto">
				{items.map((item) => (
					<SkinCard key={item.id} {...item} model_name={item.name} />
				))}
			</div>
		</div>
	);
}

function DetailView() {
	const selectedTrade = useTradeStore((s) => s.selectedTrade);

	if (!selectedTrade) return null;

	return (
		<div className="flex h-[85%] w-full flex-col gap-8 rounded-md border border-white/[.16] border-solid p-6">
			<DetailHeader />
			<main className="flex w-full flex-1 items-center gap-8">
				<DetailItemsSection
					items={selectedTrade.proposerItems}
					proposer={selectedTrade.proposer}
					otherPlayer={selectedTrade.otherPlayer}
					title="Suas ofertas"
				/>
				<DetailItemsSection
					items={selectedTrade.otherPlayerItems}
					proposer={selectedTrade.otherPlayer}
					otherPlayer={selectedTrade.proposer}
					title="Ofertas do jogador"
				/>
			</main>
		</div>
	);
}

// ---------------------------------------------------------------------------
// Main Page Component
// ---------------------------------------------------------------------------

export function Troca() {
	const visible = useVisibility((s) => s.visible);
	const { newTrade, selectedTrade, getTradesData, resetStore } = useTradeStore(
		useShallow((s) => ({
			newTrade: s.newTrade,
			selectedTrade: s.selectedTrade,
			getTradesData: s.getTradesData,
			resetStore: s.resetStore,
		})),
	);

	useEffect(() => {
		if (visible) {
			getTradesData();
			return () => resetStore();
		}
		return resetStore();
	}, [visible]);

	useEffect(() => {
		if (!visible || newTrade || selectedTrade) return;

		const interval = setInterval(() => {
			getTradesData();
		}, 10_000);

		return () => clearInterval(interval);
	}, [visible, newTrade, selectedTrade]);

	return (
		<div className="flex h-full w-full flex-col">
			<TradeHeader />
			{!newTrade && !selectedTrade && <HomeView />}
			{!newTrade && selectedTrade && <DetailView />}
			{newTrade && !selectedTrade && <NewTradeView />}
		</div>
	);
}
