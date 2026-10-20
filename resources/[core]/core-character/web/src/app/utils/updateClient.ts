import { ACTIONS } from "@app/constants/callbacks";
import {
	FACE_MAPPING,
	HEAD_MAPPING,
	SKIN_MAPPING,
} from "@app/constants/mappings";
import type { OptionPath } from "@app/constants/options";
import { getOption, useCharacterStore } from "@app/stores/Character";
import { postNui } from "./fetchNui";

export type PreviewGroup = "face" | "skin" | "head";

const ALL_GROUPS: PreviewGroup[] = ["face", "skin", "head"];

const MAPPING_BY_GROUP = {
	face: FACE_MAPPING,
	skin: SKIN_MAPPING,
	head: HEAD_MAPPING,
};

const ACTION_BY_GROUP = {
	face: ACTIONS.updateFace,
	skin: ACTIONS.updateSkin,
	head: ACTIONS.updateHead,
};

/** Indice reverso: caminho da opcao -> grupo de preview que a cobre. */
const GROUP_BY_PATH = new Map<string, PreviewGroup>();

for (const group of ALL_GROUPS) {
	for (const path of Object.values(MAPPING_BY_GROUP[group])) {
		GROUP_BY_PATH.set(path.join("."), group);
	}
}

function collect(group: PreviewGroup) {
	const { options } = useCharacterStore.getState();
	const config: Record<string, number> = {};

	for (const [key, path] of Object.entries(MAPPING_BY_GROUP[group])) {
		config[key] = Number(getOption(options, path).value);
	}

	return config;
}

/** Envia o preview imediatamente, sem esperar a janela de debounce. */
export function flushPreview(groups: PreviewGroup[] = ALL_GROUPS) {
	for (const group of groups) {
		postNui(ACTION_BY_GROUP[group], { config: collect(group) });
	}
}

// Arrastar um slider dispara uma mudanca por frame. Sem a janela, cada
// uma viraria um POST para o client — o preview continua imediato aos
// olhos e o trafego cai para uma chamada por pausa do mouse.
const PREVIEW_DELAY = 50;

const pending = new Set<PreviewGroup>();
let timeoutId: number | undefined;

export function requestPreview(groups: PreviewGroup[] = ALL_GROUPS) {
	for (const group of groups) pending.add(group);

	clearTimeout(timeoutId);

	timeoutId = window.setTimeout(() => {
		flushPreview([...pending]);
		pending.clear();
	}, PREVIEW_DELAY);
}

/** Atualiza so o grupo que cobre a opcao alterada. */
export function previewOption(path: OptionPath) {
	const group = GROUP_BY_PATH.get(path.join("."));

	requestPreview(group ? [group] : ALL_GROUPS);
}
