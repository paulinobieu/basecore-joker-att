import { fetchNui } from "@app/utils/fetchNui";
import { isEnvBrowser } from "@app/utils/misc";
import { create } from "zustand";

interface VisibilityStore {
	visible: boolean;
}

interface VisibilityActions {
	setVisible: (value: boolean) => void;
	fetchHideFrame: () => Promise<void>;
}

export const useVisibilityStore = create<VisibilityStore & VisibilityActions>()(
	(set, get) => ({
		visible: isEnvBrowser(),

		setVisible: (value) => set({ visible: value }),

		fetchHideFrame: async () => {
			if (!get().visible) return;

			set({ visible: false });
			await fetchNui({ path: "craft:close", mockData: true });
		},
	}),
);
