import {
	DEFAULT_ZONE,
	TATTOO_ZONES,
	type Tattoo,
	type TattooZone,
	type ZoneKey,
} from "@app/constants/tattoos";
import { create } from "zustand";

interface TattoosStore {
	zones: Record<ZoneKey, TattooZone>;
	activeZone: ZoneKey;
	/** Nomes das decorações que o personagem está usando. */
	active: string[];
}

interface TattoosActions {
	/** Aplica o catálogo e as tatuagens em uso que o client mandou. */
	applyCatalog: (
		available: Partial<Record<ZoneKey, Tattoo[]>>,
		active: string[],
	) => void;
	setActiveZone: (zone: ZoneKey) => void;
	toggle: (name: string) => void;
}

export const useTattoosStore = create<TattoosStore & TattoosActions>()(
	(set) => ({
		zones: TATTOO_ZONES,
		activeZone: DEFAULT_ZONE,
		active: [],

		applyCatalog: (available, active) =>
			set((state) => {
				const zones = {} as Record<ZoneKey, TattooZone>;

				// Zona sem tatuagem no payload fica com a lista vazia em vez de
				// sumir: a trilha lateral desenha as seis o tempo todo.
				for (const key of Object.keys(state.zones) as ZoneKey[]) {
					zones[key] = { ...state.zones[key], available: available[key] ?? [] };
				}

				return { zones, active };
			}),

		setActiveZone: (activeZone) => set({ activeZone }),

		toggle: (name) =>
			set((state) => ({
				active: state.active.includes(name)
					? state.active.filter((current) => current !== name)
					: [...state.active, name],
			})),
	}),
);
