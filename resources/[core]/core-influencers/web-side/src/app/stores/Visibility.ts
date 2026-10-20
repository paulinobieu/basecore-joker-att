import { fetchNui } from "@app/utils/fetchNui";
import { isEnvBrowser } from "@app/utils/misc";
import { create } from "zustand";

interface VisibilityStore {
	visible: boolean;
}

interface VisibilityActions {
	setVisible: (value: boolean) => void;
	close: () => Promise<void>;
}

export const useVisibilityStore = create<VisibilityStore & VisibilityActions>()(
	(set, get) => ({
		visible: isEnvBrowser(),
		setVisible: (newVisibility: boolean) => set({ visible: newVisibility }),

		close: async () => {
			const { visible } = get();

			if (!visible) return;

			set({ visible: false });

			if (!isEnvBrowser()) {
				await fetchNui({ path: "close" });
			}
		},
	}),
);
