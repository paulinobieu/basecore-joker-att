/**
 * Catálogo de peças.
 *
 * Os valores aqui são só o ponto de partida para abrir a tela no
 * navegador: in-game o client manda o mesmo formato na mensagem `open`,
 * já com o que o jogador está vestindo e com os limites reais do modelo.
 */

export type CategoryKey = "head" | "chest" | "legs";

export interface ClothesItemInfos {
	/** Nº de texturas da peça atual. */
	maxTex: number;
	/** Maior índice de peça disponível no modelo. */
	maxItem: number;
	/** Chave do ícone, resolvida em `itemIcons`. */
	icon: string;
	name: string;
}

export interface ClothesItem {
	/** A peça aceita o índice -1 (nenhuma). */
	negative: boolean;
	item: number;
	texture: number;
	infos: ClothesItemInfos;
}

/** Peças de uma região do corpo, indexadas pela chave que o client usa. */
export type ClothesCategory = Record<string, ClothesItem>;

export type ClothesConfig = Record<CategoryKey, ClothesCategory>;

export const CLOTHES_CONFIG: ClothesConfig = {
	head: {
		ear: {
			negative: true,
			item: -1,
			texture: 0,
			infos: { maxTex: 25, maxItem: 27, icon: "orelha", name: "ORELHA" },
		},
		hat: {
			negative: true,
			item: -1,
			texture: 0,
			infos: { maxTex: 25, maxItem: 193, icon: "chapeu", name: "CHAPÉU" },
		},
		mask: {
			negative: false,
			item: 0,
			texture: 0,
			infos: { maxTex: 25, maxItem: 309, icon: "mascara", name: "MÁSCARA" },
		},
		glass: {
			negative: false,
			item: -1,
			texture: 0,
			infos: { maxTex: 25, maxItem: 58, icon: "oculos", name: "ÓCULOS" },
		},
		accessory: {
			negative: false,
			item: 0,
			texture: 0,
			infos: {
				maxTex: 25,
				maxItem: 191,
				icon: "acessorios",
				name: "ACESSÓRIOS",
			},
		},
	},
	chest: {
		bracelet: {
			negative: true,
			item: -1,
			texture: 0,
			infos: { maxTex: 25, maxItem: 22, icon: "bracelete", name: "BRACELETE" },
		},
		tshirt: {
			negative: false,
			item: 0,
			texture: 0,
			infos: { maxTex: 25, maxItem: 436, icon: "camisas", name: "CAMISA" },
		},
		torso: {
			negative: false,
			item: 0,
			texture: 0,
			infos: { maxTex: 25, maxItem: 743, icon: "jaqueta", name: "JAQUETA" },
		},
		decals: {
			negative: false,
			item: 0,
			texture: 0,
			infos: { maxTex: 25, maxItem: 202, icon: "adesivo", name: "ADESIVO" },
		},
		backpack: {
			negative: false,
			item: 0,
			texture: 0,
			infos: { maxTex: 25, maxItem: 142, icon: "mochila", name: "MOCHILA" },
		},
		arms: {
			negative: false,
			item: 0,
			texture: 0,
			infos: { maxTex: 25, maxItem: 295, icon: "maos", name: "MÃOS" },
		},
		vest: {
			negative: false,
			item: 0,
			texture: 0,
			infos: { maxTex: 25, maxItem: 79, icon: "coletes", name: "COLETE" },
		},
		watch: {
			negative: true,
			item: -1,
			texture: 0,
			infos: { maxTex: 25, maxItem: 35, icon: "relogio", name: "RELÓGIO" },
		},
	},
	legs: {
		shoes: {
			negative: false,
			item: 0,
			texture: 0,
			infos: { maxTex: 25, maxItem: 193, icon: "sapato", name: "SAPATO" },
		},
		pants: {
			negative: false,
			item: 0,
			texture: 0,
			infos: { maxTex: 25, maxItem: 245, icon: "calca", name: "CALÇAS" },
		},
	},
};

/** Ordem em que a trilha lateral agrupa as peças. */
export const CATEGORY_ORDER: CategoryKey[] = ["head", "chest", "legs"];

export const DEFAULT_CATEGORY: CategoryKey = "head";
export const DEFAULT_ITEM = "accessory";
