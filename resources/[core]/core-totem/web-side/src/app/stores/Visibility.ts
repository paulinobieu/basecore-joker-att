import { fetchNui } from "@app/utils/fetchNui";
import { isEnvBrowser } from "@app/utils/misc";
import { create } from "zustand";

interface VisibilityStore {
	visible: boolean;
	setVisible: (value: boolean) => void;
	fetchHideFrame: () => Promise<void>;
}

export const useVisibilityStore = create<VisibilityStore>((set, get) => ({
	visible: isEnvBrowser(),
	setVisible: (visible) => set({ visible }),
	fetchHideFrame: async () => {
		if (!get().visible) return;

		if (!isEnvBrowser()) {
			await fetchNui({ path: "close", payload: {}, mockData: { ok: true } });
		}

		set({ visible: false });
	},
}));
