import { SHOP_MOCK } from "@app/mocks/shop";
import { fetchNui } from "@app/utils/fetchNui";
import { create } from "zustand";

export interface IProduct {
	id: string;
	name: string;
	image: string;
	price: number;
	/** `-1` representa estoque ilimitado. */
	stock: number;
	category: string;
}

export interface ICategory {
	id: string;
	label: string;
}

export interface IShop {
	id: string;
	label: string;
	subtitle: string;
}

export type SortMode = "cheapest" | "expensive" | "name";

export interface IShopData {
	shop: IShop;
	categories: ICategory[];
	products: IProduct[];
}

interface Store {
	shop: IShop | null;
	categories: ICategory[];
	products: IProduct[];

	status: "idle" | "loading" | "ready";

	category: string;
	search: string;
	sort: SortMode;
}

interface Actions {
	getShopData(): Promise<void>;

	setCategory(category: string): void;
	setSearch(search: string): void;
	setSort(sort: SortMode): void;

	clearStore(): void;
}

const initialState: Store = {
	shop: null,
	categories: [],
	products: [],

	status: "idle",

	category: "all",
	search: "",
	sort: "cheapest",
};

export const useShop = create<Store & Actions>()((set) => ({
	...initialState,

	getShopData: async () => {
		set({ status: "loading" });

		const data = await fetchNui<IShopData | null>({
			path: "shop:getData",
			mockData: SHOP_MOCK,
			delay: 250,
		});

		if (!data) {
			set({ status: "ready" });
			return;
		}

		set({
			shop: data.shop,
			categories: data.categories ?? [],
			products: data.products ?? [],
			status: "ready",
		});
	},

	setCategory: (category) => set({ category }),
	setSearch: (search) => set({ search }),
	setSort: (sort) => set({ sort }),

	clearStore: () => set({ ...initialState }),
}));
