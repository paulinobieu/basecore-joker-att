import { ARSENAL_MOCK } from "@app/mocks/arsenal";
import { create } from "zustand";

/**
 * Formato cru vindo do `Core.GetArsenalData`. O Lua repete o mesmo valor em
 * varios campos por compatibilidade (id/key, item/name/label, price/value),
 * entao aqui cada um e lido com fallback e reduzido ao que a tela usa.
 */
export interface IRawItem {
	id?: string;
	key?: string;
	item?: string;
	name?: string;
	label?: string;
	price?: number;
	value?: number;
	index?: string;
	icon?: string;
	image?: string;
}

export interface IRawCategory {
	name?: string;
	label?: string;
	category?: string;
	items?: IRawItem[];
}

export interface IItem {
	id: string;
	name: string;
	image: string;
	price: number;
	category: string;
}

export interface ICategory {
	id: string;
	label: string;
}

export type SortMode = "cheapest" | "expensive" | "name";

export const ALL_CATEGORY = "all";

interface Store {
	categories: ICategory[];
	items: IItem[];

	status: "idle" | "ready";

	category: string;
	search: string;
	sort: SortMode;
}

interface Actions {
	setArsenal(payload: IRawCategory[] | null): void;

	setCategory(category: string): void;
	setSearch(search: string): void;
	setSort(sort: SortMode): void;

	clearStore(): void;
}

const initialState: Store = {
	categories: [],
	items: [],

	status: "idle",

	category: ALL_CATEGORY,
	search: "",
	sort: "cheapest",
};

/**
 * Achata as categorias do Lua em uma lista unica de itens. O mesmo armamento
 * pode aparecer em mais de uma secao; o `id` continua sendo a chave real do
 * item, porque e por ela que o servidor agrega a compra.
 */
function normalize(payload: IRawCategory[] | null) {
	const categories: ICategory[] = [];
	const items: IItem[] = [];

	for (const entry of payload ?? []) {
		const id = entry.name || entry.category || entry.label;
		if (!id) continue;

		categories.push({ id, label: entry.label || entry.name || id });

		for (const raw of entry.items ?? []) {
			const key = raw.id || raw.key;
			if (!key) continue;

			items.push({
				id: key,
				name: raw.item || raw.name || raw.label || key,
				image: raw.image || "",
				price: Number(raw.price ?? raw.value ?? 0),
				category: id,
			});
		}
	}

	return { categories, items };
}

export const useArsenal = create<Store & Actions>()((set) => ({
	...initialState,

	setArsenal: (payload) => {
		const { categories, items } = normalize(payload);

		set({
			categories,
			items,
			status: "ready",
			category: ALL_CATEGORY,
			search: "",
		});
	},

	setCategory: (category) => set({ category }),
	setSearch: (search) => set({ search }),
	setSort: (sort) => set({ sort }),

	clearStore: () => set({ ...initialState }),
}));

/** Catalogo de demonstracao do navegador, no mesmo formato cru do Lua. */
export const browserArsenal = () => ARSENAL_MOCK;
