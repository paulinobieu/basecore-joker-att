import { fetchNui } from "@app/utils/fetchNui";
import { create } from "zustand";

export interface ConfigSelectValue {
	id: string;
	label: string;
}

export interface ConfigItem {
	title: string;
	description: string;
	type: "toggle" | "multi-select";
	toggle?: boolean;
	selectValues?: ConfigSelectValue[];
	selectedValue?: string;
}

export type EscConfig = Record<string, ConfigItem[]>;

export interface EscPlayer {
	name: string;
	id: number;
	avatar: string;
	bank: number;
	cash: number;
	diamonds: number;
	coins: number;
	role: string;
}

export interface EscLinks {
	shop: string;
	discord: string;
	tiktok: string;
	instagram: string;
}

export interface EscPlayers {
	cops: number;
	mechanics: number;
	medics: number;
	online: number;
}

export interface EscState {
	logo: string;
	links: EscLinks;
	battlepass: { current: number; total: number };
	otimization: boolean;
	player: EscPlayer;
	config: EscConfig;
	players: EscPlayers;
}

interface EscActions {
	getEscData: () => Promise<void>;
	toggleOtimization: () => Promise<void>;
	openWeaponSkins: () => Promise<void>;
	openHelpCenter: () => Promise<void>;
	openUltraBoost: () => Promise<void>;
	openBattlePass: () => Promise<void>;
	openMisteryBoxs: () => Promise<void>;
	openMap: () => Promise<void>;
	openConfig: () => Promise<void>;
	openSettings: () => Promise<void>;
	openDailyReward: () => Promise<void>;
	setConfig: (updater: (config: EscConfig) => EscConfig) => Promise<void>;
}

const initialState: EscState = {
	logo: "",
	links: { shop: "", discord: "", tiktok: "", instagram: "" },
	battlepass: { current: 0, total: 10 },
	otimization: false,
	player: {
		name: "",
		id: 0,
		avatar: "",
		bank: 0,
		cash: 0,
		diamonds: 0,
		coins: 0,
		role: "",
	},
	config: {},
	players: { cops: 0, mechanics: 0, medics: 0, online: 0 },
};

export const useEscStore = create<EscState & EscActions>()((set, get) => ({
	...initialState,

	async getEscData() {
		const data = await fetchNui<EscState>({
			path: "get:esc:data",
			mockData: {
				logo: "",
				links: { shop: "", discord: "", tiktok: "", instagram: "" },
				battlepass: { current: 5, total: 10 },
				otimization: false,
				player: {
					name: "Miguel Facca",
					id: 1293,
					avatar: "https://github.com/miguel-facca.png",
					bank: 250000,
					cash: 125000,
					diamonds: 4912,
					coins: 192,
					role: "Desenvolvedor",
				},
				config: {
					acessibilidade: [
						{
							title: "Estilo de correr",
							description: "Informe a descrição da configuração nessa parte.",
							type: "toggle",
							toggle: false,
						},
						{
							title: "Modo escuro",
							description: "Ativar ou desativar o modo escuro da interface.",
							type: "toggle",
							toggle: true,
						},
					],
					chat: [
						{
							title: "Estilo de chat",
							description: "Informe a descrição da configuração nessa parte.",
							type: "multi-select",
							selectValues: [
								{ id: "complete", label: "Completo" },
								{ id: "minimalist", label: "Minimalista" },
							],
							selectedValue: "complete",
						},
					],
				},
				players: { cops: 32, mechanics: 235, medics: 162, online: 5215 },
			},
		});

		if (data) set(data);
	},

	async toggleOtimization() {
		const resp = await fetchNui<boolean>({
			path: "post:esc:toggleOtimization",
			mockData: true,
		});
		if (resp) set((state) => ({ otimization: !state.otimization }));
	},

	async openWeaponSkins() {
		await fetchNui({ path: "post:esc:openWeaponSkins", mockData: true });
	},

	async openHelpCenter() {
		await fetchNui({ path: "post:esc:openHelpCenter", mockData: true });
	},

	async openUltraBoost() {
		await fetchNui({ path: "post:esc:openUltraBoost", mockData: true });
	},

	async openBattlePass() {
		await fetchNui({ path: "post:esc:openBattlePass", mockData: true });
	},

	async openMisteryBoxs() {
		await fetchNui({ path: "post:esc:openMisteryBoxs", mockData: true });
	},

	async openMap() {
		await fetchNui({ path: "post:esc:openMap", mockData: true });
	},

	async openConfig() {
		await fetchNui({ path: "post:esc:openConfig", mockData: true });
	},

	async openSettings() {
		await fetchNui({ path: "post:esc:openSettings", mockData: true });
	},

	async openDailyReward() {
		await fetchNui({ path: "post:esc:openDailyReward", mockData: true });
	},

	async setConfig(updater) {
		const previous = get().config;
		const next = updater(get().config);

		set({ config: next });

		const resp = await fetchNui({
			path: "post:esc:setConfig",
			payload: next,
			mockData: true,
		});

		if (!resp) set({ config: previous });
	},
}));
