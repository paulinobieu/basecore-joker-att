import type { Screen } from "@app/constants/callbacks";
import { create } from "zustand";

export interface CharacterSlotInfo {
	title: string;
	value: string;
	icon?: string;
}

/**
 * Um slot da tela de selecao. Sem `name` o slot esta vazio:
 * `createPerson` true significa liberado, false significa bloqueado
 * (comprado com coins quando a loja estiver habilitada).
 */
export interface CharacterSlot {
	id?: string;
	name?: string;
	image?: string;
	infos?: CharacterSlotInfo[];
	createPerson?: boolean;
}

export interface SpawnLocation {
	name: string;
	text: string;
	image: string;
	hash?: string;
	x?: number;
	y?: number;
	z?: number;
}

interface ScreenStore {
	screen: Screen | null;

	/** Tela de selecao. */
	slots: CharacterSlot[];

	/** Tela de spawn. */
	locations: SpawnLocation[];

	/** Barbearia: estado para restaurar se sair sem salvar. */
	backupCharacter: Record<string, number> | null;
}

interface ScreenActions {
	setScreen: (screen: Screen | null) => void;
	setSlots: (slots: CharacterSlot[]) => void;
	setLocations: (locations: SpawnLocation[]) => void;
	setBackupCharacter: (character: Record<string, number> | null) => void;
}

export const useScreenStore = create<ScreenStore & ScreenActions>()((set) => ({
	screen: null,
	slots: [],
	locations: [],
	backupCharacter: null,

	setScreen: (screen) => set({ screen }),
	setSlots: (slots) => set({ slots }),
	setLocations: (locations) => set({ locations }),
	setBackupCharacter: (backupCharacter) => set({ backupCharacter }),
}));
