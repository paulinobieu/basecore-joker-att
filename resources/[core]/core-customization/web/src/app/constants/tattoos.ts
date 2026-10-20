/**
 * Zonas de tatuagem.
 *
 * O catálogo (`available`) chega vazio: quem preenche é o client, na
 * mensagem `open`, com o que a loja daquele ponto oferece para o sexo
 * do personagem.
 */

export type ZoneKey =
	| "head"
	| "torso"
	| "leftarm"
	| "rightarm"
	| "leftleg"
	| "rightleg";

export interface Tattoo {
	/** Nome da decoração — é a chave que identifica a tatuagem ativa. */
	name: string;
	/** Coleção (overlay) a que ela pertence. */
	part: string;
	link: string;
}

export interface TattooZone {
	/** Chave do ícone, resolvida em `tattooZoneIcons`. */
	icon: string;
	title: string;
	available: Tattoo[];
}

export const TATTOO_ZONES: Record<ZoneKey, TattooZone> = {
	head: { icon: "head", title: "CABEÇA", available: [] },
	torso: { icon: "chest", title: "PEITO", available: [] },
	leftarm: { icon: "arm-left", title: "BRAÇO ESQUERDO", available: [] },
	rightarm: { icon: "arm-right", title: "BRAÇO DIREITO", available: [] },
	leftleg: { icon: "leg-left", title: "PERNA ESQUERDA", available: [] },
	rightleg: { icon: "leg-right", title: "PERNA DIREITA", available: [] },
};

export const DEFAULT_ZONE: ZoneKey = "rightarm";
