import { fetchNuiSimple } from "@app/utils/fetchNui";
import { isEnvBrowser } from "@app/utils/misc";
import { create } from "zustand";

interface VisibilityStore {
	visible: boolean;
	canCloseUi: boolean;
}

interface VisibilityActions {
	setVisible: (value: boolean) => void;
	setCanCloseUi: (value: boolean) => void;
	fetchHideFrame: () => Promise<void>;
}

export const useVisibilityStore = create<VisibilityStore & VisibilityActions>()(
	(set, get) => ({
		visible: isEnvBrowser(),
		canCloseUi: true,
		setVisible: (newVisibility: boolean) => set({ visible: newVisibility }),
		setCanCloseUi: (newStatus: boolean) => set({ canCloseUi: newStatus }),

		fetchHideFrame: async () => {
			const { visible } = get();
			if (!visible) return;

			if (isEnvBrowser()) {
				set({ visible: false });
				return;
			}

			await fetchNuiSimple("exit");
			set({ visible: false });
		},
	}),
);
