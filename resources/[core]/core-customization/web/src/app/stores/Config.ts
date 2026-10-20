import type { PedType } from "@app/stores/Textures";
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
	/** Cores do servidor: tríade, variante nomeada ou formato antigo. */
	colors?: ColorTriad | keyof typeof ColorVariants | Record<string, unknown>;
	logo?: string | Partial<LogoConfig>;
}

interface ConfigStore {
	logo: LogoConfig;

	/** Modelo vestido pelo jogador: define qual catálogo a grade lê. */
	pedType: PedType;
	/** Administrador sai da loja sem passar pela confirmação. */
	admin: boolean;
}

interface ConfigActions {
	applySetup: (payload: SetupPayload) => void;
	setUser: (user: { pedType?: PedType; admin?: boolean }) => void;
}

// Medidas iguais às do HUD. Não são configuráveis pelo servidor: só a
// imagem é, e ela vem no setup.
const defaultLogo: LogoConfig = {
	image: "https://cdn.corenetwork.dev/IDCore/HUD_GIF.gif",
	width: "9.375rem",
	height: "9.375rem",
	top: "-1.1875rem",
};

export const useConfigStore = create<ConfigStore & ConfigActions>()((set) => ({
	logo: defaultLogo,
	pedType: "Male",
	admin: false,

	applySetup: (payload) =>
		set((state) => {
			// O payload do client pode vir embrulhado numa chave que muda por
			// recurso; resolveServerColors acha a tríade sem depender disso.
			const colors = resolveServerColors(payload.colors);

			if (typeof colors === "string") {
				applyServerColors(colors as keyof typeof ColorVariants);
			} else {
				const triad = normalizeServerColors(colors);

				if (triad) applyServerColors(triad);
			}

			// Aceita só a URL ou o objeto completo com dimensões.
			const logo =
				typeof payload.logo === "string"
					? { ...state.logo, image: payload.logo }
					: { ...state.logo, ...(payload.logo ?? {}) };

			return { logo };
		}),

	setUser: ({ pedType, admin }) =>
		set((state) => ({
			pedType: pedType ?? state.pedType,
			admin: admin ?? state.admin,
		})),
}));
