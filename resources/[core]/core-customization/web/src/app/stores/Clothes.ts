import {
	CLOTHES_CONFIG,
	type CategoryKey,
	type ClothesConfig,
	type ClothesItem,
	DEFAULT_CATEGORY,
	DEFAULT_ITEM,
} from "@app/constants/clothes";
import { create } from "zustand";

interface ClothesStore {
	config: ClothesConfig;

	/**
	 * A trilha lateral é uma lista única de peças, então categoria e
	 * peça andam sempre juntas: não existe seleção de categoria isolada.
	 */
	activeCategory: CategoryKey;
	activeItem: string;
}

interface ClothesActions {
	/** Aplica o catálogo que o client mandou ao abrir a loja. */
	applyConfig: (config: Partial<ClothesConfig>) => void;
	select: (category: CategoryKey, item: string) => void;
	/** Troca a peça. A textura volta a zero: ela não vale para outro modelo. */
	setItem: (value: number) => void;
	setTexture: (value: number) => void;
}

export const useClothesStore = create<ClothesStore & ClothesActions>()(
	(set) => ({
		config: CLOTHES_CONFIG,
		activeCategory: DEFAULT_CATEGORY,
		activeItem: DEFAULT_ITEM,

		applyConfig: (config) =>
			set((state) => ({
				config: { ...state.config, ...config },
			})),

		select: (activeCategory, activeItem) => set({ activeCategory, activeItem }),

		setItem: (value) =>
			set((state) =>
				update(state, (item) => ({ ...item, item: value, texture: 0 })),
			),

		setTexture: (value) =>
			set((state) => update(state, (item) => ({ ...item, texture: value }))),
	}),
);

function update(
	state: ClothesStore,
	change: (item: ClothesItem) => ClothesItem,
): Pick<ClothesStore, "config"> {
	const { config, activeCategory, activeItem } = state;
	const category = config[activeCategory];
	const current = category[activeItem];

	if (!current) return { config };

	return {
		config: {
			...config,
			[activeCategory]: { ...category, [activeItem]: change(current) },
		},
	};
}

/** A peça em edição — a que o menu, a grade e o preview usam. */
export function activeClothesItem(
	state: ClothesStore,
): ClothesItem | undefined {
	return state.config[state.activeCategory]?.[state.activeItem];
}
