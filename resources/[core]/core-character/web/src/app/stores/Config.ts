import {
	type Palettes,
	palettes as defaultPalettes,
} from "@app/constants/palettes";
import {
	type ColorTriad,
	type ColorVariants,
	applyServerColors,
	normalizeServerColors,
	resolveServerColors,
} from "@app/utils/colors";
import { create } from "zustand";

export interface LogoConfig {
	image: string;
	width: string;
	height: string;
	top: string;
}

export interface SetupPayload {
	/** Cores do servidor: triade, variante nomeada ou formato antigo. */
	colors?: ColorTriad | keyof typeof ColorVariants | Record<string, unknown>;
	logo?: string | Partial<LogoConfig>;
	palettes?: Partial<Palettes>;
	paths?: { face?: string };
	config?: {
		buyPerson?: boolean;
		buyPersonPrice?: number;
		eyesBarber?: boolean;
	};
}

interface ConfigStore {
	logo: LogoConfig;
	palettes: Palettes;

	/** Base das miniaturas de heranca (paterno/materno). */
	pathFace: string;

	buyPerson: boolean;
	buyPersonPrice: number;
	/** Habilita a cor dos olhos dentro da barbearia. */
	eyesBarber: boolean;

	admin: boolean;
}

interface ConfigActions {
	applySetup: (payload: SetupPayload) => void;
	setAdmin: (admin: boolean) => void;
}

const defaultLogo: LogoConfig = {
	image: "https://cdn.corenetwork.dev/IDCore/HUD_GIF.gif",
	width: "9.375rem",
	height: "9.375rem",
	top: "-1.1875rem",
};

export const useConfigStore = create<ConfigStore & ConfigActions>()((set) => ({
	logo: defaultLogo,
	palettes: defaultPalettes,
	pathFace: "https://cdn.corenetwork.dev/CoreCharacter/Faces/",

	buyPerson: false,
	buyPersonPrice: 300,
	eyesBarber: true,

	admin: false,

	applySetup: (payload) =>
		set((state) => {
			// O payload do client pode vir embrulhado numa chave que muda por
			// recurso; resolveServerColors acha a triade sem depender disso.
			const colors = resolveServerColors(payload.colors);

			if (typeof colors === "string") {
				applyServerColors(colors as keyof typeof ColorVariants);
			} else {
				const triad = normalizeServerColors(colors);

				if (triad) applyServerColors(triad);
			}

			// Aceita so a URL ou o objeto completo com dimensoes.
			const logo =
				typeof payload.logo === "string"
					? { ...state.logo, image: payload.logo }
					: { ...state.logo, ...(payload.logo ?? {}) };

			return {
				logo,
				palettes: { ...state.palettes, ...(payload.palettes ?? {}) },
				pathFace: payload.paths?.face ?? state.pathFace,
				buyPerson: payload.config?.buyPerson ?? state.buyPerson,
				buyPersonPrice: payload.config?.buyPersonPrice ?? state.buyPersonPrice,
				eyesBarber: payload.config?.eyesBarber ?? state.eyesBarber,
			};
		}),

	setAdmin: (admin) => set({ admin }),
}));
