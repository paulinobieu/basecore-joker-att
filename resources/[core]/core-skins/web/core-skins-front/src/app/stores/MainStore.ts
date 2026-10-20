import { create } from "zustand";

export interface DurationOption {
	id: string;
	label: string;
	days: number;
	price?: number | null;
}

interface MainStoreState {
	name: string;
	skinsCoins: number;
	vouchers: number;
	avatar: string | null;
	id: number;
	improvementEnabled: boolean;
	durations: DurationOption[];
	setPlayerData: (data: {
		name: string;
		skinsCoins: number;
		vouchers: number;
		avatar: string | null;
		id: number;
		improvementEnabled?: boolean;
		durations?: DurationOption[];
	}) => void;
	setSkinsCoins: (skinsCoins: number) => void;
	setVouchers: (vouchers: number) => void;
}

export const useMainStore = create<MainStoreState>()((set) => ({
	name: "",
	skinsCoins: 0,
	vouchers: 0,
	avatar: null,
	id: 0,
	improvementEnabled: true,
	durations: [],
	setPlayerData: (data) => set(data),
	setSkinsCoins: (skinsCoins) => set({ skinsCoins }),
	setVouchers: (vouchers) => set({ vouchers }),
}));
