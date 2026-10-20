import { ACTIONS } from "@app/constants/callbacks";
import type { ClothesConfig } from "@app/constants/clothes";
import { useClothesStore } from "@app/stores/Clothes";
import { postNui } from "./fetchNui";

/** O client só precisa da peça e da textura para vestir o ped. */
export type PreviewPayload = Record<string, { item: number; texture: number }>;

function flatten(config: ClothesConfig): PreviewPayload {
	const preview: PreviewPayload = {};

	for (const category of Object.values(config)) {
		for (const [key, entry] of Object.entries(category)) {
			preview[key] = {
				item: Number(entry.item),
				texture: Number(entry.texture),
			};
		}
	}

	return preview;
}

// Segurar uma seta ou digitar no campo dispara uma mudança por
// keydown. Sem a janela, cada uma viraria um POST para o client — o
// preview continua imediato aos olhos e o tráfego cai para uma chamada
// por pausa.
const PREVIEW_DELAY = 50;

let timeoutId: number | undefined;

/** Envia o preview imediatamente, sem esperar a janela de debounce. */
export function flushPreview() {
	postNui(ACTIONS.updatePreview, {
		config: flatten(useClothesStore.getState().config),
	});
}

export function requestPreview() {
	clearTimeout(timeoutId);

	timeoutId = window.setTimeout(flushPreview, PREVIEW_DELAY);
}
