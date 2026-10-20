import { fetchNui } from "@app/utils/fetchNui";
import { isEnvBrowser } from "@app/utils/misc";
import { create } from "zustand";

interface VisibilityStore {
	visible: boolean;
	closing: boolean;
}

interface VisibilityActions {
	setVisible: (value: boolean) => void;
	fetchHideFrame: () => Promise<void>;
}

export const useVisibilityStore = create<VisibilityStore & VisibilityActions>()(
	(set, get) => ({
		visible: isEnvBrowser(),
		closing: false,

		setVisible: (value) => {
			if (!value) {
				set({ closing: true });
				setTimeout(() => set({ visible: false, closing: false }), 280);
				return;
			}
			set({ visible: true, closing: false });
		},

		fetchHideFrame: async () => {
			const { visible } = get();
			if (!visible) return;

			set({ closing: true });
			await fetchNui({ path: "close", payload: {}, mockData: true });
			setTimeout(() => set({ visible: false, closing: false }), 280);
		},
	}),
);
