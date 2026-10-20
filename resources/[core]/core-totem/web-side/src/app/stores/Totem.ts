import { BROWSER_TOTEM } from "@app/mocks/totem";
import type { OpenPayload, UpdatePayload } from "@app/types/totem";
import { applyThemeColor } from "@app/utils/colors";
import { isEnvBrowser } from "@app/utils/misc";
import { create } from "zustand";

interface TotemStore {
	config: OpenPayload | null;
	openTotem: (payload: OpenPayload) => void;
	updateTotem: (payload: UpdatePayload) => void;
	clearTotem: () => void;
}

if (isEnvBrowser()) {
	applyThemeColor(BROWSER_TOTEM.themeColor);
}

export const useTotemStore = create<TotemStore>((set) => ({
	config: isEnvBrowser() ? BROWSER_TOTEM : null,
	openTotem: (payload) => {
		applyThemeColor(payload.themeColor);
		set({ config: payload });
	},
	updateTotem: (payload) =>
		set((state) => ({
			config: state.config ? { ...state.config, ...payload } : null,
		})),
	clearTotem: () => set({ config: isEnvBrowser() ? BROWSER_TOTEM : null }),
}));
