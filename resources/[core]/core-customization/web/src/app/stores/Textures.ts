import { create } from "zustand";

export type PedType = "Male" | "Female";

export interface TextureVariant {
	image: string;
	/** Maior índice de textura da peça. */
	max: number;
}

/** Peça -> índice (string, porque inclui "-1") -> miniatura e texturas. */
export type TextureCatalog = Record<string, Record<string, TextureVariant>>;

interface TexturesStore {
	catalog: Record<PedType, TextureCatalog>;
	/** O client já mandou o catálogo. */
	loaded: boolean;
}

interface TexturesActions {
	setCatalog: (catalog: Record<PedType, TextureCatalog>) => void;
}

export const useTexturesStore = create<TexturesStore & TexturesActions>()(
	(set) => ({
		catalog: { Male: {}, Female: {} },
		loaded: false,

		setCatalog: (catalog) => set({ catalog, loaded: true }),
	}),
);

/** Referência estável: um `{}` novo por render invalidaria o seletor. */
const EMPTY: Record<string, TextureVariant> = {};

export function variantsOf(pedType: PedType, item: string) {
	return useTexturesStore.getState().catalog[pedType]?.[item] ?? EMPTY;
}

/**
 * Índices disponíveis de uma peça, em ordem. O -1 ("nenhuma") vem
 * primeiro; o resto sobe numericamente.
 */
export function orderedIndexes(variants: Record<string, TextureVariant>) {
	return Object.keys(variants)
		.map(Number)
		.sort((a, b) => a - b);
}
