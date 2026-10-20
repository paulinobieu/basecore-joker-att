import { fetchNui } from "@app/utils/fetchNui";
import { sleep } from "@app/utils/misc";
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
		visible: false,
		closing: false,
		setVisible: (newVisibility: boolean) =>
			set({ visible: newVisibility, closing: false }),

		fetchHideFrame: async () => {
			const { visible, closing } = get();

			if (!visible || closing) return;

			set({ closing: true });

			await sleep(250);
			await fetchNui({
				path: "core-weather",
				payload: { action: "close" },
				mockData: "ok",
			});

			set({ visible: false, closing: false });
		},
	}),
);
